## Un personnage en combat : stats, kit (une compétence par palier + un passif), recharges, états, modificateurs.
## Module pur : aucune dépendance aux nœuds de scène.
class_name CombatUnit
extends RefCounted

const TIERS := ["basique", "moyenne", "forte"]

var id: String
var display_name: String
var class_id: String
var team: int = 0
var slot: int = 0
var max_hp: int = 100
var hp: int = 100
var base_speed: int = 5
var power: int = 100
## Multiplicateur de ses soins (1 en PvP ; plus bas pour les ennemis de la Tour, pour qu'aucun étage ne s'éternise).
var heal_mult: float = 1.0
## Palier -> identifiant de compétence.
var skills: Dictionary = {}
var passive: String = ""
## Modificateurs permanents du personnage (les nœuds de son Destin, un jour l'évolution), par clé : les mêmes clés
## que les paramètres des passifs (« reduction », « forte_minus », « feu_bonus »…). Le moteur lit toujours la somme
## du paramètre du passif et du modificateur (Combat._pv).
var mods: Dictionary = {}
## Modificateurs propres à une compétence (évolutions de compétence du Destin) : identifiant -> {clé: valeur}.
var skill_mods: Dictionary = {}
## États contre lesquels il est immunisé (passif, Destin).
var immunities: Array = []
## La créature de l'Invocateur ({} s'il n'en a pas) : {kind, name, hp, max_hp, power, strike, element, turns}.
## Un Golem encaisse les coups directs destinés à son camp ; un Spectre frappe seul en fin de tour.
var creature: Dictionary = {}
## Palier -> numéro du tour à partir duquel la compétence est de nouveau disponible.
var cooldown_until: Dictionary = {}
var statuses: Array[Dictionary] = []
## Drapeaux « une fois par combat » (second_souffle, resurrection, revived...) et compteurs (esquives, combo...).
var flags: Dictionary = {}
var last_target: String = ""
## Le dernier ennemi qui lui a porté un coup direct.
var last_hit_by: String = ""
var is_player: bool = false
## Acolyte : second personnage du duo, toujours piloté par l'IA (le joueur ne contrôle jamais ses sorts).
var is_acolyte: bool = false
## Monstre de la Tour (data/bestiaire.json) : class_id est alors l'identifiant du monstre.
var is_monster: bool = false


## Construit une unité depuis une classe et des choix de kit (index par palier et index de passif).
## partner_class : la classe de l'autre membre du duo (vide hors duo) ; is_acolyte : un acolyte (joué par l'IA).
## Les deux servent au budget de puissance du Destin.
static func from_class(data: CombatData, p_class_id: String, picks: Dictionary, p_id: String, p_team: int, p_slot: int, partner_class: String = "", p_is_acolyte: bool = false) -> CombatUnit:
	var cls: Dictionary = data.classes[p_class_id]
	var unit := CombatUnit.new()
	unit.id = p_id
	unit.class_id = p_class_id
	unit.display_name = str(picks.get("name", cls["name"]))
	unit.team = p_team
	unit.slot = p_slot
	unit.max_hp = int(cls["stats"]["max_hp"])
	unit.hp = unit.max_hp
	unit.base_speed = int(cls["stats"]["speed"])
	unit.power = int(cls["stats"]["power"])
	for tier in TIERS:
		var pool: Array = cls["skills"][tier]
		unit.skills[tier] = pool[int(picks.get(tier, 0)) % pool.size()]
	var passive_pool: Array = cls["passives"]
	unit.passive = passive_pool[int(picks.get("passive", 0)) % passive_pool.size()]
	# Budget de puissance du Destin : un kit dont les pièces vont trop bien ensemble a un peu moins de PV et de
	# puissance, et inversement (data/destins.json).
	unit.is_acolyte = p_is_acolyte
	var bonus := data.kit_bonus(unit.skills.values(), unit.passive, p_class_id, partner_class, p_is_acolyte)
	if bonus != 0.0:
		unit.max_hp = maxi(1, int(round(float(unit.max_hp) * (1.0 + bonus))))
		unit.hp = unit.max_hp
		unit.power = maxi(1, int(round(float(unit.power) * (1.0 + bonus))))
	unit.setup_immunities(data)
	return unit


## Construit un monstre du bestiaire : ses stats et son kit sont fixes (pas de Destin).
static func from_monster(data: CombatData, monster_id: String, p_id: String, p_team: int, p_slot: int) -> CombatUnit:
	var monster: Dictionary = data.monsters[monster_id]
	var unit := CombatUnit.new()
	unit.id = p_id
	unit.class_id = monster_id
	unit.is_monster = true
	unit.display_name = str(monster["name"])
	unit.team = p_team
	unit.slot = p_slot
	unit.max_hp = int(monster["stats"]["max_hp"])
	unit.hp = unit.max_hp
	unit.base_speed = int(monster["stats"]["speed"])
	unit.power = int(monster["stats"]["power"])
	for tier in TIERS:
		unit.skills[tier] = str(monster["skills"][tier])
	unit.passive = str(monster.get("passive", ""))
	unit.setup_immunities(data)
	return unit


## Applique les modificateurs permanents (nœuds de Destin pris) : PV et puissance tout de suite, le reste est lu
## par le moteur au fil du combat.
func apply_mods(data: CombatData, p_mods: Dictionary, p_skill_mods: Dictionary = {}) -> void:
	for key in p_mods:
		if p_mods[key] is Array:
			# Une liste (« immune ») s'allonge.
			var merged: Array = mods.get(key, []).duplicate()
			for item in p_mods[key]:
				if not merged.has(item):
					merged.append(item)
			mods[key] = merged
		else:
			mods[key] = float(mods.get(key, 0.0)) + float(p_mods[key])
	for skill_id in p_skill_mods:
		var current: Dictionary = skill_mods.get(skill_id, {})
		for key in p_skill_mods[skill_id]:
			current[key] = float(current.get(key, 0.0)) + float(p_skill_mods[skill_id][key])
		skill_mods[skill_id] = current
	if mods.has("hp_pct"):
		max_hp = maxi(1, int(round(float(max_hp) * (1.0 + float(mods["hp_pct"])))))
		hp = max_hp
		mods.erase("hp_pct")
	if mods.has("power_pct"):
		power = maxi(1, int(round(float(power) * (1.0 + float(mods["power_pct"])))))
		mods.erase("power_pct")
	setup_immunities(data)


## Les immunités viennent du passif (« immune » dans ses paramètres) et des modificateurs.
func setup_immunities(data: CombatData) -> void:
	immunities = []
	for status_id in data.passive_list(passive, "immune"):
		immunities.append(str(status_id))
	for status_id in mods.get("immune", []):
		if not immunities.has(str(status_id)):
			immunities.append(str(status_id))


## Tire un kit au hasard (en attendant le générateur de Destin de l'étape 3).
static func random_picks(rng: RandomNumberGenerator) -> Dictionary:
	return {
		"basique": rng.randi_range(0, 1),
		"moyenne": rng.randi_range(0, 1),
		"forte": rng.randi_range(0, 1),
		"passive": rng.randi_range(0, 3),
	}


func is_alive() -> bool:
	return hp > 0


func hp_ratio() -> float:
	return float(hp) / float(max_hp)


func tier_of(skill_id: String) -> String:
	for tier in TIERS:
		if skills.get(tier, "") == skill_id:
			return tier
	return ""


func has_status(status_id: String) -> bool:
	return not get_status(status_id).is_empty()


func get_status(status_id: String) -> Dictionary:
	for status in statuses:
		if status["id"] == status_id:
			return status
	return {}


## Ajoute un état ; s'il existe déjà, garde la durée et la valeur les plus hautes.
func add_status(status: Dictionary) -> void:
	var existing := get_status(status["id"])
	if existing.is_empty():
		statuses.append(status.duplicate())
		return
	existing["turns"] = maxi(int(existing.get("turns", 0)), int(status.get("turns", 0)))
	existing["value"] = maxi(int(existing.get("value", 0)), int(status.get("value", 0)))
	if status.has("source"):
		existing["source"] = status["source"]


func remove_status(status_id: String) -> void:
	for i in range(statuses.size() - 1, -1, -1):
		if statuses[i]["id"] == status_id:
			statuses.remove_at(i)


func is_immune(status_id: String) -> bool:
	return immunities.has(status_id)


func has_creature() -> bool:
	return not creature.is_empty() and int(creature.get("hp", 0)) > 0


func barrier_amount() -> int:
	return int(get_status("barriere").get("value", 0))


func status_ids() -> Array[String]:
	var ids: Array[String] = []
	for status in statuses:
		ids.append(str(status["id"]))
	return ids


## Un modificateur propre à une compétence (évolution de Destin), 0 s'il n'y en a pas.
func skill_mod(skill_id: String, key: String) -> float:
	return float(skill_mods.get(skill_id, {}).get(key, 0.0))
