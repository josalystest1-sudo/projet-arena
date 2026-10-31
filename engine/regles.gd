## Les règles du combat V2 (docs/SPEC-COMBAT-V2.md, section 5) : création d'un combat, actions légales, menaces,
## Synergies, et la résolution d'un tour phase par phase (2a à 2i), dans l'ordre imposé par la spécification. Toutes
## les actions se calculent sur l'état de la fin de la phase 0 (Renfort, Affaiblissement, Désarmé, Aveuglé, Poison,
## Brûlure de chacun) ; les PV et les barrières, eux, bougent au fil des écritures. Aucun hasard : mêmes entrées, même
## résultat. Module pur.
class_name Regles
extends RefCounted

## Les traits légendaires (data/items.json, traits ; engine/equipement.gd) : des passifs du porteur, appliqués ici.
## Férocité frappe plus fort un ennemi sous ce seuil de PV ; Carapace pose sa barrière pour ce nombre de tours.
const FEROCITE_SEUIL := 0.30
const CARAPACE_TOURS := 3
## Les états de contrôle qui ouvrent Brisure (section 8).
const CONTROLES_BRISURE := ["etourdi", "gele", "enracine", "aveugle", "silencie", "provoque"]
## Les chiffres des quatre Synergies (section 8), des règles comme les éclats : hors des données.
const BRISURE_DEGATS := 1.25
const EMBRASEMENT_TOURS := 1
const BASTION_BARRIERE := 1.3
const HARMONIE_TOURS := 1
## Les places qui font des Synergies (pas les ennemis de la Tour).
const PLACES_SYNERGIE := ["joueur", "acolyte", "echo"]
## Désarmé : dégâts directs ×0,5 ; Poison : soins reçus ×0,5 ; Brûlure : barrières reçues ×0,5 (section 6).
const DESARME := 0.5
const POISON_SOINS := 0.5
const BRULURE_BARRIERES := 0.5
## L'ordre des ticks (2f) : les DoT dans cet ordre, puis le Gardien.
const ORDRE_DOTS := ["saignement", "brulure", "poison", "familier"]
## La phase où s'applique chaque type d'effet.
const PHASE_EFFET := {"dissipe": "2a", "purge": "2a", "degats": "2b", "soin": "2c", "barriere": "2d", "etat": "2e",
	"dot": "2e", "gardien": "2e", "renfort": "2e", "affaiblissement": "2e", "egare": "2e"}
## Ce qui empêche un nœud d'être joué : seul le moyeu sous Gelé, pas de Clé sous Silencié (section 5.2).
const ARRONDI := 0.000001


# --- Création ------------------------------------------------------------------

## Un combat : camp A (le joueur puis son acolyte, ou le joueur puis ses deux Échos : engine/trio.gd), camp B (de même,
## ou 1 à 4 ennemis de la Tour), au même niveau. La place de chacun : « joueur » (le premier du camp), « acolyte »,
## « echo » (un Destin marqué Écho) ou « ennemi » (la Tour). L'état rendu est celui de la fin de la phase 0 du tour 1.
static func nouveau_combat(camp_a: Array, camp_b: Array, niveau: int, mode: String, donnees: Donnees = null) -> EtatCombat:
	var d := donnees if donnees != null else Donnees.defaut()
	var e := EtatCombat.new()
	e.tour = 1
	e.niveau = maxi(1, niveau)
	e.mode = mode
	e.regles = d.regles
	e.defs_etats = d.etats
	e.defs_traits = d.objets.get("traits", {})
	var m := multiplicateur_niveau(e)
	for c in [["a", camp_a], ["b", camp_b]]:
		var membres: Array = c[1]
		for i in range(membres.size()):
			var destin: Destin = membres[i]
			var id := "%s%d" % [c[0], i + 1]
			var place := "joueur" if i == 0 else ("echo" if destin.echo else "acolyte")
			if mode == "tour" and c[0] == "b":
				place = "ennemi"
			e.ordre.append(id)
			var bonus: Array = []
			for v in range(destin.voies.size()):
				bonus.append([destin.bonus_valeurs(v, 1), destin.bonus_valeurs(v, 2), destin.bonus_valeurs(v, 3), destin.bonus_valeurs(v, 4)])
			# L'équipement (engine/equipement.gd) : ses PV max et sa Force entrent ici ; ses autres lignes à chaque valeur
			# (valeur). Sans équipement, × 1 : le combat est le même au bit près.
			var pv_max := plancher(float(destin.pv_base) * destin.pv_mult * m * (1.0 + destin.bonus_pv()) * (1.0 + float(destin.mods.get("pv", 0.0))))
			e.statique[id] = {"camp": c[0], "place": place, "classe": destin.classe_id, "nom": destin.nom, "sprite": destin.sprite,
				"role": destin.role, "k": destin.k * (1.0 + float(destin.mods.get("force", 0.0))), "pv_max": pv_max, "moyeu": destin.moyeu,
				"voies": destin.voies, "bonus": bonus, "mods": destin.mods.duplicate(), "traits": Array(destin.traits)}
			var nv := destin.voies.size()
			var eteints: Array = []
			for v in range(nv):
				eteints.append([0, 0, 0, 0])
			e.persos[id] = {"pv": pv_max, "ko": false, "etats": {}, "barriere": 0, "barrier_until": 0,
				"jalons": _zeros(nv), "spent_until": eteints, "inactivite": _zeros(nv), "last_voie": -1,
				"cible_ennemie": "", "cible_alliee": "", "soins": 0, "tenacite": false}
			# Carapace : une barrière dès le début du combat, comme posée au tour 1.
			if porte(e, id, "carapace"):
				e.persos[id]["barriere"] = plancher(float(pv_max) * valeur_trait(e, "carapace"))
				e.persos[id]["barrier_until"] = e.tour + CARAPACE_TOURS - 1
	return e


## Ce perso porte-t-il ce trait légendaire ? (« trait » est un mot réservé de GDScript.)
static func porte(e: EtatCombat, id: String, nom: String) -> bool:
	return nom in e.fiche(id).get("traits", [])


## La valeur d'un trait (data/items.json, traits).
static func valeur_trait(e: EtatCombat, nom: String) -> float:
	return float(e.defs_traits.get(nom, {}).get("valeur", 0.0))


## M(niveau) = 1 + 0,05 × (niveau − 1) (section 3.3).
static func multiplicateur_niveau(e: EtatCombat) -> float:
	return 1.0 + float(e.regles["niveau_pente"]) * float(e.niveau - 1)


## Mort subite (section 5.5) : à partir du tour 12 en PvP, dégâts directs et DoT ×(1 + 0,15 × (tour − 11)).
static func mort_subite(e: EtatCombat) -> float:
	var debut := int(e.regles["mort_subite_tour"])
	if e.mode != "pvp" or e.tour < debut:
		return 1.0
	return 1.0 + float(e.regles["mort_subite_pas"]) * float(e.tour - debut + 1)


## Arrondi à l'inférieur (section 3.3), à l'abri des erreurs de virgule (900 × 1,45 doit donner 1305).
static func plancher(x: float) -> int:
	return floori(x + ARRONDI)


static func _zeros(n: int) -> Array:
	var out: Array = []
	out.resize(n)
	out.fill(0)
	return out


# --- Actions légales et cibles (section 5.2) -------------------------------------

## Une action : le moyeu, ou le nœud de rang `rang` de la voie `voie` (0 à 4), avec ses cibles.
static func action(perso: String, source: String, voie: int = -1, rang: int = 0, cible_ennemie: String = "", cible_alliee: String = "") -> Dictionary:
	return {"perso": perso, "source": source, "voie": voie, "rang": rang, "cible_ennemie": cible_ennemie, "cible_alliee": cible_alliee}


## Les actions légales d'un perso ce tour-ci, cibles par défaut remplies : le moyeu d'abord, puis le prochain nœud de
## chaque voie qui peut être joué. Vide si le perso est KO ou Étourdi.
static func actions_legales(e: EtatCombat, id: String) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	if not e.vivant(id) or e.a_etat(id, "etourdi"):
		return out
	var ce := cible_ennemie(e, id)
	var ca := cible_alliee(e, id)
	out.append(action(id, "moyeu", -1, 0, ce, ca))
	if e.a_etat(id, "gele"):
		return out
	var p := e.perso(id)
	for v in range(e.nb_voies(id)):
		var rang := int(p["jalons"][v]) + 1
		if rang > 4 or not bool(e.noeud(id, v, rang)["allume"]):
			continue
		if int(p["spent_until"][v][rang - 1]) > e.tour:
			continue
		if rang == 4 and e.a_etat(id, "silencie"):
			continue
		if e.a_etat(id, "enracine") and int(p["last_voie"]) >= 0 and v != int(p["last_voie"]):
			continue
		out.append(action(id, "voie", v, rang, ce, ca))
	return out


## La cible ennemie d'un perso : le provocateur s'il est Provoqué (et que le provocateur vit), sinon celle qu'il a
## choisie si elle vit encore, sinon l'ennemi vivant qui a le moins de PV en pourcentage (à égalité, dans l'ordre :
## le joueur adverse avant son acolyte, le premier ennemi de la Tour).
static func cible_ennemie(e: EtatCombat, id: String) -> String:
	var forcee := provocateur(e, id)
	if forcee != "":
		return forcee
	var choisie := str(e.perso(id)["cible_ennemie"])
	var ennemis := e.ennemis_vivants(id)
	if choisie in ennemis:
		return choisie
	return plus_bas(e, ennemis)


## La cible alliée : celle choisie si elle vit encore, sinon l'allié vivant (soi compris) au plus bas en pourcentage.
static func cible_alliee(e: EtatCombat, id: String) -> String:
	var choisie := str(e.perso(id)["cible_alliee"])
	var allies := e.allies_vivants(id)
	if choisie in allies:
		return choisie
	return plus_bas(e, allies)


static func plus_bas(e: EtatCombat, ids: Array[String]) -> String:
	var meilleur := ""
	for id in ids:
		if meilleur == "" or e.pv_pourcent(id) < e.pv_pourcent(meilleur):
			meilleur = id
	return meilleur


static func provocateur(e: EtatCombat, id: String) -> String:
	if not e.a_etat(id, "provoque"):
		return ""
	var source := str(e.perso(id)["etats"]["provoque"]["source"])
	return source if e.statique.has(source) and e.vivant(source) else ""


## L'action telle qu'elle sera jouée : une action illégale (nœud absent de la liste, cible KO ou du mauvais camp) est
## remplacée par le moyeu (section 5.3) ; une cible vide prend la cible par défaut ; Provoqué force la cible ennemie.
## Vide si le perso ne joue pas (KO, Étourdi).
static func valider(e: EtatCombat, id: String, declaration: Variant) -> Dictionary:
	var legales := actions_legales(e, id)
	if legales.is_empty():
		return {}
	var choisie: Dictionary = {}
	if declaration is Dictionary and not declaration.is_empty():
		for l in legales:
			if str(l["source"]) != str(declaration.get("source", "")):
				continue
			if str(l["source"]) == "voie" and (int(l["voie"]) != int(declaration.get("voie", -1)) or int(l["rang"]) != int(declaration.get("rang", 0))):
				continue
			choisie = l.duplicate()
		if not choisie.is_empty():
			var ce := str(declaration.get("cible_ennemie", ""))
			var ca := str(declaration.get("cible_alliee", ""))
			if ce != "":
				if ce in e.ennemis_vivants(id):
					choisie["cible_ennemie"] = ce
				else:
					choisie = {}
			if not choisie.is_empty() and ca != "":
				if ca in e.allies_vivants(id):
					choisie["cible_alliee"] = ca
				else:
					choisie = {}
	if choisie.is_empty():
		choisie = legales[0].duplicate()
	var forcee := provocateur(e, id)
	if forcee != "":
		choisie["cible_ennemie"] = forcee
	return choisie


## Le nœud joué par une action.
static func noeud_de(e: EtatCombat, a: Dictionary) -> Dictionary:
	return e.noeud(str(a["perso"]), int(a["voie"]), int(a["rang"]) if str(a["source"]) == "voie" else 0)


## L'identifiant d'un nœud : classe.voie.rang (section 9), classe.moyeu pour le moyeu.
static func id_noeud(e: EtatCombat, a: Dictionary) -> String:
	var fiche := e.fiche(str(a["perso"]))
	if str(a["source"]) != "voie":
		return "%s.moyeu" % fiche["classe"]
	return "%s.%s.%d" % [fiche["classe"], fiche["voies"][int(a["voie"])]["id"], int(a["rang"])]


## Les persos touchés par un effet d'une action.
static func cibles(e: EtatCombat, a: Dictionary, cible: String) -> Array[String]:
	var id := str(a["perso"])
	var out: Array[String] = []
	match cible:
		"un_ennemi":
			var t := str(a.get("cible_ennemie", ""))
			if t != "" and t in e.ennemis_vivants(id):
				out.append(t)
		"tous_les_ennemis":
			out = e.ennemis_vivants(id)
		"soi":
			out.append(id)
		"un_allie":
			var t := str(a.get("cible_alliee", ""))
			if t != "" and t in e.allies_vivants(id):
				out.append(t)
		"duo":
			out = e.allies_vivants(id)
	return out


# --- Menaces (section 12.3) ------------------------------------------------------

## Les menaces d'un perso, figées en phase 0 : ses nœuds allumés de rang 3 ou 4 encore devant son jalon, d'échéance
## ≤ 2, triés par échéance puis par budget décroissant, 3 au plus. Une menace est barrée si un état déjà posé
## l'empêchera d'être jouée au tour où elle deviendra jouable (Silencié pour une Clé, Gelé, Étourdi, Enraciné hors de
## sa dernière voie).
static func menaces(e: EtatCombat, id: String) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	if not e.vivant(id):
		return out
	var p := e.perso(id)
	for v in range(e.nb_voies(id)):
		var jalon := int(p["jalons"][v])
		for rang in [3, 4]:
			var n := e.noeud(id, v, rang)
			if not bool(n["allume"]) or rang <= jalon:
				continue
			var ech := echeance(e, id, v, rang)
			if ech > 2:
				continue
			out.append({"voie": v, "rang": rang, "echeance": ech, "barre": _empeche(e, id, v, rang, e.tour + ech - 1),
				"budget": Budget.budget(e.regles, n)})
	out.sort_custom(func(x, y): return x["echeance"] < y["echeance"] or (x["echeance"] == y["echeance"] and x["budget"] > y["budget"]))
	if out.size() > 3:
		out.resize(3)
	return out


## L'échéance d'un nœud (section 2) : max(rang − jalon, extinction restante) ; 1 = jouable à la prochaine résolution.
static func echeance(e: EtatCombat, id: String, voie: int, rang: int) -> int:
	var p := e.perso(id)
	var ech := rang - int(p["jalons"][voie])
	var retour := int(p["spent_until"][voie][rang - 1])
	if retour > e.tour:
		ech = maxi(ech, retour - e.tour)
	return ech


## Un état actif au tour t empêche-t-il ce nœud ?
static func _empeche(e: EtatCombat, id: String, voie: int, rang: int, t: int) -> bool:
	if e.a_etat(id, "etourdi", t) or e.a_etat(id, "gele", t):
		return true
	if rang == 4 and e.a_etat(id, "silencie", t):
		return true
	var derniere := int(e.perso(id)["last_voie"])
	return e.a_etat(id, "enracine", t) and derniere >= 0 and voie != derniere


# --- Synergies (section 8) ---------------------------------------------------------

## Les Synergies des déclarations validées : dans chaque camp, entre deux persos qui jouent tous les deux ce tour (le
## joueur et son acolyte ; dans un trio, chaque paire parmi le joueur et ses Échos). Les ennemis de la Tour n'en font
## pas. Un même effet renforcé par deux paires ne l'est qu'une fois.
## Rend { "liste": [{ nom, camp, acteurs, cible }], "mods": { cle -> multiplicateur ou tours en plus } }, la clé
## étant « acteur|index de l'effet|cible ».
static func synergies(e: EtatCombat, actions: Dictionary) -> Dictionary:
	var liste: Array = []
	var mods := {"degats": {}, "dot": {}, "barriere": {}, "renfort": {}}
	var vues := {}
	for p_camp in ["a", "b"]:
		var membres: Array[String] = []
		for id in e.ordre:
			if e.camp(id) == p_camp and e.fiche(id)["place"] in PLACES_SYNERGIE and not actions.get(id, {}).is_empty():
				membres.append(id)
		for i in range(membres.size()):
			for j in range(i + 1, membres.size()):
				_synergies_paire(e, actions, membres[i], membres[j], p_camp, liste, vues, mods)
	return {"liste": liste, "mods": mods}


## Les Synergies d'une paire d'un même camp (les deux sens : chacun peut poser le contrôle, l'autre frapper).
static func _synergies_paire(e: EtatCombat, actions: Dictionary, p: String, q: String, p_camp: String, liste: Array, vues: Dictionary, mods: Dictionary) -> void:
	var effets := {p: _effets_cibles(e, actions[p]), q: _effets_cibles(e, actions[q])}
	for paire in [[p, q], [q, p]]:
		var x: String = paire[0]
		var y: String = paire[1]
		for fx in effets[x]:
			for fy in effets[y]:
				for t in fx["cibles"]:
					# Brisure : un contrôle posé par x, des dégâts directs à un ennemi par y, sur la même cible.
					if fx["type"] == "etat" and fx["nom"] in CONTROLES_BRISURE and fy["type"] == "degats" and fy["cible"] == "un_ennemi" and t in fy["cibles"]:
						mods["degats"]["%s|%d|%s" % [y, fy["index"], t]] = BRISURE_DEGATS
						_noter(liste, vues, "Brisure", p_camp, [x, y], t)
					# Embrasement : les deux posent un DoT sur la même cible.
					if fx["type"] == "dot" and fy["type"] == "dot" and t in fy["cibles"]:
						mods["dot"]["%s|%d|%s" % [x, fx["index"], t]] = EMBRASEMENT_TOURS
						mods["dot"]["%s|%d|%s" % [y, fy["index"], t]] = EMBRASEMENT_TOURS
						_noter(liste, vues, "Embrasement", p_camp, [x, y], t)
					# Bastion : une barrière sur un allié, un soin sur le même allié.
					if fx["type"] == "barriere" and fy["type"] == "soin" and t in fy["cibles"]:
						mods["barriere"]["%s|%d|%s" % [x, fx["index"], t]] = BASTION_BARRIERE
						_noter(liste, vues, "Bastion", p_camp, [x, y], t)
				# Harmonie : un Renfort sur un allié, des dégâts directs par l'autre.
				if fx["type"] == "renfort" and fy["type"] == "degats" and not fx["cibles"].is_empty():
					for t in fx["cibles"]:
						mods["renfort"]["%s|%d|%s" % [x, fx["index"], t]] = HARMONIE_TOURS
					_noter(liste, vues, "Harmonie", p_camp, [x, y], fx["cibles"][0])


## Les Synergies qu'un perso peut compléter ce tour-ci avec l'action déjà déclarée de son allié : pour chacune de ses
## actions légales et chaque cible possible, les noms des Synergies qu'elle déclencherait. Rend [{ action, noms }],
## l'action avec ses cibles. Sert à l'affichage (les cases dorées, les ennemis qui préparent une Synergie) ; la règle
## reste synergies().
static func synergies_possibles(e: EtatCombat, id: String, action_alliee: Dictionary) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	if action_alliee.is_empty():
		return out
	var allie := str(action_alliee["perso"])
	var validee := valider(e, allie, action_alliee)
	if validee.is_empty():
		return out
	var ennemis: Array[String] = e.ennemis_vivants(id)
	if provocateur(e, id) != "":
		ennemis = [provocateur(e, id)]
	for a in actions_legales(e, id):
		for ce in ennemis:
			for ca in e.allies_vivants(id):
				var essai := a.duplicate()
				essai["cible_ennemie"] = ce
				essai["cible_alliee"] = ca
				var noms: Array[String] = []
				for s in synergies(e, {id: essai, allie: validee})["liste"]:
					noms.append(str(s["nom"]))
				if not noms.is_empty():
					out.append({"action": essai, "noms": noms})
	return out


static func _effets_cibles(e: EtatCombat, a: Dictionary) -> Array:
	var out: Array = []
	var effets: Array = noeud_de(e, a)["effets"]
	for i in range(effets.size()):
		var ef: Dictionary = effets[i]
		out.append({"index": i, "type": ef["type"], "nom": ef.get("nom", ""), "cible": ef["cible"], "cibles": cibles(e, a, str(ef["cible"]))})
	return out


## Une Synergie n'est notée qu'une fois par paire (et par camp), quel que soit le sens.
static func _noter(liste: Array, vues: Dictionary, nom: String, p_camp: String, acteurs: Array, cible: String) -> void:
	var paire := [str(acteurs[0]), str(acteurs[1])]
	paire.sort()
	var cle := "%s|%s|%s|%s" % [nom, p_camp, paire[0], paire[1]]
	if vues.has(cle):
		return
	vues[cle] = true
	liste.append({"nom": nom, "camp": p_camp, "acteurs": acteurs.duplicate(), "cible": cible})


# --- Résolution d'un tour (sections 5.3 et 5.4) --------------------------------------

## Résout le tour en cours : validation des déclarations (perso -> action ; absente : le moyeu ; Étourdi : ignorée),
## Synergies, phases 2a à 2i, puis la phase 0 du tour suivant si le combat continue. Rend un nouvel état ; celui
## reçu n'est pas modifié.
static func resoudre_tour(etat: EtatCombat, declarations: Dictionary) -> EtatCombat:
	var e := etat.copie()
	e.journal = []
	if e.fini:
		return e
	var actions := {}
	for id in e.ordre:
		var a := valider(e, id, declarations.get(id, {}))
		if not a.is_empty():
			actions[id] = a
			e.perso(id)["cible_ennemie"] = a["cible_ennemie"]
			e.perso(id)["cible_alliee"] = a["cible_alliee"]
	e.actions_jouees = actions.duplicate(true)
	# L'instantané de la fin de la phase 0 : ce que valent les états de chacun pour tout le tour.
	var instant := {}
	var pv_debut := {"a": [0, 0], "b": [0, 0]}
	for id in e.ordre:
		instant[id] = {"renfort": e.valeur_etat(id, "renfort"), "affaiblissement": e.valeur_etat(id, "affaiblissement"),
			"desarme": e.a_etat(id, "desarme"), "aveugle": e.a_etat(id, "aveugle"), "poison": e.a_etat(id, "poison"),
			"brulure": e.a_etat(id, "brulure")}
		pv_debut[e.camp(id)][0] += int(e.perso(id)["pv"])
		pv_debut[e.camp(id)][1] += int(e.fiche(id)["pv_max"])
	var syn := synergies(e, actions)
	for s in syn["liste"]:
		_ev(e, "2a", str(s["acteurs"][0]), "", str(s["cible"]), "synergie", 0, 0, str(s["nom"]))
	var mods: Dictionary = syn["mods"]
	for phase in ["2a", "2b", "2c", "2d", "2e"]:
		for id in e.ordre:
			if not actions.has(id):
				continue
			var a: Dictionary = actions[id]
			var effets: Array = noeud_de(e, a)["effets"]
			for i in range(effets.size()):
				var ef: Dictionary = effets[i]
				if PHASE_EFFET[ef["type"]] != phase:
					continue
				if instant[id]["aveugle"] and ef["cible"] == "un_ennemi":
					# Aveuglé : ses effets sur un seul ennemi ne font rien (le nœud est joué quand même).
					if ef["type"] == "degats":
						_ev(e, phase, id, id_noeud(e, a), str(a["cible_ennemie"]), "degats", 0, 0, "aveugle")
					continue
				_appliquer(e, a, i, ef, phase, instant, mods)
	_ticks(e)
	_durees(e)
	_compter_soins(e, actions)
	_jalons(e, actions)
	_ko_et_fin(e, pv_debut)
	if not e.fini:
		e.tour += 1
	return e


## Un effet d'une action, dans sa phase.
static func _appliquer(e: EtatCombat, a: Dictionary, index: int, ef: Dictionary, phase: String, instant: Dictionary, mods: Dictionary) -> void:
	var id := str(a["perso"])
	var nid := id_noeud(e, a)
	var voie := int(a["voie"])
	var rang := int(a["rang"]) if str(a["source"]) == "voie" else 0
	var forces := 1.0 + float(instant[id]["renfort"]) - float(instant[id]["affaiblissement"])
	var touches := cibles(e, a, str(ef["cible"]))
	match str(ef["type"]):
		"dissipe":
			for t in touches:
				var retires: Array[String] = []
				for nom in e.perso(t)["etats"].keys():
					if bool(e.defs_etats[nom]["dissipable"]):
						e.perso(t)["etats"].erase(nom)
						retires.append(str(nom))
				if int(e.perso(t)["barriere"]) > 0:
					e.perso(t)["barriere"] = 0
					retires.append("barriere")
				_ev(e, phase, id, nid, t, "dissipe", retires.size(), 0, ",".join(retires))
		"purge":
			for t in touches:
				var retires: Array[String] = []
				for nom in e.perso(t)["etats"].keys():
					if bool(e.defs_etats[nom]["negatif"]) and bool(e.defs_etats[nom]["purgeable"]):
						e.perso(t)["etats"].erase(nom)
						retires.append(str(nom))
				_ev(e, phase, id, nid, t, "purge", retires.size(), 0, ",".join(retires))
		"degats":
			var base := valeur(e, id, voie, rang, float(ef["valeur"]), "degats") * maxf(0.0, forces) * mort_subite(e)
			if instant[id]["desarme"]:
				base *= DESARME
			for t in touches:
				var montant := plancher(base * float(mods["degats"].get("%s|%d|%s" % [id, index, t], 1.0)))
				# Férocité : plus fort sur un ennemi déjà bas.
				if porte(e, id, "ferocite") and e.pv_pourcent(t) < FEROCITE_SEUIL:
					montant = plancher(float(montant) * (1.0 + valeur_trait(e, "ferocite")))
				_blesser(e, phase, id, nid, t, montant, false, "degats")
				# Soif : une part du dégât revient en soin.
				if porte(e, id, "soif") and montant > 0 and e.vivant(id):
					_soigner(e, phase, id, nid, id, plancher(float(montant) * valeur_trait(e, "soif")), "soin", "soif")
		"soin":
			var base := valeur(e, id, voie, rang, float(ef["valeur"]), "soin") * maxf(0.0, forces) * usure_soins(e, id)
			for t in touches:
				var montant := plancher(base)
				if instant[t]["poison"]:
					montant = plancher(float(montant) * POISON_SOINS)
				_soigner(e, phase, id, nid, t, montant, "soin")
		"barriere":
			var base := valeur(e, id, voie, rang, float(ef["valeur"]), "barriere") * maxf(0.0, forces)
			for t in touches:
				var montant := plancher(base * float(mods["barriere"].get("%s|%d|%s" % [id, index, t], 1.0)))
				if instant[t]["brulure"]:
					montant = plancher(float(montant) * BRULURE_BARRIERES)
				var p := e.perso(t)
				if montant > int(p["barriere"]):
					p["barriere"] = montant
					p["barrier_until"] = e.tour + 2
					_ev(e, phase, id, nid, t, "barriere", montant)
				else:
					_ev(e, phase, id, nid, t, "barriere", 0, 0, "plus petite")
		"etat":
			for t in touches:
				_poser(e, t, str(ef["nom"]), int(ef["tours"]), 0.0, id)
				_ev(e, phase, id, nid, t, "etat", int(ef["tours"]), 0, str(ef["nom"]))
		"dot":
			var par_tour := plancher(valeur(e, id, voie, rang, float(ef["par_tour"]), "dot") * maxf(0.0, forces))
			for t in touches:
				var tours := int(ef["tours"]) + int(mods["dot"].get("%s|%d|%s" % [id, index, t], 0))
				if porte(e, id, "persistance"):
					tours += 1
				_poser(e, t, str(ef["sous_type"]), tours, float(par_tour), id)
				_ev(e, phase, id, nid, t, "etat", par_tour, 0, "%s:%d" % [ef["sous_type"], tours])
		"gardien":
			var par_tour := plancher(valeur(e, id, voie, rang, float(ef["par_tour"]), "gardien") * maxf(0.0, forces) * usure_soins(e, id))
			for t in touches:
				_poser(e, t, "gardien", int(ef["tours"]), float(par_tour), id)
				_ev(e, phase, id, nid, t, "etat", par_tour, 0, "gardien:%d" % int(ef["tours"]))
		"renfort", "affaiblissement":
			var fraction := pourcent(e, id, voie, rang, float(ef["pourcent"]))
			for t in touches:
				var tours := int(ef["tours"])
				if ef["type"] == "renfort":
					tours += int(mods["renfort"].get("%s|%d|%s" % [id, index, t], 0))
				_poser(e, t, str(ef["type"]), tours, fraction, id)
				_ev(e, phase, id, nid, t, "etat", roundi(fraction * 100.0), 0, "%s:%d" % [ef["type"], tours])
		"egare":
			for t in touches:
				var p := e.perso(t)
				for v in range(p["jalons"].size()):
					p["jalons"][v] = maxi(0, int(p["jalons"][v]) - 1)
					p["inactivite"][v] = 0
				_ev(e, phase, id, nid, t, "egare")


## Une valeur numérique d'un nœud (dégâts, soin, barrière, DoT, Gardien) : × M(niveau) × k de la classe × (éclats +
## équipement). type : le type de l'effet (« degats », « soin », « barriere », « dot », « gardien »), pour la ligne
## d'équipement qui s'y applique ; avec le rang, les lignes Clés et Ouvertures (engine/equipement.gd, bonus).
static func valeur(e: EtatCombat, id: String, voie: int, rang: int, base: float, type: String = "") -> float:
	var fiche := e.fiche(id)
	var bonus := 0.0 if rang == 0 else float(fiche["bonus"][voie][rang - 1])
	return base * multiplicateur_niveau(e) * float(fiche["k"]) * (1.0 + bonus + Equipement.bonus(fiche.get("mods", {}), rang, type))


## Un pourcentage d'un nœud (Renfort, Affaiblissement), en fraction : × éclats seulement (ni M ni k).
static func pourcent(e: EtatCombat, id: String, voie: int, rang: int, pc: float) -> float:
	var fiche := e.fiche(id)
	var bonus := 0.0 if rang == 0 else float(fiche["bonus"][voie][rang - 1])
	return pc / 100.0 * (1.0 + bonus)


## À la Tour, les soins d'un monstre s'affaiblissent à chaque usage (docs/GDD_V2.md, § 4.1 : pas de limite de tours en
## PvE, et tout combat reste gagnable) : × tour_soins_usure (data/rules.json) puissance le nombre de ses actions de soin
## déjà jouées (Soin direct ou Gardien). 1 partout ailleurs.
static func usure_soins(e: EtatCombat, id: String) -> float:
	if e.mode != "tour" or e.camp(id) != "b":
		return 1.0
	return pow(float(e.regles["tour_soins_usure"]), float(e.perso(id).get("soins", 0)))


## Après un tour à la Tour : chaque monstre qui a joué une action de soin en compte une de plus.
static func _compter_soins(e: EtatCombat, actions: Dictionary) -> void:
	if e.mode != "tour":
		return
	for id in actions:
		if e.camp(id) != "b":
			continue
		for ef in noeud_de(e, actions[id])["effets"]:
			if ef["type"] in ["soin", "gardien"]:
				e.perso(id)["soins"] = int(e.perso(id).get("soins", 0)) + 1
				break


## Des dégâts sur un perso : la barrière absorbe d'abord (sauf pour le Saignement), le reste va aux PV.
static func _blesser(e: EtatCombat, phase: String, acteur: String, nid: String, t: String, montant: int, ignore_barriere: bool, type: String, detail: String = "") -> void:
	var p := e.perso(t)
	var absorbe := 0 if ignore_barriere else mini(int(p["barriere"]), montant)
	p["barriere"] = int(p["barriere"]) - absorbe
	p["pv"] = int(p["pv"]) - (montant - absorbe)
	_ev(e, phase, acteur, nid, t, type, montant, absorbe, detail)
	# Épines : un dégât direct subi en renvoie une part à l'attaquant (jamais en chaîne).
	if type == "degats" and acteur != t and acteur != "" and montant > 0 and porte(e, t, "epines") and e.vivant(acteur):
		_blesser(e, phase, t, "", acteur, plancher(float(montant) * valeur_trait(e, "epines")), false, "epines")


static func _soigner(e: EtatCombat, phase: String, acteur: String, nid: String, t: String, montant: int, type: String, detail: String = "") -> void:
	var p := e.perso(t)
	# Grâce : les soins reçus sont plus grands.
	if porte(e, t, "grace"):
		montant = plancher(float(montant) * (1.0 + valeur_trait(e, "grace")))
	var avant := int(p["pv"])
	p["pv"] = mini(avant + montant, int(e.fiche(t)["pv_max"]))
	_ev(e, phase, acteur, nid, t, type, int(p["pv"]) - avant, 0, detail)


## Pose un état (2e) : actif à partir du tour suivant, pour `duree` tours. Déjà présent : la fin la plus lointaine et
## la valeur la plus forte sont gardées, jamais deux instances.
static func _poser(e: EtatCombat, t: String, nom: String, duree: int, val: float, source: String) -> void:
	var etats: Dictionary = e.perso(t)["etats"]
	# Endurance : un état négatif subi dure un tour de moins, jamais moins d'un.
	if porte(e, t, "endurance") and bool(e.defs_etats.get(nom, {}).get("negatif", false)):
		duree = maxi(1, duree - 1)
	var fin := e.tour + duree
	if etats.has(nom):
		var s: Dictionary = etats[nom]
		s["fin"] = maxi(int(s["fin"]), fin)
		s["valeur"] = maxf(float(s["valeur"]), val)
		s["source"] = source
	else:
		etats[nom] = {"debut": e.tour + 1, "fin": fin, "valeur": val, "source": source}


## 2f : les DoT et les Gardiens posés avant ce tour, sur les persos vivants.
static func _ticks(e: EtatCombat) -> void:
	var ms := mort_subite(e)
	for id in e.ordre:
		if not e.vivant(id):
			continue
		for nom in ORDRE_DOTS:
			if e.a_etat(id, nom):
				var s: Dictionary = e.perso(id)["etats"][nom]
				_blesser(e, "2f", str(s["source"]), "", id, plancher(float(s["valeur"]) * ms), nom == "saignement", "tick", nom)
		if e.a_etat(id, "gardien"):
			var soin := int(e.perso(id)["etats"]["gardien"]["valeur"])
			if e.a_etat(id, "poison"):
				soin = plancher(float(soin) * POISON_SOINS)
			_soigner(e, "2f", str(e.perso(id)["etats"]["gardien"]["source"]), "", id, soin, "tick", "gardien")


## 2g : les états posés avant ce tour arrivés à leur fin disparaissent ; la barrière expire à son tour limite.
static func _durees(e: EtatCombat) -> void:
	for id in e.ordre:
		var p := e.perso(id)
		for nom in p["etats"].keys():
			var s: Dictionary = p["etats"][nom]
			if int(s["debut"]) <= e.tour and int(s["fin"]) <= e.tour:
				p["etats"].erase(nom)
				_ev(e, "2g", id, "", id, "expire", 0, 0, str(nom))
		if int(p["barriere"]) > 0 and e.tour >= int(p["barrier_until"]):
			p["barriere"] = 0
			_ev(e, "2g", id, "", id, "expire", 0, 0, "barriere")


## 2h : extinction du nœud joué, jalons, dernière voie, inactivité et refroidissement.
static func _jalons(e: EtatCombat, actions: Dictionary) -> void:
	var extinction := int(e.regles["extinction"])
	var refroidissement := int(e.regles["refroidissement"])
	for id in e.ordre:
		if not e.vivant(id):
			continue
		var p := e.perso(id)
		var a: Dictionary = actions.get(id, {})
		var jouee := -1
		# Ancrage : ses voies refroidissent un tour plus tard.
		var refroidissement_id := refroidissement + (1 if porte(e, id, "ancrage") else 0)
		if not a.is_empty() and str(a["source"]) == "voie":
			jouee = int(a["voie"])
			var rang := int(a["rang"])
			# Fulgurance : une Clé s'éteint un tour de moins.
			var extinction_noeud := extinction - (1 if rang == 4 and porte(e, id, "fulgurance") else 0)
			p["spent_until"][jouee][rang - 1] = e.tour + extinction_noeud + 1
			p["jalons"][jouee] = rang if rang < 4 else 0
			p["last_voie"] = jouee if rang < 4 else -1
			_ev(e, "2h", id, id_noeud(e, a), id, "jalon", int(p["jalons"][jouee]), 0, str(e.fiche(id)["voies"][jouee]["id"]))
		for w in range(p["jalons"].size()):
			if w == jouee:
				p["inactivite"][w] = 0
			else:
				p["inactivite"][w] = int(p["inactivite"][w]) + 1
			if int(p["inactivite"][w]) >= refroidissement_id:
				p["inactivite"][w] = 0
				if int(p["jalons"][w]) > 0:
					p["jalons"][w] = int(p["jalons"][w]) - 1
					_ev(e, "2h", id, "", id, "refroidissement", int(p["jalons"][w]), 0, str(e.fiche(id)["voies"][w]["id"]))


## 2i : KO, puis fin du combat. Deux camps KO au même tour : gagne celui qui avait le plus de PV en début de tour
## (somme des PV sur somme des PV max) ; égalité parfaite : le camp A.
static func _ko_et_fin(e: EtatCombat, pv_debut: Dictionary) -> void:
	var tombes: Array[String] = []
	for id in e.ordre:
		var p := e.perso(id)
		# Ténacité : la première fois, il reste à 1 PV.
		if not bool(p["ko"]) and int(p["pv"]) <= 0 and porte(e, id, "tenacite") and not bool(p.get("tenacite", false)):
			p["tenacite"] = true
			p["pv"] = 1
			_ev(e, "2i", id, "", id, "tenacite")
		if not bool(p["ko"]) and int(p["pv"]) <= 0:
			p["ko"] = true
			p["pv"] = 0
			p["etats"] = {}
			p["barriere"] = 0
			tombes.append(id)
			_ev(e, "2i", id, "", id, "ko")
	if not tombes.is_empty():
		# Provoqué tombe avec son provocateur.
		for id in e.ordre:
			var etats: Dictionary = e.perso(id)["etats"]
			if etats.has("provoque") and str(etats["provoque"]["source"]) in tombes:
				etats.erase("provoque")
	var a_tombe := e.vivants("a").is_empty()
	var b_tombe := e.vivants("b").is_empty()
	if not a_tombe and not b_tombe:
		return
	e.fini = true
	if a_tombe and b_tombe:
		var pa := float(pv_debut["a"][0]) / float(maxi(1, pv_debut["a"][1]))
		var pb := float(pv_debut["b"][0]) / float(maxi(1, pv_debut["b"][1]))
		e.vainqueur = "b" if pb > pa else "a"
	else:
		e.vainqueur = "b" if a_tombe else "a"
	_ev(e, "2i", "", "", "", "fin", 0, 0, e.vainqueur)


static func fini(e: EtatCombat) -> Dictionary:
	return {"fini": e.fini, "vainqueur": e.vainqueur}


static func _ev(e: EtatCombat, phase: String, acteur: String, nid: String, cible: String, type: String, val: int = 0, absorbe: int = 0, detail: String = "") -> void:
	e.journal.append({"tour": e.tour, "phase": phase, "acteur": acteur, "noeud": nid, "cible": cible, "type": type,
		"valeur": val, "absorbe": absorbe, "detail": detail})
