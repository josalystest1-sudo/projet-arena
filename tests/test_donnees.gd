## Les fichiers de données sont cohérents entre eux.
extends "res://tests/test_case.gd"


func test_les_classes_ont_des_kits_complets() -> void:
	assert_true(data.classes.size() >= 3, "au moins les trois classes du prototype")
	for class_id in data.classes:
		assert_true(data.classes[class_id]["roles"].size() == 2 and data.classes[class_id]["roles"][0] != data.classes[class_id]["roles"][1], class_id + " : un rôle principal et un secondaire")
		assert_true(PixelSprites.SPRITES.has(class_id), class_id + " : un sprite")
		assert_true(str(data.classes[class_id].get("identity", "")).length() > 5, class_id + " : une identité en une phrase")
		var cls: Dictionary = data.classes[class_id]
		for tier in CombatUnit.TIERS:
			assert_eq(cls["skills"][tier].size(), 2, "%s : 2 compétences %s" % [class_id, tier])
			for skill_id in cls["skills"][tier]:
				assert_true(data.skills.has(skill_id), "compétence inconnue : " + skill_id)
				assert_eq(data.skill(skill_id)["tier"], tier, "palier de " + skill_id)
				assert_eq(data.skill(skill_id)["class"], class_id, "classe de " + skill_id)
				var text := data.skill_description(skill_id)
				assert_true(text.length() > 5 and not text.contains("{"), "%s : description remplie (%s)" % [skill_id, text])
		assert_eq(cls["passives"].size(), 4, "%s : 4 passifs" % class_id)
		for passive_id in cls["passives"]:
			assert_true(data.passives.has(passive_id), "passif inconnu : " + passive_id)
			assert_eq(str(data.passives.get(passive_id, {}).get("class", "")), class_id, "classe du passif " + passive_id)


func test_synergies_referencent_des_competences_existantes() -> void:
	var names := {}
	for synergy in data.synergies:
		assert_false(names.has(synergy["name"]), "deux Synergies portent le nom %s" % synergy["name"])
		names[synergy["name"]] = true
		for skill_id in synergy["skills"]:
			if str(skill_id).begins_with("*"):
				continue
			assert_true(data.skills.has(skill_id), "synergie %s : compétence inconnue %s" % [synergy["id"], skill_id])
		if str(synergy["skills"][0]).begins_with("*") or str(synergy["skills"][1]).begins_with("*"):
			continue
		var class_a: String = data.skill(synergy["skills"][0])["class"]
		var class_b: String = data.skill(synergy["skills"][1])["class"]
		assert_ne(class_a, class_b, "synergie %s relie deux classes différentes" % synergy["id"])
		# Une Synergie se joue entre un joueur et son acolyte : deux classes de rôles principaux différents.
		assert_ne(data.role_of(class_a), data.role_of(class_b), "synergie %s relie deux classes qui peuvent former un duo" % synergy["id"])


func test_au_moins_une_synergie_par_paire_de_classes() -> void:
	# GDD : chaque classe a au moins une Synergie avec chaque classe qui peut lui servir d'acolyte.
	var class_ids: Array = data.classes.keys()
	for i in range(class_ids.size()):
		for j in range(i + 1, class_ids.size()):
			if data.role_of(class_ids[i]) == data.role_of(class_ids[j]):
				continue
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
	assert_eq(unit.hp, int(data.classes["mage"]["stats"]["max_hp"]), "PV du Mage pris dans les données")
