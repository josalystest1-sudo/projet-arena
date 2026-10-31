## Les guildes (docs/GDD_V2.md, § 9.1 ; docs/PLAN.md, phase 6) : un nom, une bannière composée avec les modèles du jeu
## (un motif, deux couleurs), des rôles (un chef, des officiers, des membres), une taille qui grossit avec le niveau de la
## guilde (100 au plus), et une ressource, l'Influence, gagnée par l'activité des membres (duels, étages, Gardiens, boss,
## sélections comme Écho ; plus tard les territoires) et dépensée pour monter des effets (XP des membres, butin en plus
## à la Tour, reforge moins chère) ; jamais de puissance en PvP. Les chiffres : data/guildes.json. Une guilde est un
## dictionnaire {id, nom, banniere, influence, influence_totale, effets, membres, cree} qui vit sur le serveur
## (scenes/net/serveur.gd) ; ce module dit les règles et ne garde rien. Module pur : le hasard du monde simulé vient
## d'une graine.
class_name Guilde
extends RefCounted

const ROLES := ["chef", "officier", "membre"]
const CLES_GUILDE := ["id", "nom", "banniere", "influence", "influence_totale", "effets", "membres", "cree"]
const CLES_MEMBRE := ["id", "pseudo", "classe", "niveau", "role", "depuis"]
const CLES_BANNIERE := ["motif", "fond", "couleur"]
## Ce que chaque rôle peut faire : exclure un membre, acheter un effet, nommer ou retirer un officier, transmettre la
## guilde, la dissoudre. Un officier n'exclut qu'un membre (jamais un officier ni le chef).
const POUVOIRS := {"chef": ["exclure", "acheter", "promouvoir", "retrograder", "transmettre", "dissoudre"],
	"officier": ["exclure", "acheter"], "membre": []}


# --- Le nom et la bannière ------------------------------------------------------------------------

## Un nom acceptable : de 3 à 20 caractères visibles (data/guildes.json).
static func nom_valide(nom: String, d: Donnees) -> bool:
	var n := nom.strip_edges().length()
	return n >= int(d.guildes["nom"]["min"]) and n <= int(d.guildes["nom"]["max"])


## Une bannière : un motif et deux couleurs (le fond, la couleur du motif), différentes, parmi les modèles du jeu.
static func banniere_valide(b: Dictionary, d: Donnees) -> bool:
	for cle in CLES_BANNIERE:
		if not b.has(cle):
			return false
	var modeles: Dictionary = d.guildes["banniere"]
	return modeles["motifs"].has(str(b["motif"])) and modeles["couleurs"].has(str(b["fond"])) and modeles["couleurs"].has(str(b["couleur"])) and str(b["fond"]) != str(b["couleur"])


## Une bannière tirée avec une graine.
static func banniere_defaut(graine: int, d: Donnees) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = graine ^ 0x6A11DE
	var motifs: Array = d.guildes["banniere"]["motifs"].keys()
	var couleurs: Array = d.guildes["banniere"]["couleurs"].keys()
	var fond: String = couleurs[rng.randi_range(0, couleurs.size() - 1)]
	var couleur: String = couleurs[(couleurs.find(fond) + 1 + rng.randi_range(0, couleurs.size() - 2)) % couleurs.size()]
	return {"motif": str(motifs[rng.randi_range(0, motifs.size() - 1)]), "fond": fond, "couleur": couleur}


## La couleur (Godot) d'une couleur de bannière.
static func couleur(id: String, d: Donnees) -> Color:
	return Color(str(d.guildes["banniere"]["couleurs"].get(id, "888888")))


# --- Le niveau, la taille, l'Influence ------------------------------------------------------------

## Le niveau d'une guilde : le dernier palier d'Influence totale atteint (data/guildes.json, niveaux ; le premier vaut
## le niveau 1).
static func niveau(influence_totale: int, d: Donnees) -> int:
	var n := 1
	var paliers: Array = d.guildes["niveaux"]
	for i in range(paliers.size()):
		if influence_totale >= int(paliers[i]):
			n = i + 1
	return n


## L'Influence qui manque pour le niveau suivant (0 au dernier).
static func manque_niveau(influence_totale: int, d: Donnees) -> int:
	var n := niveau(influence_totale, d)
	var paliers: Array = d.guildes["niveaux"]
	if n >= paliers.size():
		return 0
	return int(paliers[n]) - influence_totale


## Les places d'une guilde de ce niveau : base + par_niveau par niveau au-delà du premier, max au plus.
static func taille_max(p_niveau: int, d: Donnees) -> int:
	var t: Dictionary = d.guildes["taille"]
	return mini(int(t["max"]), int(t["base"]) + int(t["par_niveau"]) * maxi(0, p_niveau - 1))


## L'Influence que vaut une activité d'un membre (« duel », « duel_gagne », « etage », « gardien », « boss »,
## « selection »), n fois ; 0 pour une activité inconnue.
static func influence_de(activite: String, n: int, d: Donnees) -> int:
	return int(d.guildes["influence"].get(activite, 0)) * maxi(0, n)


## Le coût du prochain niveau d'un effet : coût × (1 + pente × niveau déjà atteint) ; 0 si l'effet est au maximum.
static func cout_effet(effet: String, niveau_effet: int, d: Donnees) -> int:
	var e: Dictionary = d.guildes["effets"][effet]
	if niveau_effet >= int(e["max"]):
		return 0
	return roundi(float(e["cout"]) * (1.0 + float(e["pente"]) * float(niveau_effet)))


## Le bonus d'un effet dans une guilde (valeur × niveau de l'effet), en fraction ; 0 sans guilde.
static func bonus(guilde: Dictionary, effet: String, d: Donnees) -> float:
	if guilde.is_empty() or not d.guildes["effets"].has(effet):
		return 0.0
	return float(d.guildes["effets"][effet]["valeur"]) * float(int(guilde.get("effets", {}).get(effet, 0)))


## « Savoir de guilde II : +10 % d'XP pour chaque membre ».
static func texte_effet(effet: String, niveau_effet: int, d: Donnees) -> String:
	var e: Dictionary = d.guildes["effets"][effet]
	var v := float(e["valeur"]) * float(maxi(1, niveau_effet)) * 100.0
	var chiffre := ("%.1f" % v).replace(".0", "").replace(".", ",")
	var rang: String = ["", " I", " II", " III", " IV", " V"][clampi(niveau_effet, 0, 5)]
	return "%s%s : %s" % [e["nom"], rang, str(e["texte"]).replace("{v}", chiffre)]


# --- Une guilde et ses membres --------------------------------------------------------------------

## Une guilde neuve, fondée par ce personnage (sa fiche : id, pseudo, classe, niveau), qui en est le chef.
static func nouvelle(id: String, nom: String, banniere: Dictionary, chef: Dictionary, jour: String, d: Donnees) -> Dictionary:
	var effets := {}
	for e in d.guildes["effets"]:
		effets[str(e)] = 0
	return {"id": id, "nom": nom.strip_edges(), "banniere": banniere.duplicate(), "influence": 0, "influence_totale": 0, "effets": effets,
		"membres": [_membre(chef, "chef", jour)], "cree": jour}


static func _membre(fiche: Dictionary, role: String, jour: String) -> Dictionary:
	return {"id": str(fiche["id"]), "pseudo": str(fiche.get("pseudo", "")), "classe": str(fiche.get("classe", "")), "niveau": int(fiche.get("niveau", 1)),
		"role": role, "depuis": jour}


static func guilde_valide(g: Dictionary, d: Donnees) -> bool:
	for cle in CLES_GUILDE:
		if not g.has(cle):
			return false
	if not nom_valide(str(g["nom"]), d) or not g["banniere"] is Dictionary or not banniere_valide(g["banniere"], d) or not g["membres"] is Array:
		return false
	var chefs := 0
	for m in g["membres"]:
		if not m is Dictionary:
			return false
		for cle in CLES_MEMBRE:
			if not m.has(cle):
				return false
		if not str(m["role"]) in ROLES:
			return false
		if str(m["role"]) == "chef":
			chefs += 1
	return chefs == 1 and not g["membres"].is_empty()


## Le membre d'une guilde (vide s'il n'en est pas).
static func membre(g: Dictionary, id: String) -> Dictionary:
	for m in g.get("membres", []):
		if str(m["id"]) == id:
			return m
	return {}


## Le rôle d'un personnage dans une guilde ("" s'il n'en est pas).
static func role_de(g: Dictionary, id: String) -> String:
	return str(membre(g, id).get("role", ""))


## Ce rôle a-t-il ce pouvoir ?
static func peut(role: String, pouvoir: String) -> bool:
	return pouvoir in POUVOIRS.get(role, [])


## Le chef de la guilde.
static func chef(g: Dictionary) -> Dictionary:
	for m in g.get("membres", []):
		if str(m["role"]) == "chef":
			return m
	return {}


## Reste-t-il une place ?
static func peut_rejoindre(g: Dictionary, d: Donnees) -> bool:
	return g.get("membres", []).size() < taille_max(niveau(int(g.get("influence_totale", 0)), d), d)


## Un membre de plus (la guilde rendue, la même si c'est impossible : plus de place, ou déjà membre).
static func ajouter(g: Dictionary, fiche: Dictionary, jour: String, d: Donnees) -> Dictionary:
	if not peut_rejoindre(g, d) or not membre(g, str(fiche["id"])).is_empty():
		return g
	var out := g.duplicate(true)
	out["membres"].append(_membre(fiche, "membre", jour))
	return out


## Un membre de moins : s'il était le chef, la guilde passe au plus ancien officier, sinon au plus ancien membre ; s'il
## était seul, la guilde est dissoute (vide).
static func retirer(g: Dictionary, id: String) -> Dictionary:
	var m := membre(g, id)
	if m.is_empty():
		return g
	var out := g.duplicate(true)
	for i in range(out["membres"].size()):
		if str(out["membres"][i]["id"]) == id:
			out["membres"].remove_at(i)
			break
	if out["membres"].is_empty():
		return {}
	if str(m["role"]) == "chef":
		var suivant := _plus_ancien(out["membres"], "officier")
		if suivant.is_empty():
			suivant = _plus_ancien(out["membres"], "membre")
		suivant["role"] = "chef"
	return out


static func _plus_ancien(membres: Array, role: String) -> Dictionary:
	var choix := {}
	for m in membres:
		if str(m["role"]) == role and (choix.is_empty() or str(m["depuis"]) < str(choix["depuis"])):
			choix = m
	return choix


## Un changement de rôle décidé par `par` : nommer un officier (officiers_max au plus), le remettre membre, ou lui
## transmettre la guilde (l'ancien chef devient officier). La guilde rendue, la même si c'est impossible.
static func changer_role(g: Dictionary, par: String, id: String, role: String, d: Donnees) -> Dictionary:
	var acteur := role_de(g, par)
	var cible := role_de(g, id)
	if cible == "" or id == par or not role in ROLES:
		return g
	var pouvoir := "transmettre" if role == "chef" else ("promouvoir" if role == "officier" else "retrograder")
	if not peut(acteur, pouvoir) or cible == "chef":
		return g
	if role == "officier" and _compte(g, "officier") >= int(d.guildes["officiers_max"]):
		return g
	var out := g.duplicate(true)
	for m in out["membres"]:
		if str(m["id"]) == id:
			m["role"] = role
		elif role == "chef" and str(m["id"]) == par:
			m["role"] = "officier"
	return out


static func _compte(g: Dictionary, role: String) -> int:
	var n := 0
	for m in g.get("membres", []):
		if str(m["role"]) == role:
			n += 1
	return n


## Une exclusion décidée par `par` : le chef exclut n'importe qui sauf lui ; un officier, un membre seulement.
static func exclure(g: Dictionary, par: String, id: String) -> Dictionary:
	var acteur := role_de(g, par)
	var cible := role_de(g, id)
	if cible == "" or id == par or not peut(acteur, "exclure") or cible == "chef" or (acteur == "officier" and cible != "membre"):
		return g
	return retirer(g, id)


# --- L'Influence et les effets ---------------------------------------------------------------------

## De l'Influence gagnée (la réserve et le total).
static func gagner(g: Dictionary, montant: int) -> Dictionary:
	if montant <= 0:
		return g
	var out := g.duplicate(true)
	out["influence"] = int(out["influence"]) + montant
	out["influence_totale"] = int(out["influence_totale"]) + montant
	return out


## Un effet monté d'un niveau par `par` (chef ou officier), contre de l'Influence ; la même guilde si c'est impossible.
static func acheter(g: Dictionary, par: String, effet: String, d: Donnees) -> Dictionary:
	if not peut(role_de(g, par), "acheter") or not d.guildes["effets"].has(effet):
		return g
	var actuel := int(g.get("effets", {}).get(effet, 0))
	var cout := cout_effet(effet, actuel, d)
	if cout <= 0 or int(g.get("influence", 0)) < cout:
		return g
	var out := g.duplicate(true)
	out["influence"] = int(out["influence"]) - cout
	out["effets"][effet] = actuel + 1
	return out


# --- Le monde simulé ------------------------------------------------------------------------------

## Les guildes du monde simulé (scenes/net/serveur_simule.gd) : les joueurs simulés répartis dans les guildes de
## data/guildes.json (simule.noms), le plus ancien chef, un officier ; bannières et Influence tirées avec la graine.
static func guildes_simulees(joueurs: Array, jour: String, d: Donnees) -> Array:
	var sim: Dictionary = d.guildes["simule"]
	var noms: Array = sim["noms"]
	var rng := RandomNumberGenerator.new()
	rng.seed = int(sim["graine"])
	var out: Array = []
	for i in range(noms.size()):
		var membres: Array = []
		for j in range(joueurs.size()):
			if j % noms.size() == i:
				membres.append(joueurs[j])
		if membres.is_empty():
			continue
		var g := nouvelle("sim-guilde-%d" % (i + 1), str(noms[i]), banniere_defaut(int(sim["graine"]) + i, d), membres[0], "2026-10-01", d)
		for k in range(1, membres.size()):
			g["membres"].append(_membre(membres[k], "officier" if k == 1 else "membre", "2026-10-%02d" % mini(28, 1 + k)))
		g = gagner(g, rng.randi_range(200, 3000))
		var effets: Array = d.guildes["effets"].keys()
		g["effets"][str(effets[i % effets.size()])] = 1
		out.append(g)
	return out


## L'Influence qu'apportent les membres simulés d'une guilde pendant n jours (chacun entre les deux bornes de
## simule.influence_par_jour, tiré avec le jour).
static func influence_simulee(g: Dictionary, jour: String, n_jours: int, d: Donnees) -> int:
	var bornes: Array = d.guildes["simule"]["influence_par_jour"]
	var total := 0
	var rng := RandomNumberGenerator.new()
	rng.seed = (jour + str(g.get("id", ""))).hash()
	for m in g.get("membres", []):
		if str(m["id"]).begins_with("sim-"):
			for _k in range(maxi(0, n_jours)):
				total += rng.randi_range(int(bornes[0]), int(bornes[1]))
	return total
