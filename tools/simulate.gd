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
	var waits := 0
	var waits_paid := 0
	for i in range(count):
		var combat := Combat.create(data, Duo.random_duo(data, rng), Duo.random_duo(data, rng), rng.randi_range(0, 1))
		var first_ko := 0
		# Les acolytes qui ont gardé leur forte au tour précédent : leur Synergie s'est-elle déclenchée ce tour-ci ?
		var waited := {}
		while not combat.finished:
			var actions: Array = CombatAI.choose_team(combat, 0)
			actions.append_array(CombatAI.choose_team(combat, 1))
			var fired := {}
			for event in combat.resolve_turn(actions):
				if event["type"] == "synergy":
					synergies[event["name"]] = int(synergies.get(event["name"], 0)) + 1
					for actor in event["actors"]:
						fired[actor] = true
				elif event["type"] == "ko" and first_ko == 0:
					first_ko = combat.turn
			for unit_id in waited:
				if fired.has(unit_id):
					waits_paid += 1
			waited = {}
			for action in actions:
				if action.waits_for_synergy:
					waits += 1
					waited[action.actor_id] = true
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
	print("Attentes de l'acolyte pour une Synergie : %.2f par combat ; Synergie déclenchée au tour suivant dans %.0f %% des cas" % [float(waits) / count, 100.0 * waits_paid / maxi(waits, 1)])
	var names := key_games.keys()
	names.sort()
	for key in names:
		print("  %-24s %5.1f %%  (%d)" % [key, 100.0 * float(key_wins.get(key, 0)) / float(key_games[key]), key_games[key]])
	# Pilier « le duo gagne » : jouer autour de son acolyte doit battre l'ignorer.
	print("")
	print("Jouer autour de l'acolyte (lire son annonce et chercher les Synergies) :")
	print("  contre un joueur qui ignore son annonce : %.1f %% de victoires" % _duel(data, count, "malin", "ignore"))
	print("La règle d'attente (l'acolyte garde sa forte un tour pour une Synergie) :")
	print("  avec, contre sans : %.1f %% de victoires" % _duel(data, count, "malin", "sans_attente"))
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


## malin : le joueur IA lit l'annonce de son acolyte (comme en jeu) ; ignore : il ne la lit pas ;
## sans_attente : comme malin, mais l'acolyte n'attend jamais pour une Synergie.
func _plan(combat: Combat, team: int, style: String) -> Array:
	if style == "malin":
		return CombatAI.choose_team(combat, team)
	var actions: Array = []
	var announce: CombatAction = null
	var acolyte := combat.acolyte_of(team)
	if acolyte != null and acolyte.is_alive():
		announce = CombatAI.decide_acolyte(combat, acolyte, style != "sans_attente")["action"]
		actions.append(announce)
	for unit in combat.team_units(team, true):
		if unit != acolyte:
			actions.append(CombatAI.decide_leader(combat, unit, announce if style == "sans_attente" else null)["action"])
	return actions
