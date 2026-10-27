## La Tour : étages générés, pas de mort subite, PV et recharges gardés d'un étage à l'autre.
extends "res://tests/test_case.gd"

const GM := ["guerrier", "mage"]


func new_tower(classes: Array = GM, picks: Dictionary = {}) -> Tower:
	return Tower.start(data, duo_team(classes, picks))


func seeded(value: int) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = value
	return rng


## Termine le combat en cours d'un étage : tous les ennemis tombent (ou tout le duo, si won est faux).
func end_floor(combat: Combat, won: bool) -> void:
	for unit in combat.team_units(1 if won else 0):
		unit.hp = 0
	combat.resolve_turn([])


func test_dix_etages_de_deux_ou_trois_ennemis() -> void:
	var tower := new_tower()
	assert_eq(tower.floor_count(), 10, "10 étages")
	var rng := seeded(1)
	for number in range(1, 11):
		tower.current_floor = number
		var enemies := tower.floor_enemies(rng)
		assert_eq(enemies.size(), int(tower.floor_info()["enemies"]), "étage %d : nombre d'ennemis" % number)
		assert_between(enemies.size(), 2, 3, "étage %d : 2 ou 3 ennemis" % number)
		for enemy in enemies:
			assert_true(data.classes.has(enemy["class_id"]), "les ennemis sont construits avec les classes du jeu")
		if tower.is_boss_floor():
			assert_true(str(enemies[0]["name"]).begins_with("Gardien"), "étage %d : un Gardien" % number)
			assert_true(float(enemies[0]["max_hp_mult"]) > float(enemies[1]["max_hp_mult"]), "le Gardien a plus de PV")


func test_meme_graine_meme_tour() -> void:
	var tower := new_tower()
	assert_eq(tower.floor_enemies(seeded(5)), tower.floor_enemies(seeded(5)), "mêmes ennemis")


func test_les_ennemis_suivent_la_force_de_l_etage() -> void:
	var tower := new_tower()
	tower.current_floor = 3
	var combat := tower.create_combat(seeded(2))
	var info := tower.floor_info()
	for enemy in combat.team_units(1):
		var base := int(data.classes[enemy.class_id]["stats"]["max_hp"])
		assert_eq(enemy.max_hp, int(round(base * float(info["hp"]))), "PV réglés par l'étage")
		assert_eq(enemy.hp, enemy.max_hp, "les ennemis commencent à fond")


func test_pas_de_mort_subite_a_la_tour() -> void:
	var combat := new_tower().create_combat(seeded(3))
	jump_to_turn(combat, 15)
	assert_false(combat.is_sudden_death(), "pas de mort subite")
	assert_eq(combat.sudden_death_damage_mult(), 1.0, "dégâts normaux")
	assert_eq(combat.sudden_death_heal_mult(), 1.0, "soins normaux")


func test_les_ennemis_s_epuisent() -> void:
	var tower := new_tower(["mage", "pretre"], {"pretre": {"basique": 1, "passive": 3}})
	var combat := tower.create_combat(seeded(4))
	var enemy := combat.get_unit("b1")
	var ally := combat.get_unit("a1")
	jump_to_turn(combat, combat.exhaustion_turn - 1)
	assert_true(combat._heal_amount(enemy, enemy, 80) > 0, "avant l'épuisement, les ennemis soignent (moins fort)")
	assert_true(combat._heal_amount(enemy, enemy, 80) < 80, "les soins des ennemis de la Tour sont réduits")
	jump_to_turn(combat, combat.exhaustion_turn)
	assert_eq(combat._heal_amount(enemy, enemy, 80), 0, "épuisés : plus de soins")
	assert_eq(combat._barrier_amount(enemy, 60), 0, "ni de barrières")
	assert_eq(combat._heal_amount(combat.get_unit("a2"), ally, 44), 44, "ton duo soigne toujours")


func test_a_la_limite_de_tours_les_ennemis_abandonnent() -> void:
	var combat := new_tower().create_combat(seeded(6))
	jump_to_turn(combat, combat.forced_end_turn)
	combat.resolve_turn([])
	assert_true(combat.finished, "fin à la limite de tours")
	assert_eq(combat.end_reason, "limite_de_tours", "raison")
	assert_eq(combat.winner, 0, "le duo, encore debout, franchit l'étage")


func test_entre_deux_etages_pv_et_recharges_conserves() -> void:
	var tower := new_tower()
	var combat := tower.create_combat(seeded(7))
	jump_to_turn(combat, 5)
	var guerrier := combat.get_unit("a1")
	guerrier.hp = 100
	guerrier.cooldown_until = {"moyenne": 6, "forte": 9}
	combat.get_unit("a2").hp = 0
	end_floor(combat, true)
	var result := tower.finish_floor(combat)
	assert_true(result["won"], "étage franchi")
	assert_eq(tower.current_floor, 2, "on monte")
	var next := tower.create_combat(seeded(8))
	var g2 := next.get_unit("a1")
	var m2 := next.get_unit("a2")
	assert_eq(g2.hp, 100 + int(round(g2.max_hp * 0.2)), "20 % des PV max rendus")
	assert_eq(m2.hp, int(round(m2.max_hp * 0.2)), "l'acolyte KO revient avec 20 %")
	assert_eq(next.cooldown_remaining(g2, "forte"), 3, "la forte reste en recharge (jouée 4 tours plus tôt)")
	assert_true(next.can_use(g2, "moyenne"), "la moyenne revenue")
	assert_true(next.can_use(m2, "forte"), "une forte jamais jouée est prête dès le tour 1 de l'étage suivant")


func test_une_defaite_arrete_la_montee() -> void:
	var tower := new_tower()
	tower.current_floor = 4
	var combat := tower.create_combat(seeded(9))
	end_floor(combat, false)
	var result := tower.finish_floor(combat)
	assert_false(result["won"], "étage perdu")
	assert_true(tower.finished, "la montée s'arrête")
	assert_eq(tower.reached, 4, "étage atteint : 4")


func test_le_dernier_etage_franchi_termine_la_tour() -> void:
	var tower := new_tower()
	tower.current_floor = tower.floor_count()
	var combat := tower.create_combat(seeded(10))
	end_floor(combat, true)
	tower.finish_floor(combat)
	assert_true(tower.finished and tower.cleared_all, "sommet franchi")
	assert_eq(tower.reached, 10, "étage atteint : 10")


func test_une_montee_complete_par_l_ia() -> void:
	var rng := seeded(11)
	var floors := 0
	for i in range(5):
		var tower := Tower.start(data, Duo.random_duo(data, rng))
		while not tower.finished:
			var combat := tower.create_combat(rng)
			while not combat.finished:
				var actions: Array = CombatAI.choose_team(combat, 0)
				actions.append_array(CombatAI.choose_team(combat, 1))
				combat.resolve_turn(actions)
				assert_true(combat.turn <= combat.forced_end_turn, "jamais au-delà de la limite de tours")
			tower.finish_floor(combat)
			floors += 1
		assert_between(tower.reached, 1, 10, "un étage atteint")
	assert_true(floors > 5, "les duos franchissent des étages")
