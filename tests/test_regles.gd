## Recharges, ordre de vitesse, actions par défaut.
extends "res://tests/test_case.gd"


func test_basique_toujours_disponible_moyenne_et_forte_en_recharge() -> void:
	var combat := standard_combat()
	var guerrier := combat.get_unit("a1")
	assert_true(combat.can_use(guerrier, "basique"), "basique tour 1")
	assert_true(combat.can_use(guerrier, "moyenne"), "moyenne tour 1")
	assert_false(combat.can_use(guerrier, "forte"), "forte indisponible tour 1")
	assert_eq(combat.cooldown_remaining(guerrier, "forte"), 2, "forte dispo dans 2 tours")

	combat.resolve_turn([action("a1", "provocation", "b1")])
	heal_all(combat)
	assert_eq(combat.turn, 2, "tour 2")
	assert_false(combat.can_use(guerrier, "moyenne"), "moyenne en recharge tour 2")
	assert_eq(combat.cooldown_remaining(guerrier, "moyenne"), 2, "2 tours de recharge")
	combat.resolve_turn([])
	heal_all(combat)
	assert_false(combat.can_use(guerrier, "moyenne"), "moyenne en recharge tour 3")
	assert_true(combat.can_use(guerrier, "forte"), "forte disponible tour 3")
	combat.resolve_turn([action("a1", "fendoir", "b2")])
	heal_all(combat)
	assert_eq(combat.turn, 4, "tour 4")
	assert_true(combat.can_use(guerrier, "moyenne"), "moyenne de retour tour 4")
	assert_eq(combat.cooldown_remaining(guerrier, "forte"), 4, "forte : 4 tours de recharge")
	jump_to_turn(combat, 7)
	assert_false(combat.can_use(guerrier, "forte"), "forte toujours en recharge tour 7")
	jump_to_turn(combat, 8)
	assert_true(combat.can_use(guerrier, "forte"), "forte de retour tour 8")


func test_action_invalide_remplacee_par_la_basique() -> void:
	var combat := standard_combat()
	var events := combat.resolve_turn([action("a1", "fendoir", "b1")])
	var first := events_of_type(events, "action")
	var found := false
	for event in first:
		if event["actor"] == "a1":
			found = true
			assert_eq(event["skill"], "taillade", "la forte au tour 1 devient la basique")
	assert_true(found, "le Guerrier a agi")


func test_sans_choix_basique_sur_la_meme_cible() -> void:
	var combat := standard_combat()
	combat.resolve_turn([action("a1", "taillade", "b3")])
	var events := combat.resolve_turn([])
	for event in events_of_type(events, "action"):
		if event["actor"] == "a1":
			assert_eq(event["skill"], "taillade", "basique par défaut")
			assert_eq(event["targets"], ["b3"], "même cible qu'au tour précédent")


func test_ordre_de_vitesse() -> void:
	var combat := standard_combat()
	var events := combat.resolve_turn([])
	assert_eq(action_order(events), ["a1", "b1", "a2", "b2", "a3", "b3"], "Guerriers, puis Mages, puis Prêtres")


func test_priorite_a_vitesse_egale_alterne() -> void:
	var combat := standard_combat()
	var events := combat.resolve_turn([])
	assert_eq(action_order(events)[0], "a1", "tour 1 : l'équipe prioritaire passe devant")
	var events_2 := combat.resolve_turn([])
	assert_eq(action_order(events_2)[0], "b1", "tour 2 : l'autre équipe passe devant")
	var combat_b := Combat.create(data, standard_team(), standard_team(), 1)
	assert_eq(action_order(combat_b.resolve_turn([]))[0], "b1", "priorité donnée à l'équipe B au tour 1")


func test_etincelle_agit_tot() -> void:
	var combat := standard_combat({"mage": {"basique": 1}})
	var events := combat.resolve_turn([action("a2", "etincelle", "b1")])
	assert_eq(action_order(events)[0], "a2", "le Mage à l'Étincelle agit en premier")


func test_trait_de_givre_fait_agir_en_dernier() -> void:
	var combat := standard_combat()
	var events := combat.resolve_turn([action("a2", "trait_de_givre", "b3")])
	assert_eq(action_order(events).back(), "b3", "la cible gelée agit en dernier")


func test_trait_de_givre_sur_cible_ayant_deja_agi_la_gele_au_tour_suivant() -> void:
	var combat := standard_combat()
	combat.resolve_turn([action("a2", "trait_de_givre", "b1")])
	assert_true(combat.get_unit("b1").has_status("gele"), "gelé pour le tour suivant")
	var events := combat.resolve_turn([])
	assert_eq(action_order(events).back(), "b1", "le Guerrier gelé agit en dernier au tour 2")
	assert_false(combat.get_unit("b1").has_status("gele"), "le gel est terminé")


func test_coup_de_bouclier_repousse_d_un_cran() -> void:
	var combat := standard_combat({"guerrier": {"basique": 1}})
	# Ordre normal : a1, b1, a2, b2, a3, b3. a1 repousse b1 derrière a2.
	var events := combat.resolve_turn([action("a1", "coup_de_bouclier", "b1")])
	assert_eq(action_order(events), ["a1", "a2", "b1", "b2", "a3", "b3"], "b1 passe derrière a2")


func test_action_perdue_si_ko_avant_d_agir() -> void:
	var combat := standard_combat()
	var mage_b := combat.get_unit("b2")
	mage_b.hp = 10
	var events := combat.resolve_turn([action("a1", "taillade", "b2")])
	var lost := events_of_type(events, "action_lost")
	assert_eq(lost.size(), 1, "une action perdue")
	if lost.size() == 1:
		assert_eq(lost[0]["actor"], "b2", "le Mage KO perd son action")


func test_deterministe() -> void:
	var combat_1 := standard_combat()
	var combat_2 := standard_combat()
	var events_1 := combat_1.resolve_turn([action("a2", "arc_de_foudre", "b1")])
	var events_2 := combat_2.resolve_turn([action("a2", "arc_de_foudre", "b1")])
	assert_eq(events_1, events_2, "mêmes entrées, mêmes événements")
