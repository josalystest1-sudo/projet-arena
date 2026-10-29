## Le générateur de Destin (docs/SPEC-COMBAT-V2.md, sections 3 et 4) : le seul hasard du jeu. À partir d'une classe
## et d'une graine, il tire la forme de chaque nœud actif (Base, Diffuse, Concentrée, Persistante, Vive), puis il
## allume les nœuds et les éclats (allumage par défaut, ou la liste du joueur). Toutes les formes sont neutres en
## budget : leurs valeurs sont recalculées avec la grille des coûts (section 7.2) pour que le nœud garde exactement
## le coût de sa forme de base. Module pur : le hasard vient de la graine fournie.
class_name Generateur
extends RefCounted

const FORMES := ["base", "diffuse", "concentree", "persistante", "vive"]
## La graine de l'acolyte : celle du joueur XOR 0x5A5A5A5A (section 4).
const XOR_ACOLYTE := 0x5A5A5A5A
## L'allumage par défaut (IA, Échos sans historique, simulateur, personnages de test).
const PAR_DEFAUT: Array[String] = ["defaut"]
## Une forme Persistante étale sur 3 tours.
const PERSISTANTE_TOURS := 3
## Le DoT d'une forme Persistante, selon la classe (l'Archer : Saignement sur sa voie de la Précision, Brûlure ailleurs).
const DOT_PERSISTANTE := {"guerrier": "saignement", "voleur": "saignement", "pugiliste": "saignement",
	"diplomate": "saignement", "mage": "brulure", "archer": "brulure", "alchimiste": "poison", "invocateur": "familier",
	"pretre": "saignement", "barde": "saignement"}
const MONO := ["un_ennemi", "un_allie", "soi"]
const MULTI := ["tous_les_ennemis", "duo"]


## Le Destin d'un joueur : 5 voies, formes tirées avec la graine, N1 allumés d'office, puis `niveau` points placés
## (PAR_DEFAUT : l'allumage par défaut ; sinon la liste des nœuds allumés par le joueur, dans l'ordre, ex. « v2.n2 »,
## « v1.e1 »).
static func generer(classe_id: String, graine: int, niveau: int, allumage: Array[String] = PAR_DEFAUT, donnees: Donnees = null) -> Destin:
	return _generer(classe_id, graine, niveau, allumage, [], false, donnees)


## L'acolyte d'un joueur : la classe fixée par celle du joueur (section 3.2), ses 3 premières voies, la graine du
## joueur XOR 0x5A5A5A5A ; toutes ses voies allumées à partir du niveau 10, l'allumage par défaut avant.
static func acolyte(classe_joueur: String, graine_joueur: int, niveau: int, donnees: Donnees = null) -> Destin:
	var d := donnees if donnees != null else Donnees.defaut()
	var classe := str(d.classe(classe_joueur)["acolyte"])
	var voies: Array = []
	for v in range(3):
		voies.append(d.classe(classe)["voies"][v]["id"])
	return _generer(classe, graine_joueur ^ XOR_ACOLYTE, niveau, PAR_DEFAUT, voies, true, d)


## Un monstre de la Tour (section 10.4) : sa classe, ses seules voies (dans l'ordre du bestiaire), son multiplicateur
## de PV ; formes tirées avec la graine, allumage par défaut au niveau du joueur.
static func monstre(monstre_id: String, graine: int, niveau: int, donnees: Donnees = null) -> Destin:
	var d := donnees if donnees != null else Donnees.defaut()
	var def: Dictionary = d.bestiaire["monstres"][monstre_id]
	var destin := _generer(str(def["classe"]), graine, niveau, PAR_DEFAUT, def["voies"], false, d)
	destin.nom = str(def["nom"])
	destin.sprite = monstre_id
	destin.pv_mult = float(def["pv_mult"])
	return destin


## voies : les identifiants des voies gardées, dans cet ordre (vide : toutes, dans l'ordre de la classe).
static func _generer(classe_id: String, graine: int, niveau: int, allumage: Array[String], voies: Array, est_acolyte: bool, donnees: Donnees) -> Destin:
	var d := donnees if donnees != null else Donnees.defaut()
	var destin := Destin.de_base(d, classe_id, 5, false)
	if not voies.is_empty():
		var gardees: Array = []
		for id in voies:
			for voie in destin.voies:
				if voie["id"] == id:
					gardees.append(voie)
		destin.voies = gardees
	destin.graine = graine
	destin.acolyte = est_acolyte
	var rng := RandomNumberGenerator.new()
	for v in range(destin.voies.size()):
		var voie: Dictionary = destin.voies[v]
		for r in range(4):
			var noeud: Dictionary = voie["noeuds"][r]
			var formes := _formes_du_noeud(d, noeud, classe_id, str(voie["id"]))
			rng.seed = graine + v * 4 + r
			var forme_noeud: Dictionary = formes[rng.randi_range(0, formes.size() - 1)].duplicate(true)
			forme_noeud["allume"] = r == 0
			voie["noeuds"][r] = forme_noeud
	var liste := allumage
	if allumage == PAR_DEFAUT:
		liste = allumage_defaut(destin.voies.size(), niveau, est_acolyte)
	allumer(destin, liste, niveau)
	return destin


## L'allumage par défaut (section 3.1) : à chaque niveau, N2 de chaque voie, puis N3, puis les Clés, puis É1, É3, É2
## de chaque voie (un monstre de la Tour aussi, sur ses seules voies). L'acolyte : tout est allumé à partir du niveau 10 (12 nœuds actifs, É1 et É3 de sa
## première voie) ; avant, les N2, N3 et Clés dans le même ordre.
static func allumage_defaut(nb_voies: int, niveau: int, est_acolyte: bool = false) -> Array[String]:
	var ordre: Array[String] = []
	for rang in [2, 3, 4]:
		for v in range(nb_voies):
			ordre.append("v%d.n%d" % [v + 1, rang])
	if est_acolyte:
		if niveau >= 10:
			ordre.append_array(["v1.e1", "v1.e3"])
			return ordre
		return ordre.slice(0, maxi(0, niveau))
	for eclat in [1, 3, 2]:
		for v in range(nb_voies):
			ordre.append("v%d.e%d" % [v + 1, eclat])
	return ordre.slice(0, clampi(niveau, 0, ordre.size()))


## Allume les nœuds d'une liste, dans l'ordre, en respectant la règle d'allumage (un rang k exige le rang k−1 de la
## même voie ; un éclat exige son nœud) ; une entrée impossible est ignorée. Au plus `niveau` points (l'acolyte n'a
## pas de limite : son allumage est fixé par son niveau). Rend le nombre de points placés.
static func allumer(destin: Destin, liste: Array[String], niveau: int) -> int:
	var places := 0
	for cle in liste:
		if not destin.acolyte and places >= niveau:
			break
		if peut_allumer(destin, cle):
			_poser_allume(destin, cle)
			places += 1
	return places


## Un nœud (« v2.n3 ») ou un éclat (« v1.e4 ») peut-il être allumé maintenant ?
static func peut_allumer(destin: Destin, cle: String) -> bool:
	var parse := _lire_cle(destin, cle)
	if parse.is_empty():
		return false
	var voie: Dictionary = destin.voies[parse["voie"]]
	if parse["type"] == "n":
		var rang: int = parse["numero"]
		if bool(voie["noeuds"][rang - 1]["allume"]):
			return false
		return rang == 1 or bool(voie["noeuds"][rang - 2]["allume"])
	var eclat: int = parse["numero"]
	if bool(voie["eclats"][eclat - 1]):
		return false
	return bool(voie["noeuds"][Destin.ECLAT_NOEUD[eclat - 1] - 1]["allume"])


static func _poser_allume(destin: Destin, cle: String) -> void:
	var parse := _lire_cle(destin, cle)
	var voie: Dictionary = destin.voies[parse["voie"]]
	if parse["type"] == "n":
		voie["noeuds"][parse["numero"] - 1]["allume"] = true
	else:
		voie["eclats"][parse["numero"] - 1] = true


static func _lire_cle(destin: Destin, cle: String) -> Dictionary:
	var parties := cle.split(".")
	if parties.size() != 2 or not parties[0].begins_with("v") or parties[1].length() < 2:
		return {}
	var v := int(parties[0].substr(1)) - 1
	var type := parties[1].substr(0, 1)
	var numero := int(parties[1].substr(1))
	if v < 0 or v >= destin.voies.size() or not type in ["n", "e"]:
		return {}
	if (type == "n" and (numero < 1 or numero > 4)) or (type == "e" and (numero < 1 or numero > 5)):
		return {}
	return {"voie": v, "type": type, "numero": numero}


# --- Formes ----------------------------------------------------------------------

## Le nœud sous chacune des formes qu'il peut prendre, dans l'ordre de FORMES (gardé en mémoire : il ne dépend que
## des données).
static func _formes_du_noeud(d: Donnees, noeud: Dictionary, classe_id: String, voie_id: String) -> Array:
	var cle := "formes|%s|%s|%d" % [classe_id, voie_id, int(noeud["rang"])]
	if not d.memoire.has(cle):
		var formes: Array = []
		for forme in formes_possibles(d.regles, noeud, classe_id, voie_id):
			formes.append(appliquer_forme(d.regles, noeud, forme, classe_id, voie_id))
		d.memoire[cle] = formes
	return d.memoire[cle]


## Les formes qu'un nœud peut prendre (Base toujours) : Diffuse s'il a un effet mono-cible, Concentrée s'il a un effet
## multi-cible, Persistante s'il a des dégâts ou un soin directs, Vive s'il a un DoT ou un Gardien ; et seulement si
## la forme peut garder le coût du nœud (des états devenus multi-cibles peuvent coûter plus que tout le budget).
static func formes_possibles(regles: Dictionary, noeud: Dictionary, classe_id: String, voie_id: String) -> Array[String]:
	var out: Array[String] = ["base"]
	for forme in ["diffuse", "concentree", "persistante", "vive"]:
		if _forme_concerne(noeud, forme) and not appliquer_forme(regles, noeud, forme, classe_id, voie_id).is_empty():
			out.append(forme)
	return out


static func _forme_concerne(noeud: Dictionary, forme: String) -> bool:
	for ef in noeud["effets"]:
		match forme:
			"diffuse":
				if ef["cible"] in MONO:
					return true
			"concentree":
				if ef["cible"] in MULTI:
					return true
			"persistante":
				if ef["type"] in ["degats", "soin"]:
					return true
			"vive":
				if ef["type"] in ["dot", "gardien"]:
					return true
	return false


## Un nœud sous une forme : les cibles et les types changent comme le dit la section 4 (facteurs nominaux), les effets
## de même type sur la même cible se regroupent, puis toutes les valeurs (dégâts, soins, barrières, DoT, Gardiens,
## pourcentages) sont remises à l'échelle pour que le coût reste celui de la forme de base. Vide si c'est impossible
## (les états, Purge, Dissipe et Égaré coûtent à eux seuls autant que tout le nœud).
static func appliquer_forme(regles: Dictionary, noeud: Dictionary, forme: String, classe_id: String, voie_id: String) -> Dictionary:
	var out := noeud.duplicate(true)
	out["forme"] = forme
	if forme == "base":
		return out
	var effets: Array = []
	for ef in noeud["effets"]:
		effets.append(_transformer(regles, ef, forme, classe_id, voie_id))
	effets = _regrouper(effets)
	var cout := Budget.cout(regles, noeud)
	var fixe := 0.0
	var variable := 0.0
	for ef in effets:
		if _a_valeur(ef):
			variable += Budget.cout_effet(regles, ef)
		else:
			fixe += Budget.cout_effet(regles, ef)
	if variable <= 0.0 or cout - fixe <= 0.0:
		return {}
	var echelle := (cout - fixe) / variable
	for ef in effets:
		_mettre_a_l_echelle(ef, echelle)
	out["effets"] = effets
	return out


## Un effet sous une forme. Les facteurs sont les rapports exacts de la grille des coûts, dont la section 4 donne les
## arrondis : Diffuse ÷1,3 et Concentrée ×1,3 (le prix d'une cible multiple), Persistante dégâts → DoT ×1/0,7 (≈ 1,43)
## et soin → Gardien ×0,9/0,65 (≈ 1,38) sur 3 tours, Vive DoT → dégâts ×0,7 et Gardien → soin ×0,65/0,9.
static func _transformer(regles: Dictionary, ef: Dictionary, forme: String, classe_id: String, voie_id: String) -> Dictionary:
	var couts: Dictionary = regles["couts"]
	var multi := float(regles["multi_cible"])
	var out := ef.duplicate()
	match forme:
		"diffuse":
			if ef["cible"] in MONO:
				out["cible"] = "tous_les_ennemis" if ef["cible"] == "un_ennemi" else "duo"
				_mettre_a_l_echelle(out, 1.0 / multi)
		"concentree":
			if ef["cible"] in MULTI:
				out["cible"] = "un_ennemi" if ef["cible"] == "tous_les_ennemis" else "un_allie"
				_mettre_a_l_echelle(out, multi)
		"persistante":
			if ef["type"] == "degats":
				var type_dot: String = "saignement" if classe_id == "archer" and voie_id == "precision" else DOT_PERSISTANTE.get(classe_id, "saignement")
				var total := float(ef["valeur"]) * float(couts["degats"]) / float(couts["dot"])
				out = {"type": "dot", "sous_type": type_dot, "par_tour": total / PERSISTANTE_TOURS, "tours": PERSISTANTE_TOURS, "cible": ef["cible"]}
			elif ef["type"] == "soin":
				var total := float(ef["valeur"]) * float(couts["soin"]) / float(couts["gardien"])
				out = {"type": "gardien", "par_tour": total / PERSISTANTE_TOURS, "tours": PERSISTANTE_TOURS, "cible": ef["cible"]}
		"vive":
			if ef["type"] == "dot":
				var valeur := float(ef["par_tour"]) * float(ef["tours"]) * float(couts["dot"]) / float(couts["degats"])
				out = {"type": "degats", "valeur": valeur, "cible": ef["cible"]}
			elif ef["type"] == "gardien":
				var valeur := float(ef["par_tour"]) * float(ef["tours"]) * float(couts["gardien"]) / float(couts["soin"])
				out = {"type": "soin", "valeur": valeur, "cible": ef["cible"]}
	return out


## Deux effets de même type sur la même cible (un DoT né d'une forme Persistante et le DoT déjà là, des dégâts nés
## d'une forme Vive et les dégâts déjà là) n'en font qu'un : leurs totaux s'additionnent, sur la durée du premier. Sinon
## le second serait perdu (un état ne se cumule jamais).
static func _regrouper(effets: Array) -> Array:
	var out: Array = []
	for ef in effets:
		var fusion := false
		if ef["type"] in ["degats", "soin", "barriere", "dot", "gardien"]:
			for deja in out:
				if deja["type"] == ef["type"] and deja["cible"] == ef["cible"] and deja.get("sous_type", "") == ef.get("sous_type", ""):
					if ef["type"] in ["dot", "gardien"]:
						var total := float(deja["par_tour"]) * float(deja["tours"]) + float(ef["par_tour"]) * float(ef["tours"])
						deja["par_tour"] = total / float(deja["tours"])
					else:
						deja["valeur"] = float(deja["valeur"]) + float(ef["valeur"])
					fusion = true
					break
		if not fusion:
			out.append(ef)
	return out


static func _a_valeur(ef: Dictionary) -> bool:
	return ef["type"] in ["degats", "soin", "barriere", "dot", "gardien", "renfort", "affaiblissement"]


static func _mettre_a_l_echelle(ef: Dictionary, facteur: float) -> void:
	match str(ef["type"]):
		"degats", "soin", "barriere":
			ef["valeur"] = float(ef["valeur"]) * facteur
		"dot", "gardien":
			ef["par_tour"] = float(ef["par_tour"]) * facteur
		"renfort", "affaiblissement":
			ef["pourcent"] = float(ef["pourcent"]) * facteur
