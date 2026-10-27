## Composition des duos : classe complémentaire de l'acolyte, Synergie garantie, tirage reproductible.
extends "res://tests/test_case.gd"


func test_l_acolyte_complete_le_role_du_joueur() -> void:
	for class_id in data.classes:
		var options := Duo.acolyte_classes(data, class_id)
		assert_false(options.is_empty(), "%s a au moins une classe d'acolyte possible" % class_id)
		for acolyte_class in options:
			assert_ne(Duo.main_role(data, acolyte_class), Duo.main_role(data, class_id), "%s ne reçoit pas un acolyte du même rôle" % class_id)
	assert_eq(Duo.acolyte_classes(data, "guerrier"), ["mage", "pretre"], "un Front reçoit un Dégâts ou un Soutien")
	assert_eq(Duo.acolyte_classes(data, "mage"), ["guerrier", "pretre"], "un Dégâts reçoit un Front ou un Soutien")
	assert_eq(Duo.acolyte_classes(data, "pretre"), ["guerrier", "mage"], "un Soutien reçoit un Front ou un Dégâts")


func test_tout_kit_de_joueur_a_une_synergie_possible_avec_chaque_classe_d_acolyte() -> void:
	# Garantie du GDD : aucun duo sans Synergie. Pour chaque kit du joueur et chaque classe d'acolyte,
	# au moins un kit d'acolyte forme une Synergie avec lui.
	for class_id in data.classes:
		for picks in Duo.all_picks(data, class_id):
			for acolyte_class in Duo.acolyte_classes(data, class_id):
				var found := false
				for acolyte_picks in Duo.all_picks(data, acolyte_class):
					if not Duo.kit_synergies(data, class_id, picks, acolyte_class, acolyte_picks).is_empty():
						found = true
						break
				assert_true(found, "%s %s n'a aucune Synergie possible avec un %s" % [class_id, str(picks), acolyte_class])


func test_l_acolyte_tire_a_toujours_une_synergie_avec_son_joueur() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	for i in range(200):
		var class_id: String = data.classes.keys()[i % data.classes.size()]
		var picks := CombatUnit.random_picks(rng)
		var acolyte := Duo.draw_acolyte(data, class_id, picks, rng)
		assert_true(Duo.acolyte_classes(data, class_id).has(acolyte["class_id"]), "classe complémentaire")
		assert_false(Duo.kit_synergies(data, class_id, picks, acolyte["class_id"], acolyte["picks"]).is_empty(), "au moins une Synergie")


func test_les_deux_classes_d_acolyte_sortent() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	var seen := {}
	for i in range(60):
		seen[Duo.draw_acolyte(data, "pretre", CombatUnit.random_picks(rng), rng)["class_id"]] = true
	assert_eq(seen.size(), 2, "un Prêtre reçoit tantôt un Guerrier, tantôt un Mage")


func test_tirage_reproductible() -> void:
	var rng_1 := RandomNumberGenerator.new()
	var rng_2 := RandomNumberGenerator.new()
	rng_1.seed = 99
	rng_2.seed = 99
	assert_eq(Duo.random_duo(data, rng_1), Duo.random_duo(data, rng_2), "même graine, même duo")


func test_duo_dans_le_combat() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	var combat := Combat.create(data, Duo.random_duo(data, rng, "mage"), Duo.random_duo(data, rng))
	assert_eq(combat.units.size(), 4, "2 contre 2")
	assert_eq(combat.leader_of(0).class_id, "mage", "le joueur du camp A est le Mage demandé")
	assert_false(combat.leader_of(0).is_acolyte, "le joueur n'est pas l'acolyte")
	assert_true(combat.acolyte_of(0).is_acolyte, "le second membre est l'acolyte")
	assert_ne(Duo.main_role(data, combat.acolyte_of(0).class_id), "degats", "l'acolyte d'un Mage n'est pas un Dégâts")
	assert_eq(combat.acolyte_of(1).team, 1, "chaque camp a son acolyte")
