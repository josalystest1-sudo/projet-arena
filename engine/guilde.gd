## Les guildes (docs/GDD_V2.md, § 9.1 ; docs/PLAN.md, phase 6) : un nom, une bannière composée avec les modèles du jeu
## (un motif, deux couleurs), une annonce, un chef et des rôles que le chef définit lui-même (jusqu'à cinq, chacun avec
## ses pouvoirs : exclure, recruter, éditer l'annonce, dépenser l'Influence, donner un rôle, changer la bannière ;
## décision de Gautier du 1er novembre), une taille qui grossit avec le niveau de la guilde (100 au plus), et une
## ressource, l'Influence, gagnée par l'activité des membres (duels, étages, Gardiens, boss, sélections comme Écho ;
## plus tard les territoires) et dépensée pour monter des effets (XP des membres, butin en plus à la Tour, reforge moins
## chère) ; jamais de puissance en PvP. Une guilde est ouverte (on la rejoint librement s'il reste une place) ou sur
## invitation. Les chiffres : data/guildes.json. Une guilde est un dictionnaire {id, nom, banniere, annonce, ouvert,
## roles, influence, influence_totale, effets, membres, cree} qui vit sur le serveur (scenes/net/serveur.gd) ; ce module
## dit les règles et ne garde rien. Module pur : le hasard du monde simulé vient d'une graine.
class_name Guilde
extends RefCounted

## Le rôle du chef : hors de la liste, un seul, tous les pouvoirs, et ce que lui seul fait (transmettre, dissoudre,
## définir les rôles).
const CHEF := "chef"
const CLES_GUILDE := ["id", "nom", "banniere", "annonce", "ouvert", "roles", "influence", "influence_totale", "effets", "membres", "cree"]
const CLES_MEMBRE := ["id", "pseudo", "classe", "niveau", "role", "depuis"]
const CLES_BANNIERE := ["motif", "fond", "couleur"]
const CLES_ROLE := ["id", "nom", "pouvoirs"]
const NOM_ROLE_MIN := 2
const NOM_ROLE_MAX := 16


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


# --- Les rôles et les pouvoirs ------------------------------------------------------------------------

## Les pouvoirs qui existent (data/guildes.json, pouvoirs), dans l'ordre des données.
static func pouvoirs(d: Donnees) -> Array[String]:
	var out: Array[String] = []
	for p in d.guildes["pouvoirs"]:
		out.append(str(p))
	return out


## Le texte d'un pouvoir : « exclure un membre ».
static func texte_pouvoir(pouvoir: String, d: Donnees) -> String:
	return str(d.guildes["pouvoirs"].get(pouvoir, pouvoir))


## Un rôle de la guilde (vide s'il n'existe pas ; le chef n'est pas dans la liste).
static func role(g: Dictionary, id_role: String) -> Dictionary:
	for r in g.get("roles", []):
		if str(r["id"]) == id_role:
			return r
	return {}


## Le rôle des nouveaux venus : le dernier de la liste.
static func role_defaut(g: Dictionary) -> String:
	var roles: Array = g.get("roles", [])
	return str(roles[roles.size() - 1]["id"]) if not roles.is_empty() else ""


## Le nom d'un rôle, « Chef » pour le chef.
static func nom_role(g: Dictionary, id_role: String) -> String:
	if id_role == CHEF:
		return "Chef"
	return str(role(g, id_role).get("nom", id_role))


## Un rôle acceptable : un identifiant simple (minuscules, sans espace, pas « chef »), un nom de 2 à 16 caractères, des
## pouvoirs connus, sans doublon.
static func role_valide(r: Dictionary, d: Donnees) -> bool:
	for cle in CLES_ROLE:
		if not r.has(cle):
			return false
	var id := str(r["id"])
	if id == "" or id == CHEF or id != id.to_lower().replace(" ", "_") or not r["pouvoirs"] is Array:
		return false
	var n := str(r["nom"]).strip_edges().length()
	if n < NOM_ROLE_MIN or n > NOM_ROLE_MAX:
		return false
	var vus: Array = []
	for p in r["pouvoirs"]:
		if not d.guildes["pouvoirs"].has(str(p)) or vus.has(str(p)):
			return false
		vus.append(str(p))
	return true


## Ce membre a-t-il ce pouvoir ? Le chef les a tous ; les autres, ceux de leur rôle.
static func peut(g: Dictionary, membre_id: String, pouvoir: String) -> bool:
	var m := membre(g, membre_id)
	if m.is_empty():
		return false
	if str(m["role"]) == CHEF:
		return true
	return pouvoir in role(g, str(m["role"])).get("pouvoirs", [])


## Le chef définit un rôle : nouveau (roles_max au plus) ou retouché (nom, pouvoirs). La même guilde si c'est impossible.
static func definir_role(g: Dictionary, par: String, r: Dictionary, d: Donnees) -> Dictionary:
	if role_de(g, par) != CHEF or not role_valide(r, d):
		return g
	var out := g.duplicate(true)
	var propre := {"id": str(r["id"]), "nom": str(r["nom"]).strip_edges(), "pouvoirs": Array(r["pouvoirs"])}
	for i in range(out["roles"].size()):
		if str(out["roles"][i]["id"]) == propre["id"]:
			out["roles"][i] = propre
			return out
	if out["roles"].size() >= int(d.guildes["roles_max"]):
		return g
	out["roles"].append(propre)
	return out


## Le chef supprime un rôle (jamais le dernier) : ses membres prennent le rôle des nouveaux venus.
static func supprimer_role(g: Dictionary, par: String, id_role: String) -> Dictionary:
	if role_de(g, par) != CHEF or role(g, id_role).is_empty() or g["roles"].size() <= 1:
		return g
	var out := g.duplicate(true)
	for i in range(out["roles"].size()):
		if str(out["roles"][i]["id"]) == id_role:
			out["roles"].remove_at(i)
			break
	var defaut := role_defaut(out)
	for m in out["membres"]:
		if str(m["role"]) == id_role:
			m["role"] = defaut
	return out


# --- Une guilde et ses membres --------------------------------------------------------------------

## Une guilde neuve, fondée par ce personnage (sa fiche : id, pseudo, classe, niveau), qui en est le chef ; les rôles
## de départ sont ceux des données ; ouverte.
static func nouvelle(id: String, nom: String, banniere: Dictionary, chef_fiche: Dictionary, jour: String, d: Donnees) -> Dictionary:
	var effets := {}
	for e in d.guildes["effets"]:
		effets[str(e)] = 0
	var roles: Array = []
	for r in d.guildes["roles_defaut"]:
		roles.append(r.duplicate(true))
	return {"id": id, "nom": nom.strip_edges(), "banniere": banniere.duplicate(), "annonce": "", "ouvert": true, "roles": roles,
		"influence": 0, "influence_totale": 0, "effets": effets, "membres": [_membre(chef_fiche, CHEF, jour)], "cree": jour}


static func _membre(fiche: Dictionary, p_role: String, jour: String) -> Dictionary:
	return {"id": str(fiche["id"]), "pseudo": str(fiche.get("pseudo", "")), "classe": str(fiche.get("classe", "")), "niveau": int(fiche.get("niveau", 1)),
		"role": p_role, "depuis": jour}


static func guilde_valide(g: Dictionary, d: Donnees) -> bool:
	for cle in CLES_GUILDE:
		if not g.has(cle):
			return false
	if not nom_valide(str(g["nom"]), d) or not g["banniere"] is Dictionary or not banniere_valide(g["banniere"], d) or not g["membres"] is Array or not g["roles"] is Array:
		return false
	if g["roles"].is_empty() or g["roles"].size() > int(d.guildes["roles_max"]):
		return false
	var ids: Array = []
	for r in g["roles"]:
		if not r is Dictionary or not role_valide(r, d) or ids.has(str(r["id"])):
			return false
		ids.append(str(r["id"]))
	var chefs := 0
	for m in g["membres"]:
		if not m is Dictionary:
			return false
		for cle in CLES_MEMBRE:
			if not m.has(cle):
				return false
		if str(m["role"]) == CHEF:
			chefs += 1
		elif not ids.has(str(m["role"])):
			return false
	return chefs == 1 and str(g["annonce"]).length() <= int(d.guildes["annonce_max"])


## Le membre d'une guilde (vide s'il n'en est pas).
static func membre(g: Dictionary, id: String) -> Dictionary:
	for m in g.get("membres", []):
		if str(m["id"]) == id:
			return m
	return {}


## Le rôle d'un personnage dans une guilde ("" s'il n'en est pas).
static func role_de(g: Dictionary, id: String) -> String:
	return str(membre(g, id).get("role", ""))


## Le chef de la guilde.
static func chef(g: Dictionary) -> Dictionary:
	for m in g.get("membres", []):
		if str(m["role"]) == CHEF:
			return m
	return {}


## Reste-t-il une place ?
static func a_une_place(g: Dictionary, d: Donnees) -> bool:
	return g.get("membres", []).size() < taille_max(niveau(int(g.get("influence_totale", 0)), d), d)


## Peut-on la rejoindre librement : ouverte, et une place.
static func peut_rejoindre(g: Dictionary, d: Donnees) -> bool:
	return bool(g.get("ouvert", true)) and a_une_place(g, d)


## Un membre de plus, avec le rôle des nouveaux venus (la guilde rendue, la même si c'est impossible : fermée sans
## invitation, plus de place, ou déjà membre).
static func ajouter(g: Dictionary, fiche: Dictionary, jour: String, d: Donnees, invite: bool = false) -> Dictionary:
	if not a_une_place(g, d) or not membre(g, str(fiche["id"])).is_empty() or (not invite and not bool(g.get("ouvert", true))):
		return g
	var out := g.duplicate(true)
	out["membres"].append(_membre(fiche, role_defaut(out), jour))
	return out


## Une invitation par `par` (le pouvoir « recruter ») : le personnage entre même si la guilde est fermée.
static func inviter(g: Dictionary, par: String, fiche: Dictionary, jour: String, d: Donnees) -> Dictionary:
	if not peut(g, par, "recruter"):
		return g
	return ajouter(g, fiche, jour, d, true)


## Un membre de moins : s'il était le chef, la guilde passe au membre du rôle le plus haut (le premier de la liste),
## le plus ancien ; s'il était seul, la guilde est dissoute (vide).
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
	if str(m["role"]) == CHEF:
		var suivant := {}
		for r in out["roles"]:
			suivant = _plus_ancien(out["membres"], str(r["id"]))
			if not suivant.is_empty():
				break
		if suivant.is_empty():
			suivant = out["membres"][0]
		suivant["role"] = CHEF
	return out


static func _plus_ancien(membres: Array, p_role: String) -> Dictionary:
	var choix := {}
	for m in membres:
		if str(m["role"]) == p_role and (choix.is_empty() or str(m["depuis"]) < str(choix["depuis"])):
			choix = m
	return choix


## Un changement de rôle décidé par `par` : un rôle de la liste (le chef, ou le pouvoir « rôles » ; jamais sur le chef),
## ou « chef » pour transmettre la guilde (le chef seulement ; il prend alors le premier rôle de la liste). La guilde
## rendue, la même si c'est impossible.
static func changer_role(g: Dictionary, par: String, id: String, p_role: String, d: Donnees) -> Dictionary:
	var cible := role_de(g, id)
	if cible == "" or id == par or cible == CHEF:
		return g
	if p_role == CHEF:
		if role_de(g, par) != CHEF:
			return g
	elif role(g, p_role).is_empty() or not peut(g, par, "roles"):
		return g
	var out := g.duplicate(true)
	for m in out["membres"]:
		if str(m["id"]) == id:
			m["role"] = p_role
		elif p_role == CHEF and str(m["id"]) == par:
			m["role"] = str(out["roles"][0]["id"])
	return out


## Une exclusion décidée par `par` (le chef, ou le pouvoir « exclure ») : jamais le chef, jamais soi-même.
static func exclure(g: Dictionary, par: String, id: String) -> Dictionary:
	var cible := role_de(g, id)
	if cible == "" or id == par or cible == CHEF or not peut(g, par, "exclure"):
		return g
	return retirer(g, id)


## L'annonce de la guilde (le pouvoir « annonce »), annonce_max caractères au plus.
static func changer_annonce(g: Dictionary, par: String, texte: String, d: Donnees) -> Dictionary:
	if not peut(g, par, "annonce") or texte.strip_edges().length() > int(d.guildes["annonce_max"]):
		return g
	var out := g.duplicate(true)
	out["annonce"] = texte.strip_edges()
	return out


## Ouvrir ou fermer la guilde (le pouvoir « recruter »).
static func changer_recrutement(g: Dictionary, par: String, ouvert: bool) -> Dictionary:
	if not peut(g, par, "recruter"):
		return g
	var out := g.duplicate(true)
	out["ouvert"] = ouvert
	return out


## Changer la bannière (le pouvoir « bannière »).
static func changer_banniere(g: Dictionary, par: String, b: Dictionary, d: Donnees) -> Dictionary:
	if not peut(g, par, "banniere") or not banniere_valide(b, d):
		return g
	var out := g.duplicate(true)
	out["banniere"] = b.duplicate()
	return out


# --- L'Influence et les effets ---------------------------------------------------------------------

## De l'Influence gagnée (la réserve et le total).
static func gagner(g: Dictionary, montant: int) -> Dictionary:
	if montant <= 0:
		return g
	var out := g.duplicate(true)
	out["influence"] = int(out["influence"]) + montant
	out["influence_totale"] = int(out["influence_totale"]) + montant
	return out


## Un effet monté d'un niveau par `par` (le pouvoir « acheter »), contre de l'Influence ; la même guilde si c'est
## impossible.
static func acheter(g: Dictionary, par: String, effet: String, d: Donnees) -> Dictionary:
	if not peut(g, par, "acheter") or not d.guildes["effets"].has(effet):
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
## data/guildes.json (simule.noms), le premier chef, le second au premier rôle de la liste ; une guilde sur deux est
## fermée (sur invitation) ; bannières et Influence tirées avec la graine.
static func guildes_simulees(joueurs: Array, _jour: String, d: Donnees) -> Array:
	var sim: Dictionary = d.guildes["simule"]
	var noms: Array = sim["noms"]
	var rng := RandomNumberGenerator.new()
	rng.seed = int(sim["graine"])
	var out: Array = []
	var annonces := ["Entre qui veut, on grimpe ensemble.", "Sur invitation : des joueurs réguliers, le soir.", "Des Échos pour tout le monde, des duels pour rire.", "La Tour d'abord, le reste après."]
	for i in range(noms.size()):
		var membres: Array = []
		for j in range(joueurs.size()):
			if j % noms.size() == i:
				membres.append(joueurs[j])
		if membres.is_empty():
			continue
		var g := nouvelle("sim-guilde-%d" % (i + 1), str(noms[i]), banniere_defaut(int(sim["graine"]) + i, d), membres[0], "2026-10-01", d)
		for k in range(1, membres.size()):
			g["membres"].append(_membre(membres[k], str(g["roles"][0]["id"]) if k == 1 else role_defaut(g), "2026-10-%02d" % mini(28, 1 + k)))
		g = gagner(g, rng.randi_range(200, 3000))
		var effets: Array = d.guildes["effets"].keys()
		g["effets"][str(effets[i % effets.size()])] = 1
		g["ouvert"] = i % 2 == 0
		g["annonce"] = annonces[i % annonces.size()]
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
