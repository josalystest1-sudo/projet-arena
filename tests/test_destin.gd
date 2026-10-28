## Le Destin : un arbre de 45 nœuds, unique, au budget de puissance garanti ; le mini-Destin de l'acolyte ; les nœuds en combat.
extends "res://tests/test_case.gd"

const GM := ["guerrier", "mage"]


func tree_for(class_id: String, seed_value: int = 7, mini: bool = false, picks: Dictionary = {}) -> Dictionary:
	return Destin.generate(data, class_id, picks, seed_value, mini)


func test_un_arbre_de_45_noeuds_bien_formes() -> void:
	var tree := tree_for("mage")
	var nodes: Array = tree["nodes"]
	assert_eq(nodes.size(), int(data.destin_nodes["size"]), "45 nœuds")
	var counts := {}
	var children := {}
	for node in nodes:
		counts[node["type"]] = int(counts.get(node["type"], 0)) + 1
		assert_true(str(node.get("name", "")).length() > 2, "nœud %d : un nom" % int(node["id"]))
		assert_true(str(node.get("description", "")).length() > 5 and not str(node["description"]).contains("{"), "nœud %d : une description remplie (%s)" % [int(node["id"]), str(node.get("description", ""))])
		assert_true(float(node["value"]) > 0.0, "nœud %d : une valeur" % int(node["id"]))
		var parent := int(node["parent"])
		if int(node["id"]) == 0:
			assert_eq(parent, -1, "la racine n'a pas de parent")
		else:
			assert_true(parent >= 0 and parent < int(node["id"]), "nœud %d : relié à un nœud déjà placé" % int(node["id"]))
			children[parent] = int(children.get(parent, 0)) + 1
	for parent in children:
		assert_true(int(children[parent]) <= int(data.destin_nodes["max_children"]), "trois enfants au plus")
	var expected: Dictionary = data.destin_nodes["counts"]
	for type in expected:
		assert_eq(int(counts.get(type, 0)), int(expected[type]), "nombre de nœuds %s (GDD : 50 / 30 / 15 / 5 %%)" % type)
	for node in nodes:
		if node["type"] == "cle":
			assert_true(int(node["depth"]) >= 3, "une Clé est au bout d'un chemin d'au moins 3 nœuds")


func test_chaque_element_du_kit_a_son_evolution() -> void:
	for class_id in data.class_ids:
		var rng := RandomNumberGenerator.new()
		rng.seed = 3
		var picks := CombatUnit.random_picks(rng)
		var tree := tree_for(class_id, 11, false, picks)
		var kit := Duo.kit_skills(data, class_id, picks)
		var passive_pool: Array = data.classes[class_id]["passives"]
		kit.append(passive_pool[int(picks["passive"]) % passive_pool.size()])
		var evolved := {}
		for node in tree["nodes"]:
			if node["type"] == "evolution":
				evolved[node["skill"]] = true
		for element in kit:
			assert_true(evolved.has(element), "%s : une évolution pour %s" % [class_id, element])


func test_tous_les_destins_se_valent() -> void:
	# Même valeur totale et même valeur atteignable avec 30 points, à 2 % près, pour toutes les classes et toutes les graines.
	var tolerance := float(data.destin_nodes["tolerance"])
	var total_target := float(data.destin_nodes["total_value"])
	var best_target := float(data.destin_nodes["best_value"])
	var rng := RandomNumberGenerator.new()
	rng.seed = 21
	for i in range(20):
		var class_id: String = data.class_ids[i % data.class_ids.size()]
		var tree := tree_for(class_id, 500 + i, false, CombatUnit.random_picks(rng))
		assert_between(float(tree["total"]), total_target * (1.0 - tolerance), total_target * (1.0 + tolerance), "%s, graine %d : valeur totale" % [class_id, 500 + i])
		assert_between(float(tree["best"]), best_target * (1.0 - tolerance), best_target * (1.0 + tolerance), "%s, graine %d : meilleure valeur avec 30 points" % [class_id, 500 + i])
		assert_eq(float(tree["best"]), Destin.best_value(tree, int(data.destin_nodes["points"])), "la meilleure valeur est celle du calcul")


func test_meme_graine_meme_destin_et_graines_differentes_destins_differents() -> void:
	var a := tree_for("guerrier", 42)
	var b := tree_for("guerrier", 42)
	assert_eq(a["nodes"], b["nodes"], "même graine, même classe, même kit : même arbre")
	var c := tree_for("guerrier", 43)
	assert_ne(a["nodes"], c["nodes"], "une autre graine : un autre arbre")


func test_placement_des_points() -> void:
	var tree := tree_for("pretre")
	var taken: Array = []
	assert_eq(Destin.available(tree, taken), [0], "le premier point va à la racine")
	assert_false(Destin.can_take(tree, taken, 5), "pas ailleurs")
	taken.append(0)
	var next := Destin.available(tree, taken)
	assert_eq(next, Destin.children_of(tree, 0), "puis les enfants de la racine")
	for node_id in next:
		assert_true(Destin.can_take(tree, taken, node_id), "nœud %d disponible" % node_id)
	assert_false(Destin.can_take(tree, taken, 0), "un nœud pris ne se reprend pas")
	# Le placement automatique (l'acolyte) prend toujours le nœud disponible qui vaut le plus.
	var auto := Destin.auto_take(tree, taken)
	assert_true(next.has(auto), "le choix automatique est un nœud disponible")
	for node_id in next:
		assert_true(float(Destin.node_of(tree, auto)["value"]) >= float(Destin.node_of(tree, node_id)["value"]), "et le plus précieux")


func test_le_mini_destin_de_l_acolyte() -> void:
	var tree := tree_for("mage", 9, true)
	assert_eq(tree["nodes"].size(), int(data.destin_nodes["mini_size"]), "15 nœuds")
	var taken: Array = []
	for i in range(int(data.destin_nodes["mini_points"])):
		var pick := Destin.auto_take(tree, taken)
		assert_true(pick >= 0, "point %d : un nœud à prendre" % (i + 1))
		taken.append(pick)
	assert_eq(taken.size(), tree["nodes"].size(), "avec ses 15 points, tout l'arbre est pris")
	var mods := Destin.mods_for(tree, taken)
	assert_false(mods["mods"].is_empty(), "des modificateurs")


func test_les_noeuds_pris_jouent_en_combat() -> void:
	# Un Mage dont le Destin donne +10 % de PV, +5 % de puissance et une Boule de feu plus forte.
	var tree := {"nodes": [
		{"id": 0, "parent": -1, "type": "stat", "value": 1.0, "mods": {"hp_pct": 0.1}},
		{"id": 1, "parent": 0, "type": "stat", "value": 1.0, "mods": {"power_pct": 0.05}},
		{"id": 2, "parent": 0, "type": "evolution", "value": 2.0, "skill": "boule_de_feu", "skill_mods": {"power_bonus": 0.2}},
		{"id": 3, "parent": 2, "type": "stat", "value": 1.0, "mods": {"speed_bonus": 3}},
	]}
	var mods := Destin.mods_for(tree, [0, 1, 2])
	assert_eq(mods["mods"], {"hp_pct": 0.1, "power_pct": 0.05}, "les stats des nœuds pris, pas celle du nœud 3")
	assert_eq(mods["skill_mods"], {"boule_de_feu": {"power_bonus": 0.2}}, "l'évolution de la Boule de feu")
	var team := duo_team(["mage", "guerrier"])
	team[0]["mods"] = mods["mods"]
	team[0]["skill_mods"] = mods["skill_mods"]
	var combat := Combat.create(data, team, duo_team(GM))
	var mage := combat.get_unit("a1")
	var stats: Dictionary = data.classes["mage"]["stats"]
	assert_eq(mage.max_hp, int(round(int(stats["max_hp"]) * 1.1)), "+10 % de PV")
	assert_eq(mage.power, int(round(int(stats["power"]) * 1.05)), "+5 % de puissance")
	var events := combat.resolve_turn([action("a1", "boule_de_feu", "b2")])
	assert_eq(damage_from(events, "a1", "b2"), int(round(round(skill_power("boule_de_feu") * 1.2) * mage.power / 100.0)), "Boule de feu +20 %, à la puissance du Destin")


func test_les_cles_du_destin() -> void:
	# Clé « en zone » : une fois par combat, la basique frappe tous les ennemis. Clé « libre » : la première forte ne lance pas sa recharge.
	var team := duo_team(["mage", "guerrier"])
	team[0]["skill_mods"] = {"boule_de_feu": {"zone_once": 1}, "nova": {"free_once": 1}}
	var combat := Combat.create(data, team, duo_team(GM))
	var events := combat.resolve_turn([action("a1", "boule_de_feu", "b2")])
	assert_eq(events_of_type(events, "zone_cast").size(), 1, "la Clé joue")
	assert_true(damage_from(events, "a1", "b1") > 0 and damage_from(events, "a1", "b2") > 0, "les deux ennemis sont touchés")
	heal_all(combat)
	var again := combat.resolve_turn([action("a1", "boule_de_feu", "b2")])
	assert_eq(damage_from(again, "a1", "b1"), 0, "une seule fois par combat")
	jump_to_turn(combat, 3)
	heal_all(combat)
	var free := combat.resolve_turn([action("a1", "nova", "b1")])
	assert_eq(events_of_type(free, "free_cast").size(), 1, "la première Nova est libre")
	assert_true(combat.can_use(combat.get_unit("a1"), "forte"), "la Nova est encore prête")
	heal_all(combat)
	combat.resolve_turn([action("a1", "nova", "b1")])
	assert_false(combat.can_use(combat.get_unit("a1"), "forte"), "la seconde lance sa recharge")


func test_l_evolution_rebond() -> void:
	var team := duo_team(["mage", "guerrier"])
	team[0]["skill_mods"] = {"boule_de_feu": {"bounce": 0.5}}
	var combat := Combat.create(data, team, duo_team(GM))
	var events := combat.resolve_turn([action("a1", "boule_de_feu", "b2")])
	assert_eq(events_of_type(events, "bounce").size(), 1, "la Boule de feu rebondit")
	var main := damage_from(events, "a1", "b2")
	assert_eq(main, int(round(skill_power("boule_de_feu") * class_power("mage"))), "la cible prend tout")
	assert_eq(damage_from(events, "a1", "b1"), int(round(skill_power("boule_de_feu") * class_power("mage") * 0.5 * (1.0 - pp("peau_de_fer", "reduction")))), "le second ennemi, la moitié (Peau de fer)")


func test_le_placement_au_hasard_et_les_etiquettes_des_modeles() -> void:
	# Le simulateur place les points au hasard (chaque modèle de nœud doit être mesuré) et nomme les modèles pris.
	var tree := tree_for("voleur", 5)
	var rng := RandomNumberGenerator.new()
	rng.seed = 1
	var taken: Array = []
	for i in range(int(data.destin_nodes["points"])):
		var pick := Destin.random_take(tree, taken, rng)
		assert_true(Destin.can_take(tree, taken, pick), "point %d : un nœud disponible" % (i + 1))
		taken.append(pick)
	assert_eq(taken.size(), int(data.destin_nodes["points"]), "tous les points placés")
	assert_eq(Destin.random_take(tree, range(tree["nodes"].size()), rng), -1, "arbre plein : plus rien à prendre")
	var known := Destin.template_ids(data)
	assert_true(known.has("stat:pv") and known.has("evolution:passive_flat") and known.has("pivot:solide") and known.has("cle:zone"), "les étiquettes des données")
	for i in range(6):
		var class_id: String = data.class_ids[i % data.class_ids.size()]
		var other := tree_for(class_id, 900 + i, i % 2 == 1, CombatUnit.random_picks(rng))
		for node in other["nodes"]:
			var label := Destin.template_of(node)
			assert_true(known.has(label), "%s : le nœud %d a un modèle connu des données (%s)" % [class_id, int(node["id"]), label])


func test_les_points_selon_le_niveau_et_le_placement_automatique() -> void:
	assert_eq(Destin.points_for_level(data, 1, false), 1, "niveau 1 : 1 point")
	assert_eq(Destin.points_for_level(data, 30, false), int(data.destin_nodes["points"]), "niveau 30 : 30 points")
	assert_eq(Destin.points_for_level(data, 45, false), int(data.destin_nodes["points"]), "jamais plus de 30")
	assert_eq(Destin.points_for_level(data, 7, true), 3, "l'acolyte : un point tous les deux niveaux")
	assert_eq(Destin.points_for_level(data, 30, true), int(data.destin_nodes["mini_points"]), "15 au niveau 30")
	assert_eq(Destin.points_for_level(data, -2, false), 0, "pas de niveau négatif")
	var tree := tree_for("archer", 8)
	var taken := Destin.auto_points(tree, [0], 12)
	assert_eq(taken.size(), 12, "12 points placés seuls")
	assert_eq(taken[0], 0, "la racine d'abord")
	for i in range(1, taken.size()):
		assert_true(Destin.can_take(tree, taken.slice(0, i), taken[i]), "point %d relié aux précédents" % (i + 1))
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	var random := Destin.random_points(tree, 9, rng)
	assert_eq(random.size(), 9, "9 points au hasard")
	assert_eq(Destin.labels_of(tree, random).split("+").size(), 9, "une étiquette par nœud pris")


func test_les_valeurs_propres_au_mini_destin() -> void:
	# « mini_strength » multiplie les bonus et la valeur d'un modèle dans le mini-Destin de l'acolyte, pas dans le Destin du joueur.
	# (Construction directe d'un arbre à graine fixe, sans la recherche de la cible, pour comparer le même arbre.)
	var config: Dictionary = data.destin_nodes
	var size := int(config["mini_size"])
	var counts: Dictionary = config["mini_counts"]
	var total := float(config["mini_total_value"])
	var picks := {"basique": 0, "moyenne": 1, "forte": 0, "passive": 2}
	var saved: Variant = config.get("mini_strength", {})
	config["mini_strength"] = {}
	var rng := RandomNumberGenerator.new()
	rng.seed = 31
	var before := Destin._build(data, "mage", picks, rng, size, counts, total, true)
	var evolution_label := ""
	var pivot_label := ""
	for node in before["nodes"]:
		if node["type"] == "evolution" and evolution_label == "":
			evolution_label = Destin.template_of(node)
		if node["type"] == "pivot" and pivot_label == "":
			pivot_label = Destin.template_of(node)
	assert_true(evolution_label != "" and pivot_label != "", "une évolution et un pivot dans le mini-Destin")
	config["mini_strength"] = {evolution_label: 2.0, pivot_label: 0.5}
	rng.seed = 31
	var after := Destin._build(data, "mage", picks, rng, size, counts, total, true)
	var seen := 0
	for i in range(after["nodes"].size()):
		var node: Dictionary = after["nodes"][i]
		var label := Destin.template_of(node)
		assert_eq(label, Destin.template_of(before["nodes"][i]), "même arbre, nœud %d" % i)
		var old_node: Dictionary = before["nodes"][i]
		if label == evolution_label:
			var has_float := false
			for key in old_node.get("skill_mods", {}):
				if old_node["skill_mods"][key] is float:
					has_float = true
					assert_eq(float(node["skill_mods"][key]), float(old_node["skill_mods"][key]) * 2.0, "%s : bonus doublé dans le mini-Destin" % label)
			if has_float:
				assert_eq(float(node["value"]), float(old_node["value"]) * 2.0, "%s : deux fois plus cher" % label)
			else:
				assert_eq(float(node["value"]), float(old_node["value"]), "%s : un chiffre entier ne bouge pas" % label)
			seen += 1
		elif label == pivot_label:
			for key in old_node["mods"]:
				assert_eq(float(node["mods"][key]), float(old_node["mods"][key]) * 0.5, "%s : bonus de moitié" % label)
			assert_eq(float(node["value"]), float(old_node["value"]) * 0.5, "%s : moitié prix" % label)
			seen += 1
	assert_true(seen >= 2, "les deux modèles concernés sont dans l'arbre")
	rng.seed = 31
	var big := Destin._build(data, "mage", picks, rng, int(config["size"]), config["counts"], float(config["total_value"]), false)
	config["mini_strength"] = saved
	rng.seed = 31
	var big_before := Destin._build(data, "mage", picks, rng, int(config["size"]), config["counts"], float(config["total_value"]), false)
	assert_eq(big["nodes"], big_before["nodes"], "le Destin du joueur ne change pas")
