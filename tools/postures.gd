## Banc d'essai des postures de l'acolyte : aucune ne doit dominer.
## Pour chaque rôle d'acolyte, chaque posture gardée tout le combat contre Libre tout le combat (même duos, chaque façon
## joue un camp sur deux), puis la façon de changer de posture du joueur IA contre Libre tout le combat.
## godot --headless --path . --script res://tools/postures.gd -- 1500 [front|degats|soutien]
extends SceneTree


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var count := int(args[0]) if args.size() > 0 else 1500
	var roles: Array = [str(args[1])] if args.size() > 1 else ["front", "degats", "soutien"]
	var data := CombatData.load_default()
	for role in roles:
		print("Acolyte %s :" % role)
		var postures: Array = data.postures["by_role"][role]
		for posture in postures:
			if posture == CombatAI.LIBRE:
				continue
			var result := _duel(data, count, role, posture)
			print("  %-16s tout le combat, contre Libre : %5.1f %%   %s" % [data.postures["postures"][posture]["name"], result["rate"], result["by_class"]])
		var smart := _duel(data, count, role, "")
		print("  le joueur IA qui change de posture (règles de choose_posture), contre Libre : %5.1f %%" % smart["rate"])
	quit(0)


## Une façon de jouer (posture fixe, ou "" pour les changements du joueur IA) contre Libre, sur des duos dont l'acolyte
## a le rôle donné (l'adversaire est tiré sans contrainte).
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
	var by_class := ""
	for class_id in class_games:
		by_class += "joueur %s %.0f %%  " % [class_id, 100.0 * int(class_wins.get(class_id, 0)) / int(class_games[class_id])]
	return {"rate": 100.0 * wins / count, "by_class": by_class}
