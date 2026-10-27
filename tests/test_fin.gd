## Conditions de fin, mort subite, IA.
extends "res://tests/test_case.gd"

const GM := ["guerrier", "mage"]


func test_victoire_quand_le_duo_adverse_est_ko() -> void:
	var combat := duo_combat(GM, GM)
	for unit_id in ["b1", "b2"]:
		combat.get_unit(unit_id).hp = 5
	var events := combat.resolve_turn([action("a1", "taillade", "b1"), action("a2", "boule_de_feu", "b2")])
	assert_true(combat.finished, "combat terminé")
	assert_eq(combat.winner, 0, "le camp A gagne")
	assert_eq(events_of_type(events, "end").size(), 1, "événement de fin")
	assert_eq(events_of_type(events, "end")[0]["reason"], "ko", "fin par KO")


func test_le_combat_continue_tant_qu_un_membre_du_duo_est_debout() -> void:
	var combat := duo_combat(GM, GM)
	combat.get_unit("b1").hp = 5
	combat.resolve_turn([action("a1", "taillade", "b1")])
	assert_false(combat.get_unit("b1").is_alive(), "le joueur adverse est KO")
	assert_false(combat.finished, "son acolyte se bat encore")


func test_mort_subite_reduit_les_soins_et_augmente_les_degats() -> void:
	var combat := duo_combat(["mage", "pretre"], GM, {"pretre": {"basique": 1, "passive": 3}})
	jump_to_turn(combat, combat.sudden_death_turn)
	assert_true(combat.is_sudden_death(), "mort subite active")
	var mage := combat.get_unit("a1")
	mage.hp = int(mage.max_hp * 0.85)
	var damage_mult := combat.sudden_death_damage_mult()
	var heal_mult := combat.sudden_death_heal_mult()
	assert_true(damage_mult > 1.0, "les dégâts augmentent")
	assert_true(heal_mult < 1.0, "les soins baissent")
	var events := combat.resolve_turn([action("a2", "priere", "a1"), action("b2", "boule_de_feu", "a1")])
	var healed := 0
	for event in events_of_type(events, "heal"):
		if event["target"] == "a1" and event["kind"] == "priere":
			healed += int(event["amount"])
	assert_eq(healed, int(round(40 * heal_mult)), "Prière (40) réduite par la mort subite")
	var hits := damage_from(events, "b2", "a1", "hit")
	assert_eq(hits, int(round(34 * 1.1 * damage_mult)), "dégâts augmentés au premier tour de mort subite")


func test_fin_forcee_sans_match_nul() -> void:
	var combat := duo_combat(GM, GM)
	jump_to_turn(combat, combat.forced_end_turn - 1)
	combat.resolve_turn([])
	assert_false(combat.finished, "pas fini avant le dernier tour")
	assert_eq(combat.turn, combat.forced_end_turn, "dernier tour")
	# Les deux duos sont identiques et jouent pareil ; seule différence : le Guerrier B est entamé.
	heal_all(combat)
	combat.get_unit("b1").hp = int(combat.get_unit("b1").max_hp * 0.6)
	combat.resolve_turn([])
	assert_true(combat.finished, "fin forcée")
	assert_eq(combat.end_reason, "mort_subite", "raison : mort subite")
	assert_true(combat.team_total_hp(0) > combat.team_total_hp(1), "le duo A a plus de PV")
	assert_eq(combat.winner, 0, "le duo avec le plus de PV gagne")


func test_egalite_parfaite_departagee() -> void:
	var combat := duo_combat(GM, GM)
	jump_to_turn(combat, combat.forced_end_turn)
	combat.resolve_turn([])
	assert_true(combat.finished, "fin forcée")
	assert_true(combat.winner in [0, 1], "jamais de match nul")


func test_ia_soigne_un_allie_bas() -> void:
	var combat := duo_combat(["mage", "pretre"], GM)
	combat.get_unit("a1").hp = 45
	var choice := CombatAI.choose(combat, combat.get_unit("a2"), [])
	assert_eq(choice.skill_id, "restauration", "le Prêtre choisit Restauration")
	assert_eq(choice.target_id, "a1", "sur le Mage blessé")


func test_ia_concentre_la_cible_des_allies() -> void:
	var combat := duo_combat(GM, GM)
	var choice := CombatAI.choose(combat, combat.get_unit("a1"), [action("a2", "boule_de_feu", "b1")])
	assert_eq(choice.target_id, "b1", "le Guerrier suit l'Intention du Mage")


func test_ia_releve_un_ko() -> void:
	var combat := duo_combat(["guerrier", "pretre"], GM, {"pretre": {"forte": 1}})
	advance_to_turn(combat, 3)
	heal_all(combat)
	combat.get_unit("a1").hp = 0
	var choice := CombatAI.choose(combat, combat.get_unit("a2"), [])
	assert_eq(choice.skill_id, "resurrection", "le Prêtre relève")
	assert_eq(choice.target_id, "a1", "le Guerrier KO")


func test_ia_cherche_la_synergie_provocation_nova() -> void:
	var combat := duo_combat(GM, GM)
	advance_to_turn(combat, 3)
	heal_all(combat)
	var choice := CombatAI.choose(combat, combat.get_unit("a2"), [action("a1", "provocation", "b2")])
	assert_eq(choice.skill_id, "nova", "le Mage aligne sa Nova sur la Provocation")


func test_combats_ia_contre_ia_se_terminent() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 2026
	var wins := {0: 0, 1: 0}
	var turns_total := 0
	var synergies := 0
	for i in range(30):
		var combat := Combat.create(data, Duo.random_duo(data, rng), Duo.random_duo(data, rng), i % 2)
		while not combat.finished:
			var actions := CombatAI.choose_team(combat, 0)
			actions.append_array(CombatAI.choose_team(combat, 1))
			var events := combat.resolve_turn(actions)
			synergies += events_of_type(events, "synergy").size()
			assert_true(combat.turn <= combat.forced_end_turn + 1, "jamais au-delà du tour de fin forcée")
		wins[combat.winner] += 1
		turns_total += combat.turn
	assert_eq(wins[0] + wins[1], 30, "30 vainqueurs")
	assert_true(synergies > 0, "des Synergies se déclenchent en IA contre IA")
	assert_between(float(turns_total) / 30.0, 5.0, 15.0, "durée moyenne des combats (tours)")
	print("    (IA vs IA : %d / %d victoires, %.1f tours en moyenne, %d synergies)" % [wins[0], wins[1], float(turns_total) / 30.0, synergies])
