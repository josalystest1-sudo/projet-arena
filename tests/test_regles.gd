## Recharges, ordre de vitesse, actions par défaut.
extends "res://tests/test_case.gd"

const GM := ["guerrier", "mage"]


func test_basique_toujours_disponible_moyenne_et_forte_en_recharge() -> void:
	var combat := duo_combat(GM, GM)
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
	var combat := duo_combat(GM, GM)
	var events := combat.resolve_turn([action("a1", "fendoir", "b1")])
	var found := false
	for event in events_of_type(events, "action"):
		if event["actor"] == "a1":
			found = true
			assert_eq(event["skill"], "taillade", "la forte au tour 1 devient la basique")
	assert_true(found, "le Guerrier a agi")


func test_sans_choix_basique_sur_la_meme_cible() -> void:
	var combat := duo_combat(GM, GM)
	combat.resolve_turn([action("a1", "taillade", "b2")])
	var events := combat.resolve_turn([])
	for event in events_of_type(events, "action"):
		if event["actor"] == "a1":
			assert_eq(event["skill"], "taillade", "basique par défaut")
			assert_eq(event["targets"], ["b2"], "même cible qu'au tour précédent")


func test_ordre_de_vitesse() -> void:
	var combat := duo_combat(GM, GM)
	assert_eq(action_order(combat.resolve_turn([])), ["a1", "b1", "a2", "b2"], "les Guerriers, puis les Mages")
	var mixed := duo_combat(["guerrier", "pretre"], ["mage", "pretre"])
	assert_eq(action_order(mixed.resolve_turn([])), ["a1", "b1", "a2", "b2"], "Guerrier (9), Mage (8), puis les Prêtres (7)")


func test_priorite_a_vitesse_egale_alterne() -> void:
	var combat := duo_combat(GM, GM)
	var events := combat.resolve_turn([])
	assert_eq(action_order(events)[0], "a1", "tour 1 : le camp prioritaire passe devant")
	var events_2 := combat.resolve_turn([])
	assert_eq(action_order(events_2)[0], "b1", "tour 2 : l'autre camp passe devant")
	var combat_b := Combat.create(data, duo_team(GM), duo_team(GM), 1)
	assert_eq(action_order(combat_b.resolve_turn([]))[0], "b1", "priorité donnée au camp B au tour 1")


func test_etincelle_agit_tot() -> void:
	var combat := duo_combat(GM, GM, {"mage": {"basique": 1}})
	var events := combat.resolve_turn([action("a2", "etincelle", "b1")])
	assert_eq(action_order(events)[0], "a2", "le Mage à l'Étincelle agit en premier")


func test_trait_de_givre_fait_agir_en_dernier() -> void:
	var combat := duo_combat(["mage", "pretre"], GM)
	# Ordre normal : b1 (Guerrier), a1 (Mage), b2 (Mage), a2 (Prêtre). Le Mage A gèle le Mage B.
	var events := combat.resolve_turn([action("a1", "trait_de_givre", "b2")])
	assert_eq(action_order(events).back(), "b2", "la cible gelée agit en dernier")


func test_trait_de_givre_sur_cible_ayant_deja_agi_la_gele_au_tour_suivant() -> void:
	var combat := duo_combat(GM, GM)
	combat.resolve_turn([action("a2", "trait_de_givre", "b1")])
	assert_true(combat.get_unit("b1").has_status("gele"), "gelé pour le tour suivant")
	var events := combat.resolve_turn([])
	assert_eq(action_order(events).back(), "b1", "le Guerrier gelé agit en dernier au tour 2")
	assert_false(combat.get_unit("b1").has_status("gele"), "le gel est terminé")


func test_coup_de_bouclier_repousse_d_un_cran() -> void:
	var combat := duo_combat(GM, GM, {"guerrier": {"basique": 1}})
	# Ordre normal : a1, b1, a2, b2. a1 repousse b1 derrière a2.
	var events := combat.resolve_turn([action("a1", "coup_de_bouclier", "b1")])
	assert_eq(action_order(events), ["a1", "a2", "b1", "b2"], "b1 passe derrière a2")


func test_action_perdue_si_ko_avant_d_agir() -> void:
	var combat := duo_combat(GM, GM)
	combat.get_unit("b2").hp = 10
	var events := combat.resolve_turn([action("a1", "taillade", "b2")])
	var lost := events_of_type(events, "action_lost")
	assert_eq(lost.size(), 1, "une action perdue")
	if lost.size() == 1:
		assert_eq(lost[0]["actor"], "b2", "le Mage KO perd son action")


func test_deterministe() -> void:
	var combat_1 := duo_combat(GM, GM)
	var combat_2 := duo_combat(GM, GM)
	var events_1 := combat_1.resolve_turn([action("a2", "arc_de_foudre", "b1")])
	var events_2 := combat_2.resolve_turn([action("a2", "arc_de_foudre", "b1")])
	assert_eq(events_1, events_2, "mêmes entrées, mêmes événements")


func test_camps_de_taille_variable() -> void:
	# La Tour : un duo contre trois ennemis. Le moteur n'impose aucune taille de camp.
	var combat := Combat.create(data, duo_team(GM), [member("guerrier"), member("mage"), member("pretre")])
	assert_eq(combat.team_units(0).size(), 2, "2 alliés")
	assert_eq(combat.team_units(1).size(), 3, "3 ennemis")
	var events := combat.resolve_turn([action("a2", "arc_de_foudre", "b3")])
	assert_eq(action_order(events).size(), 5, "les 5 persos agissent")
	var guard := 0
	while not combat.finished and guard < 30:
		combat.resolve_turn([])
		guard += 1
	assert_true(combat.finished, "le combat 2 contre 3 se termine")
	assert_true(combat.winner in [0, 1], "avec un vainqueur")
