## Banc d'essai des postures de l'acolyte : aucune ne doit dominer.
## Pour chaque rôle d'acolyte, des duos dont l'acolyte a ce rôle affrontent des duos tirés au hasard qui jouent Libre.
## On mesure d'abord ces duos en Libre (la référence : elle n'est pas 50 %, certains duos sont plus forts que d'autres
## contre des adversaires au hasard), puis avec chaque posture gardée tout le combat, puis avec les changements de posture
## du joueur IA. Chaque ligne donne l'écart à la référence, en tout et selon la classe du joueur.
## godot --headless --path . --script res://tools/postures.gd -- 2000 [front|degats|soutien]
extends SceneTree


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var count := int(args[0]) if args.size() > 0 else 2000
	var roles: Array = [str(args[1])] if args.size() > 1 else ["front", "degats", "soutien"]
	var data := CombatData.load_default()
	for role in roles:
		print("Acolyte %s :" % role)
		var base := _duel(data, count, role, CombatAI.LIBRE)
		print("  %-20s %5.1f %%   %s" % ["Libre (référence)", base["rate"], _by_class(base, {})])
		var postures: Array = data.postures["by_role"][role]
		for posture in postures:
			if posture == CombatAI.LIBRE:
				continue
			var result := _duel(data, count, role, posture)
			print("  %-20s %+5.1f   %s" % [data.postures["postures"][posture]["name"], result["rate"] - base["rate"], _by_class(result, base)])
		var smart := _duel(data, count, role, "")
		print("  %-20s %+5.1f   %s" % ["Joueur IA (change)", smart["rate"] - base["rate"], _by_class(smart, base)])
	quit(0)


## Des duos dont l'acolyte a ce rôle, avec une posture fixe (ou "" : les changements du joueur IA), contre des duos tirés
## au hasard en Libre. Les mêmes tirages pour chaque posture (même graine).
func _duel(data: CombatData, count: int, role: String, posture: String) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var wins := 0
	var games := 0
	var class_wins := {}
	var class_games := {}
	while games < count:
		var duo: Array = Duo.random_duo(data, rng)
		if Duo.main_role(data, str(duo[1]["class_id"])) != role:
			continue
		var other: Array = Duo.random_duo(data, rng)
		var team_a := games % 2
		var combat := Combat.create(data, duo if team_a == 0 else other, other if team_a == 0 else duo, rng.randi_range(0, 1))
		while not combat.finished:
			var actions: Array = CombatAI.plan_team(combat, team_a, [], posture)["actions"]
			actions.append_array(CombatAI.plan_team(combat, 1 - team_a, [], CombatAI.LIBRE)["actions"])
			combat.resolve_turn(actions)
		var class_id := str(duo[0]["class_id"])
		class_games[class_id] = int(class_games.get(class_id, 0)) + 1
		games += 1
		if combat.winner == team_a:
			wins += 1
			class_wins[class_id] = int(class_wins.get(class_id, 0)) + 1
	var rates := {}
	for class_id in class_games:
		rates[class_id] = 100.0 * int(class_wins.get(class_id, 0)) / int(class_games[class_id])
	return {"rate": 100.0 * wins / count, "by_class": rates}


## Le taux selon la classe du joueur (ou l'écart à la référence quand elle est donnée).
func _by_class(result: Dictionary, base: Dictionary) -> String:
	var parts: Array = []
	var keys: Array = result["by_class"].keys()
	keys.sort()
	for class_id in keys:
		var rate: float = result["by_class"][class_id]
		if base.is_empty():
			parts.append("joueur %s %.0f %%" % [class_id, rate])
		else:
			parts.append("joueur %s %+.0f" % [class_id, rate - float(base["by_class"].get(class_id, 50.0))])
	return "  ".join(parts)
