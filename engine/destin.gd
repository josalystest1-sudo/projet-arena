## Le Destin (GDD, « Le Destin ») : un arbre de 45 nœuds généré à la création, unique, non modifiable, où le joueur place
## 1 point par niveau (30 points). Quatre types de nœuds : Stat (bonus permanent), Évolution de compétence (modifie une
## des 3 actives ou le passif), Pivot (renforce le rôle secondaire), Clé (puissant, au bout d'un chemin de 3 nœuds).
## Le mini-Destin de l'acolyte : 15 nœuds, mêmes règles, points placés seuls.
##
## Le budget de puissance : chaque nœud vaut des points de puissance (data/destin_nodes.json). Tous les arbres ont
## la même valeur totale et la même valeur atteignable avec les points disponibles (à 2 % près) : la différence
## entre deux Destins est une différence de forme et de combinaisons, jamais de puissance brute.
##
## Module pur : le hasard vient d'une graine (même graine, même classe, même kit : même arbre).
## Un arbre : {seed, mini, nodes: [{id, parent, depth, type, name, description, value, mods, skill, skill_mods}], total, best}.
class_name Destin
extends RefCounted

const TYPES := ["stat", "evolution", "pivot", "cle"]
const ATTEMPTS := 400


# ---------------------------------------------------------------------------
# Génération
# ---------------------------------------------------------------------------

## Génère le Destin d'un personnage (ou le mini-Destin de l'acolyte, mini = true).
static func generate(data: CombatData, class_id: String, picks: Dictionary, seed_value: int, mini: bool = false) -> Dictionary:
	var config: Dictionary = data.destin_nodes
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var size := int(config.get("mini_size" if mini else "size", 45))
	var points := int(config.get("mini_points" if mini else "points", 30))
	var counts: Dictionary = config.get("mini_counts" if mini else "counts", {})
	var total_target := float(config.get("mini_total_value" if mini else "total_value", 60.0))
	var best_target := float(config.get("mini_best_value" if mini else "best_value", 46.0))
	var tolerance := float(config.get("tolerance", 0.02))
	var best_tree := {}
	var best_gap := INF
	for attempt in range(ATTEMPTS):
		var tree := _build(data, class_id, picks, rng, size, counts, total_target, mini)
		tree["seed"] = seed_value
		tree["mini"] = mini
		tree["best"] = best_value(tree, points)
		var gap := absf(tree["best"] - best_target) / best_target
		if gap < best_gap:
			best_gap = gap
			best_tree = tree
		if gap <= tolerance:
			break
	best_tree["attempts_gap"] = best_gap
	return best_tree


## Un arbre : sa forme (un parent par nœud, trois enfants au plus), puis le contenu de chaque nœud, puis la mise
## à l'échelle des nœuds de Stat pour que la valeur totale tombe juste.
static func _build(data: CombatData, class_id: String, picks: Dictionary, rng: RandomNumberGenerator, size: int, counts: Dictionary, total_target: float, mini: bool = false) -> Dictionary:
	var max_children := int(data.destin_nodes.get("max_children", 3))
	var nodes: Array = []
	var children: Array = []
	for i in range(size):
		var parent := -1
		var depth := 0
		if i > 0:
			var candidates: Array = []
			for j in range(i):
				if children[j] < max_children:
					candidates.append(j)
			parent = candidates[rng.randi_range(0, candidates.size() - 1)]
			children[parent] += 1
			depth = int(nodes[parent]["depth"]) + 1
		nodes.append({"id": i, "parent": parent, "depth": depth, "type": "stat"})
		children.append(0)

	# Les types : les Clés au bout d'un chemin (profondeur 3 au moins), les Évolutions (une au moins par élément du
	# kit), les Pivots, le reste en Stat. La racine est toujours une Stat.
	var pool: Array = range(1, size)
	_shuffle(pool, rng)
	var keys_wanted := int(counts.get("cle", 2))
	var deep: Array = []
	for i in pool:
		if int(nodes[i]["depth"]) >= 3 and children[i] == 0:
			deep.append(i)
	var assigned := {}
	for k in range(mini(keys_wanted, deep.size())):
		assigned[deep[k]] = "cle"
	var left: Array = []
	for i in pool:
		if not assigned.has(i):
			left.append(i)
	var evolutions := int(counts.get("evolution", 14))
	var pivots := int(counts.get("pivot", 7))
	for i in range(left.size()):
		assigned[left[i]] = "evolution" if i < evolutions else ("pivot" if i < evolutions + pivots else "stat")
	for i in assigned:
		nodes[i]["type"] = assigned[i]

	# Le contenu.
	var kit := Duo.kit_skills(data, class_id, picks)
	var passive_pool: Array = data.classes[class_id]["passives"]
	var passive: String = passive_pool[int(picks.get("passive", 0)) % passive_pool.size()]
	var elements: Array = kit.duplicate()
	elements.append(passive)
	var evolution_nodes: Array = []
	for node in nodes:
		if node["type"] == "evolution":
			evolution_nodes.append(node)
	# Chaque élément du kit a au moins une évolution ; les autres sont tirées au hasard.
	for k in range(evolution_nodes.size()):
		var element: String = elements[k] if k < elements.size() else elements[rng.randi_range(0, elements.size() - 1)]
		_fill_evolution(data, evolution_nodes[k], element, element == passive, rng)
	var secondary := str(data.classes[class_id]["roles"][1])
	for node in nodes:
		match str(node["type"]):
			"stat":
				_fill_stat(data, node, class_id, kit, rng)
			"pivot":
				_fill_pivot(data, node, class_id, secondary, rng)
			"cle":
				_fill_key(data, node, class_id, kit, rng)

	# Dans un mini-Destin, un modèle n'a pas la même force que chez le joueur (l'acolyte est de la classe complémentaire,
	# ses points vont sur un petit arbre) : sa valeur est multipliée par le facteur du modèle (« mini_values »).
	if mini:
		var factors: Dictionary = data.destin_nodes.get("mini_values", {})
		for node in nodes:
			var factor := float(factors.get(template_of(node), 1.0))
			if factor != 1.0:
				node["value"] = float(node["value"]) * factor
				if node.has("base_value"):
					node["base_value"] = float(node["base_value"]) * factor

	# Mise à l'échelle des Stats : la valeur totale de l'arbre est la même pour tous.
	var fixed := 0.0
	var stat_total := 0.0
	for node in nodes:
		if node["type"] == "stat":
			stat_total += float(node["value"])
		else:
			fixed += float(node["value"])
	var factor := clampf((total_target - fixed) / maxf(stat_total, 0.001), 0.5, 2.5)
	for node in nodes:
		if node["type"] == "stat":
			_scale_stat(node, factor)
	# Les vitesses restent entières : un second passage sur les autres Stats rattrape l'arrondi.
	var rounded := 0.0
	var smooth := 0.0
	for node in nodes:
		if node["type"] != "stat":
			continue
		if bool(node.get("integer", false)):
			rounded += float(node["value"])
		else:
			smooth += float(node["value"])
	var correction := clampf((total_target - fixed - rounded) / maxf(smooth, 0.001), 0.8, 1.25)
	for node in nodes:
		if node["type"] == "stat" and not bool(node.get("integer", false)):
			node["base_value"] = float(node["value"])
			_scale_stat(node, correction)
	var total := 0.0
	for node in nodes:
		total += float(node["value"])
	return {"nodes": nodes, "total": total}


static func _fill_stat(data: CombatData, node: Dictionary, class_id: String, kit: Array, rng: RandomNumberGenerator) -> void:
	var templates: Array = data.destin_nodes.get("stats", [])
	var usable: Array = []
	for template in templates:
		var needs := str(template.get("needs", ""))
		if needs == "" or _kit_has_effect(data, kit, needs):
			usable.append(template)
	var template: Dictionary = usable[rng.randi_range(0, usable.size() - 1)]
	# Un nœud de Stat est petit ou grand (une ou deux unités).
	var units := 1 if rng.randi_range(0, 99) < 65 else 2
	var element := _pick_element(data, class_id, rng)
	var mods := {}
	for key in template["mods"]:
		mods[str(key).replace("<element>", element)] = float(template["mods"][key]) * float(units)
	node["template"] = str(template["id"])
	node["units"] = units
	node["integer"] = bool(template.get("integer", false))
	node["element"] = element
	node["mods"] = mods
	node["value"] = float(template["value"]) * float(units)
	node["base_value"] = node["value"]
	node["name_template"] = str(template["name"])
	_name_stat(node)


static func _scale_stat(node: Dictionary, factor: float) -> void:
	# Une vitesse reste un nombre entier : on arrondit (et la valeur suit).
	var mods: Dictionary = node["mods"]
	var scaled := {}
	var applied := factor
	for key in mods:
		var value := float(mods[key]) * factor
		if bool(node.get("integer", false)):
			var rounded := maxf(1.0, round(value))
			applied = rounded / float(mods[key])
			value = rounded
		scaled[key] = value
	node["mods"] = scaled
	node["value"] = float(node["base_value"]) * applied
	_name_stat(node)


static func _name_stat(node: Dictionary) -> void:
	var mods: Dictionary = node["mods"]
	var amount := 0.0
	for key in mods:
		amount = float(mods[key])
	var n := int(round(amount)) if bool(node.get("integer", false)) else int(round(amount * 100.0))
	node["name"] = str(node["name_template"]).replace("{n}", str(n)).replace("{element}", str(node.get("element", "")))
	node["description"] = "Bonus permanent : " + str(node["name"]).to_lower() + "."


static func _fill_evolution(data: CombatData, node: Dictionary, element: String, is_passive: bool, rng: RandomNumberGenerator) -> void:
	var templates: Dictionary = data.destin_nodes.get("evolutions", {})
	node["skill"] = element
	if is_passive:
		var passive: Dictionary = data.passives.get(element, {})
		var lever := str(passive.get("lever", ""))
		var template: Dictionary = templates["passive"] if lever != "" else templates["passive_flat"]
		var passive_name := data.passive_name(element)
		if lever != "":
			var share := float(template.get("share", 0.25))
			node["mods"] = {lever: float(passive["params"][lever]) * share}
			node["name"] = str(template["name"]).replace("{passive}", passive_name)
			node["description"] = str(template["description"]).replace("{passive}", passive_name).replace("{n}", str(int(round(share * 100.0))))
		else:
			node["mods"] = template["mods"].duplicate()
			node["name"] = str(template["name"]).replace("{passive}", passive_name)
			node["description"] = str(template["description"]).replace("{passive}", passive_name).replace("{n}", str(int(round(float(template["mods"]["power_pct"]) * 100.0))))
		node["template"] = "passive" if lever != "" else "passive_flat"
		node["value"] = float(template["value"])
		return
	var skill := data.skill(element)
	var kinds: Array = ["power"]
	if _has_effect(skill, "status"):
		kinds.append("duration")
	if str(skill.get("tier", "")) != "basique":
		kinds.append("cooldown")
	if str(skill.get("target", "")) == "enemy" and _has_effect(skill, "damage"):
		kinds.append("bounce")
	var kind: String = kinds[rng.randi_range(0, kinds.size() - 1)]
	var template: Dictionary = templates[kind]
	var skill_name := data.skill_name(element)
	node["template"] = kind
	node["skill_mods"] = template["skill_mods"].duplicate()
	var n := 0
	for key in template["skill_mods"]:
		var v := float(template["skill_mods"][key])
		n = int(round(v * 100.0)) if v < 1.0 else int(v)
	node["name"] = str(template["name"]).replace("{skill}", skill_name).replace("{n}", str(n))
	node["description"] = str(template["description"]).replace("{skill}", skill_name).replace("{n}", str(n))
	node["value"] = float(template["value"]) + (0.3 if kind == "cooldown" and str(skill.get("tier", "")) == "forte" else 0.0)


static func _fill_pivot(data: CombatData, node: Dictionary, class_id: String, secondary: String, rng: RandomNumberGenerator) -> void:
	var templates: Array = data.destin_nodes.get("pivots", {}).get(secondary, [])
	var template: Dictionary = templates[rng.randi_range(0, templates.size() - 1)]
	var element := _pick_element(data, class_id, rng)
	var mods := {}
	var n := 0
	for key in template["mods"]:
		var v := float(template["mods"][key])
		mods[str(key).replace("<element>", element)] = v
		n = int(round(v * 100.0)) if v < 1.0 else int(v)
	node["template"] = str(template["id"])
	node["mods"] = mods
	node["name"] = str(template["name"])
	node["description"] = str(template["description"]).replace("{n}", str(n)).replace("{element}", element)
	node["value"] = float(template["value"])


static func _fill_key(data: CombatData, node: Dictionary, class_id: String, kit: Array, rng: RandomNumberGenerator) -> void:
	var templates: Array = data.destin_nodes.get("cles", [])
	var usable: Array = []
	for template in templates:
		var tier := str(template.get("tier", ""))
		if tier == "":
			usable.append(template)
			continue
		var skill_id := _kit_skill_of_tier(data, kit, tier)
		var skill := data.skill(skill_id)
		var needs := str(template.get("needs", ""))
		if needs == "enemy_damage" and not (str(skill.get("target", "")) == "enemy" and _has_effect(skill, "damage")):
			continue
		usable.append(template)
	var template: Dictionary = usable[rng.randi_range(0, usable.size() - 1)]
	node["template"] = str(template["id"])
	node["value"] = float(template["value"])
	var n := 0
	if template.has("mods"):
		node["mods"] = template["mods"].duplicate()
		for key in template["mods"]:
			n = int(round(float(template["mods"][key]) * 100.0))
		node["name"] = str(template["name"])
		node["description"] = str(template["description"]).replace("{n}", str(n))
	else:
		var skill_id := _kit_skill_of_tier(data, kit, str(template["tier"]))
		node["skill"] = skill_id
		node["skill_mods"] = template["skill_mods"].duplicate()
		node["name"] = str(template["name"]).replace("{skill}", data.skill_name(skill_id))
		node["description"] = str(template["description"]).replace("{skill}", data.skill_name(skill_id))


# ---------------------------------------------------------------------------
# Lecture et placement des points
# ---------------------------------------------------------------------------

## Les modificateurs que donnent les nœuds pris : {mods, skill_mods}, à passer à Combat.create.
static func mods_for(tree: Dictionary, taken: Array) -> Dictionary:
	var mods := {}
	var skill_mods := {}
	for node in tree.get("nodes", []):
		if not taken.has(int(node["id"])):
			continue
		for key in node.get("mods", {}):
			mods[key] = float(mods.get(key, 0.0)) + float(node["mods"][key])
		if node.has("skill_mods"):
			var current: Dictionary = skill_mods.get(node["skill"], {})
			for key in node["skill_mods"]:
				current[key] = float(current.get(key, 0.0)) + float(node["skill_mods"][key])
			skill_mods[node["skill"]] = current
	return {"mods": mods, "skill_mods": skill_mods}


## Peut-on prendre ce nœud ? Le premier point va à la racine ; ensuite, un nœud relié à un nœud pris.
static func can_take(tree: Dictionary, taken: Array, node_id: int) -> bool:
	if taken.has(node_id):
		return false
	var node := node_of(tree, node_id)
	if node.is_empty():
		return false
	if taken.is_empty():
		return int(node["parent"]) < 0
	if taken.has(int(node["parent"])):
		return true
	for other in tree["nodes"]:
		if int(other["parent"]) == node_id and taken.has(int(other["id"])):
			return true
	return false


static func available(tree: Dictionary, taken: Array) -> Array:
	var result: Array = []
	for node in tree.get("nodes", []):
		if can_take(tree, taken, int(node["id"])):
			result.append(int(node["id"]))
	return result


## Les points de Destin d'un personnage à un niveau donné : un par niveau pour le joueur (30 au plus), un tous les
## deux niveaux pour le mini-Destin de l'acolyte (15 au plus).
static func points_for_level(data: CombatData, level: int, is_mini: bool) -> int:
	if is_mini:
		return mini(maxi(level, 0) / 2, int(data.destin_nodes.get("mini_points", 15)))
	return mini(maxi(level, 0), int(data.destin_nodes.get("points", 30)))


## Place des points au hasard (simulateurs) : les nœuds pris, dans l'ordre.
static func random_points(tree: Dictionary, points: int, rng: RandomNumberGenerator) -> Array:
	var taken: Array = []
	for p in range(points):
		var next := random_take(tree, taken, rng)
		if next < 0:
			break
		taken.append(next)
	return taken


## Place des points seuls (l'acolyte, le duo IA d'en face) : le nœud disponible qui vaut le plus, jusqu'au compte.
static func auto_points(tree: Dictionary, taken: Array, points: int) -> Array:
	var result: Array = taken.duplicate()
	while result.size() < points:
		var next := auto_take(tree, result)
		if next < 0:
			break
		result.append(next)
	return result


## Les étiquettes des modèles des nœuds pris (« stat:pv+evolution:power+… »), pour les CSV des simulateurs.
static func labels_of(tree: Dictionary, taken: Array) -> String:
	var labels: Array = []
	for node_id in taken:
		labels.append(template_of(node_of(tree, node_id)))
	return "+".join(labels)


## Le placement au hasard (simulateur d'équilibrage) : un nœud disponible tiré au sort, pour que chaque modèle de
## nœud soit mesuré, pas seulement les plus précieux.
static func random_take(tree: Dictionary, taken: Array, rng: RandomNumberGenerator) -> int:
	var choices := available(tree, taken)
	if choices.is_empty():
		return -1
	return int(choices[rng.randi_range(0, choices.size() - 1)])


## L'étiquette du modèle d'un nœud (« stat:pv », « evolution:power », « pivot:solide », « cle:zone ») : c'est par
## modèle que le simulateur mesure les nœuds et que tools/regleur_destin.py règle leurs valeurs.
static func template_of(node: Dictionary) -> String:
	return "%s:%s" % [str(node.get("type", "")), str(node.get("template", ""))]


## Toutes les étiquettes de modèle que les données connaissent (data/destin_nodes.json).
static func template_ids(data: CombatData) -> Array[String]:
	var config: Dictionary = data.destin_nodes
	var result: Array[String] = []
	for template in config.get("stats", []):
		result.append("stat:" + str(template["id"]))
	for kind in config.get("evolutions", {}):
		result.append("evolution:" + str(kind))
	for role in config.get("pivots", {}):
		for template in config["pivots"][role]:
			result.append("pivot:" + str(template["id"]))
	for template in config.get("cles", []):
		result.append("cle:" + str(template["id"]))
	return result


## Le placement automatique (l'acolyte) : le nœud disponible qui vaut le plus (à égalité, le premier).
static func auto_take(tree: Dictionary, taken: Array) -> int:
	var best := -1
	var best_value := -1.0
	for node_id in available(tree, taken):
		var value := float(node_of(tree, node_id)["value"])
		if value > best_value:
			best = node_id
			best_value = value
	return best


static func node_of(tree: Dictionary, node_id: int) -> Dictionary:
	for node in tree.get("nodes", []):
		if int(node["id"]) == node_id:
			return node
	return {}


static func children_of(tree: Dictionary, node_id: int) -> Array:
	var result: Array = []
	for node in tree.get("nodes", []):
		if int(node["parent"]) == node_id:
			result.append(int(node["id"]))
	return result


## La valeur totale des nœuds pris.
static func taken_value(tree: Dictionary, taken: Array) -> float:
	var total := 0.0
	for node in tree.get("nodes", []):
		if taken.has(int(node["id"])):
			total += float(node["value"])
	return total


## La meilleure valeur atteignable avec un nombre de points (un sous-arbre connexe qui contient la racine), par
## programmation dynamique sur l'arbre.
static func best_value(tree: Dictionary, points: int) -> float:
	var nodes: Array = tree["nodes"]
	if nodes.is_empty() or points <= 0:
		return 0.0
	return _best(tree, 0, points)[mini(points, nodes.size())]


static func _best(tree: Dictionary, node_id: int, points: int) -> Array:
	var node := node_of(tree, node_id)
	var table: Array = []
	table.resize(points + 1)
	for j in range(points + 1):
		table[j] = -INF
	table[0] = 0.0
	if points >= 1:
		table[1] = float(node["value"])
	for child_id in children_of(tree, node_id):
		var child_table := _best(tree, child_id, points)
		var merged: Array = table.duplicate()
		for j in range(1, points + 1):
			if table[j] == -INF:
				continue
			for t in range(1, points - j + 1):
				if child_table[t] == -INF:
					continue
				merged[j + t] = maxf(merged[j + t], table[j] + child_table[t])
		table = merged
	# Avec j points, on peut toujours s'arrêter plus tôt : la meilleure valeur avec j au plus.
	for j in range(1, points + 1):
		table[j] = maxf(table[j], table[j - 1])
	return table


# ---------------------------------------------------------------------------
# Utilitaires
# ---------------------------------------------------------------------------

static func _shuffle(list: Array, rng: RandomNumberGenerator) -> void:
	for i in range(list.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp = list[i]
		list[i] = list[j]
		list[j] = tmp


static func _pick_element(data: CombatData, class_id: String, rng: RandomNumberGenerator) -> String:
	var elements: Array = data.classes[class_id].get("elements", ["contondant"])
	return str(elements[rng.randi_range(0, elements.size() - 1)])


static func _has_effect(skill: Dictionary, effect_type: String) -> bool:
	for effect in skill.get("effects", []):
		if str(effect["type"]) == effect_type:
			return true
	return false


static func _kit_has_effect(data: CombatData, kit: Array, effect_type: String) -> bool:
	for skill_id in kit:
		if _has_effect(data.skill(skill_id), effect_type):
			return true
	return false


static func _kit_skill_of_tier(data: CombatData, kit: Array, tier: String) -> String:
	for skill_id in kit:
		if str(data.skill(skill_id).get("tier", "")) == tier:
			return skill_id
	return str(kit[0])
