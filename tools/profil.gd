## Chronomètre les grandes étapes du simulateur, pour savoir où va le temps.
## godot --headless --path . --script res://tools/profil.gd -- [combats]
extends SceneTree


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var count := int(args[0]) if args.size() > 0 else 200
	var data := CombatData.load_default()
	var rng := RandomNumberGenerator.new()
	rng.seed = 1
	var t0 := Time.get_ticks_usec()
	var duos: Array = []
	for i in range(count * 2):
		duos.append(Duo.random_duo(data, rng))
	var t1 := Time.get_ticks_usec()
	var turns := 0
	var ai_usec := 0
	var resolve_usec := 0
	var create_usec := 0
	for i in range(count):
		var c0 := Time.get_ticks_usec()
		var combat := Combat.create(data, duos[2 * i], duos[2 * i + 1], rng.randi_range(0, 1))
		create_usec += Time.get_ticks_usec() - c0
		while not combat.finished:
			var a0 := Time.get_ticks_usec()
			var actions: Array = CombatAI.choose_team(combat, 0)
			actions.append_array(CombatAI.choose_team(combat, 1))
			var a1 := Time.get_ticks_usec()
			combat.resolve_turn(actions)
			resolve_usec += Time.get_ticks_usec() - a1
			ai_usec += a1 - a0
			turns += 1
	var t2 := Time.get_ticks_usec()
	var s0 := Time.get_ticks_usec()
	var found := 0
	for i in range(2000):
		if not data.find_synergy("priere", "rempart").is_empty():
			found += 1
		if not data.find_synergy("nova", "ordre").is_empty():
			found += 1
	var s1 := Time.get_ticks_usec()
	print("%d combats, %d tours (%.1f par combat)" % [count, turns, float(turns) / count])
	print("  tirage des duos : %.1f ms par combat (%d duos)" % [(t1 - t0) / 1000.0 / count, count * 2])
	print("  création        : %.2f ms par combat" % [create_usec / 1000.0 / count])
	print("  IA              : %.1f ms par combat (%.2f ms par tour)" % [ai_usec / 1000.0 / count, ai_usec / 1000.0 / turns])
	print("  résolution      : %.1f ms par combat (%.2f ms par tour)" % [resolve_usec / 1000.0 / count, resolve_usec / 1000.0 / turns])
	print("  total           : %.1f ms par combat" % [(t2 - t0) / 1000.0 / count])
	print("  find_synergy    : %.1f µs par appel (%d synergies, %d trouvées)" % [(s1 - s0) / 4000.0, data.synergies.size(), found])
	quit(0)
