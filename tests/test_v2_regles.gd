## Combat V2 : les règles du tour (docs/SPEC-COMBAT-V2.md, section 14, tests 11 à 36).
extends "res://tests/test_case.gd"


func _degats_de(e: EtatCombat, acteur: String) -> Array:
	var out: Array = []
	for ev in evenements(e, "degats"):
		if ev["acteur"] == acteur:
			out.append(ev["valeur"])
	return out


# 11. Le moyeu est toujours légal, sauf sous Étourdi.
func test_11_moyeu_toujours_legal_sauf_etourdi() -> void:
	var e := combat([destin("guerrier"), destin("pretre", 3)], [destin("mage"), destin("guerrier", 3)])
	for id in e.ordre:
		assert_eq(Regles.actions_legales(e, id)[0]["source"], "moyeu", id + " : le moyeu d'abord")
	assert_eq(voies_legales(e, "a1"), [[0, 1], [1, 1], [2, 1], [3, 1], [4, 1]], "tour 1 : les cinq ouvertures")
	assert_eq(voies_legales(e, "a2"), [[0, 1], [1, 1], [2, 1]], "l'acolyte : trois voies")
	for nom in ["gele", "silencie", "enracine", "aveugle", "desarme", "provoque", "egare", "saignement", "renfort", "affaiblissement"]:
		var e2 := e.copie()
		poser(e2, "a1", nom, 1, 0.1, "b1")
		assert_eq(Regles.actions_legales(e2, "a1")[0]["source"], "moyeu", "moyeu légal sous " + nom)
	poser(e, "a1", "etourdi")
	assert_true(Regles.actions_legales(e, "a1").is_empty(), "Étourdi : aucune action, pas même le moyeu")


# 12. Un nœud joué est éteint exactement 3 tours.
func test_12_un_noeud_joue_est_eteint_trois_tours() -> void:
	var e := duel_essai(essai([[[deg(10)]]]))
	e = tour(e, {"a1": jouer(e, "a1", 0)})
	assert_eq(int(e.perso("a1")["spent_until"][0][0]), 5, "joué au tour 1 : rejouable à partir du tour 5")
	e = tour(e)
	e = tour(e)
	assert_eq(int(e.perso("a1")["jalons"][0]), 0, "le jalon a refroidi : la voie repart de N1")
	assert_eq(e.tour, 4, "tour 4")
	assert_false([0, 1] in voies_legales(e, "a1"), "tour 4 : N1 encore éteint (3e tour)")
	e = tour(e)
	assert_true([0, 1] in voies_legales(e, "a1"), "tour 5 : N1 de nouveau jouable")


# 13. Jouer la Clé remet la voie à zéro.
func test_13_la_cle_remet_la_voie_a_zero() -> void:
	var e := duel_essai(essai([[[deg(10)], [deg(10)], [deg(10)], [deg(10)]]]))
	for r in range(3):
		e = tour(e, {"a1": jouer(e, "a1", 0)})
		assert_eq(int(e.perso("a1")["jalons"][0]), r + 1, "jalon après le rang %d" % (r + 1))
		assert_eq(int(e.perso("a1")["last_voie"]), 0, "dernière voie")
	e = tour(e, {"a1": jouer(e, "a1", 0)})
	assert_eq(e.actions_jouees["a1"]["rang"], 4, "la Clé a été jouée")
	assert_eq(int(e.perso("a1")["jalons"][0]), 0, "Clé : jalon 0")
	assert_eq(int(e.perso("a1")["last_voie"]), -1, "Clé : dernière voie vidée")
	assert_eq(int(e.perso("a1")["spent_until"][0][3]), 8, "Clé jouée au tour 4 : éteinte jusqu'au tour 8")


# 14. Un jalon refroidit après 2 tours sans jouer la voie ; le compteur repart de 0.
func test_14_refroidissement() -> void:
	var e := duel_essai(essai([[[deg(10)], [deg(10)]], [[deg(10)]]]))
	e = tour(e, {"a1": jouer(e, "a1", 0)})
	e = tour(e, {"a1": jouer(e, "a1", 0)})
	assert_eq(e.perso("a1")["jalons"], [2, 0], "deux nœuds joués")
	e = tour(e)
	assert_eq(e.perso("a1")["jalons"], [2, 0], "un tour sans la voie : rien")
	assert_eq(int(e.perso("a1")["inactivite"][0]), 1, "compteur à 1")
	e = tour(e)
	assert_eq(e.perso("a1")["jalons"], [1, 0], "deux tours sans la voie : le jalon recule")
	assert_eq(int(e.perso("a1")["inactivite"][0]), 0, "compteur remis à 0")
	assert_eq(evenements(e, "refroidissement").size(), 1, "un événement de refroidissement")
	e = tour(e, {"a1": jouer(e, "a1", 1)})
	assert_eq(e.perso("a1")["jalons"], [1, 1], "jouer une autre voie : un tour d'inactivité pour la première")
	e = tour(e)
	assert_eq(e.perso("a1")["jalons"], [0, 1], "deuxième tour : elle recule encore")


# 15. Égaré recule tous les jalons et ne touche pas aux extinctions.
func test_15_egare_recule_tous_les_jalons() -> void:
	var e := duel_essai(essai([[[deg(10)], [deg(10)], [deg(10)]], [[deg(10)]], [[deg(10)]]]), null, essai([[[egare()]]]))
	e.perso("a1")["jalons"] = [2, 1, 0]
	e.perso("a1")["spent_until"][0] = [4, 5, 0, 0]
	e.perso("a1")["last_voie"] = 0
	e = tour(e, {"b1": jouer(e, "b1", 0, "a1")})
	assert_eq(evenements(e, "egare", "a1").size(), 1, "Égaré posé")
	assert_eq(e.perso("a1")["jalons"], [1, 0, 0], "tous les jalons reculent d'un rang, jamais sous 0")
	assert_eq(e.perso("a1")["spent_until"][0], [4, 5, 0, 0], "les extinctions restent")
	assert_eq(int(e.perso("a1")["last_voie"]), 0, "dernière voie inchangée")
	assert_eq(e.perso("a1")["inactivite"], [1, 1, 1], "compteurs remis à 0 par Égaré, puis le moyeu joué")


# 16. Gelé : seul le moyeu est jouable.
func test_16_gele_seul_le_moyeu() -> void:
	var e := duel_essai(essai([[[deg(10)]], [[deg(10)]]]))
	poser(e, "a1", "gele")
	var legales := Regles.actions_legales(e, "a1")
	assert_eq(legales.size(), 1, "une seule action")
	assert_eq(legales[0]["source"], "moyeu", "le moyeu")
	e = tour(e, {"a1": Regles.action("a1", "voie", 0, 1)})
	assert_eq(e.actions_jouees["a1"]["source"], "moyeu", "un nœud déclaré sous Gelé devient le moyeu")


# 17. Silencié : aucune Clé.
func test_17_silencie_pas_de_cle() -> void:
	var e := duel_essai(essai([[[deg(10)], [deg(10)], [deg(10)], [deg(10)]], [[deg(10)]]]))
	e.perso("a1")["jalons"] = [3, 0]
	assert_eq(voies_legales(e, "a1"), [[0, 4], [1, 1]], "la Clé est jouable")
	poser(e, "a1", "silencie")
	assert_eq(voies_legales(e, "a1"), [[1, 1]], "Silencié : plus de Clé, le reste oui")


# 18. Enraciné : le moyeu ou la voie de la dernière action ; rien d'interdit sans dernière voie.
func test_18_enracine() -> void:
	var e := duel_essai(essai([[[deg(10)], [deg(10)]], [[deg(10)], [deg(10)]], [[deg(10)], [deg(10)]]]))
	e.perso("a1")["jalons"] = [1, 1, 0]
	e.perso("a1")["last_voie"] = 1
	poser(e, "a1", "enracine")
	assert_eq(voies_legales(e, "a1"), [[1, 2]], "seulement la suite de la dernière voie")
	assert_eq(Regles.actions_legales(e, "a1")[0]["source"], "moyeu", "et le moyeu")
	e.perso("a1")["last_voie"] = -1
	assert_eq(voies_legales(e, "a1"), [[0, 2], [1, 2], [2, 1]], "sans dernière voie, Enraciné n'interdit rien")


# 19. Aveuglé : 0 dégât sur un seul ennemi, les dégâts à tous restent.
func test_19_aveugle() -> void:
	var a1 := essai([[[deg(100)]], [[deg(100, "tous_les_ennemis")]]])
	var e := duel_essai(a1)
	poser(e, "a1", "aveugle")
	var e1 := tour(e, {"a1": jouer(e, "a1", 0, "b1")})
	assert_eq(_degats_de(e1, "a1"), [0], "un seul ennemi : rien")
	assert_eq(int(e1.perso("b1")["pv"]), 1000, "PV intacts")
	assert_eq(int(e1.perso("a1")["jalons"][0]), 1, "le nœud est quand même joué")
	var e2 := tour(e, {"a1": jouer(e, "a1", 1)})
	assert_eq(_degats_de(e2, "a1"), [100, 100], "tous les ennemis : intact")


# 20. Désarmé : dégâts directs ×0,5.
func test_20_desarme() -> void:
	var e := duel_essai(essai([[[deg(101)]]]))
	poser(e, "a1", "desarme")
	e = tour(e, {"a1": jouer(e, "a1", 0, "b1")})
	assert_eq(_degats_de(e, "a1"), [50], "101 × 0,5, arrondi à l'inférieur")


# 21. Provoqué force la cible.
func test_21_provoque_force_la_cible() -> void:
	var e := duel_essai(essai([[[deg(100)]]]))
	poser(e, "a1", "provoque", 1, 0.0, "b2")
	assert_eq(Regles.cible_ennemie(e, "a1"), "b2", "cible par défaut : le provocateur")
	e = tour(e, {"a1": jouer(e, "a1", 0, "b1")})
	assert_eq(e.actions_jouees["a1"]["cible_ennemie"], "b2", "la cible déclarée est remplacée par le provocateur")
	assert_eq(int(e.perso("b2")["pv"]), 900, "le provocateur prend les coups")
	assert_eq(int(e.perso("b1")["pv"]), 1000, "l'autre ennemi n'est pas touché")


# 22. Barrière, Saignement, Brûlure, Poison.
func test_22_barriere_saignement_brulure_poison() -> void:
	var e := duel_essai(essai([[[deg(100)]], [[soin(100)]]]), null, null, essai([[[barriere(100, "un_allie")]]]))
	var e1 := e.copie()
	e1.perso("b1")["barriere"] = 30
	e1.perso("b1")["barrier_until"] = e1.tour + 2
	e1 = tour(e1, {"a1": jouer(e1, "a1", 0, "b1")})
	assert_eq(evenements(e1, "degats", "b1")[0]["absorbe"], 30, "la barrière absorbe d'abord")
	assert_eq(int(e1.perso("b1")["pv"]), 930, "le reste va aux PV")
	assert_eq(int(e1.perso("b1")["barriere"]), 0, "barrière épuisée")
	var e2 := e.copie()
	e2.perso("b1")["barriere"] = 1000
	e2.perso("b1")["barrier_until"] = e2.tour + 2
	poser(e2, "b1", "saignement", 2, 20.0, "a1")
	e2 = tour(e2)
	assert_eq(int(e2.perso("b1")["pv"]), 980, "le Saignement passe la barrière")
	assert_eq(int(e2.perso("b1")["barriere"]), 1000, "et ne l'entame pas")
	var e3 := e.copie()
	poser(e3, "b1", "brulure", 2, 0.0, "a1")
	e3 = tour(e3, {"b2": jouer(e3, "b2", 0, "", "b1")})
	assert_eq(int(e3.perso("b1")["barriere"]), 50, "Brûlure : la barrière reçue ×0,5")
	var e4 := e.copie()
	e4.perso("a2")["pv"] = 500
	poser(e4, "a2", "poison", 2, 0.0, "b1")
	e4 = tour(e4, {"a1": jouer(e4, "a1", 1, "", "a2")})
	assert_eq(int(e4.perso("a2")["pv"]), 550, "Poison : le soin reçu ×0,5")


# 23. Un état posé ce tour-ci n'est actif qu'au tour suivant.
func test_23_etat_actif_au_tour_suivant() -> void:
	var e := duel_essai(essai([[[etat("gele", 1)]]]), essai([[[renfort(50)], [deg(100)]]]), essai([[[deg(10)], [deg(10)]]]))
	e = tour(e, {"a1": jouer(e, "a1", 0, "b1"), "b1": jouer(e, "b1", 0, "a1"), "a2": jouer(e, "a2", 0)})
	assert_eq(e.actions_jouees["b1"]["source"], "voie", "gelé ce tour-ci, il joue quand même son nœud")
	assert_eq(int(e.perso("b1")["jalons"][0]), 1, "et avance sur sa voie")
	assert_eq(Regles.actions_legales(e, "b1").size(), 1, "au tour suivant, seul le moyeu")
	e = tour(e, {"a2": jouer(e, "a2", 0, "b2")})
	assert_eq(_degats_de(e, "a2"), [150], "le Renfort posé au tour 1 joue au tour 2")
	assert_true(voies_legales(e, "b1").size() > 0, "au tour 3, Gelé est fini")


# 24. Étourdi dure exactement un tour.
func test_24_etourdi_un_tour() -> void:
	var e := duel_essai(essai([[[etat("etourdi", 1)]]]), null, essai([[[deg(10)]]]))
	e = tour(e, {"a1": jouer(e, "a1", 0, "b1")})
	assert_true(Regles.actions_legales(e, "b1").is_empty(), "tour 2 : aucune action")
	e = tour(e, {"b1": jouer(e, "b1", 0, "a1")})
	assert_false(e.actions_jouees.has("b1"), "sa déclaration est ignorée")
	assert_false(e.perso("b1")["etats"].has("etourdi"), "l'état a disparu à la fin du tour 2")
	assert_eq(voies_legales(e, "b1"), [[0, 1]], "tour 3 : il rejoue")


# 25. Pas de cumul : la durée la plus longue et la valeur la plus forte, une seule instance.
func test_25_pas_de_cumul() -> void:
	var e := duel_essai(essai([[[dot("saignement", 10, 3)], [dot("saignement", 20, 1)], [dot("saignement", 5, 5)]]]))
	e = tour(e, {"a1": jouer(e, "a1", 0, "b1")})
	assert_eq(int(e.perso("b1")["etats"]["saignement"]["fin"]), 4, "posé au tour 1 pour 3 tours : jusqu'au tour 4")
	e = tour(e, {"a1": jouer(e, "a1", 0, "b1")})
	var s: Dictionary = e.perso("b1")["etats"]["saignement"]
	assert_eq(int(s["fin"]), 4, "la durée la plus longue est gardée")
	assert_eq(int(s["valeur"]), 20, "la valeur la plus forte est gardée")
	e = tour(e, {"a1": jouer(e, "a1", 0, "b1")})
	s = e.perso("b1")["etats"]["saignement"]
	assert_eq(int(s["fin"]), 8, "une durée plus longue prolonge")
	assert_eq(int(s["valeur"]), 20, "une valeur plus faible ne remplace pas")
	assert_eq(e.perso("b1")["etats"].size(), 1, "une seule instance")


# 26. Les ticks avant les durées ; pas de tick le tour de la pose.
func test_26_ticks() -> void:
	var e := duel_essai(essai([[[dot("saignement", 10, 1)]]]))
	e = tour(e, {"a1": jouer(e, "a1", 0, "b1")})
	assert_eq(evenements(e, "tick", "b1").size(), 0, "pas de tick le tour de la pose")
	assert_eq(int(e.perso("b1")["pv"]), 1000, "PV intacts")
	e = tour(e)
	assert_eq(evenements(e, "tick", "b1").size(), 1, "un tick au tour suivant, avant que l'état expire")
	assert_eq(int(e.perso("b1")["pv"]), 990, "10 dégâts")
	assert_false(e.perso("b1")["etats"].has("saignement"), "puis il expire")
	e = tour(e)
	assert_eq(int(e.perso("b1")["pv"]), 990, "plus rien ensuite")


# 27. Les KO ne sont constatés qu'en 2i : un soin du même tour sauve.
func test_27_un_soin_sauve() -> void:
	var e := duel_essai(essai([[[deg(100)]]]), null, null, essai([[[soin(100)]]]))
	e.perso("b1")["pv"] = 50
	e = tour(e, {"a1": jouer(e, "a1", 0, "b1"), "b2": jouer(e, "b2", 0, "", "b1")})
	assert_false(bool(e.perso("b1")["ko"]), "pas KO")
	assert_eq(int(e.perso("b1")["pv"]), 50, "50 − 100 + 100")


# 28. Double KO : gagne le camp qui avait le plus de PV (en %) en début de tour ; égalité : le camp A.
func test_28_double_ko() -> void:
	for cas in [[600, 400, "a"], [400, 600, "b"], [500, 500, "a"]]:
		var e := combat([essai([[[deg(5000)]]])], [essai([[[deg(5000)]]])])
		e.perso("a1")["pv"] = cas[0]
		e.perso("b1")["pv"] = cas[1]
		e = tour(e, {"a1": jouer(e, "a1", 0), "b1": jouer(e, "b1", 0)})
		assert_true(e.fini, "combat fini")
		assert_eq(e.vainqueur, cas[2], "PV %d contre %d" % [cas[0], cas[1]])
		assert_true(bool(e.perso("a1")["ko"]) and bool(e.perso("b1")["ko"]), "les deux KO")


# 29. Mort subite (spécification : au tour 12, ×1,15) ; les soins ne bougent pas ; pas de mort subite à la Tour.
func test_29_mort_subite() -> void:
	var a1 := essai([[[deg(100)]]])
	var a2 := essai([[[soin(100)]]])
	# Les chiffres de data/rules.json (la spécification : tour 12, pas de 0,15 ; le réglage peut les changer).
	var debut := int(donnees.regles["mort_subite_tour"])
	var pas := float(donnees.regles["mort_subite_pas"])
	var cas_liste := [[debut - 1, "pvp", 100], [debut, "pvp", Regles.plancher(100.0 * (1.0 + pas))], [debut + 1, "pvp", Regles.plancher(100.0 * (1.0 + 2.0 * pas))], [debut, "tour", 100]]
	for cas in cas_liste:
		var e := combat([a1, a2], [essai(), essai()], 1, cas[1])
		e.tour = cas[0]
		e.perso("a1")["pv"] = 500
		poser(e, "b2", "saignement", 1, 10.0, "a1")
		e = tour(e, {"a1": jouer(e, "a1", 0, "b1"), "a2": jouer(e, "a2", 0, "", "a1")})
		assert_eq(_degats_de(e, "a1"), [cas[2]], "dégâts au tour %d (%s)" % [cas[0], cas[1]])
		assert_eq(int(e.perso("a1")["pv"]), 600, "soin intact au tour %d (%s)" % [cas[0], cas[1]])
		var ms := 1.0 if cas[1] == "tour" or cas[0] < debut else 1.0 + pas * float(cas[0] - debut + 1)
		assert_eq(evenements(e, "tick", "b2")[0]["valeur"], Regles.plancher(10.0 * ms), "DoT au tour %d (%s)" % [cas[0], cas[1]])


# 30. M(niveau) multiplie les PV et les valeurs, pas les durées.
func test_30_niveau() -> void:
	var e := combat([essai([[[deg(100), dot("brulure", 10, 3)]]]), essai()], [essai(), essai()], 3)
	assert_eq(int(e.fiche("a1")["pv_max"]), 1100, "PV × 1,1 au niveau 3")
	e = tour(e, {"a1": jouer(e, "a1", 0, "b1")})
	assert_eq(_degats_de(e, "a1"), [110], "dégâts × 1,1")
	var s: Dictionary = e.perso("b1")["etats"]["brulure"]
	assert_eq(int(s["valeur"]), 11, "DoT × 1,1")
	assert_eq(int(s["fin"]) - int(s["debut"]) + 1, 3, "durée inchangée")
	var e30 := combat([destin("guerrier")], [destin("mage")], 30)
	assert_eq(int(e30.fiche("a1")["pv_max"]), Regles.plancher(float(donnees.classe("guerrier")["pv"]) * 2.45), "Guerrier au niveau 30 : PV × 2,45")
	assert_eq(int(e30.fiche("b1")["pv_max"]), Regles.plancher(float(donnees.classe("mage")["pv"]) * 2.45), "Mage au niveau 30 : PV × 2,45")


# 31. Éclats : +5 % (É1, É3), +3 % de PV (É2, É4), +10 % sur la Clé (É5).
func test_31_eclats() -> void:
	var cas := [[[true, false, false, false, false], 1, 105], [[true, false, true, false, false], 1, 110],
		[[true, false, true, false, true], 4, 120], [[false, false, false, false, true], 1, 100]]
	for c in cas:
		var a1 := essai([[[deg(100)], [deg(100)], [deg(100)], [deg(100)]]])
		a1.voies[0]["eclats"] = c[0]
		var e := duel_essai(a1)
		e.perso("a1")["jalons"][0] = c[1] - 1
		e = tour(e, {"a1": jouer(e, "a1", 0, "b1")})
		assert_eq(_degats_de(e, "a1"), [c[2]], "éclats %s, rang %d" % [str(c[0]), c[1]])
	var a := essai([[[renfort(20)]], [[deg(10)]]])
	a.voies[0]["eclats"] = [false, true, false, true, false]
	a.voies[1]["eclats"] = [true, true, false, false, false]
	var e := duel_essai(a)
	assert_eq(int(e.fiche("a1")["pv_max"]), 1090, "trois éclats de PV : +9 %")
	a.voies[0]["eclats"] = [true, false, false, false, false]
	e = duel_essai(a)
	e = tour(e, {"a1": jouer(e, "a1", 0)})
	assert_almost(float(e.perso("a1")["etats"]["renfort"]["valeur"]), 0.21, "les éclats montent aussi les pourcentages")


# 32. Sans déclaration à la fin du chrono : le moyeu.
func test_32_chrono_depasse_moyeu() -> void:
	var e := combat([destin("guerrier"), destin("pretre", 3)], [destin("mage"), destin("guerrier", 3)])
	e = tour(e, {})
	for id in e.ordre:
		assert_eq(e.actions_jouees[id]["source"], "moyeu", id + " joue son moyeu")


# 33. Les quatre Synergies.
func test_33_synergies() -> void:
	# Brisure : un contrôle et des dégâts directs sur la même cible.
	var e := duel_essai(essai([[[etat("gele", 1)]]]), essai([[[deg(100)]]]))
	var e1 := tour(e, {"a1": jouer(e, "a1", 0, "b1"), "a2": jouer(e, "a2", 0, "b1")})
	assert_eq(_degats_de(e1, "a2"), [125], "Brisure : ×1,25")
	assert_eq(evenements(e1, "synergie")[0]["detail"], "Brisure", "annoncée")
	var e2 := tour(e, {"a1": jouer(e, "a1", 0, "b2"), "a2": jouer(e, "a2", 0, "b1")})
	assert_eq(_degats_de(e2, "a2"), [100], "pas la même cible : pas de Brisure")
	# Embrasement : deux DoT sur la même cible durent un tour de plus.
	e = duel_essai(essai([[[dot("saignement", 10, 2)]]]), essai([[[dot("brulure", 10, 2)]]]))
	e1 = tour(e, {"a1": jouer(e, "a1", 0, "b1"), "a2": jouer(e, "a2", 0, "b1")})
	assert_eq(int(e1.perso("b1")["etats"]["saignement"]["fin"]), 4, "Embrasement : Saignement +1 tour")
	assert_eq(int(e1.perso("b1")["etats"]["brulure"]["fin"]), 4, "Embrasement : Brûlure +1 tour")
	# Bastion : une barrière et un soin sur le même allié.
	e = duel_essai(essai([[[barriere(100, "un_allie")]]]), essai([[[soin(100)]]]))
	e.perso("a2")["pv"] = 500
	e1 = tour(e, {"a1": jouer(e, "a1", 0, "", "a2"), "a2": jouer(e, "a2", 0, "", "a2")})
	assert_eq(int(e1.perso("a2")["barriere"]), 130, "Bastion : barrière ×1,3")
	# Harmonie : un Renfort, et l'autre frappe.
	e = duel_essai(essai([[[renfort(20)]]]), essai([[[deg(100)]]], 1000, [soin(0, "soi")]))
	e1 = tour(e, {"a1": jouer(e, "a1", 0), "a2": jouer(e, "a2", 0, "b1")})
	assert_eq(int(e1.perso("a1")["etats"]["renfort"]["fin"]), 4, "Harmonie : Renfort +1 tour")
	e2 = tour(e, {"a1": jouer(e, "a1", 0)})
	assert_eq(int(e2.perso("a1")["etats"]["renfort"]["fin"]), 3, "sans dégâts de l'autre : 2 tours")
	assert_eq(evenements(e2, "synergie").size(), 0, "aucune Synergie")


# 34. Ordre d'application : joueur A, acolyte A, joueur B, acolyte B, et les effets dans l'ordre du nœud.
func test_34_ordre_d_application() -> void:
	var noeud := [[[deg(100), deg(50)]]]
	var e := duel_essai(essai(noeud), essai(noeud), essai(noeud), essai(noeud))
	e.perso("b1")["barriere"] = 120
	e.perso("b1")["barrier_until"] = e.tour + 2
	var decl := {}
	for id in e.ordre:
		decl[id] = jouer(e, id, 0, "b1" if id.begins_with("a") else "a1")
	e = tour(e, decl)
	var vu: Array = []
	for ev in evenements(e, "degats"):
		vu.append([ev["acteur"], ev["valeur"], ev["absorbe"]])
	assert_eq(vu, [["a1", 100, 100], ["a1", 50, 20], ["a2", 100, 0], ["a2", 50, 0], ["b1", 100, 0], ["b1", 50, 0], ["b2", 100, 0], ["b2", 50, 0]], "ordre des dégâts et de la barrière")


func _partie(e: EtatCombat) -> Array:
	# Quelques tours scriptés avec les vraies classes : chacun avance sur sa voie 1, puis sa voie 2.
	var declarations: Array = []
	for t in range(6):
		var d := {}
		for id in e.ordre:
			var legales := voies_legales(e, id)
			if not legales.is_empty():
				var v: int = legales[t % legales.size()][0]
				d[id] = jouer(e, id, v)
		declarations.append(d)
		e = tour(e, d)
	return [e, declarations]


# 35. Même état et mêmes déclarations : même résolution, 1 000 fois.
func test_35_determinisme() -> void:
	var e := combat([destin("guerrier"), destin("pretre", 3)], [destin("mage"), destin("guerrier", 3)], 12)
	var milieu: EtatCombat = _partie(e)[0]
	var decl := {}
	for id in milieu.ordre:
		var legales := Regles.actions_legales(milieu, id)
		if not legales.is_empty():
			decl[id] = legales[legales.size() - 1]
	var reference := JSON.stringify(tour(milieu, decl).vers_dict())
	var avant := JSON.stringify(milieu.vers_dict())
	for i in range(1000):
		if JSON.stringify(tour(milieu, decl).vers_dict()) != reference:
			failures.append("résolution %d différente" % i)
			break
	assert_eq(JSON.stringify(milieu.vers_dict()), avant, "l'état reçu n'est pas modifié")


# 36. Un EtatCombat sérialisé puis désérialisé donne la même résolution.
func test_36_serialisation() -> void:
	var e := combat([destin("voleur"), destin("pugiliste", 3)], [destin("alchimiste"), destin("voleur", 3)], 5)
	var res: Array = _partie(e)
	var milieu: EtatCombat = res[0]
	var decl := {}
	for id in milieu.ordre:
		var legales := Regles.actions_legales(milieu, id)
		if not legales.is_empty():
			decl[id] = legales[legales.size() - 1]
	var direct := tour(milieu, decl)
	var copie := tour(EtatCombat.depuis_dict(milieu.vers_dict()), decl)
	assert_eq(JSON.stringify(copie.vers_dict()), JSON.stringify(direct.vers_dict()), "dictionnaire")
	var par_json := tour(EtatCombat.depuis_dict(JSON.parse_string(JSON.stringify(milieu.vers_dict()))), decl)
	assert_eq(JSON.stringify(par_json.journal), JSON.stringify(direct.journal), "par du JSON : même journal")
	assert_eq(JSON.stringify(par_json.persos), JSON.stringify(direct.persos), "par du JSON : mêmes persos")
	assert_eq(par_json.tour, direct.tour, "par du JSON : même tour")
