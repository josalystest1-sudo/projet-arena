## Chargement des données de jeu : classes, compétences, passifs, Synergies, états, règles, IA, Tour.
## Module pur : aucune dépendance aux nœuds de scène. Les données vivent dans res://data/.
class_name CombatData
extends RefCounted

const DATA_DIR := "res://data/"

var classes: Dictionary = {}
## Les classes dans l'ordre des données (data/classes.json) : celui des écrans.
var class_ids: Array[String] = []
var skills: Dictionary = {}
var passives: Dictionary = {}
var statuses: Dictionary = {}
var synergies: Array = []
var _synergy_by_id: Dictionary = {}
## Règles chiffrées du combat (mort subite, recharges...), dans data/rules.json.
var rules: Dictionary = {}
## L'IA : comment joue l'acolyte selon son rôle, ses seuils et les raisons affichées, dans data/ia.json.
var ai: Dictionary = {}
## La Tour : étages, ennemis, PV rendus entre deux étages, dans data/tower.json.
var tower: Dictionary = {}
## Le bestiaire de la Tour (data/bestiaire.json) : les monstres, leurs familles et leurs rangs. Leurs compétences et
## leurs passifs propres sont rangés avec les autres (skills, passives), marqués « monster ».
var monsters: Dictionary = {}
var monster_families: Dictionary = {}
var monster_ranks: Dictionary = {}
## Le budget de puissance des Destins (data/destins.json), en ajustement des PV et de la puissance (+0,04 = +4 %) :
## « kit_items » pour un élément seul qui n'a pas de chiffre à régler (Rempart, Résonance, Météorologue) ;
## « kit_pairs » pour une paire d'un même kit qui va trop bien (ou trop mal) ensemble ; « kit_triples » pour les trois
## compétences ensemble (clé : les trois dans l'ordre alphabétique, ex. « arc_de_foudre+etincelle+nova »).
## En duo, le partenaire compte aussi : « duo_items » (un élément selon la classe du partenaire, ex. un Bouclier de mana
## à côté d'un Guerrier), « duo_classes » (la composition du duo) et « duo_orders » (qui en est le joueur et qui
## l'acolyte : « mage>guerrier », un Mage avec son acolyte Guerrier). Un acolyte, toujours joué par l'IA, a aussi son
## ajustement par classe : « acolyte_classes ». Enfin, un même kit n'a pas la même force joué par le joueur et joué
## par l'acolyte (un Destin de joueur n'est jamais joué en acolyte) : « kits » donne, par côté (« joueur », « acolyte »)
## et par kit complet (clé : classe puis ses quatre éléments, ex. « pretre:priere+restauration+egide+foi »), le reste
## à corriger une fois tout le reste appliqué.
var destins: Dictionary = {}
## Les modèles de nœuds du Destin (data/destin_nodes.json) : tailles, parts, valeurs en points de puissance.
var destin_nodes: Dictionary = {}


static func load_default() -> CombatData:
	return load_from_dir(DATA_DIR)


static func load_from_dir(dir: String) -> CombatData:
	var data := CombatData.new()
	data.skills = _read_json(dir + "skills.json")
	data.passives = _read_json(dir + "passives.json")
	data.statuses = _read_json(dir + "statuses.json")
	data.synergies = _read_json(dir + "synergies.json")
	for synergy in data.synergies:
		data._synergy_by_id[str(synergy["id"])] = synergy
	data.rules = _read_json(dir + "rules.json")
	data.ai = _read_json(dir + "ia.json")
	data.tower = _read_json(dir + "tower.json")
	data.destins = _read_json(dir + "destins.json")
	data.destin_nodes = _read_json(dir + "destin_nodes.json")
	for class_id in _read_json(dir + "classes.json"):
		data.class_ids.append(str(class_id))
		data.classes[class_id] = _read_json(dir + "classes/" + class_id + ".json")
	var bestiary: Dictionary = _read_json(dir + "bestiaire.json")
	data.monsters = bestiary.get("monsters", {})
	data.monster_families = bestiary.get("families", {})
	data.monster_ranks = bestiary.get("ranks", {})
	for skill_id in bestiary.get("skills", {}):
		data.skills[skill_id] = bestiary["skills"][skill_id]
		data.skills[skill_id]["monster"] = true
	for passive_id in bestiary.get("passives", {}):
		data.passives[passive_id] = bestiary["passives"][passive_id]
		data.passives[passive_id]["monster"] = true
	return data


static func _read_json(path: String) -> Variant:
	var file := FileAccess.open(path, FileAccess.READ)
	assert(file != null, "Fichier de données introuvable : " + path)
	var text := file.get_as_text()
	var parsed: Variant = JSON.parse_string(text)
	assert(parsed != null, "JSON invalide : " + path)
	return parsed


func skill(skill_id: String) -> Dictionary:
	return skills.get(skill_id, {})


func skill_name(skill_id: String) -> String:
	return str(skill(skill_id).get("name", skill_id))


func passive_name(passive_id: String) -> String:
	return str(passives.get(passive_id, {}).get("name", passive_id))


## Clé d'une paire d'éléments d'un kit (deux compétences, ou une compétence et le passif), dans l'ordre alphabétique.
static func pair_key(a: String, b: String) -> String:
	return "%s+%s" % [a, b] if a < b else "%s+%s" % [b, a]


## Plafond de l'ajustement total d'un kit : au-delà, ce n'est plus un réglage à la marge, c'est l'effet qu'il faut revoir
## (le régleur à 10 classes avait fini par cumuler jusqu'à +60 % sur certains kits).
const MAX_KIT_BONUS := 0.25


## L'ajustement de PV et de puissance d'un kit (3 compétences + 1 passif) : ses éléments, ses paires, et en duo
## (partner_class non vide) ses éléments selon la classe du partenaire et la composition du duo. Plafonné à ±25 %.
func kit_bonus(skill_ids: Array, passive_id: String, own_class: String = "", partner_class: String = "", is_acolyte: bool = false) -> float:
	var singles: Dictionary = destins.get("kit_items", {})
	var pairs: Dictionary = destins.get("kit_pairs", {})
	var with_partner: Dictionary = destins.get("duo_items", {}).get(partner_class, {})
	var items: Array = skill_ids.duplicate()
	items.append(passive_id)
	var total := 0.0
	for i in range(items.size()):
		total += float(singles.get(str(items[i]), 0.0)) + float(with_partner.get(str(items[i]), 0.0))
		for j in range(i + 1, items.size()):
			total += float(pairs.get(pair_key(str(items[i]), str(items[j])), 0.0))
	var trio: Array = skill_ids.duplicate()
	trio.sort()
	total += float(destins.get("kit_triples", {}).get("+".join(trio), 0.0))
	if partner_class != "":
		total += float(destins.get("duo_classes", {}).get(pair_key(own_class, partner_class), 0.0))
		var order := "%s>%s" % ([partner_class, own_class] if is_acolyte else [own_class, partner_class])
		total += float(destins.get("duo_orders", {}).get(order, 0.0))
	if is_acolyte:
		total += float(destins.get("acolyte_classes", {}).get(own_class, 0.0))
	if own_class != "":
		var side := "acolyte" if is_acolyte else "joueur"
		total += float(destins.get("kits", {}).get(side, {}).get(kit_key(own_class, skill_ids, passive_id), 0.0))
	return clampf(total, -MAX_KIT_BONUS, MAX_KIT_BONUS)


## Clé d'un kit complet : sa classe, puis ses trois compétences (basique, moyenne, forte) et son passif.
static func kit_key(class_id: String, skill_ids: Array, passive_id: String) -> String:
	var items: Array = skill_ids.duplicate()
	items.append(passive_id)
	return "%s:%s" % [class_id, "+".join(items)]


## Un chiffre d'un passif (data/passives.json, « params »). Les clés disent ce que fait le passif, quel que soit son
## nom (« reduction » : moins de dégâts subis ; « forte_minus » : forte qui revient plus tôt ; « regen » : se soigne
## en fin de tour…) : le moteur ne connaît que les clés, jamais les noms.
func passive_param(passive_id: String, key: String, fallback: float) -> float:
	var value: Variant = passives.get(passive_id, {}).get("params", {}).get(key, fallback)
	return float(value) if value is float or value is int else fallback


## Une liste d'un passif (ex. « immune » : les états contre lesquels il immunise).
func passive_list(passive_id: String, key: String) -> Array:
	var value: Variant = passives.get(passive_id, {}).get("params", {}).get(key, [])
	return value if value is Array else []


## Le chiffre que le régleur fait bouger pour un passif ou une Synergie (« lever » dans les données ; vide : pas de
## chiffre, il se règle par le budget du Destin).
func lever_of(entry: Dictionary) -> String:
	return str(entry.get("lever", ""))


## Un chiffre d'une Synergie (data/synergies.json, « params »).
func synergy_param(synergy_id: String, key: String, fallback: float) -> float:
	return float(synergy_by_id(synergy_id).get("params", {}).get(key, fallback))


## Remplace les {clé} d'une description par les chiffres : {clé%} donne un pourcentage (0,15 → 15 %),
## {clé} un nombre (1,5 → « 1,5 »).
static func fill(text: String, params: Dictionary) -> String:
	for key in params:
		if not (params[key] is float or params[key] is int):
			continue
		var value := float(params[key])
		text = text.replace("{%s%%}" % key, "%d %%" % int(round(value * 100.0)))
		var plain := str(int(value)) if is_equal_approx(value, round(value)) else ("%.1f" % value).replace(".", ",")
		text = text.replace("{%s}" % key, plain)
	return text


## Description d'une compétence, avec ses chiffres du moment : {percent}, {turns}, {value}... sont lus dans ses effets.
func skill_description(skill_id: String) -> String:
	var skill_data := skill(skill_id)
	var params := {}
	for effect in skill_data.get("effects", []):
		for key in effect:
			if not params.has(key) and (effect[key] is int or effect[key] is float):
				params[key] = effect[key]
	return fill(str(skill_data.get("description", "")), params)


func passive_description(passive_id: String) -> String:
	var passive: Dictionary = passives.get(passive_id, {})
	return fill(str(passive.get("description", "")), passive.get("params", {}))


func synergy_description(synergy: Dictionary) -> String:
	return fill(str(synergy.get("description", "")), synergy.get("params", {}))


## Comment joue un acolyte de cette classe (selon son rôle), avec les seuils des données.
func acolyte_rules(class_id: String) -> String:
	var role := role_of(class_id)
	return fill(str(ai.get("roles", {}).get(role, "")), ai.get("thresholds", {}))


func status_name(status_id: String) -> String:
	return str(statuses.get(status_id, {}).get("name", status_id))


func is_negative_status(status_id: String) -> bool:
	return status_flag(status_id, "negative")


## Un drapeau d'un état (data/statuses.json) : « negative », « control » (Provoqué, Gelé, Étourdi… retirés par
## Protocole, bloqués par Impassible), « dot » (dégâts en fin de tour), « untargetable » (on ne peut pas le viser).
func status_flag(status_id: String, flag: String) -> bool:
	return bool(statuses.get(status_id, {}).get(flag, false))


## Ce que fait un état pour l'IA (« kind » : protection, renfort, controle), vide si rien n'est dit.
func status_kind(status_id: String) -> String:
	return str(statuses.get(status_id, {}).get("kind", ""))


## Les états qui font des dégâts en fin de tour, dans l'ordre des données (saignement, brûlure, poison…).
func dot_statuses() -> Array[String]:
	var result: Array[String] = []
	for status_id in statuses:
		if status_flag(status_id, "dot"):
			result.append(str(status_id))
	return result


## Un coup au contact (épée, poing, canne…) : un type de dégâts physique et pas « à distance » (flèche, dague lancée).
## Les sorts (feu, givre, foudre, ombre, lumière) ne sont jamais au contact. Sert aux ripostes (Garde haute, Sang acide).
func is_contact(skill_id: String) -> bool:
	var skill_data := skill(skill_id)
	return str(skill_data.get("element", "")) in Combat.PHYSICAL and not bool(skill_data.get("ranged", false))


func class_name_of(class_id: String) -> String:
	if monsters.has(class_id):
		return str(monsters[class_id]["name"])
	return str(classes.get(class_id, {}).get("name", class_id))


func is_monster(class_id: String) -> bool:
	return monsters.has(class_id)


## Le rôle principal d'une classe ou d'un monstre (front, degats, soutien) : c'est lui que suit l'IA.
func role_of(class_id: String) -> String:
	if monsters.has(class_id):
		return str(monsters[class_id]["role"])
	return str(classes.get(class_id, {}).get("roles", [""])[0])


## Le rang d'un monstre, en toutes lettres (Sbire, Soldat, Élite, Gardien).
func monster_rank_name(monster_id: String) -> String:
	return str(monster_ranks.get(str(monsters.get(monster_id, {}).get("rank", "")), ""))


## Les monstres d'une famille (ou tous), Gardiens compris ou non, dans un ordre fixe.
func monsters_of(family: String = "", with_guardians: bool = true) -> Array[String]:
	var result: Array[String] = []
	for monster_id in monsters:
		var monster: Dictionary = monsters[monster_id]
		if family != "" and str(monster["family"]) != family:
			continue
		if not with_guardians and str(monster["rank"]) == "gardien":
			continue
		result.append(monster_id)
	result.sort()
	return result


## Retourne la Synergie reliant deux compétences, ou un dictionnaire vide. Un membre du couple peut être un joker
## de palier (« *forte » : n'importe quelle forte d'une autre classe, ex. Hymne + n'importe quelle forte).
func find_synergy(skill_a: String, skill_b: String) -> Dictionary:
	if skill_a == skill_b:
		return {}
	refresh_caches()
	var key := skill_a + "|" + skill_b
	if _synergy_cache.has(key):
		return _synergy_cache[key]
	var result := {}
	for synergy in synergies:
		var pair: Array = synergy["skills"]
		if (_matches(pair[0], skill_a, skill_b) and _matches(pair[1], skill_b, skill_a)) \
				or (_matches(pair[0], skill_b, skill_a) and _matches(pair[1], skill_a, skill_b)):
			result = synergy
			break
	_synergy_cache[key] = result
	return result


## Mémoires des recherches (couple de compétences -> Synergie, et kits d'acolyte possibles par kit de joueur) : le
## simulateur fait des centaines de recherches par duo tiré, et les tirages représentaient les trois quarts du temps
## d'un combat simulé. Elles se vident d'elles-mêmes si la liste des Synergies change (les tests en ajoutent).
var _synergy_cache: Dictionary = {}
var duo_cache: Dictionary = {}
var _cache_synergy_count: int = -1


func refresh_caches() -> void:
	if _cache_synergy_count != synergies.size():
		_synergy_cache.clear()
		duo_cache.clear()
		_cache_synergy_count = synergies.size()


## La compétence correspond-elle à un membre du couple ? Un joker « *palier » accepte toute compétence de ce palier
## d'une autre classe que l'autre membre du couple.
func _matches(pattern: String, skill_id: String, other_id: String) -> bool:
	if not pattern.begins_with("*"):
		return pattern == skill_id
	var candidate := skill(skill_id)
	return str(candidate.get("tier", "")) == pattern.substr(1) and str(candidate.get("class", "")) != str(skill(other_id).get("class", "?"))


func synergy_by_id(synergy_id: String) -> Dictionary:
	return _synergy_by_id.get(synergy_id, {})
