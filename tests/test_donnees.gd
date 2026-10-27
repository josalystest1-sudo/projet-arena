## Les fichiers de données sont cohérents entre eux.
extends "res://tests/test_case.gd"


func test_trois_classes_avec_kits_complets() -> void:
	assert_eq(data.classes.size(), 3, "nombre de classes")
	for class_id in data.classes:
		var cls: Dictionary = data.classes[class_id]
		for tier in CombatUnit.TIERS:
			assert_eq(cls["skills"][tier].size(), 2, "%s : 2 compétences %s" % [class_id, tier])
			for skill_id in cls["skills"][tier]:
				assert_true(data.skills.has(skill_id), "compétence inconnue : " + skill_id)
				assert_eq(data.skill(skill_id)["tier"], tier, "palier de " + skill_id)
				assert_eq(data.skill(skill_id)["class"], class_id, "classe de " + skill_id)
		assert_eq(cls["passives"].size(), 4, "%s : 4 passifs" % class_id)
		for passive_id in cls["passives"]:
			assert_true(data.passives.has(passive_id), "passif inconnu : " + passive_id)


func test_synergies_referencent_des_competences_existantes() -> void:
	for synergy in data.synergies:
		for skill_id in synergy["skills"]:
			assert_true(data.skills.has(skill_id), "synergie %s : compétence inconnue %s" % [synergy["id"], skill_id])
		var class_a: String = data.skill(synergy["skills"][0])["class"]
		var class_b: String = data.skill(synergy["skills"][1])["class"]
		assert_ne(class_a, class_b, "synergie %s relie deux classes différentes" % synergy["id"])


func test_au_moins_une_synergie_par_paire_de_classes() -> void:
	var class_ids: Array = data.classes.keys()
	for i in range(class_ids.size()):
		for j in range(i + 1, class_ids.size()):
			var found := false
			for synergy in data.synergies:
				var pair := [data.skill(synergy["skills"][0])["class"], data.skill(synergy["skills"][1])["class"]]
				if class_ids[i] in pair and class_ids[j] in pair:
					found = true
			assert_true(found, "aucune synergie entre %s et %s" % [class_ids[i], class_ids[j]])


func test_unite_tire_une_competence_par_palier() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	var unit := CombatUnit.from_class(data, "mage", CombatUnit.random_picks(rng), "a1", 0, 0)
	for tier in CombatUnit.TIERS:
		assert_eq(data.skill(unit.skills[tier])["tier"], tier, "palier tiré")
	assert_true(data.passives.has(unit.passive), "passif tiré")
	assert_eq(unit.hp, 230, "PV du Mage")
