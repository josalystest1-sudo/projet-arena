## La carte du monde (docs/GDD_V2.md, § 9.2 ; docs/PLAN.md, phase 7) : une seule carte, celle où l'on choisit son donjon
## et celle des territoires. Trois régions par tranche de niveau, chacune de territoires reliés entre eux (data/carte.json),
## qui apparaissent avec la population (un territoire existe dès que le serveur compte `des` guildes). Chaque territoire a
## un type (Mine, Sanctuaire, Marché, Relais, Bastion) qui vaut quelque chose à la guilde qui le tient. Le donjon d'une
## région apparaît chaque semaine sur l'un de ses territoires (tiré avec la semaine) ; la guilde qui tient ce territoire
## touche une part de l'entrée. Qui tient quoi vit sur le serveur (scenes/net/serveur.gd : un état {territoire ->
## {guilde, nom, banniere, depuis}}, remis à zéro à chaque saison) ; les guerres qui le changent viennent après (§ 9.3).
## Module pur : le hasard vient de la semaine et de la graine du monde simulé.
class_name Carte
extends RefCounted

const CLES_TENUE := ["guilde", "nom", "banniere", "depuis"]


# --- Les régions et les territoires ----------------------------------------------------------------

## Les régions, dans l'ordre des données.
static func regions(d: Donnees) -> Array:
	return d.carte["regions"]


static func region(id: String, d: Donnees) -> Dictionary:
	for r in d.carte["regions"]:
		if str(r["id"]) == id:
			return r
	return {}


## La région d'un territoire (vide s'il n'existe pas).
static func region_de(territoire_id: String, d: Donnees) -> Dictionary:
	for r in d.carte["regions"]:
		for t in r["territoires"]:
			if str(t["id"]) == territoire_id:
				return r
	return {}


## Un territoire (vide s'il n'existe pas), avec sa région (`region`).
static func territoire(id: String, d: Donnees) -> Dictionary:
	for r in d.carte["regions"]:
		for t in r["territoires"]:
			if str(t["id"]) == id:
				var out: Dictionary = t.duplicate()
				out["region"] = str(r["id"])
				return out
	return {}


## Tous les territoires, avec leur région.
static func territoires(d: Donnees) -> Array:
	var out: Array = []
	for r in d.carte["regions"]:
		for t in r["territoires"]:
			var copie: Dictionary = t.duplicate()
			copie["region"] = str(r["id"])
			out.append(copie)
	return out


## Un territoire existe-t-il pour cette population (le nombre de guildes du serveur) ? La carte grandit et rétrécit
## avec elle (GDD § 9.4).
static func ouvert(t: Dictionary, nb_guildes: int) -> bool:
	return nb_guildes >= int(t.get("des", 0))


## Les territoires ouverts pour cette population.
static func territoires_ouverts(nb_guildes: int, d: Donnees) -> Array:
	return territoires(d).filter(func(t): return ouvert(t, nb_guildes))


## Les voisins d'un territoire (les liens vont dans les deux sens, y compris entre régions).
static func voisins(id: String, d: Donnees) -> Array[String]:
	var out: Array[String] = []
	for r in d.carte["regions"]:
		for lien in r["liens"]:
			if str(lien[0]) == id and not out.has(str(lien[1])):
				out.append(str(lien[1]))
			elif str(lien[1]) == id and not out.has(str(lien[0])):
				out.append(str(lien[0]))
	return out


## Le type d'un territoire, en clair : « Mine : 20 Influence par jour pour la guilde qui la tient ».
static func texte_type(type: String, d: Donnees) -> String:
	if not d.carte["types"].has(type):
		return type
	var t: Dictionary = d.carte["types"][type]
	return "%s : %s" % [t["nom"], str(t["texte"]).replace("{v}", str(int(t["valeur"])))]


static func nom_type(type: String, d: Donnees) -> String:
	return str(d.carte["types"].get(type, {}).get("nom", type))


# --- Les donjons de la semaine ------------------------------------------------------------------------

## Où le donjon de chaque région apparaît cette semaine : {territoire -> donjon}, tiré avec la semaine parmi les
## territoires ouverts de la région (la même carte pour tout le monde).
static func donjons_de_la_semaine(semaine: int, nb_guildes: int, d: Donnees) -> Dictionary:
	var out := {}
	for r in d.carte["regions"]:
		var ouverts: Array = r["territoires"].filter(func(t): return ouvert(t, nb_guildes))
		if ouverts.is_empty() or str(r.get("donjon", "")) == "":
			continue
		var rng := RandomNumberGenerator.new()
		rng.seed = semaine * 104729 + str(r["id"]).hash()
		out[str(ouverts[rng.randi_range(0, ouverts.size() - 1)]["id"])] = str(r["donjon"])
	return out


## Le territoire où se trouve un donjon cette semaine ("" s'il n'apparaît pas).
static func territoire_du_donjon(donjon_id: String, semaine: int, nb_guildes: int, d: Donnees) -> String:
	var ou := donjons_de_la_semaine(semaine, nb_guildes, d)
	for t in ou:
		if str(ou[t]) == donjon_id:
			return str(t)
	return ""


## La part de l'entrée d'un donjon qui va à la guilde qui tient son territoire (en Influence).
static func part_entree(entree: int, d: Donnees) -> int:
	return int(ceil(float(entree) * float(d.carte["donjon"]["part_entree"])))


# --- Qui tient quoi -----------------------------------------------------------------------------------

## Un état de la carte est-il bien formé ?
static func etat_valide(etat: Dictionary, d: Donnees) -> bool:
	for id in etat:
		if territoire(str(id), d).is_empty() or not etat[id] is Dictionary:
			return false
		for cle in CLES_TENUE:
			if not etat[id].has(cle):
				return false
	return true


## Les territoires tenus par une guilde.
static func tenus_par(etat: Dictionary, guilde_id: String) -> Array[String]:
	var out: Array[String] = []
	for id in etat:
		if str(etat[id].get("guilde", "")) == guilde_id:
			out.append(str(id))
	return out


## Ce que rapportent chaque jour les territoires tenus par une guilde : {influence (Mines), xp (Sanctuaires, par membre),
## remise (Marchés, en fraction sur la reforge), relais, bastions (le nombre)}, avec les donjons qui s'y trouvent.
static func revenus(tenus: Array, donjons: Dictionary, d: Donnees) -> Dictionary:
	var out := {"influence": 0, "xp": 0, "remise": 0.0, "relais": 0, "bastions": 0, "donjons": 0}
	for id in tenus:
		var t := territoire(str(id), d)
		if t.is_empty():
			continue
		var v := int(d.carte["types"].get(str(t["type"]), {}).get("valeur", 0))
		match str(t["type"]):
			"mine":
				out["influence"] += v
			"sanctuaire":
				out["xp"] += v
			"marche":
				out["remise"] += float(v) / 100.0
			"relais":
				out["relais"] += v
			"bastion":
				out["bastions"] += 1
		if donjons.has(str(id)):
			out["donjons"] += 1
	out["remise"] = minf(0.5, float(out["remise"]))
	return out


## Une guilde peut-elle viser ce territoire : voisin d'un des siens ; sans territoire, n'importe quel territoire neutre
## (GDD § 9.2 et 9.3 ; les guerres viennent après, la règle est posée ici).
static func peut_viser(etat: Dictionary, guilde_id: String, territoire_id: String, d: Donnees) -> bool:
	if territoire(territoire_id, d).is_empty() or str(etat.get(territoire_id, {}).get("guilde", "")) == guilde_id:
		return false
	var miens := tenus_par(etat, guilde_id)
	if miens.is_empty():
		return not etat.has(territoire_id)
	for v in voisins(territoire_id, d):
		if miens.has(v):
			return true
	return false


# --- Le monde simulé ----------------------------------------------------------------------------------

## Qui tient quoi dans le monde simulé, pour une saison : chaque guilde simulée (un résumé : id, nom, banniere) tient
## de un à trois territoires ouverts, voisins entre eux quand c'est possible, tirés avec la graine et la saison.
static func monde_simule(guildes: Array, saison: int, nb_guildes: int, d: Donnees) -> Dictionary:
	var etat := {}
	var rng := RandomNumberGenerator.new()
	rng.seed = int(d.carte["simule"]["graine"]) * 31 + saison
	var bornes: Array = d.carte["simule"]["territoires_par_guilde"]
	var libres: Array = territoires_ouverts(nb_guildes, d).map(func(t): return str(t["id"]))
	for g in guildes:
		var n := rng.randi_range(int(bornes[0]), int(bornes[1]))
		var pris: Array[String] = []
		for _k in range(n):
			if libres.is_empty():
				break
			var choix := ""
			if not pris.is_empty():
				for v in voisins(pris[pris.size() - 1], d):
					if libres.has(v):
						choix = v
						break
			if choix == "":
				choix = str(libres[rng.randi_range(0, libres.size() - 1)])
			libres.erase(choix)
			pris.append(choix)
			etat[choix] = {"guilde": str(g["id"]), "nom": str(g["nom"]), "banniere": g["banniere"], "depuis": "saison %d" % saison}
	return etat
