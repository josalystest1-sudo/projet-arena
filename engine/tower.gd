## La Tour (PvE, GDD) : le duo grimpe des étages générés, face à 2 ou 3 ennemis construits avec les classes du jeu.
## Entre deux étages, le duo garde ses PV et ses recharges, et récupère 20 % de ses PV max (un KO revient avec 20 %).
## Pas de mort subite : un étage se perd seulement quand le duo tombe. Pour éviter les combats sans fin, les ennemis
## s'épuisent au bout de quelques tours (plus de soins ni de barrières) et abandonnent à la limite de tours.
## Module pur : le hasard vient d'un générateur fourni par l'appelant (même graine, même Tour).
class_name Tower
extends RefCounted

var data: CombatData
## Étage en cours (1 = le premier).
var current_floor: int = 1
## Le duo qui monte : ses membres pour Combat.create, mis à jour d'un étage à l'autre (PV, recharges).
var duo: Array = []
var finished: bool = false
## Étage atteint : celui où le duo est tombé, ou le dernier s'il a tout franchi. C'est le record du GDD.
var reached: int = 1
var cleared_all: bool = false


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


## Les ennemis de l'étage en cours : classe et kit tirés au hasard, force réglée par l'étage (data/tower.json).
## Sur un étage de Gardien, le premier ennemi est le Gardien, avec plus de PV.
func floor_enemies(rng: RandomNumberGenerator) -> Array:
	var info := floor_info()
	var classes: Array = data.classes.keys()
	classes.sort()
	var names: Dictionary = data.tower.get("names", {})
	var enemies: Array = []
	var seen := {}
	for i in range(int(info.get("enemies", 2))):
		var class_id: String = classes[rng.randi_range(0, classes.size() - 1)]
		var name := str(names.get(class_id, data.class_name_of(class_id)))
		seen[name] = int(seen.get(name, 0)) + 1
		if int(seen[name]) > 1:
			name += " %d" % int(seen[name])
		var hp_mult := float(info.get("hp", 1.0))
		if i == 0 and is_boss_floor():
			name = "%s %s" % [data.tower.get("boss_name", "Gardien"), name]
			hp_mult *= float(data.tower.get("boss_hp", 1.5))
		enemies.append({"class_id": class_id, "picks": CombatUnit.random_picks(rng), "name": name,
			"max_hp_mult": hp_mult, "power_mult": float(info.get("power", 1.0)), "heal_mult": float(data.tower.get("enemy_heal", 1.0))})
	return enemies


## Le combat de l'étage en cours : pas de mort subite, limite de tours, recharges conservées.
func create_combat(rng: RandomNumberGenerator) -> Combat:
	var combat := Combat.create(data, duo, floor_enemies(rng), rng.randi_range(0, 1))
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
