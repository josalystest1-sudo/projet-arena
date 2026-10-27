## Mini-simulateur (avant-goût de l'étape 4) : fait jouer l'IA contre elle-même, duo contre duo.
## godot --headless --path . --script res://tools/simulate.gd -- 1000
extends SceneTree


func _initialize() -> void:
	var count := 1000
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		count = int(args[0])
	var data := CombatData.load_default()
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var wins := {0: 0, 1: 0}
	var turns := {}
	var reasons := {}
	var synergies := {}
	var first_ko_total := 0
	var first_ko_count := 0
	var key_wins := {}
	var key_games := {}
	for i in range(count):
		var combat := Combat.create(data, Duo.random_duo(data, rng), Duo.random_duo(data, rng), rng.randi_range(0, 1))
		var first_ko := 0
		while not combat.finished:
			var actions := CombatAI.choose_team(combat, 0)
			actions.append_array(CombatAI.choose_team(combat, 1))
			for event in combat.resolve_turn(actions):
				if event["type"] == "synergy":
					synergies[event["name"]] = int(synergies.get(event["name"], 0)) + 1
				elif event["type"] == "ko" and first_ko == 0:
					first_ko = combat.turn
		if first_ko > 0:
			first_ko_total += first_ko
			first_ko_count += 1
		wins[combat.winner] += 1
		turns[combat.turn] = int(turns.get(combat.turn, 0)) + 1
		reasons[combat.end_reason] = int(reasons.get(combat.end_reason, 0)) + 1
		for unit in combat.units:
			var role := "acolyte " if unit.is_acolyte else "joueur "
			var keys: Array = unit.skills.values() + [unit.passive, "classe " + unit.class_id, role + unit.class_id]
			for key in keys:
				key_games[key] = int(key_games.get(key, 0)) + 1
				if unit.team == combat.winner:
					key_wins[key] = int(key_wins.get(key, 0)) + 1
	print("Combats : %d   victoires A/B : %d / %d" % [count, wins[0], wins[1]])
	var keys := turns.keys()
	keys.sort()
	var line := "Durée (tours) :"
	var in_target := 0
	var total_turns := 0
	for t in keys:
		line += " %d:%d" % [t, turns[t]]
		total_turns += int(t) * int(turns[t])
		if int(t) >= 8 and int(t) <= 15:
			in_target += int(turns[t])
	print(line)
	print("Moyenne : %.1f tours   entre 8 et 15 : %.0f %%   premier KO : tour %.1f" % [float(total_turns) / count, 100.0 * in_target / count, float(first_ko_total) / maxi(first_ko_count, 1)])
	print("Fins : ", reasons)
	print("Synergies : ", synergies)
	var names := key_games.keys()
	names.sort()
	for key in names:
		print("  %-24s %5.1f %%  (%d)" % [key, 100.0 * float(key_wins.get(key, 0)) / float(key_games[key]), key_games[key]])
	quit(0)
