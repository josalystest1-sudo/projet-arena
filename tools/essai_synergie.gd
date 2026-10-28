## Diagnostic : un duo précis (joueur Invocateur à Golem + acolyte Prêtre à Prière) contre des duos tirés au hasard,
## avec puis sans la Synergie « golem_priere ». Si le duo gagne plus sans elle, c'est l'effet (ou l'IA) qui nuit.
## godot --headless --path . --script res://tools/essai_synergie.gd -- <combats> <synergie> <classe joueur> <basique> <moyenne> <forte> <passif> <classe acolyte> <basique> <moyenne> <forte> <passif>
extends SceneTree


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var count := int(args[0])
	var synergy_id := str(args[1])
	var player := {"class_id": str(args[2]), "picks": {"basique": int(args[3]), "moyenne": int(args[4]), "forte": int(args[5]), "passive": int(args[6])}}
	var acolyte := {"class_id": str(args[7]), "picks": {"basique": int(args[8]), "moyenne": int(args[9]), "forte": int(args[10]), "passive": int(args[11])}, "is_acolyte": true}
	for with_synergy in [true, false]:
		var data := CombatData.load_default()
		if not with_synergy:
			var kept: Array = []
			for synergy in data.synergies:
				if str(synergy["id"]) != synergy_id:
					kept.append(synergy)
			data.synergies = kept
		data.refresh_caches()
		var rng := RandomNumberGenerator.new()
		rng.seed = 5
		var wins := 0
		var fired := 0
		var turns := 0
		for i in range(count):
			var team: Array = [player.duplicate(true), acolyte.duplicate(true)]
			var enemy := Duo.random_duo(data, rng)
			var combat := Combat.create(data, team, enemy, rng.randi_range(0, 1))
			while not combat.finished:
				var actions: Array = CombatAI.choose_team(combat, 0)
				actions.append_array(CombatAI.choose_team(combat, 1))
				for event in combat.resolve_turn(actions):
					if event["type"] == "synergy" and combat.get_unit(event["actors"][0]).team == 0:
						fired += 1
			turns += combat.turn
			if combat.winner == 0:
				wins += 1
		print("%s %s : %d victoires sur %d (%.1f %%), Synergies déclenchées : %d, %.1f tours" % [synergy_id, "avec" if with_synergy else "sans", wins, count, 100.0 * wins / count, fired, float(turns) / count])
	quit(0)
