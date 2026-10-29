## Ouvre l'application dans une fenêtre au format téléphone (540 × 960), joue une suite d'étapes et prend des
## captures d'écran : pour vérifier un écran sans export web ni téléphone. Le profil est gardé à part
## (user://capture_profil.cfg, effacé au départ) : le vrai profil n'est jamais touché.
##   godot --path . --script res://tools/capture.gd -- <dossier> '<étapes JSON>'
## Étapes : {"creer":"guerrier"} (nouveau perso, graine fixe 7), {"niveau":12} (niveau du perso), {"allumer":"v1.n2"},
## {"ecran":"destin"}, {"duel":1} (un duel amical contre un trio IA), {"classe":1} (un combat classé de l'Arène), {"montee":1} (une montée de la Tour), {"fin":1} (un duel amical joué par l'IA, puis l'écran de fin ; {"fin":"classe"} : un combat classé), {"ouvrir":["versus",{"classe":true}]} (un écran avec ses options), {"gardien":5} (l'étage 5 d'une montée joué par l'IA, puis l'écran de fin : la Faveur du Gardien), {"sac":3} (trois objets dans le sac et 100 Éclats, pour la Forge), {"compter":["duels",2]} (un compteur des objectifs du jour), {"clic":[x,y]}, {"appui":[x,y,secondes]} (appui long), {"tenir":[x,y,secondes,"nom"]} (capture le doigt posé), {"attendre":0.5}, {"capture":"nom"}.
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
		elif etape.has("duel"):
			app.show_screen("combat", app.duel_contre_ia())
		elif etape.has("classe"):
			app.show_screen("combat", app.duel_classe())
		elif etape.has("montee"):
			app.show_screen("combat", app.commencer_tour())
		elif etape.has("ouvrir"):
			# Un écran avec ses options : {"ouvrir": ["versus", {"classe": true}]}.
			app.show_screen(str(etape["ouvrir"][0]), etape["ouvrir"][1] if etape["ouvrir"].size() > 1 else {})
		elif etape.has("fin"):
			# Un duel (amical, ou classé avec {"fin": "classe"}) joué jusqu'au bout par l'IA des deux côtés, puis l'écran de fin.
			var options := app.duel_classe() if str(etape["fin"]) == "classe" else app.duel_contre_ia()
			var e: EtatCombat = options["etat"]
			while not e.fini:
				e = Regles.resoudre_tour(e, IA.declarer(e))
			options["etat"] = e
			options["trace"] = {"a1": [{"nom": "Taillade", "cle": false}, {"nom": "Entaille", "cle": false}, {"nom": "Exsangue", "cle": true}], "b1": []}
			options["synergies"] = ["Brisure"]
			app.show_screen("fin", options)
		elif etape.has("gardien"):
			# Une montée depuis l'étage donné (un Gardien : 5, 10…), son étage joué jusqu'au bout par l'IA des deux
			# côtés, puis l'écran de fin (la carte « Faveur du Gardien » si c'est une première fois).
			var options := app.commencer_tour(int(etape["gardien"]))
			var e: EtatCombat = options["etat"]
			while not e.fini:
				e = Regles.resoudre_tour(e, IA.declarer(e))
			options["etat"] = e
			app.show_screen("fin", options)
		elif etape.has("sac"):
			# Des objets dans le sac (tirés comme un butin d'étage, puis de Gardien) et des Éclats, pour voir la Forge.
			for i in range(int(etape["sac"])):
				app.profile.sac.append(Equipement.butin("gardien" if i % 3 == 2 else "etage", app.profile.level, true, 100 + i, app.data))
			app.profile.eclats += 100
			app.profile.save()
		elif etape.has("compter"):
			app.compter(str(etape["compter"][0]), int(etape["compter"][1]))
		elif etape.has("clic"):
			await _clic(Vector2(etape["clic"][0], etape["clic"][1]), 0.05)
		elif etape.has("appui"):
			await _clic(Vector2(etape["appui"][0], etape["appui"][1]), float(etape["appui"][2]))
		elif etape.has("tenir"):
			# Appuyer, attendre, prendre la capture le doigt encore posé, puis relâcher : [x, y, secondes, nom].
			var pos := Vector2(etape["tenir"][0], etape["tenir"][1])
			var bas := InputEventMouseButton.new()
			bas.button_index = MOUSE_BUTTON_LEFT
			bas.pressed = true
			bas.position = pos
			bas.global_position = pos
			root.push_input(bas)
			await _attendre(float(etape["tenir"][2]))
			root.get_texture().get_image().save_png("%s/%s.png" % [dossier, etape["tenir"][3]])
			var haut := bas.duplicate()
			haut.pressed = false
			root.push_input(haut)
			await _attendre(0.1)
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
