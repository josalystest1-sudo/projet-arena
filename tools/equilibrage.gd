## Simulateur d'équilibrage (avant-goût de l'étape 4) : des milliers de combats duo contre duo, l'IA aux commandes
## des deux camps. Écrit une ligne par camp et par combat dans un fichier CSV, analysé par tools/equilibrage.py.
## godot --headless --path . --script res://tools/equilibrage.gd -- <combats> <graine> <fichier.csv>
extends SceneTree


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var count := int(args[0]) if args.size() > 0 else 1000
	var seed_value := int(args[1]) if args.size() > 1 else 1
	var path := str(args[2]) if args.size() > 2 else "user://equilibrage.csv"
	var data := CombatData.load_default()
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_line("gagne,joueur,j_basique,j_moyenne,j_forte,j_passif,acolyte,a_basique,a_moyenne,a_forte,a_passif,synergies_possibles,synergies_jouees,adverse,tours,fin")
	for i in range(count):
		var duos := [Duo.random_duo(data, rng), Duo.random_duo(data, rng)]
		var combat := Combat.create(data, duos[0], duos[1], rng.randi_range(0, 1))
		var fired := {0: 0, 1: 0}
		while not combat.finished:
			var actions: Array = CombatAI.choose_team(combat, 0)
			actions.append_array(CombatAI.choose_team(combat, 1))
			for event in combat.resolve_turn(actions):
				if event["type"] == "synergy":
					var team := combat.get_unit(event["actors"][0]).team
					fired[team] += 1
		for team in [0, 1]:
			var leader := combat.leader_of(team)
			var acolyte := combat.acolyte_of(team)
			var opponent := combat.leader_of(1 - team)
			var possible: Array = []
			for synergy in Duo.kit_synergies(data, leader.class_id, duos[team][0]["picks"], acolyte.class_id, duos[team][1]["picks"]):
				possible.append(synergy["id"])
			var row: Array = [1 if combat.winner == team else 0, leader.class_id]
			row.append_array([leader.skills["basique"], leader.skills["moyenne"], leader.skills["forte"], leader.passive])
			row.append(acolyte.class_id)
			row.append_array([acolyte.skills["basique"], acolyte.skills["moyenne"], acolyte.skills["forte"], acolyte.passive])
			row.append_array(["+".join(possible), fired[team], "%s+%s" % [opponent.class_id, combat.acolyte_of(1 - team).class_id], combat.turn, combat.end_reason])
			file.store_line(",".join(row.map(func(value): return str(value))))
	file.close()
	quit(0)
