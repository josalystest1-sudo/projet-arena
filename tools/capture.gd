## Ouvre l'application dans une fenêtre au format téléphone (540 × 960), joue une suite d'étapes et prend des
## captures d'écran : pour vérifier un écran sans export web ni téléphone. Le profil est gardé à part
## (user://capture_profil.cfg, effacé au départ) : le vrai profil n'est jamais touché.
##   godot --path . --script res://tools/capture.gd -- <dossier> '<étapes JSON>'
## Étapes : {"creer":"guerrier"} (nouveau perso, graine fixe 7), {"niveau":12} (niveau du perso), {"allumer":"v1.n2"},
## {"ecran":"destin"}, {"clic":[x,y]}, {"appui":[x,y,secondes]} (appui long), {"attendre":0.5}, {"capture":"nom"}.
## (Sans --headless : il faut une fenêtre pour dessiner.)
extends SceneTree

var app: ArenaApp


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var dossier: String = args[0] if args.size() > 0 else "user://captures"
	var etapes: Array = JSON.parse_string(args[1]) if args.size() > 1 else []
	PlayerProfile.chemin = "user://capture_profil.cfg"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PlayerProfile.chemin))
	DirAccess.make_dir_recursive_absolute(dossier)
	root.size = Vector2i(540, 960)
	app = load("res://scenes/app/app.tscn").instantiate()
	app.rng.seed = 7
	root.add_child(app)
	await _attendre(0.3)
	for etape in etapes:
		if etape.has("creer"):
			app.rng.seed = 7
			app.create_character(str(etape["creer"]))
		elif etape.has("niveau"):
			app.profile.level = int(etape["niveau"])
			app.gain_xp(0)
		elif etape.has("allumer"):
			app.allumer(str(etape["allumer"]))
		elif etape.has("ecran"):
			app.show_screen(str(etape["ecran"]))
		elif etape.has("clic"):
			await _clic(Vector2(etape["clic"][0], etape["clic"][1]), 0.05)
		elif etape.has("appui"):
			await _clic(Vector2(etape["appui"][0], etape["appui"][1]), float(etape["appui"][2]))
		elif etape.has("attendre"):
			await _attendre(float(etape["attendre"]))
		elif etape.has("capture"):
			await _attendre(0.15)
			var image := root.get_texture().get_image()
			var chemin := "%s/%s.png" % [dossier, etape["capture"]]
			image.save_png(chemin)
			print("capture : ", ProjectSettings.globalize_path(chemin))
	quit()


func _attendre(secondes: float) -> void:
	await create_timer(secondes).timeout


func _clic(pos: Vector2, duree: float) -> void:
	var bas := InputEventMouseButton.new()
	bas.button_index = MOUSE_BUTTON_LEFT
	bas.pressed = true
	bas.position = pos
	bas.global_position = pos
	root.push_input(bas)
	await _attendre(duree)
	var haut := bas.duplicate()
	haut.pressed = false
	root.push_input(haut)
	await _attendre(0.1)
