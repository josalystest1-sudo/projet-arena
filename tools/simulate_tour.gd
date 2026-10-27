## Simulateur de la Tour : l'IA fait monter des duos tirés au hasard, pour régler la difficulté des étages.
## godot --headless --path . --script res://tools/simulate_tour.gd -- 500
extends SceneTree


func _initialize() -> void:
	var count := 500
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		count = int(args[0])
	var data := CombatData.load_default()
	var rng := RandomNumberGenerator.new()
	rng.seed = 17
	var reached := {}
	var by_class := {}
	var lost_on := {}
	var turns_total := 0
	var floors_total := 0
	var limit_losses := 0
	for i in range(count):
		var duo := Duo.random_duo(data, rng)
		var tower := Tower.start(data, duo)
		while not tower.finished:
			var combat := tower.create_combat(rng)
			while not combat.finished:
				var actions: Array = CombatAI.choose_team(combat, 0)
				actions.append_array(CombatAI.choose_team(combat, 1))
				combat.resolve_turn(actions)
			turns_total += combat.turn
			floors_total += 1
			if combat.end_reason == "limite_de_tours":
				limit_losses += 1
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
	for class_id in by_class:
		var total := 0
		for value in by_class[class_id]:
			total += int(value)
		print("  joueur %-8s étage moyen %.1f" % [class_id, float(total) / by_class[class_id].size()])
	quit(0)
