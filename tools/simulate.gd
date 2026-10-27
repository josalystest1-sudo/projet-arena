## Mini-simulateur (avant-goût de l'étape 4) : fait jouer l'IA contre elle-même, duo contre duo.
## godot --headless --path . --script res://tools/simulate.gd -- 1000
extends SceneTree

var duel_synergies := {}


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
	var postures := {}
	for i in range(count):
		var combat := Combat.create(data, Duo.random_duo(data, rng), Duo.random_duo(data, rng), rng.randi_range(0, 1))
		var first_ko := 0
		while not combat.finished:
			var plan_a := CombatAI.plan_team(combat, 0)
			var plan_b := CombatAI.plan_team(combat, 1)
			for plan in [plan_a, plan_b]:
				postures[plan["posture"]] = int(postures.get(plan["posture"], 0)) + 1
			var actions: Array = plan_a["actions"]
			actions.append_array(plan_b["actions"])
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
	print("Postures choisies par les joueurs IA (par tour) : ", postures)
	var names := key_games.keys()
	names.sort()
	for key in names:
		print("  %-24s %5.1f %%  (%d)" % [key, 100.0 * float(key_wins.get(key, 0)) / float(key_games[key]), key_games[key]])
	# Pilier « le duo gagne » : jouer autour de son acolyte doit battre l'ignorer.
	print("")
	print("Jouer autour de l'acolyte (lit son annonce, cherche les Synergies, change de posture) :")
	print("  contre un joueur qui l'ignore (posture Libre, ne lit pas l'annonce) : %.1f %% de victoires" % _duel(data, count, "malin", "ignore"))
	print("  contre un joueur qui lit l'annonce mais laisse la posture sur Libre : %.1f %% de victoires" % _duel(data, count, "malin", "libre"))
	print("  lire l'annonce (posture Libre) contre l'ignorer : %.1f %%" % _duel(data, count, "libre", "ignore"))
	for posture in ["protege_moi", "fonce", "garde_ta_forte"]:
		print("  posture %s tout le combat, contre Libre tout le combat : %.1f %%" % [posture, _duel(data, count, "posture:" + posture, "libre")])
	quit(0)


## Fait s'affronter deux façons de jouer, sur les mêmes duos tirés au hasard (chaque façon joue un camp sur deux).
func _duel(data: CombatData, count: int, style_a: String, style_b: String) -> float:
	duel_synergies = {}
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var wins_a := 0
	for i in range(count):
		var combat := Combat.create(data, Duo.random_duo(data, rng), Duo.random_duo(data, rng), rng.randi_range(0, 1))
		var team_a := i % 2
		while not combat.finished:
			var actions: Array = _plan(combat, team_a, style_a)
			actions.append_array(_plan(combat, 1 - team_a, style_b))
			for event in combat.resolve_turn(actions):
				if event["type"] == "synergy":
					var side := "a" if combat.get_unit(event["actors"][0]).team == team_a else "b"
					duel_synergies[side] = int(duel_synergies.get(side, 0)) + 1
		if combat.winner == team_a:
			wins_a += 1
	print("    (Synergies par combat : %.2f contre %.2f)" % [float(duel_synergies.get("a", 0)) / count, float(duel_synergies.get("b", 0)) / count])
	return 100.0 * wins_a / count


func _plan(combat: Combat, team: int, style: String) -> Array:
	match style:
		"ignore":
			var actions: Array = []
			for unit in combat.team_units(team, true):
				if unit.is_acolyte:
					actions.append(CombatAI.decide_acolyte(combat, unit, CombatAI.LIBRE, null)["action"])
				else:
					actions.append(CombatAI.decide_leader(combat, unit, null)["action"])
			return actions
		"libre":
			return CombatAI.plan_team(combat, team, [], CombatAI.LIBRE)["actions"]
	if style.begins_with("posture:"):
		return CombatAI.plan_team(combat, team, [], style.substr(8))["actions"]
	return CombatAI.plan_team(combat, team)["actions"]
