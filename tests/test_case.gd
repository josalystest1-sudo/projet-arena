## Classe de base des tests du combat V2. Pas de dépendance à une bibliothèque externe.
extends RefCounted

var failures: Array = []
var donnees: Donnees


func setup() -> void:
	donnees = Donnees.defaut()


func assert_true(condition: bool, message: String = "") -> void:
	if not condition:
		failures.append(message if message != "" else "condition fausse")


func assert_false(condition: bool, message: String = "") -> void:
	assert_true(not condition, message)


func assert_eq(actual: Variant, expected: Variant, message: String = "") -> void:
	if actual != expected:
		failures.append("%s : attendu %s, obtenu %s" % [message, str(expected), str(actual)])


func assert_ne(actual: Variant, unexpected: Variant, message: String = "") -> void:
	if actual == unexpected:
		failures.append("%s : ne devait pas valoir %s" % [message, str(unexpected)])


func assert_between(actual: float, low: float, high: float, message: String = "") -> void:
	if actual < low or actual > high:
		failures.append("%s : %s hors de [%s, %s]" % [message, str(actual), str(low), str(high)])


func assert_almost(actual: float, expected: float, message: String) -> void:
	if absf(actual - expected) > 0.001:
		failures.append("%s : attendu %s, obtenu %s" % [message, str(expected), str(actual)])


# --- Effets écrits en clair, pour des Destins d'essai ----------------------------

func deg(valeur: int, cible: String = "un_ennemi") -> Dictionary:
	return {"type": "degats", "valeur": valeur, "cible": cible}


func soin(valeur: int, cible: String = "un_allie") -> Dictionary:
	return {"type": "soin", "valeur": valeur, "cible": cible}


func barriere(valeur: int, cible: String = "soi") -> Dictionary:
	return {"type": "barriere", "valeur": valeur, "cible": cible}


func dot(sous_type: String, par_tour: int, tours: int, cible: String = "un_ennemi") -> Dictionary:
	return {"type": "dot", "sous_type": sous_type, "par_tour": par_tour, "tours": tours, "cible": cible}


func gardien(par_tour: int, tours: int, cible: String = "un_allie") -> Dictionary:
	return {"type": "gardien", "par_tour": par_tour, "tours": tours, "cible": cible}


func etat(nom: String, tours: int, cible: String = "un_ennemi") -> Dictionary:
	return {"type": "etat", "nom": nom, "tours": tours, "cible": cible}


func renfort(pc: int, cible: String = "soi") -> Dictionary:
	return {"type": "renfort", "pourcent": pc, "tours": 2, "cible": cible}


func affaiblissement(pc: int, cible: String = "un_ennemi") -> Dictionary:
	return {"type": "affaiblissement", "pourcent": pc, "tours": 2, "cible": cible}


func egare(cible: String = "un_ennemi") -> Dictionary:
	return {"type": "egare", "cible": cible}


func purge(cible: String = "un_allie") -> Dictionary:
	return {"type": "purge", "cible": cible}


func dissipe(cible: String = "un_ennemi") -> Dictionary:
	return {"type": "dissipe", "cible": cible}


# --- Destins et combats d'essai --------------------------------------------------

## Le Destin de base d'une classe (section 9) : tous les nœuds allumés, sans éclat.
func destin(classe_id: String, nb_voies: int = 5) -> Destin:
	return Destin.de_base(donnees, classe_id, nb_voies)


## Un Destin d'essai : `voies` est une liste de voies, chacune une liste de nœuds (rang 1, 2, 3, Clé), chaque nœud une
## liste d'effets ; un nœud manquant inflige 10 à un ennemi. Le moyeu inflige 0 à un ennemi (sauf s'il est donné),
## pour que les PV ne bougent que par ce que le test fait jouer.
func essai(voies: Array = [], pv: int = 1000, moyeu: Array = []) -> Destin:
	var d := Destin.new()
	d.classe_id = "essai"
	d.nom = "Essai"
	d.role = "degats"
	d.pv_base = pv
	d.k = 1.0
	d.moyeu = {"nom": "Coup", "genre": "m", "rang": 0, "forme": "base", "allume": true, "effets": moyeu if not moyeu.is_empty() else [deg(0)]}
	for v in range(voies.size()):
		var noeuds: Array = []
		for r in range(4):
			var effets: Array = voies[v][r] if r < voies[v].size() else [deg(10)]
			noeuds.append({"rang": r + 1, "nom": "N%d" % (r + 1), "genre": "m", "forme": "base", "allume": true, "effets": effets})
		d.voies.append({"id": "v%d" % (v + 1), "nom": "Voie %d" % (v + 1), "noeuds": noeuds, "eclats": [false, false, false, false, false]})
	return d


func combat(camp_a: Array, camp_b: Array, niveau: int = 1, mode: String = "pvp") -> EtatCombat:
	return Regles.nouveau_combat(camp_a, camp_b, niveau, mode, donnees)


## Un duel de quatre Destins d'essai : chacun reçoit les mêmes voies d'essai par défaut.
func duel_essai(a1: Destin = null, a2: Destin = null, b1: Destin = null, b2: Destin = null) -> EtatCombat:
	return combat([a1 if a1 else essai(), a2 if a2 else essai()], [b1 if b1 else essai(), b2 if b2 else essai()])


## L'action « jouer le prochain nœud de la voie v » d'un perso (cibles : celles données, sinon par défaut).
func jouer(e: EtatCombat, id: String, v: int, cible_ennemie: String = "", cible_alliee: String = "") -> Dictionary:
	var rang := int(e.perso(id)["jalons"][v]) + 1
	return Regles.action(id, "voie", v, rang, cible_ennemie, cible_alliee)


func moyeu(id: String, cible_ennemie: String = "", cible_alliee: String = "") -> Dictionary:
	return Regles.action(id, "moyeu", -1, 0, cible_ennemie, cible_alliee)


func tour(e: EtatCombat, declarations: Dictionary = {}) -> EtatCombat:
	return Regles.resoudre_tour(e, declarations)


## Pose un état actif dès le tour en cours, pour `tours` tours (le tour en cours compris).
func poser(e: EtatCombat, id: String, nom: String, tours: int = 1, valeur: float = 0.0, source: String = "") -> void:
	e.perso(id)["etats"][nom] = {"debut": e.tour, "fin": e.tour + tours - 1, "valeur": valeur, "source": source}


## Les événements d'un type dans le journal du dernier tour.
func evenements(e: EtatCombat, type: String, cible: String = "") -> Array:
	var out: Array = []
	for ev in e.journal:
		if ev["type"] == type and (cible == "" or ev["cible"] == cible):
			out.append(ev)
	return out


## Les voies jouables d'un perso (hors moyeu), sous la forme [voie, rang].
func voies_legales(e: EtatCombat, id: String) -> Array:
	var out: Array = []
	for a in Regles.actions_legales(e, id):
		if a["source"] == "voie":
			out.append([a["voie"], a["rang"]])
	return out
