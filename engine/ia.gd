## L'IA du combat V2 (docs/SPEC-COMBAT-V2.md, section 10) : une seule, déterministe, pour l'acolyte (des deux camps),
## les Échos (d'un trio, ou d'un joueur absent), les ennemis de la Tour et le simulateur. Elle fixe ses deux cibles
## du tour, donne un score à chaque action légale et joue la meilleure ; à égalité, la dernière de la liste (moyeu,
## voie 1, voie 2…). Aucun tirage. Module pur.
## Les règles de bon sens (docs/GDD_V2.md, § 4.5 ; docs/PLAN.md, PR 1.2) s'ajoutent au score : achever un ennemi que les
## coups annoncés par les alliés (et ses dégâts sur la durée) laissent à portée, ne pas frapper un ennemi qu'ils abattent
## déjà, ne pas gaspiller une Clé, ne poser une barrière que sur un allié que les ennemis viseront (journal du combat V2).
class_name IA
extends RefCounted

## Les règles de bon sens. false : l'IA de la section 10 seule (le simulateur mesure ce qu'elles changent).
static var bon_sens := true
## Le bonus d'un coup qui achève un ennemi ce tour-ci, avec les coups annoncés par les alliés.
const ACHEVER := 120.0
## Une Clé dont moins de cette part de la valeur sert (dégâts absorbés ou perdus sur un ennemi déjà abattu, soin ou
## barrière en trop) perd son bonus de progression ; de même une Clé qui achève un ennemi qu'un coup moins cher achève
## aussi.
const CLE_UTILE := 0.5

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
## savoir) ; puis les Échos d'un trio, dans l'ordre du camp, chacun en connaissant les annonces déjà faites dans son camp
## (le premier ne sait rien, le second connaît le premier : docs/GDD_V2.md, § 4.3) ; puis les autres (joueurs IA,
## ennemis de la Tour), qui voient toutes ces annonces. humains : les persos que l'IA ne joue pas.
static func declarer(e: EtatCombat, humains: Array = []) -> Dictionary:
	var decl := {}
	var memoire := {}
	for id in e.ordre:
		if e.fiche(id)["place"] == "acolyte" and not id in humains:
			var a := choisir(e, id, {}, memoire)
			if not a.is_empty():
				decl[id] = a
	for id in e.ordre:
		if e.fiche(id)["place"] == "echo" and not id in humains:
			var a := choisir(e, id, decl.duplicate(), memoire)
			if not a.is_empty():
				decl[id] = a
	var connues := decl.duplicate()
	for id in e.ordre:
		if not e.fiche(id)["place"] in ["acolyte", "echo"] and not id in humains:
			var a := choisir(e, id, connues, memoire)
			if not a.is_empty():
				decl[id] = a
	return decl


## L'action d'un perso. declarations_connues : les actions déjà déclarées (celle de son acolyte, pour un joueur IA ;
## celles des Échos qui ont annoncé avant lui, dans un trio).
## memoire : les menaces déjà calculées ce tour-ci (l'état ne change pas pendant la phase de déclaration).
static func choisir(e: EtatCombat, id: String, declarations_connues: Dictionary = {}, memoire: Dictionary = {}) -> Dictionary:
	var legales := Regles.actions_legales(e, id)
	if legales.is_empty():
		return {}
	var allies := _declarations_alliees(e, id, declarations_connues)
	var ce := cible_ennemie(e, id, memoire, allies, legales)
	var ca := cible_alliee(e, id)
	var meilleure: Dictionary = {}
	var meilleur := -INF
	for l in legales:
		var a := l.duplicate()
		a["cible_ennemie"] = ce
		a["cible_alliee"] = ca
		var s := score(e, a, allies, legales.size() > 1, memoire)
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
## (PV manquants en %) × 100 + 30 s'il a une menace d'échéance 1 ; à égalité, le premier dans l'ordre. Avec le bon sens
## (et ses actions légales) : parmi les ennemis qu'un de ses coups achève ce tour-ci avec ceux annoncés par ses alliés
## s'il y en a, sinon parmi ceux que ces coups annoncés n'abattent pas déjà.
static func cible_ennemie(e: EtatCombat, id: String, memoire: Dictionary = {}, allies: Array[Dictionary] = [], legales: Array[Dictionary] = []) -> String:
	var forcee := Regles.provocateur(e, id)
	if forcee != "":
		return forcee
	var ennemis := e.ennemis_vivants(id)
	if bon_sens and not legales.is_empty():
		var annonces := degats_annonces(e, allies)
		var a_portee := ennemis_a_portee(e, id, allies, legales)
		var debout: Array[String] = []
		for t in ennemis:
			if reste(e, t, annonces) > 0:
				debout.append(t)
		if not a_portee.is_empty():
			ennemis = a_portee
		elif not debout.is_empty():
			ennemis = debout
	var meilleure := ""
	var meilleur := -INF
	for t in ennemis:
		var v := (1.0 - e.pv_pourcent(t)) * 100.0 + (CIBLE_MENACE if a_menace_imminente(e, t, memoire) else 0.0)
		if v > meilleur:
			meilleur = v
			meilleure = t
	return meilleure


# --- Le bon sens : les coups annoncés, achever ----------------------------------------------

## Les dégâts directs qu'une action infligera à chaque ennemi touché, avant sa barrière (Renfort, Affaiblissement,
## Désarmé, mort subite ; rien sur un ennemi unique si l'attaquant est Aveuglé) : { cible -> montant }.
static func degats_prevus(e: EtatCombat, a: Dictionary) -> Dictionary:
	var out := {}
	var id := str(a["perso"])
	var voie := int(a["voie"])
	var rang := int(a["rang"]) if str(a["source"]) == "voie" else 0
	var forces := _forces(e, id)
	for ef in Regles.noeud_de(e, a)["effets"]:
		if str(ef["type"]) != "degats" or (e.a_etat(id, "aveugle") and ef["cible"] == "un_ennemi"):
			continue
		var m := _montant_degats(e, id, voie, rang, ef, forces)
		for t in Regles.cibles(e, a, str(ef["cible"])):
			out[t] = int(out.get(t, 0)) + m
	return out


## Les dégâts directs annoncés par des alliés, cumulés par ennemi.
static func degats_annonces(e: EtatCombat, allies: Array[Dictionary]) -> Dictionary:
	var out := {}
	for x in allies:
		var d := degats_prevus(e, x)
		for t in d:
			out[t] = int(out.get(t, 0)) + int(d[t])
	return out


## Ce qu'il reste à infliger à un ennemi pour l'abattre ce tour-ci, après les coups annoncés et ses dégâts sur la durée
## de ce tour (PV + barrière − les deux) ; 0 ou moins : il tombe déjà.
static func reste(e: EtatCombat, t: String, annonces: Dictionary) -> int:
	return int(e.perso(t)["pv"]) + int(e.perso(t)["barriere"]) - _deja_engage(e, t, annonces)


## Ce qu'un ennemi va déjà perdre ce tour-ci : les coups annoncés par les alliés, et ses DoT de la fin du tour (moins ce
## que son Gardien lui rend).
static func _deja_engage(e: EtatCombat, t: String, annonces: Dictionary) -> int:
	return int(annonces.get(t, 0)) + ticks_a_venir(e, t)


## Les dégâts sur la durée qu'un perso prendra à la fin de ce tour (phase 2f, mort subite comprise), moins ce que son
## Gardien lui rend.
static func ticks_a_venir(e: EtatCombat, t: String) -> int:
	var ms := Regles.mort_subite(e)
	var total := 0
	for nom in Regles.ORDRE_DOTS:
		if e.a_etat(t, nom):
			total += Regles.plancher(float(e.perso(t)["etats"][nom]["valeur"]) * ms)
	if e.a_etat(t, "gardien"):
		var soin := int(e.perso(t)["etats"]["gardien"]["valeur"])
		total -= Regles.plancher(float(soin) * Regles.POISON_SOINS) if e.a_etat(t, "poison") else soin
	return total


## Les dégâts qui menacent un allié (pour la valeur d'une barrière posée sur lui, avec le bon sens) : 55 et le budget des
## menaces d'échéance 1 de chaque ennemi qui le visera (sa cible prévue par la section 10.2, ou parce que l'action le
## provoque), et pour tous les ennemis, leurs menaces d'échéance 1 qui touchent tout le camp.
static func degats_sur(e: EtatCombat, t: String, memoire: Dictionary = {}, provoques: Array = []) -> float:
	var total := 0.0
	for x in e.ennemis_vivants(t):
		var vise := x in provoques or cible_ennemie(e, x, memoire) == t
		if vise:
			total += DEGATS_PAR_ENNEMI
		for m in menaces(e, x, memoire):
			if int(m["echeance"]) != 1 or bool(m["barre"]):
				continue
			for ef in e.noeud(x, int(m["voie"]), int(m["rang"]))["effets"]:
				if ef["cible"] == "tous_les_ennemis" or (vise and ef["cible"] == "un_ennemi"):
					total += float(m["budget"])
					break
	return total


## Les ennemis qu'une des actions légales d'un perso abat ce tour-ci, avec les coups annoncés par ses alliés (et qu'ils
## n'abattent pas déjà seuls). Provoqué : seulement le provocateur.
static func ennemis_a_portee(e: EtatCombat, id: String, allies: Array[Dictionary], legales: Array[Dictionary]) -> Array[String]:
	var annonces := degats_annonces(e, allies)
	var out: Array[String] = []
	var ennemis := e.ennemis_vivants(id)
	if Regles.provocateur(e, id) != "":
		ennemis = [Regles.provocateur(e, id)]
	for t in ennemis:
		var r := reste(e, t, annonces)
		if r <= 0:
			continue
		for l in legales:
			var essai := l.duplicate()
			essai["cible_ennemie"] = t
			if int(degats_prevus(e, essai).get(t, 0)) >= r:
				out.append(t)
				break
	return out


## Les déclarations qu'un perso connaît au moment de choisir (l'ordre de declarer) : rien pour un acolyte ; les Échos
## d'avant lui dans son camp pour un Écho ; toutes celles des acolytes et des Échos de son camp pour les autres.
static func annonces_connues(e: EtatCombat, id: String, decl: Dictionary) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var place := str(e.fiche(id)["place"])
	if place == "acolyte":
		return out
	for autre in e.ordre:
		if autre == id:
			if place == "echo":
				break
			continue
		if e.camp(autre) == e.camp(id) and decl.has(autre) and e.fiche(autre)["place"] in ["acolyte", "echo"]:
			out.append(decl[autre])
	return out


static func _forces(e: EtatCombat, id: String) -> float:
	return maxf(0.0, 1.0 + e.valeur_etat(id, "renfort") - e.valeur_etat(id, "affaiblissement"))


## Les dégâts directs d'un effet (arrondis comme à la résolution).
static func _montant_degats(e: EtatCombat, id: String, voie: int, rang: int, ef: Dictionary, forces: float) -> int:
	var montant := Regles.valeur(e, id, voie, rang, float(ef["valeur"])) * forces * Regles.mort_subite(e)
	if e.a_etat(id, "desarme"):
		montant *= Regles.DESARME
	return Regles.plancher(montant)


## Une Clé qui achève un ennemi qu'une action moins chère (de rang inférieur, ou le moyeu) achève aussi, avec les mêmes
## cibles.
static func _acheve_sans_cle(e: EtatCombat, a: Dictionary, tues: Array, annonces: Dictionary) -> bool:
	for l in Regles.actions_legales(e, str(a["perso"])):
		if l["source"] == "voie" and int(l["rang"]) == 4:
			continue
		var essai := l.duplicate()
		essai["cible_ennemie"] = a["cible_ennemie"]
		essai["cible_alliee"] = a["cible_alliee"]
		var d := degats_prevus(e, essai)
		for t in tues:
			if int(d.get(t, 0)) >= reste(e, t, annonces):
				return true
	return false


## La cible alliée de l'IA : l'allié vivant (soi compris) aux PV les plus bas en pourcentage.
static func cible_alliee(e: EtatCombat, id: String) -> String:
	return Regles.plus_bas(e, e.allies_vivants(id))


## Une menace d'échéance 1 qu'aucun état n'empêche déjà.
static func a_menace_imminente(e: EtatCombat, id: String, memoire: Dictionary = {}) -> bool:
	for m in menaces(e, id, memoire):
		if int(m["echeance"]) == 1 and not bool(m["barre"]):
			return true
	return false


## Les menaces d'un perso, gardées en mémoire pour le tour.
static func menaces(e: EtatCombat, id: String, memoire: Dictionary) -> Array:
	var cle := "m|" + id
	if not memoire.has(cle):
		memoire[cle] = Regles.menaces(e, id)
	return memoire[cle]


## Les actions déjà déclarées par les alliés d'un perso, dans l'ordre du camp.
static func _declarations_alliees(e: EtatCombat, id: String, connues: Dictionary) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for autre in e.ordre:
		if autre != id and connues.has(autre) and e.camp(autre) == e.camp(id):
			out.append(connues[autre])
	return out


## Le score d'une action (section 10.1) : valeur offensive + valeur défensive + bonus de Synergie + progression −
## pénalité. NAN : action retirée (un soutien qui ne sert à rien). Les montants (dégâts, soins, barrières, PV) sont
## ramenés au niveau 1 (divisés par M(niveau)), comme les chiffres fixes du score (la grille des états, Purge, les
## bonus) : le niveau ne fait que grossir les chiffres (section 3.3), l'IA joue donc pareil à tous les niveaux.
static func score(e: EtatCombat, a: Dictionary, allies: Array[Dictionary] = [], autres_legales: bool = true, memoire: Dictionary = {}) -> float:
	var id := str(a["perso"])
	var noeud := Regles.noeud_de(e, a)
	var voie := int(a["voie"])
	var rang := int(a["rang"]) if str(a["source"]) == "voie" else 0
	var forces := _forces(e, id)
	var aveugle := e.a_etat(id, "aveugle")
	var m_niveau := Regles.multiplicateur_niveau(e)
	var offensive := 0.0
	var defensive := 0.0
	var soutien_seul := true
	# Le bon sens : les coups déjà annoncés par les alliés, ce qui se perdrait, les ennemis que l'action achève.
	var annonces := degats_annonces(e, allies) if bon_sens else {}
	var perdu := 0.0
	var tues: Array[String] = []
	var provoques: Array = []
	if bon_sens:
		for ef in noeud["effets"]:
			if ef["type"] == "etat" and ef["nom"] == "provoque":
				provoques.append_array(Regles.cibles(e, a, str(ef["cible"])))
	for ef in noeud["effets"]:
		var type := str(ef["type"])
		if not type in SOUTIEN:
			soutien_seul = false
		if aveugle and ef["cible"] == "un_ennemi":
			continue
		var touches := Regles.cibles(e, a, str(ef["cible"]))
		match type:
			"degats":
				var m := _montant_degats(e, id, voie, rang, ef, forces)
				for t in touches:
					if not bon_sens:
						offensive += minf(maxf(0.0, float(m - int(e.perso(t)["barriere"]))), float(e.perso(t)["pv"])) / m_niveau
						continue
					# Après les coups annoncés et ses DoT : ce qui reste de sa barrière, puis de ses PV ; le reste est perdu.
					var ann := _deja_engage(e, t, annonces)
					var b := maxi(0, int(e.perso(t)["barriere"]) - ann)
					var pv := int(e.perso(t)["pv"]) - maxi(0, ann - int(e.perso(t)["barriere"]))
					var utile := minf(maxf(0.0, float(m - b)), maxf(0.0, float(pv)))
					offensive += utile / m_niveau
					perdu += (float(m) - utile) / m_niveau
					if pv > 0 and m - b >= pv:
						tues.append(t)
						offensive += ACHEVER
			"dot":
				# Les ticks sont multipliés par la mort subite (section 5.5), comme les dégâts directs : sans ça, deux
				# soutiens dont les seuls dégâts sont des DoT se purgeaient l'un l'autre sans fin.
				var total := float(Regles.plancher(Regles.valeur(e, id, voie, rang, float(ef["par_tour"])) * forces * Regles.mort_subite(e)) * int(ef["tours"]))
				for t in touches:
					offensive += minf(total * DOT_POIDS, float(e.perso(t)["pv"])) / m_niveau
			"etat":
				var nom := str(ef["nom"])
				if nom == "provoque":
					# Provoquer protège son allié s'il est plus bas (valeur défensive) ; dans un trio, le plus bas des deux.
					var autre := _autre_allie_le_plus_bas(e, id)
					if autre != "" and e.pv_pourcent(id) > e.pv_pourcent(autre):
						defensive += PROVOQUE_VALEUR * touches.size()
					continue
				var base := float(e.regles["couts"][nom]) * float(ef["tours"])
				for t in touches:
					offensive += base * (MENACE_REPONSE if nom in REPONSES_A_UNE_MENACE and a_menace_imminente(e, t, memoire) else 1.0)
			"egare":
				for t in touches:
					var jalons := 0
					for j in e.perso(t)["jalons"]:
						if int(j) >= 2:
							jalons += 1
					offensive += (EGARE_BASE + EGARE_PAR_JALON * jalons) * (MENACE_REPONSE if a_menace_imminente(e, t, memoire) else 1.0)
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
					var effectif := minf(float(s), float(int(e.fiche(t)["pv_max"]) - int(e.perso(t)["pv"])))
					defensive += effectif / m_niveau
					perdu += (float(s) - effectif) / m_niveau
			"gardien":
				var total := float(Regles.plancher(Regles.valeur(e, id, voie, rang, float(ef["par_tour"])) * forces) * int(ef["tours"]))
				for t in touches:
					defensive += minf(total * GARDIEN_POIDS / m_niveau, float(int(e.fiche(t)["pv_max"]) - int(e.perso(t)["pv"])) / m_niveau + GARDIEN_MARGE)
			"barriere":
				var b := Regles.plancher(Regles.valeur(e, id, voie, rang, float(ef["valeur"])) * forces)
				var potentiels := degats_potentiels(e, id, memoire)
				for t in touches:
					if bon_sens:
						# Seulement ce que les ennemis qui viseront cet allié peuvent lui faire (soi : ceux que l'action provoque aussi).
						potentiels = degats_sur(e, t, memoire, provoques if t == id else [])
					var nouvelle := b
					if e.a_etat(t, "brulure"):
						nouvelle = Regles.plancher(float(nouvelle) * Regles.BRULURE_BARRIERES)
					var gain := maxi(0, nouvelle - int(e.perso(t)["barriere"]))
					defensive += minf(float(gain) / m_niveau, potentiels) * BARRIERE_POIDS
					perdu += maxf(0.0, float(nouvelle) / m_niveau - minf(float(gain) / m_niveau, potentiels))
			"renfort":
				var pc := Regles.pourcent(e, id, voie, rang, float(ef["pourcent"])) * 100.0
				for t in touches:
					defensive += pc * (2.0 if not menaces(e, t, memoire).is_empty() else 1.0)
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
	if not allies.is_empty() and _fait_synergie(e, a, allies):
		total += SYNERGIE_BONUS
	# Une Clé gaspillée (la moitié de sa valeur se perd, ou un coup moins cher achève le même ennemi) perd son bonus de
	# progression : elle attend un meilleur tour.
	var cle_gaspillee := false
	if bon_sens and rang == 4:
		cle_gaspillee = (perdu > 0.0 and offensive + defensive < CLE_UTILE * (offensive + defensive + perdu)) \
			or (not tues.is_empty() and _acheve_sans_cle(e, a, tues, annonces))
	if rang > 0 and not cle_gaspillee:
		total += PROGRESSION_PAR_RANG * float(rang)
		if voie == int(e.perso(id)["last_voie"]):
			total += CONTINUITE
	elif autres_legales:
		total -= MOYEU_PENALITE
	return total


## Les dégâts qui menacent un camp (pour la valeur d'une barrière) : le budget des menaces d'échéance 1 des ennemis
## (leurs nœuds qui visent des ennemis), plus 55 par ennemi vivant.
static func degats_potentiels(e: EtatCombat, id: String, memoire: Dictionary = {}) -> float:
	var cle := "p|" + e.camp(id)
	if memoire.has(cle):
		return memoire[cle]
	var total := 0.0
	for t in e.ennemis_vivants(id):
		total += DEGATS_PAR_ENNEMI
		for m in menaces(e, t, memoire):
			if int(m["echeance"]) != 1 or bool(m["barre"]):
				continue
			var n := e.noeud(t, int(m["voie"]), int(m["rang"]))
			for ef in n["effets"]:
				if ef["cible"] in ["un_ennemi", "tous_les_ennemis"]:
					total += float(m["budget"])
					break
	memoire[cle] = total
	return total


## L'allié vivant (pas soi) aux PV les plus bas en pourcentage ; à égalité, le premier dans l'ordre.
static func _autre_allie_le_plus_bas(e: EtatCombat, id: String) -> String:
	var autres: Array[String] = []
	for autre in e.allies_vivants(id):
		if autre != id:
			autres.append(autre)
	return Regles.plus_bas(e, autres) if not autres.is_empty() else ""


## L'action ferait-elle une Synergie avec l'une des actions, déjà déclarées, de ses alliés ? (Une seule fois +40, même
## si elle en complète plusieurs ; une Synergie entre deux autres alliés ne compte pas.)
static func _fait_synergie(e: EtatCombat, a: Dictionary, allies: Array[Dictionary]) -> bool:
	var actions := {str(a["perso"]): a}
	for x in allies:
		actions[str(x["perso"])] = x
	for s in Regles.synergies(e, actions)["liste"]:
		if str(a["perso"]) in s["acteurs"]:
			return true
	return false
