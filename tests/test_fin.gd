## Conditions de fin, mort subite, IA.
extends "res://tests/test_case.gd"


func test_victoire_quand_l_equipe_adverse_est_ko() -> void:
	var combat := standard_combat()
	for unit_id in ["b1", "b2", "b3"]:
		combat.get_unit(unit_id).hp = 5
	var events := combat.resolve_turn([action("a1", "taillade", "b1"), action("a2", "boule_de_feu", "b2"), action("a3", "chatiment", "b3")])
	assert_true(combat.finished, "combat terminé")
	assert_eq(combat.winner, 0, "l'équipe A gagne")
	assert_eq(events_of_type(events, "end").size(), 1, "événement de fin")
	assert_eq(events_of_type(events, "end")[0]["reason"], "ko", "fin par KO")


func test_mort_subite_reduit_les_soins_et_augmente_les_degats() -> void:
	var combat := standard_combat({"pretre": {"basique": 1}})
	jump_to_turn(combat, Combat.SUDDEN_DEATH_TURN)
	assert_true(combat.is_sudden_death(), "mort subite active")
	var mage := combat.get_unit("a2")
	mage.hp = 200
	var events := combat.resolve_turn([action("a3", "priere", "a2"), action("b2", "boule_de_feu", "a2")])
	var healed := 0
	for event in events_of_type(events, "heal"):
		if event["target"] == "a2" and event["kind"] == "priere":
			healed += int(event["amount"])
	assert_eq(healed, 20, "Prière (40) divisée par deux")
	var hits := damage_from(events, "b2", "a2", "hit")
	assert_eq(hits, int(round(34 * 1.1 * 1.25)), "dégâts +25 % au premier tour de mort subite")


func test_fin_forcee_sans_match_nul() -> void:
	var combat := standard_combat()
	jump_to_turn(combat, Combat.FORCED_END_TURN - 1)
	combat.resolve_turn([])
	assert_false(combat.finished, "pas fini avant le dernier tour")
	assert_eq(combat.turn, Combat.FORCED_END_TURN, "dernier tour")
	# Les deux équipes sont identiques et jouent pareil ; seule différence : le Guerrier B est entamé.
	for unit in combat.units:
		unit.hp = unit.max_hp
	combat.get_unit("b1").hp = 200
	combat.resolve_turn([])
	assert_true(combat.finished, "fin forcée")
	assert_eq(combat.end_reason, "mort_subite", "raison : mort subite")
	assert_true(combat.team_total_hp(0) > combat.team_total_hp(1), "l'équipe A a plus de PV")
	assert_eq(combat.winner, 0, "l'équipe avec le plus de PV gagne")


func test_egalite_parfaite_departagee() -> void:
	var combat := standard_combat()
	jump_to_turn(combat, Combat.FORCED_END_TURN)
	combat.resolve_turn([])
	assert_true(combat.finished, "fin forcée")
	assert_true(combat.winner in [0, 1], "jamais de match nul")


func test_ia_soigne_un_allie_bas() -> void:
	var combat := standard_combat()
	combat.get_unit("a2").hp = 60
	var choice := CombatAI.choose(combat, combat.get_unit("a3"), [])
	assert_eq(choice.skill_id, "restauration", "le Prêtre choisit Restauration")
	assert_eq(choice.target_id, "a2", "sur le Mage blessé")


func test_ia_concentre_la_cible_des_allies() -> void:
	var combat := standard_combat()
	var choice := CombatAI.choose(combat, combat.get_unit("a1"), [action("a2", "boule_de_feu", "b3")])
	assert_eq(choice.target_id, "b3", "le Guerrier suit l'Intention du Mage")


func test_ia_releve_un_ko() -> void:
	var combat := standard_combat({"pretre": {"forte": 1}})
	advance_to_turn(combat, 3)
	combat.get_unit("a1").hp = 0
	var choice := CombatAI.choose(combat, combat.get_unit("a3"), [])
	assert_eq(choice.skill_id, "resurrection", "le Prêtre relève")
	assert_eq(choice.target_id, "a1", "le Guerrier KO")


func test_ia_cherche_la_synergie_provocation_nova() -> void:
	var combat := standard_combat()
	advance_to_turn(combat, 3)
	var allies := [action("a1", "provocation", "b2")]
	var choice := CombatAI.choose(combat, combat.get_unit("a2"), allies)
	assert_eq(choice.skill_id, "nova", "le Mage aligne sa Nova sur la Provocation")


func test_combats_ia_contre_ia_se_terminent() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 2026
	var wins := {0: 0, 1: 0}
	var turns_total := 0
	var synergies := 0
	for i in range(30):
		var team_a := []
		var team_b := []
		for class_id in ["guerrier", "mage", "pretre"]:
			team_a.append({"class_id": class_id, "picks": CombatUnit.random_picks(rng)})
			team_b.append({"class_id": class_id, "picks": CombatUnit.random_picks(rng)})
		var combat := Combat.create(data, team_a, team_b, i % 2)
		while not combat.finished:
			var actions := CombatAI.choose_team(combat, 0)
			actions.append_array(CombatAI.choose_team(combat, 1))
			var events := combat.resolve_turn(actions)
			synergies += events_of_type(events, "synergy").size()
			assert_true(combat.turn <= Combat.FORCED_END_TURN + 1, "jamais plus de 15 tours")
		wins[combat.winner] += 1
		turns_total += combat.turn
	assert_eq(wins[0] + wins[1], 30, "30 vainqueurs")
	assert_true(synergies > 0, "des Synergies se déclenchent en IA contre IA")
	assert_between(float(turns_total) / 30.0, 5.0, 15.0, "durée moyenne des combats (tours)")
	print("    (IA vs IA : %d / %d victoires, %.1f tours en moyenne, %d synergies)" % [wins[0], wins[1], float(turns_total) / 30.0, synergies])
