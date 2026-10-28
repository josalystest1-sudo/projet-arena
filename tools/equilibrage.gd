## Simulateur d'équilibrage (étape 4) : des milliers de combats duo contre duo, l'IA aux commandes des deux camps.
## Écrit une ligne par camp et par combat dans un fichier CSV, analysé par tools/equilibrage.py.
## godot --headless --path . --script res://tools/equilibrage.gd -- <combats> <graine> <fichier.csv> [niveau]
## niveau : 0 (défaut) = sans Destin, comme au prototype ; N = les quatre personnages au niveau N (N points de
## Destin pour les joueurs, N/2 pour les mini-Destins des acolytes, placés au hasard pour que chaque modèle de nœud
## soit mesuré) ; « alea » = un niveau tiré entre 1 et 30 à chaque combat, le même pour les deux duos.
extends SceneTree

const MAX_LEVEL := 30
## Arbres gardés par kit (générer un Destin coûte quelques millisecondes ; un combat, bien moins).
const TREES_PER_KIT := 4
var _trees := {}


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var count := int(args[0]) if args.size() > 0 else 1000
	var seed_value := int(args[1]) if args.size() > 1 else 1
	var path := str(args[2]) if args.size() > 2 else "user://equilibrage.csv"
	var level_arg := str(args[3]) if args.size() > 3 else "0"
	var data := CombatData.load_default()
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_line("gagne,joueur,j_basique,j_moyenne,j_forte,j_passif,acolyte,a_basique,a_moyenne,a_forte,a_passif,synergies_possibles,synergies_jouees,adverse,tours,fin,niveau,j_destin,a_destin")
	for i in range(count):
		var level := rng.randi_range(1, MAX_LEVEL) if level_arg == "alea" else int(level_arg)
		var duos := [Duo.random_duo(data, rng), Duo.random_duo(data, rng)]
		var destins := [["", ""], ["", ""]]
		if level > 0:
			for team in [0, 1]:
				for slot in [0, 1]:
					destins[team][slot] = _give_destin(data, duos[team][slot], level, slot == 1, rng)
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
			row.append_array([level, destins[team][0], destins[team][1]])
			file.store_line(",".join(row.map(func(value): return str(value))))
	file.close()
	quit(0)


## Donne à un membre d'un duo son Destin (ou son mini-Destin) au niveau demandé, points placés au hasard.
## Renvoie les étiquettes des modèles des nœuds pris (« stat:pv+evolution:power+… »), pour le CSV.
func _give_destin(data: CombatData, member: Dictionary, level: int, is_mini: bool, rng: RandomNumberGenerator) -> String:
	var picks: Dictionary = member["picks"]
	var key := "%s:%d%d%d%d:%s:%d" % [member["class_id"], int(picks.get("basique", 0)), int(picks.get("moyenne", 0)), int(picks.get("forte", 0)), int(picks.get("passive", 0)), "m" if is_mini else "j", rng.randi_range(0, TREES_PER_KIT - 1)]
	if not _trees.has(key):
		_trees[key] = Destin.generate(data, member["class_id"], picks, rng.randi(), is_mini)
	var tree: Dictionary = _trees[key]
	var taken := Destin.random_points(tree, Destin.points_for_level(data, level, is_mini), rng)
	var mods := Destin.mods_for(tree, taken)
	member["mods"] = mods["mods"]
	member["skill_mods"] = mods["skill_mods"]
	return Destin.labels_of(tree, taken)
