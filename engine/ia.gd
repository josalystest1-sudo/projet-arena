## L'IA du combat V2 (docs/SPEC-COMBAT-V2.md, section 10) : une seule, déterministe, pour l'acolyte (des deux camps),
## les Échos, les ennemis de la Tour et le simulateur. Elle fixe ses deux cibles du tour, donne un score à chaque action
## légale et joue la meilleure ; à égalité, la dernière de la liste (moyeu, voie 1, voie 2…). Aucun tirage. Module pur.
class_name IA
extends RefCounted

## Les chiffres du score (section 10.1).
const DOT_POIDS := 0.7
const GARDIEN_POIDS := 0.65
const GARDIEN_MARGE := 20.0
const BARRIERE_POIDS := 0.7
const DEGATS_PAR_ENNEMI := 55.0
const MENACE_REPONSE := 1.5
const REPONSES_A_UNE_MENACE := ["etourdi", "gele", "silencie", "enracine", "egare"]
const AFFAIBLISSEMENT_POIDS := 2.0
const DISSIPE_VALEUR := 50.0
const DISSIPE_BARRIERE_MIN := 50
const EGARE_BASE := 60.0
const EGARE_PAR_JALON := 60.0
const PURGE_PAR_ETAT := 50.0
const PROVOQUE_VALEUR := 40.0
const SYNERGIE_BONUS := 40.0
const PROGRESSION_PAR_RANG := 15.0
const CONTINUITE := 25.0
const MOYEU_PENALITE := 40.0
const VALEUR_MINIMALE := 10.0
const CIBLE_MENACE := 30.0
## Les effets qui font d'une action une action « de soutien » (soin, barrière, renfort…), retirée si elle ne sert à
## rien (valeur effective sous 10 : pas de soin à PV pleins).
const SOUTIEN := ["soin", "barriere", "gardien", "renfort", "purge"]


## Les déclarations de tous les persos joués par l'IA, dans l'ordre de la phase 1 : les acolytes d'abord (sans rien
## savoir), puis les autres (joueurs IA, Échos, ennemis de la Tour), qui voient les choix des acolytes.
## humains : les persos que l'IA ne joue pas.
static func declarer(e: EtatCombat, humains: Array = []) -> Dictionary:
	var decl := {}
	for id in e.ordre:
		if e.fiche(id)["place"] == "acolyte" and not id in humains:
			var a := choisir(e, id, {})
			if not a.is_empty():
				decl[id] = a
	var connues := decl.duplicate()
	for id in e.ordre:
		if e.fiche(id)["place"] != "acolyte" and not id in humains:
			var a := choisir(e, id, connues)
			if not a.is_empty():
				decl[id] = a
	return decl


## L'action d'un perso. declarations_connues : les actions déjà déclarées (celle de son acolyte, pour un joueur IA).
static func choisir(e: EtatCombat, id: String, declarations_connues: Dictionary = {}) -> Dictionary:
	var legales := Regles.actions_legales(e, id)
	if legales.is_empty():
		return {}
	var ce := cible_ennemie(e, id)
	var ca := cible_alliee(e, id)
	var allie := _declaration_alliee(e, id, declarations_connues)
	var meilleure: Dictionary = {}
	var meilleur := -INF
	for l in legales:
		var a := l.duplicate()
		a["cible_ennemie"] = ce
		a["cible_alliee"] = ca
		var s := score(e, a, allie, legales.size() > 1)
		if is_nan(s):
			continue
		if s >= meilleur:
			meilleur = s
			meilleure = a
	if meilleure.is_empty():
		meilleure = legales[0].duplicate()
		meilleure["cible_ennemie"] = ce
		meilleure["cible_alliee"] = ca
	return meilleure


## La cible ennemie de l'IA (section 10.2) : le provocateur s'il est Provoqué, sinon l'ennemi vivant qui maximise
## (PV manquants en %) × 100 + 30 s'il a une menace d'échéance 1 ; à égalité, le premier dans l'ordre.
static func cible_ennemie(e: EtatCombat, id: String) -> String:
	var forcee := Regles.provocateur(e, id)
	if forcee != "":
		return forcee
	var meilleure := ""
	var meilleur := -INF
	for t in e.ennemis_vivants(id):
		var v := (1.0 - e.pv_pourcent(t)) * 100.0 + (CIBLE_MENACE if a_menace_imminente(e, t) else 0.0)
		if v > meilleur:
			meilleur = v
			meilleure = t
	return meilleure


## La cible alliée de l'IA : l'allié vivant (soi compris) aux PV les plus bas en pourcentage.
static func cible_alliee(e: EtatCombat, id: String) -> String:
	return Regles.plus_bas(e, e.allies_vivants(id))


## Une menace d'échéance 1 qu'aucun état n'empêche déjà.
static func a_menace_imminente(e: EtatCombat, id: String) -> bool:
	for m in Regles.menaces(e, id):
		if int(m["echeance"]) == 1 and not bool(m["barre"]):
			return true
	return false


static func _declaration_alliee(e: EtatCombat, id: String, connues: Dictionary) -> Dictionary:
	for autre in connues:
		if autre != id and e.statique.has(autre) and e.camp(autre) == e.camp(id):
			return connues[autre]
	return {}


## Le score d'une action (section 10.1) : valeur offensive + valeur défensive + bonus de Synergie + progression −
## pénalité. NAN : action retirée (un soutien qui ne sert à rien).
static func score(e: EtatCombat, a: Dictionary, allie: Dictionary = {}, autres_legales: bool = true) -> float:
	var id := str(a["perso"])
	var noeud := Regles.noeud_de(e, a)
	var voie := int(a["voie"])
	var rang := int(a["rang"]) if str(a["source"]) == "voie" else 0
	var forces := maxf(0.0, 1.0 + e.valeur_etat(id, "renfort") - e.valeur_etat(id, "affaiblissement"))
	var aveugle := e.a_etat(id, "aveugle")
	var offensive := 0.0
	var defensive := 0.0
	var soutien_seul := true
	for ef in noeud["effets"]:
		var type := str(ef["type"])
		if not type in SOUTIEN:
			soutien_seul = false
		if aveugle and ef["cible"] == "un_ennemi":
			continue
		var touches := Regles.cibles(e, a, str(ef["cible"]))
		match type:
			"degats":
				var montant := Regles.valeur(e, id, voie, rang, float(ef["valeur"])) * forces * Regles.mort_subite(e)
				if e.a_etat(id, "desarme"):
					montant *= Regles.DESARME
				var m := Regles.plancher(montant)
				for t in touches:
					offensive += minf(maxf(0.0, float(m - int(e.perso(t)["barriere"]))), float(e.perso(t)["pv"]))
			"dot":
				var total := float(Regles.plancher(Regles.valeur(e, id, voie, rang, float(ef["par_tour"])) * forces) * int(ef["tours"]))
				for t in touches:
					offensive += minf(total * DOT_POIDS, float(e.perso(t)["pv"]))
			"etat":
				var nom := str(ef["nom"])
				if nom == "provoque":
					# Provoquer protège son allié s'il est plus bas (valeur défensive).
					var autre := _autre_allie(e, id)
					if autre != "" and e.pv_pourcent(id) > e.pv_pourcent(autre):
						defensive += PROVOQUE_VALEUR * touches.size()
					continue
				var base := float(e.regles["couts"][nom]) * float(ef["tours"])
				for t in touches:
					offensive += base * (MENACE_REPONSE if nom in REPONSES_A_UNE_MENACE and a_menace_imminente(e, t) else 1.0)
			"egare":
				for t in touches:
					var jalons := 0
					for j in e.perso(t)["jalons"]:
						if int(j) >= 2:
							jalons += 1
					offensive += (EGARE_BASE + EGARE_PAR_JALON * jalons) * (MENACE_REPONSE if a_menace_imminente(e, t) else 1.0)
			"affaiblissement":
				offensive += Regles.pourcent(e, id, voie, rang, float(ef["pourcent"])) * 100.0 * AFFAIBLISSEMENT_POIDS * touches.size()
			"dissipe":
				for t in touches:
					if int(e.perso(t)["barriere"]) >= DISSIPE_BARRIERE_MIN or e.perso(t)["etats"].has("renfort"):
						offensive += DISSIPE_VALEUR
			"soin":
				var soin := Regles.plancher(Regles.valeur(e, id, voie, rang, float(ef["valeur"])) * forces)
				for t in touches:
					var s := soin
					if e.a_etat(t, "poison"):
						s = Regles.plancher(float(s) * Regles.POISON_SOINS)
					defensive += minf(float(s), float(int(e.fiche(t)["pv_max"]) - int(e.perso(t)["pv"])))
			"gardien":
				var total := float(Regles.plancher(Regles.valeur(e, id, voie, rang, float(ef["par_tour"])) * forces) * int(ef["tours"]))
				for t in touches:
					defensive += minf(total * GARDIEN_POIDS, float(int(e.fiche(t)["pv_max"]) - int(e.perso(t)["pv"])) + GARDIEN_MARGE)
			"barriere":
				var b := Regles.plancher(Regles.valeur(e, id, voie, rang, float(ef["valeur"])) * forces)
				var potentiels := degats_potentiels(e, id)
				for t in touches:
					var nouvelle := b
					if e.a_etat(t, "brulure"):
						nouvelle = Regles.plancher(float(nouvelle) * Regles.BRULURE_BARRIERES)
					var gain := maxi(0, nouvelle - int(e.perso(t)["barriere"]))
					defensive += minf(float(gain), potentiels) * BARRIERE_POIDS
			"renfort":
				var pc := Regles.pourcent(e, id, voie, rang, float(ef["pourcent"])) * 100.0
				for t in touches:
					defensive += pc * (2.0 if _a_gros_noeud_proche(e, t) else 1.0)
			"purge":
				for t in touches:
					var n := 0
					for nom in e.perso(t)["etats"]:
						if bool(e.defs_etats[nom]["negatif"]) and bool(e.defs_etats[nom]["purgeable"]):
							n += 1
					defensive += PURGE_PAR_ETAT * n
	if soutien_seul and defensive < VALEUR_MINIMALE:
		return NAN
	var total := offensive + defensive
	if not allie.is_empty() and _fait_synergie(e, a, allie):
		total += SYNERGIE_BONUS
	if rang > 0:
		total += PROGRESSION_PAR_RANG * float(rang)
		if voie == int(e.perso(id)["last_voie"]):
			total += CONTINUITE
	elif autres_legales:
		total -= MOYEU_PENALITE
	return total


## Les dégâts qui menacent un camp (pour la valeur d'une barrière) : le budget des menaces d'échéance 1 des ennemis
## (leurs nœuds qui visent des ennemis), plus 55 par ennemi vivant.
static func degats_potentiels(e: EtatCombat, id: String) -> float:
	var total := 0.0
	for t in e.ennemis_vivants(id):
		total += DEGATS_PAR_ENNEMI
		for m in Regles.menaces(e, t):
			if int(m["echeance"]) != 1 or bool(m["barre"]):
				continue
			var n := e.noeud(t, int(m["voie"]), int(m["rang"]))
			for ef in n["effets"]:
				if ef["cible"] in ["un_ennemi", "tous_les_ennemis"]:
					total += float(m["budget"])
					break
	return total


## Un allié renforcé qui a une Clé ou un N3 d'échéance ≤ 2 vaut le double.
static func _a_gros_noeud_proche(e: EtatCombat, id: String) -> bool:
	return not Regles.menaces(e, id).is_empty()


static func _autre_allie(e: EtatCombat, id: String) -> String:
	for autre in e.allies_vivants(id):
		if autre != id:
			return autre
	return ""


## L'action ferait-elle une Synergie avec celle, déjà déclarée, de l'allié ?
static func _fait_synergie(e: EtatCombat, a: Dictionary, allie: Dictionary) -> bool:
	var actions := {str(a["perso"]): a, str(allie["perso"]): allie}
	return not Regles.synergies(e, actions)["liste"].is_empty()
