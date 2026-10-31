## Les guerres de guilde (docs/GDD_V2.md, § 9.3 et 9.4 ; docs/PLAN.md, phase 7) : chaque soir, une guilde déclare des
## attaques (1 + sa taille ÷ 20) sur des territoires voisins des siens (neutres ou tenus ; sans territoire, un neutre) ;
## une bataille se joue en asynchrone : chaque membre a trois combats de guerre par soir, contre les trios des défenseurs
## (les personnages de la guilde qui tient le territoire, pilotés par l'IA ; un territoire neutre est gardé par des
## trios générés) ; la défense est automatique. Le score d'un camp est la somme de ses victoires, chacune pesée par la
## force de l'adversaire battu. Un territoire neutre va au meilleur score ; un territoire tenu tombe si l'attaquant
## dépasse le défenseur × 1,2 (× 1,5 avec un Bastion voisin du défenseur). Un territoire pris est protégé deux jours ;
## un territoire sans combat de guerre pendant sept jours redevient neutre ; une guilde de moins de dix membres n'attaque
## pas un territoire tenu. Les chiffres : data/guerre.json. Une bataille est un dictionnaire {id, jour, territoire,
## attaquant, defenseur, ordre, combats, resolue, resultat} qui vit sur le serveur (scenes/net/serveur.gd) ; ce module
## dit les règles. Module pur : les combats simulés sont joués par l'IA avec des graines.
class_name Guerre
extends RefCounted

const CLES_BATAILLE := ["id", "jour", "territoire", "attaquant", "defenseur", "ordre", "combats", "resolue", "resultat"]


# --- Déclarer ------------------------------------------------------------------------------------

## Le nombre d'attaques qu'une guilde de cette taille peut déclarer par soir.
static func attaques_max(taille: int, d: Donnees) -> int:
	return int(d.guerre["attaques_base"]) + maxi(0, taille) / int(d.guerre["membres_par_attaque"])


## Une bataille neuve : la guilde attaquante (un résumé : id, nom, banniere) vise un territoire, tenu par le défenseur
## (un résumé, vide s'il est neutre) ; `ordre` : le rang de la déclaration ce soir-là.
static func nouvelle_bataille(id: String, jour: String, territoire: String, attaquant: Dictionary, defenseur: Dictionary, ordre: int) -> Dictionary:
	return {"id": id, "jour": jour, "territoire": territoire, "attaquant": _resume(attaquant), "defenseur": _resume(defenseur), "ordre": ordre,
		"combats": [], "resolue": false, "resultat": ""}


static func _resume(g: Dictionary) -> Dictionary:
	if g.is_empty():
		return {}
	var membres := 0
	if g.get("membres") is Array:
		membres = g["membres"].size()
	elif g.has("membres"):
		membres = int(g["membres"])
	return {"id": str(g["id"]), "nom": str(g.get("nom", "")), "banniere": g.get("banniere", {}), "membres": membres}


static func bataille_valide(b: Dictionary) -> bool:
	for cle in CLES_BATAILLE:
		if not b.has(cle):
			return false
	return b["combats"] is Array and b["attaquant"] is Dictionary and b["defenseur"] is Dictionary


## Pourquoi une guilde ne peut pas déclarer cette attaque ce soir ("" si elle le peut) : la carte (un voisin d'un des
## siens ; sans territoire, un neutre), la protection, la taille (dix membres pour un territoire tenu), les attaques du
## soir (une par territoire, attaques_max en tout).
static func empeche(etat_carte: Dictionary, protections: Dictionary, guilde: Dictionary, territoire: String, jour: String, batailles_du_jour: Array, d: Donnees) -> String:
	if guilde.is_empty():
		return "il faut une guilde"
	var gid := str(guilde["id"])
	if not Carte.peut_viser(etat_carte, gid, territoire, d):
		return "on ne vise qu'un territoire voisin d'un des siens (sans territoire : un territoire neutre)"
	if str(protections.get(territoire, "")) >= jour and str(protections.get(territoire, "")) != "":
		return "ce territoire est protégé jusqu'au %s" % protections[territoire]
	var tenu := etat_carte.has(territoire)
	var taille: int = guilde.get("membres", []).size() if guilde.get("membres") is Array else int(guilde.get("membres", 0))
	if tenu and taille < int(d.guerre["membres_min_pour_attaquer_tenu"]):
		return "il faut %d membres pour attaquer un territoire tenu (la guilde en a %d)" % [int(d.guerre["membres_min_pour_attaquer_tenu"]), taille]
	var miennes := 0
	for b in batailles_du_jour:
		if str(b["attaquant"].get("id", "")) == gid:
			if str(b["territoire"]) == territoire:
				return "la guilde attaque déjà ce territoire ce soir"
			miennes += 1
	if miennes >= attaques_max(taille, d):
		return "la guilde a déclaré toutes ses attaques du soir (%d)" % attaques_max(taille, d)
	return ""


# --- Les combats et le score ---------------------------------------------------------------------

## Le poids d'une victoire : 1 + le niveau de l'adversaire battu ÷ poids_niveau.
static func poids(niveau_adverse: int, d: Donnees) -> float:
	return 1.0 + float(maxi(1, niveau_adverse)) / float(d.guerre["poids_niveau"])


## Les combats déjà faits par un personnage dans une bataille, dans un camp.
static func combats_de(b: Dictionary, compte: String, camp: String) -> int:
	var n := 0
	for c in b["combats"]:
		if str(c["compte"]) == compte and str(c["camp"]) == camp:
			n += 1
	return n


## Ce qu'il reste de combats à un attaquant (ou un défenseur qui joue) dans une bataille ce soir.
static func reste(b: Dictionary, compte: String, camp: String, d: Donnees) -> int:
	return maxi(0, int(d.guerre["combats_par_membre"]) - combats_de(b, compte, camp))


## Un combat de guerre enregistré : le personnage, son camp (« attaquant » ou « defenseur »), gagné ou non, le niveau
## de l'adversaire (son poids), l'adversaire (son identifiant, pour compter ses défenses).
static func enregistrer(b: Dictionary, compte: String, camp: String, gagne: bool, niveau_adverse: int, adversaire: String, d: Donnees) -> Dictionary:
	var out := b.duplicate(true)
	out["combats"].append({"compte": compte, "camp": camp, "gagne": gagne, "poids": poids(niveau_adverse, d), "adversaire": adversaire})
	return out


## Le score d'un camp : la somme des poids de ses victoires.
static func score(b: Dictionary, camp: String) -> float:
	var s := 0.0
	for c in b["combats"]:
		if str(c["camp"]) == camp and bool(c["gagne"]):
			s += float(c["poids"])
	return s


## Combien de fois un personnage a servi d'adversaire (défendu) dans une bataille.
static func defenses_de(b: Dictionary, compte: String) -> int:
	var n := 0
	for c in b["combats"]:
		if str(c.get("adversaire", "")) == compte and str(c["camp"]) == "attaquant":
			n += 1
	return n


## Le défenseur qui va se battre : parmi les membres défenseurs (des fiches), un qui n'a pas encore défendu trois fois,
## tiré avec la graine ; vide s'il n'y a personne (un territoire neutre) ou si tous sont épuisés (alors n'importe lequel).
static func defenseur(b: Dictionary, membres: Array, graine: int, d: Donnees) -> Dictionary:
	if membres.is_empty():
		return {}
	var libres: Array = membres.filter(func(m): return defenses_de(b, str(m["id"])) < int(d.guerre["defenses_max_par_perso"]))
	if libres.is_empty():
		libres = membres
	var rng := RandomNumberGenerator.new()
	rng.seed = graine ^ 0x6E5E
	return libres[rng.randi_range(0, libres.size() - 1)]


# --- Le résultat --------------------------------------------------------------------------------

## Le coefficient de défense d'un territoire tenu : 1,2 ; 1,5 si son tenant tient aussi un Bastion voisin.
static func coefficient_defense(etat_carte: Dictionary, territoire: String, d: Donnees) -> float:
	var tenant := str(etat_carte.get(territoire, {}).get("guilde", ""))
	if tenant == "":
		return 1.0
	for v in Carte.voisins(territoire, d):
		if str(etat_carte.get(v, {}).get("guilde", "")) == tenant and str(Carte.territoire(v, d).get("type", "")) == "bastion":
			return float(d.guerre["defense_bastion"])
	return float(d.guerre["defense"])


## Le résultat d'une bataille : « attaquant » (le territoire est pris), « defenseur » (il reste au tenant), « neutre »
## (un territoire neutre que personne ne prend : aucune victoire).
static func resultat(b: Dictionary, etat_carte: Dictionary, d: Donnees) -> String:
	var att := score(b, "attaquant")
	var def := score(b, "defenseur")
	if b["defenseur"].is_empty():
		return "attaquant" if att > 0.0 and att >= def else "neutre"
	return "attaquant" if att > def * coefficient_defense(etat_carte, str(b["territoire"]), d) else "defenseur"


## La carte après une bataille résolue : le territoire pris change de main et devient protégé jusqu'à `jour` +
## protection_jours. Rend {etat, protections}.
static func appliquer(etat_carte: Dictionary, protections: Dictionary, b: Dictionary, p_resultat: String, jour: String, d: Donnees) -> Dictionary:
	var etat := etat_carte.duplicate(true)
	var prot := protections.duplicate()
	if p_resultat == "attaquant":
		var a: Dictionary = b["attaquant"]
		etat[str(b["territoire"])] = {"guilde": str(a["id"]), "nom": str(a.get("nom", "")), "banniere": a.get("banniere", {}), "depuis": jour}
		prot[str(b["territoire"])] = jour_plus(jour, int(d.guerre["protection_jours"]))
	return {"etat": etat, "protections": prot}


## Les territoires sans aucun combat de guerre depuis neutre_apres_jours (data/carte.json) redeviennent neutres ;
## `derniers` : territoire -> le dernier jour où on s'y est battu (ou le jour de la prise). Rend la carte.
static func neutraliser(etat_carte: Dictionary, derniers: Dictionary, jour: String, d: Donnees) -> Dictionary:
	var etat := etat_carte.duplicate(true)
	var limite := int(d.carte["neutre_apres_jours"])
	for t in etat_carte:
		var dernier := str(derniers.get(t, etat_carte[t].get("depuis", "")))
		if not dernier.begins_with("20"):
			continue
		if Arene.jours(jour) - Arene.jours(dernier) >= limite:
			etat.erase(t)
	return etat


## Un jour plus n jours (« AAAA-MM-JJ »).
static func jour_plus(jour: String, n: int) -> String:
	return Time.get_datetime_string_from_unix_time(Arene.jours(jour) * 86400 + n * 86400).substr(0, 10)


# --- Les combats simulés et les attaques du monde ----------------------------------------------------

## Un combat de guerre joué par l'IA des deux côtés : le trio de l'attaquant (sa fiche) contre celui du défenseur, au
## niveau de l'attaquant. Vrai si l'attaquant gagne.
static func combat_ia(attaquant: Dictionary, defenseur: Dictionary, graine: int, d: Donnees) -> bool:
	var a := Serveur.destin_de(attaquant, d)
	a.echo = false
	var b := Serveur.destin_de(defenseur, d)
	b.echo = false
	var niveau := int(attaquant["niveau"])
	var e := Regles.nouveau_combat(Trio.camp(a, niveau, d), Trio.camp(b, int(defenseur["niveau"]), d), niveau, "pvp", d)
	var tours := 0
	while not e.fini and tours < 100:
		e = Regles.resoudre_tour(e, IA.declarer(e))
		tours += 1
	return e.fini and e.vainqueur == "a"


## Les attaques que les guildes du monde simulé déclarent un soir : attaques_par_jour guildes tirées avec le jour, chacune
## sur un territoire qu'elle peut viser (neutre de préférence). Rend [{attaquant (résumé), territoire}].
static func attaques_simulees(guildes: Array, etat_carte: Dictionary, protections: Dictionary, jour: String, d: Donnees) -> Array:
	var out: Array = []
	if guildes.is_empty():
		return out
	var rng := RandomNumberGenerator.new()
	rng.seed = (jour + "guerre").hash() ^ int(d.guerre["simule"]["graine"])
	var ids: Array = Carte.territoires_ouverts(guildes.size() + 1, d).map(func(t): return str(t["id"]))
	for _k in range(int(d.guerre["simule"]["attaques_par_jour"])):
		# Une guilde tirée ; si elle n'a rien à viser, la suivante.
		var depart := rng.randi_range(0, guildes.size() - 1)
		for essai in range(guildes.size()):
			var g: Dictionary = guildes[(depart + essai) % guildes.size()]
			var cibles: Array = []
			for t in ids:
				if empeche(etat_carte, protections, g, str(t), jour, out.map(func(x): return {"attaquant": x["attaquant"], "territoire": x["territoire"]}), d) == "":
					cibles.append(t)
			if cibles.is_empty():
				continue
			var neutres: Array = cibles.filter(func(t): return not etat_carte.has(t))
			var parmi: Array = neutres if not neutres.is_empty() else cibles
			out.append({"attaquant": _resume(g), "territoire": str(parmi[rng.randi_range(0, parmi.size() - 1)])})
			break
	return out
