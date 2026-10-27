## Chargement des données de jeu : classes, compétences, passifs, Synergies, états, règles, postures, Tour.
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
## Postures de l'acolyte : noms, descriptions et seuils de l'IA, dans data/postures.json.
var postures: Dictionary = {}
## La Tour : étages, ennemis, PV rendus entre deux étages, dans data/tower.json.
var tower: Dictionary = {}


static func load_default() -> CombatData:
	return load_from_dir(DATA_DIR)


static func load_from_dir(dir: String) -> CombatData:
	var data := CombatData.new()
	data.skills = _read_json(dir + "skills.json")
	data.passives = _read_json(dir + "passives.json")
	data.statuses = _read_json(dir + "statuses.json")
	data.synergies = _read_json(dir + "synergies.json")
	data.rules = _read_json(dir + "rules.json")
	data.postures = _read_json(dir + "postures.json")
	data.tower = _read_json(dir + "tower.json")
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
