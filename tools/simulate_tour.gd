## Simulateur de la Tour : l'IA fait monter des duos tirés au hasard, pour régler la difficulté des étages.
## godot --headless --path . --script res://tools/simulate_tour.gd -- 500 [graine] [etages.csv] [niveau]
## Le fichier CSV (facultatif) a une ligne par étage joué : de quoi mesurer la menace réelle de chaque monstre.
## niveau : 0 (défaut) = sans Destin ; N = le duo au niveau N (Destin et mini-Destin, points placés au hasard) et
## les monstres renforcés en conséquence (Tower, « level_scale ») ; « alea » = un niveau tiré entre 1 et 30 par montée.
extends SceneTree

const MAX_LEVEL := 30
const TREES_PER_KIT := 4
var _trees := {}


func _initialize() -> void:
	var count := 500
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		count = int(args[0])
	var data := CombatData.load_default()
	var rng := RandomNumberGenerator.new()
	rng.seed = int(args[1]) if args.size() > 1 else 17
	var csv: FileAccess = null
	if args.size() > 2 and str(args[2]) != "-":
		csv = FileAccess.open(str(args[2]), FileAccess.WRITE)
		csv.store_line("etage,famille,monstres,gagne,pv_perdus,tours,niveau")
	var level_arg := str(args[3]) if args.size() > 3 else "0"
	var group_sizes := {}
	var family_stats := {}
	var reached := {}
	var by_class := {}
	var lost_on := {}
	var turns_total := 0
	var floors_total := 0
	var limit_losses := 0
	for i in range(count):
		var level := rng.randi_range(1, MAX_LEVEL) if level_arg == "alea" else int(level_arg)
		var duo := Duo.random_duo(data, rng)
		if level > 0:
			for slot in [0, 1]:
				_give_destin(data, duo[slot], level, slot == 1, rng)
		var tower := Tower.start(data, duo, level)
		while not tower.finished:
			var combat := tower.create_combat(rng)
			var hp_before := 0
			var max_total := 0
			for unit in combat.team_units(0):
				hp_before += unit.hp
				max_total += unit.max_hp
			var monsters: Array = []
			for unit in combat.team_units(1):
				monsters.append(unit.class_id)
			var family := str(data.monsters[monsters[0]]["family"])
			if tower.is_boss_floor():
				family = "gardien " + str(monsters[0])
			group_sizes[monsters.size()] = int(group_sizes.get(monsters.size(), 0)) + 1
			while not combat.finished:
				var actions: Array = CombatAI.choose_team(combat, 0)
				actions.append_array(CombatAI.choose_team(combat, 1))
				combat.resolve_turn(actions)
			turns_total += combat.turn
			floors_total += 1
			if combat.end_reason == "limite_de_tours":
				limit_losses += 1
			var hp_after := 0
			for unit in combat.team_units(0):
				hp_after += unit.hp
			var lost := float(hp_before - hp_after) / float(max_total)
			if not family_stats.has(family):
				family_stats[family] = [0, 0, 0.0]
			family_stats[family][0] += 1
			family_stats[family][1] += 0 if combat.winner == 0 else 1
			family_stats[family][2] += lost
			if csv != null:
				csv.store_line("%d,%s,%s,%d,%.4f,%d,%d" % [tower.current_floor, family, "+".join(monsters), 1 if combat.winner == 0 else 0, lost, combat.turn, level])
			var result := tower.finish_floor(combat)
			if not result["won"]:
				lost_on[tower.current_floor] = int(lost_on.get(tower.current_floor, 0)) + 1
		var top := tower.reached + (1 if tower.cleared_all else 0)
		reached[top] = int(reached.get(top, 0)) + 1
		var class_id: String = duo[0]["class_id"]
		if not by_class.has(class_id):
			by_class[class_id] = []
		by_class[class_id].append(tower.reached)
	print("Montées : %d   tours par étage : %.1f   étages gagnés à la limite de tours (abandon) : %d" % [count, float(turns_total) / floors_total, limit_losses])
	var line := "Étage atteint (11 = sommet franchi) :"
	var keys := reached.keys()
	keys.sort()
	for key in keys:
		line += " %d:%d" % [key, reached[key]]
	print(line)
	var losses := "Étage où la montée s'arrête :"
	keys = lost_on.keys()
	keys.sort()
	for key in keys:
		losses += " %d:%d" % [key, lost_on[key]]
	print(losses)
	var sizes := "Monstres par étage :"
	keys = group_sizes.keys()
	keys.sort()
	for key in keys:
		sizes += " %d:%d" % [key, group_sizes[key]]
	print(sizes)
	keys = family_stats.keys()
	keys.sort()
	for key in keys:
		var stat: Array = family_stats[key]
		print("  %-22s %5d étages   chute %4.1f %%   PV perdus %4.1f %%" % [key, stat[0], 100.0 * stat[1] / stat[0], 100.0 * stat[2] / stat[0]])
	for class_id in by_class:
		var total := 0
		for value in by_class[class_id]:
			total += int(value)
		print("  joueur %-8s étage moyen %.1f" % [class_id, float(total) / by_class[class_id].size()])
	quit(0)


## Donne à un membre du duo son Destin (ou son mini-Destin) au niveau demandé, points placés au hasard.
func _give_destin(data: CombatData, member: Dictionary, level: int, is_mini: bool, rng: RandomNumberGenerator) -> void:
	var picks: Dictionary = member["picks"]
	var key := "%s:%d%d%d%d:%s:%d" % [member["class_id"], int(picks.get("basique", 0)), int(picks.get("moyenne", 0)), int(picks.get("forte", 0)), int(picks.get("passive", 0)), "m" if is_mini else "j", rng.randi_range(0, TREES_PER_KIT - 1)]
	if not _trees.has(key):
		_trees[key] = Destin.generate(data, member["class_id"], picks, rng.randi(), is_mini)
	var taken := Destin.random_points(_trees[key], Destin.points_for_level(data, level, is_mini), rng)
	var mods := Destin.mods_for(_trees[key], taken)
	member["mods"] = mods["mods"]
	member["skill_mods"] = mods["skill_mods"]
