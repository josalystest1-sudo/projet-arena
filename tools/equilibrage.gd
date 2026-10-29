## Le simulateur d'équilibrage du combat V2 en ligne de commande (la logique est dans tools/equilibrage_lib.gd).
## Un travailleur (une part d'une mesure, écrite en JSON) :
##   godot --headless --path . --script res://tools/equilibrage.gd -- simuler <matrice|routes|tour> <part> <parts> <n> <graine0> <sortie.json>
## Le rapport (additionne les parts d'un dossier, écrit le rapport en français et le résumé en JSON) :
##   godot --headless --path . --script res://tools/equilibrage.gd -- rapport <dossier> <rapport.md> <resume.json> "<titre>" [boutons.json]
## tools/regleur.py lance les travailleurs en parallèle, puis le rapport.
extends SceneTree

const Lib := preload("res://tools/equilibrage_lib.gd")


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var d := Donnees.defaut()
	if not d.erreurs.is_empty():
		for erreur in d.erreurs:
			printerr(erreur)
		quit(1)
		return
	match args[0] if args.size() > 0 else "":
		"simuler":
			var debut := Time.get_ticks_msec()
			var out := Lib.simuler(d, args[1], int(args[2]), int(args[3]), int(args[4]), int(args[5]))
			var f := FileAccess.open(args[6], FileAccess.WRITE)
			f.store_string(JSON.stringify(out))
			f.close()
			print("%s, part %s sur %s : %d s" % [args[1], args[2], args[3], (Time.get_ticks_msec() - debut) / 1000])
		"rapport":
			var parts: Array = []
			var dir := DirAccess.open(args[1])
			for nom in dir.get_files():
				if nom.ends_with(".json"):
					parts.append(JSON.parse_string(FileAccess.get_file_as_string(args[1].path_join(nom))))
			var mesure := Lib.fusionner(parts, d.ordre_classes.size())
			var r := Lib.resumer(d, mesure)
			var boutons: Array = []
			if args.size() > 5 and FileAccess.file_exists(args[5]):
				boutons = JSON.parse_string(FileAccess.get_file_as_string(args[5]))
			var md := FileAccess.open(args[2], FileAccess.WRITE)
			md.store_string(Lib.rapport(d, r, args[4], boutons))
			md.close()
			r["criteres"] = Lib.criteres(r)
			var js := FileAccess.open(args[3], FileAccess.WRITE)
			js.store_string(JSON.stringify(r, "  "))
			js.close()
			var tenus := 0
			for c in r["criteres"]:
				tenus += 1 if c["ok"] else 0
			print("%d critères tenus sur 6" % tenus)
		_:
			printerr("usage : simuler … ou rapport … (voir l'en-tête de tools/equilibrage.gd)")
			quit(1)
			return
	quit()
