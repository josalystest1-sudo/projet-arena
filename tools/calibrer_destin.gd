## Calibre les cibles du Destin : génère des arbres neufs (premier essai gardé, sans chercher la cible) et donne la
## médiane de leur valeur totale et de leur meilleure valeur avec 30 points. tools/regleur_destin.py s'en sert pour
## remettre « best_value » (data/destin_nodes.json) sur la valeur naturelle des arbres après avoir changé les valeurs.
## godot --headless --path . --script res://tools/calibrer_destin.gd -- [arbres] [graine]
extends SceneTree


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var count := int(args[0]) if args.size() > 0 else 100
	var seed_value := int(args[1]) if args.size() > 1 else 12345
	var data := CombatData.load_default()
	# Tolérance infinie : le premier arbre est gardé, c'est sa valeur naturelle qu'on mesure.
	data.destin_nodes["tolerance"] = 1.0e9
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var bests: Array[float] = []
	var totals: Array[float] = []
	for i in range(count):
		var class_id: String = data.class_ids[i % data.class_ids.size()]
		var tree := Destin.generate(data, class_id, CombatUnit.random_picks(rng), rng.randi(), false)
		bests.append(float(tree["best"]))
		totals.append(float(tree["total"]))
	bests.sort()
	totals.sort()
	print("arbres=%d best_median=%.2f total_median=%.2f best_min=%.2f best_max=%.2f" % [count, bests[count / 2], totals[count / 2], bests[0], bests[count - 1]])
	quit(0)
