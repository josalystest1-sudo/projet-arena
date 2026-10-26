## Mini-simulateur (avant-goût de l'étape 3) : fait jouer l'IA contre elle-même.
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
	var skill_wins := {}
	var skill_games := {}
	for i in range(count):
		var team_a := []
		var team_b := []
		for class_id in ["guerrier", "mage", "pretre"]:
			team_a.append({"class_id": class_id, "picks": CombatUnit.random_picks(rng)})
			team_b.append({"class_id": class_id, "picks": CombatUnit.random_picks(rng)})
		var combat := Combat.create(data, team_a, team_b, rng.randi_range(0, 1))
		while not combat.finished:
			var actions := CombatAI.choose_team(combat, 0)
			actions.append_array(CombatAI.choose_team(combat, 1))
			for event in combat.resolve_turn(actions):
				if event["type"] == "synergy":
					synergies[event["id"]] = int(synergies.get(event["id"], 0)) + 1
		wins[combat.winner] += 1
		turns[combat.turn] = int(turns.get(combat.turn, 0)) + 1
		reasons[combat.end_reason] = int(reasons.get(combat.end_reason, 0)) + 1
		for unit in combat.units:
			for key in unit.skills.values() + [unit.passive]:
				skill_games[key] = int(skill_games.get(key, 0)) + 1
				if unit.team == combat.winner:
					skill_wins[key] = int(skill_wins.get(key, 0)) + 1
	print("Combats : %d   victoires A/B : %d / %d" % [count, wins[0], wins[1]])
	var keys := turns.keys()
	keys.sort()
	var line := "Durée (tours) :"
	for t in keys:
		line += " %d:%d" % [t, turns[t]]
	print(line)
	print("Fins : ", reasons)
	print("Synergies : ", synergies)
	var names := skill_games.keys()
	names.sort()
	for key in names:
		print("  %-22s %5.1f %%" % [key, 100.0 * float(skill_wins.get(key, 0)) / float(skill_games[key])])
	quit(0)
