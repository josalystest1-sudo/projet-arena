## Chargement des données de jeu : classes, compétences, passifs, Synergies, états, règles, IA, Tour.
## Module pur : aucune dépendance aux nœuds de scène. Les données vivent dans res://data/.
class_name CombatData
extends RefCounted

const DATA_DIR := "res://data/"

var classes: Dictionary = {}
var skills: Dictionary = {}
var passives: Dictionary = {}
var statuses: Dictionary = {}
var synergies: Array = []
## Règles chiffrées du combat (mort subite, recharges...), dans data/rules.json.
var rules: Dictionary = {}
## L'IA : comment joue l'acolyte selon son rôle, ses seuils et les raisons affichées, dans data/ia.json.
var ai: Dictionary = {}
## La Tour : étages, ennemis, PV rendus entre deux étages, dans data/tower.json.
var tower: Dictionary = {}
## Le budget de puissance des Destins (data/destins.json), en ajustement des PV et de la puissance (+0,04 = +4 %) :
## « kit_items » pour un élément seul qui n'a pas de chiffre à régler (Rempart, Résonance, Météorologue) ;
## « kit_pairs » pour une paire d'un même kit qui va trop bien (ou trop mal) ensemble ; « kit_triples » pour les trois
## compétences ensemble (clé : les trois dans l'ordre alphabétique, ex. « arc_de_foudre+etincelle+nova »).
## En duo, le partenaire compte aussi : « duo_items » (un élément selon la classe du partenaire, ex. un Bouclier de mana
## à côté d'un Guerrier), « duo_classes » (la composition du duo) et « duo_orders » (qui en est le joueur et qui
## l'acolyte : « mage>guerrier », un Mage avec son acolyte Guerrier). Un acolyte, toujours joué par l'IA, a aussi son
## ajustement par classe : « acolyte_classes ».
var destins: Dictionary = {}


static func load_default() -> CombatData:
	return load_from_dir(DATA_DIR)


static func load_from_dir(dir: String) -> CombatData:
	var data := CombatData.new()
	data.skills = _read_json(dir + "skills.json")
	data.passives = _read_json(dir + "passives.json")
	data.statuses = _read_json(dir + "statuses.json")
	data.synergies = _read_json(dir + "synergies.json")
	data.rules = _read_json(dir + "rules.json")
	data.ai = _read_json(dir + "ia.json")
	data.tower = _read_json(dir + "tower.json")
	data.destins = _read_json(dir + "destins.json")
	var class_ids: Array = _read_json(dir + "classes.json")
	for class_id in class_ids:
		data.classes[class_id] = _read_json(dir + "classes/" + class_id + ".json")
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


## L'ajustement de PV et de puissance d'un kit (3 compétences + 1 passif) : ses éléments, ses paires, et en duo
## (partner_class non vide) ses éléments selon la classe du partenaire et la composition du duo.
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
	return total


## Un chiffre d'un passif (data/passives.json, « params »).
func passive_param(passive_id: String, key: String, fallback: float) -> float:
	return float(passives.get(passive_id, {}).get("params", {}).get(key, fallback))


## Un chiffre d'une Synergie (data/synergies.json, « params »).
func synergy_param(synergy_id: String, key: String, fallback: float) -> float:
	for synergy in synergies:
		if synergy["id"] == synergy_id:
			return float(synergy.get("params", {}).get(key, fallback))
	return fallback


## Remplace les {clé} d'une description par les chiffres : {clé%} donne un pourcentage (0,15 → 15 %),
## {clé} un nombre (1,5 → « 1,5 »).
static func fill(text: String, params: Dictionary) -> String:
	for key in params:
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
	var role := str(classes.get(class_id, {}).get("roles", [""])[0])
	return fill(str(ai.get("roles", {}).get(role, "")), ai.get("thresholds", {}))


func status_name(status_id: String) -> String:
	return str(statuses.get(status_id, {}).get("name", status_id))


func is_negative_status(status_id: String) -> bool:
	return bool(statuses.get(status_id, {}).get("negative", false))


func class_name_of(class_id: String) -> String:
	return str(classes.get(class_id, {}).get("name", class_id))


## Retourne la Synergie reliant deux compétences, ou un dictionnaire vide.
func find_synergy(skill_a: String, skill_b: String) -> Dictionary:
	for synergy in synergies:
		var pair: Array = synergy["skills"]
		if (pair[0] == skill_a and pair[1] == skill_b) or (pair[0] == skill_b and pair[1] == skill_a):
			return synergy
	return {}
