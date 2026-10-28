## Le bestiaire de la Tour : des monstres complets, joués par la même IA, et leurs mécaniques propres.
extends "res://tests/test_case.gd"


## Un combat du duo Guerrier + Mage contre des monstres.
func monster_combat(monster_ids: Array) -> Combat:
	var enemies := []
	for monster_id in monster_ids:
		enemies.append({"monster_id": monster_id})
	return Combat.create(data, duo_team(["guerrier", "mage"]), enemies)


func test_chaque_monstre_est_complet() -> void:
	assert_true(data.monsters.size() >= 12, "un bestiaire d'au moins 12 monstres")
	for monster_id in data.monsters:
		var monster: Dictionary = data.monsters[monster_id]
		assert_true(data.monster_families.has(str(monster["family"])), monster_id + " : une famille connue")
		assert_true(data.monster_ranks.has(str(monster["rank"])), monster_id + " : un rang connu")
		assert_true(str(monster["role"]) in ["front", "degats", "soutien"], monster_id + " : un rôle pour l'IA")
		assert_true(float(monster["menace"]) > 0.0, monster_id + " : une menace")
		for tier in CombatUnit.TIERS:
			var skill_id := str(monster["skills"][tier])
			assert_true(data.skills.has(skill_id), "%s : compétence %s connue" % [monster_id, skill_id])
			assert_eq(str(data.skill(skill_id).get("tier")), tier, "%s : %s est bien une %s" % [monster_id, skill_id, tier])
			var text := data.skill_description(skill_id)
			assert_true(text.length() > 5 and not text.contains("{"), "%s : description remplie (%s)" % [skill_id, text])
		var passive := str(monster.get("passive", ""))
		if passive != "":
			assert_true(data.passives.has(passive), "%s : passif %s connu" % [monster_id, passive])
			assert_false(data.passive_description(passive).contains("{"), passive + " : description remplie")
		assert_true(PixelSprites.SPRITES.has(monster_id), monster_id + " : un sprite")


func test_chaque_famille_a_de_quoi_remplir_un_etage() -> void:
	for family in data.monster_families:
		var ranks := {}
		for monster_id in data.monsters_of(family, false):
			ranks[data.monsters[monster_id]["rank"]] = true
		assert_true(ranks.has("sbire"), family + " : des sbires (pour les groupes de 4)")
		assert_true(ranks.size() >= 2, family + " : plusieurs rangs")
	var guardians := 0
	for monster_id in data.monsters:
		if str(data.monsters[monster_id]["rank"]) == "gardien":
			guardians += 1
			assert_true(data.monsters_of(str(data.monsters[monster_id]["family"]), false).size() > 0, monster_id + " : une escorte possible")
	assert_true(guardians >= 2, "au moins deux Gardiens")


func test_un_monstre_est_construit_depuis_le_bestiaire() -> void:
	var combat := monster_combat(["loup", "rat"])
	var wolf := combat.get_unit("b1")
	assert_true(wolf.is_monster, "un monstre")
	assert_eq(wolf.display_name, "Loup gris", "son nom")
	assert_eq(wolf.max_hp, int(data.monsters["loup"]["stats"]["max_hp"]), "ses PV")
	assert_eq(wolf.skills["forte"], "curee", "son kit fixe")
	assert_eq(Duo.main_role(data, "loup"), "degats", "son rôle, pour l'IA")
	assert_eq(data.class_name_of("loup"), "Loup gris", "son nom d'espèce")


func test_les_monstres_jouent_avec_l_ia_et_le_combat_se_termine() -> void:
	for group in [["ours", "loup", "rat", "rat"], ["necromancien", "goule", "squelette"], ["golem"], ["chaman", "gobelin", "gobelin", "gobelin"], ["liche", "squelette", "squelette"]]:
		var combat := monster_combat(group)
		var guard := 0
		while not combat.finished and guard < 40:
			var actions: Array = CombatAI.choose_team(combat, 0)
			var monsters := CombatAI.choose_team(combat, 1)
			assert_eq(monsters.size(), combat.team_units(1, true).size(), "%s : une Intention par monstre debout" % str(group))
			actions.append_array(monsters)
			combat.resolve_turn(actions)
			guard += 1
		assert_true(combat.finished, "%s : le combat se termine" % str(group))


func test_vol_de_vie() -> void:
	# Ton duo ne la frappe pas ce tour-ci : Prière et Rempart sur le Prêtre ; elle dévore le Guerrier.
	var team := duo_team(["pretre", "guerrier"], {"pretre": {"basique": 1}, "guerrier": {"moyenne": 1}})
	var combat := Combat.create(data, team, [{"monster_id": "goule"}])
	var ghoul := combat.get_unit("b1")
	ghoul.hp = 50
	var events := combat.resolve_turn([action("a1", "priere", "a1"), action("a2", "rempart", "a1"), action("b1", "devorer", "a2")])
	var dealt := damage_from(events, "b1", "a2")
	assert_true(dealt > 0, "Dévorer frappe")
	assert_eq(ghoul.hp, 50 + int(round(dealt * float(data.skill("devorer")["effects"][0]["lifesteal"]))), "elle se soigne d'une part des dégâts")


func test_affaibli_reduit_les_degats_infliges() -> void:
	var combat := monster_combat(["gelee"])
	var mage := combat.get_unit("a2")
	var normal := combat._damage_amount(mage, combat.get_unit("b1"), 50, 1.0, true)
	mage.add_status({"id": "affaibli", "turns": 2, "value": 25})
	assert_between(combat._damage_amount(mage, combat.get_unit("b1"), 50, 1.0, true), int(round(normal * 0.75)) - 1, int(round(normal * 0.75)) + 1, "-25 % de dégâts (à l'arrondi près)")
	assert_true(data.is_negative_status("affaibli"), "un état négatif (une Purification le retire)")


func test_meute_plus_forte_a_plusieurs() -> void:
	var combat := monster_combat(["rat", "rat", "rat"])
	var rat := combat.get_unit("b1")
	var target := combat.get_unit("a1")
	var full := combat._damage_amount(rat, target, 40, 1.0, true)
	combat.get_unit("b2").hp = 0
	combat.get_unit("b3").hp = 0
	var alone := combat._damage_amount(rat, target, 40, 1.0, true)
	assert_true(full > alone, "plus fort quand la meute est debout")
	var bonus := data.passive_param("meute", "per_ally_bonus", 0.0)
	assert_between(float(full) / float(alone), 1.0 + 2.0 * bonus - 0.05, 1.0 + 2.0 * bonus + 0.05, "+%d %% par autre monstre debout" % int(bonus * 100))


func test_regeneration_s_arrete_quand_les_monstres_s_epuisent() -> void:
	# Ton duo ne la frappe pas : Prière et Rempart sur toi, et le Rempart absorbe son coup.
	var team := duo_team(["pretre", "guerrier"], {"pretre": {"basique": 1}, "guerrier": {"moyenne": 1}})
	var combat := Combat.create(data, team, [{"monster_id": "gelee", "heal_mult": 0.5}])
	combat.exhausted_team = 1
	combat.exhaustion_turn = 12
	var jelly := combat.get_unit("b1")
	jelly.hp = 100
	combat.resolve_turn([action("a1", "priere", "a1"), action("a2", "rempart", "a1"), action("b1", "fouet_gluant", "a1")])
	var expected := int(round(round(jelly.max_hp * data.passive_param("regeneration", "regen", 0.0)) * 0.5))
	assert_eq(jelly.hp, 100 + expected, "elle se reforme à chaque tour (soins des monstres réduits)")
	jump_to_turn(combat, 12)
	var before := jelly.hp
	combat.resolve_turn([action("a1", "priere", "a1"), action("a2", "rempart", "a1"), action("b1", "fouet_gluant", "a1")])
	assert_eq(jelly.hp, before, "épuisée : plus de régénération")
