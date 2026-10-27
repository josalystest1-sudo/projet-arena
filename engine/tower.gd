## La Tour (PvE) : le duo grimpe des étages générés, face à des monstres du bestiaire (de 1 à 4 par étage).
## Entre deux étages, le duo garde ses PV et ses recharges, et récupère 20 % de ses PV max (un KO revient avec 20 %).
## Pas de mort subite : un étage se perd seulement quand le duo tombe. Pour éviter les combats sans fin, les ennemis
## s'épuisent au bout de quelques tours (plus de soins ni de barrières) et abandonnent à la limite de tours.
## Module pur : le hasard vient d'un générateur fourni par l'appelant (même graine, même Tour).
class_name Tower
extends RefCounted

## De combien la menace d'un groupe peut dépasser le budget de l'étage (ou tomber en dessous) pour être acceptée.
const BUDGET_SLACK := 0.35

var data: CombatData
## Étage en cours (1 = le premier).
var current_floor: int = 1
## Le duo qui monte : ses membres pour Combat.create, mis à jour d'un étage à l'autre (PV, recharges).
var duo: Array = []
var finished: bool = false
## Étage atteint : celui où le duo est tombé, ou le dernier s'il a tout franchi. C'est le record du GDD.
var reached: int = 1
var cleared_all: bool = false
## Les monstres de l'étage à venir, tirés d'avance pour pouvoir les annoncer entre deux étages.
var planned: Array = []


static func start(p_data: CombatData, duo_members: Array) -> Tower:
	var tower := Tower.new()
	tower.data = p_data
	for member in duo_members:
		tower.duo.append(member.duplicate(true))
	return tower


func floor_count() -> int:
	return data.tower.get("floors", []).size()


func floor_info(number: int = -1) -> Dictionary:
	var floors: Array = data.tower.get("floors", [])
	var index := (current_floor if number < 0 else number) - 1
	return floors[clampi(index, 0, floors.size() - 1)]


func is_boss_floor(number: int = -1) -> bool:
	return bool(floor_info(number).get("boss", false))


## Les monstres de l'étage en cours (data/bestiaire.json), de 1 à 4 (data/tower.json, « max_monsters »).
## Un étage ordinaire tire une famille, puis des monstres de cette famille jusqu'à son budget de menace : beaucoup de
## petits ou peu de gros. Un étage de Gardien tire un Gardien, avec une escorte de sa famille si l'étage en prévoit une.
## La force de l'étage (PV et puissance en multiplicateurs) s'applique à tous ses monstres.
func floor_enemies(rng: RandomNumberGenerator) -> Array:
	var info := floor_info()
	var max_count := int(data.tower.get("max_monsters", 4))
	var group: Array[String] = []
	var family := ""
	var budget := float(info.get("budget", 2))
	if is_boss_floor():
		var guardians: Array[String] = []
		for monster_id in data.monsters_of():
			if str(data.monsters[monster_id]["rank"]) == "gardien":
				guardians.append(monster_id)
		var guardian: String = guardians[rng.randi_range(0, guardians.size() - 1)]
		group.append(guardian)
		family = str(data.monsters[guardian]["family"])
		budget = float(info.get("escort", 0))
	else:
		var families: Array = data.monster_families.keys()
		families.sort()
		family = str(families[rng.randi_range(0, families.size() - 1)])
	if budget > 0.0:
		group.append_array(_fill(data.monsters_of(family, false), budget, max_count - group.size(), rng))
	var enemies: Array = []
	var seen := {}
	for monster_id in group:
		var name := data.class_name_of(monster_id)
		seen[monster_id] = int(seen.get(monster_id, 0)) + 1
		if int(seen[monster_id]) > 1:
			name += " %d" % int(seen[monster_id])
		enemies.append({"monster_id": monster_id, "name": name, "max_hp_mult": float(info.get("hp", 1.0)),
			"power_mult": float(info.get("power", 1.0)), "heal_mult": float(data.tower.get("enemy_heal", 1.0))})
	return enemies


## Un groupe tiré au hasard parmi des monstres, dont la menace totale tombe sur le budget (au plus près si aucun
## tirage n'y arrive), sans dépasser max_count monstres ni un soigneur. Les plus menaçants passent devant (plus lisible à l'écran).
func _fill(candidates: Array[String], budget: float, max_count: int, rng: RandomNumberGenerator) -> Array[String]:
	var best: Array[String] = []
	var best_gap := INF
	for attempt in range(60):
		var group: Array[String] = []
		var left := budget
		while group.size() < max_count:
			var affordable: Array[String] = []
			for monster_id in candidates:
				if _menace(monster_id) <= left + BUDGET_SLACK and not (_is_support(monster_id) and _has_support(group)):
					affordable.append(monster_id)
			if affordable.is_empty():
				break
			var pick: String = affordable[rng.randi_range(0, affordable.size() - 1)]
			group.append(pick)
			left -= _menace(pick)
		var gap := absf(left)
		if gap < best_gap:
			best = group
			best_gap = gap
		if gap <= BUDGET_SLACK:
			break
	best.sort_custom(func(a, b): return _menace(a) > _menace(b) or (_menace(a) == _menace(b) and a < b))
	return best


## Au plus un soigneur par étage : à plusieurs, ils se soignent entre eux et l'étage s'éternise.
func _is_support(monster_id: String) -> bool:
	return str(data.monsters[monster_id]["role"]) == "soutien"


func _has_support(group: Array[String]) -> bool:
	for monster_id in group:
		if _is_support(monster_id):
			return true
	return false


func _menace(monster_id: String) -> float:
	return float(data.monsters[monster_id].get("menace", 1))


## Les monstres de l'étage en cours, tirés une seule fois (le même tirage sert à l'annonce et au combat).
func plan_floor(rng: RandomNumberGenerator) -> Array:
	if planned.is_empty():
		planned = floor_enemies(rng)
	return planned


## La famille des monstres de l'étage en cours (celle du Gardien sur un étage de Gardien).
func planned_family(rng: RandomNumberGenerator) -> String:
	return str(data.monsters[plan_floor(rng)[0]["monster_id"]]["family"])


## Le combat de l'étage en cours : pas de mort subite, limite de tours, recharges conservées.
func create_combat(rng: RandomNumberGenerator) -> Combat:
	var enemies := plan_floor(rng)
	planned = []
	var combat := Combat.create(data, duo, enemies, rng.randi_range(0, 1))
	combat.sudden_death_enabled = false
	combat.forced_end_turn = int(data.tower.get("turn_limit", 30))
	# Un étage ne se perd que si le duo tombe (GDD) : à la limite de tours, les ennemis épuisés abandonnent.
	combat.forced_end_winner = 0
	# Pour qu'aucun étage ne s'éternise : au bout de quelques tours, les ennemis s'épuisent (plus de soins ni de barrières).
	combat.exhausted_team = 1
	combat.exhaustion_turn = int(data.tower.get("exhaustion_turn", 12))
	# Les recharges sont conservées : après le premier étage, une forte prête l'est dès le tour 1.
	if current_floor > 1:
		combat.strong_available_from_turn = 1
	return combat


## Après le combat d'un étage. Gagné : le duo garde PV et recharges, récupère 20 % de ses PV max, et monte.
## Perdu : la montée s'arrête. Renvoie {won, report: [{id, before, after, revived}]}.
func finish_floor(combat: Combat) -> Dictionary:
	reached = current_floor
	if combat.winner != 0:
		finished = true
		return {"won": false, "report": []}
	var ratio := float(data.tower.get("heal_between_floors", 0.2))
	var report: Array = []
	for unit in combat.team_units(0):
		var bonus := int(round(float(unit.max_hp) * ratio))
		var after := mini(unit.hp + bonus, unit.max_hp) if unit.is_alive() else bonus
		var cooldowns := {}
		for tier in ["moyenne", "forte"]:
			cooldowns[tier] = maxi(0, int(unit.cooldown_until.get(tier, 0)) - (combat.turn + 1))
		var member: Dictionary = duo[unit.slot]
		member["hp"] = maxi(after, 1)
		member["cooldowns"] = cooldowns
		report.append({"id": unit.id, "before": unit.hp, "after": member["hp"], "revived": not unit.is_alive()})
	if current_floor >= floor_count():
		finished = true
		cleared_all = true
	else:
		current_floor += 1
	return {"won": true, "report": report}
