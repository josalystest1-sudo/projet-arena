## Ouvre l'application dans une fenêtre au format téléphone (540 × 960), joue une suite d'étapes et prend des
## captures d'écran : pour vérifier un écran sans export web ni téléphone. Le profil est gardé à part
## (user://capture_profil.cfg, effacé au départ) : le vrai profil n'est jamais touché.
##   godot --path . --script res://tools/capture.gd -- <dossier> '<étapes JSON>'
## Étapes : {"creer":"guerrier"} (nouveau perso, graine fixe 7), {"niveau":12} (niveau du perso), {"allumer":"v1.n2"},
## {"ecran":"destin"}, {"duel":1} (un duel amical contre un trio IA), {"classe":1} (un combat classé de l'Arène), {"donjon":"terrier"} (une descente, aux portes ; ["terrier","vague"] : la première vague jouée, puis la fin ; ["terrier","boss"] : le boss verrouillé jusqu'à la limite, puis la fin), {"montee":1} (une montée de la Tour), {"fin":1} (un duel amical joué par l'IA, puis l'écran de fin ; {"fin":"classe"} : un combat classé), {"ouvrir":["versus",{"classe":true}]} (un écran avec ses options), {"gardien":5} (l'étage 5 d'une montée joué par l'IA, puis l'écran de fin : la Faveur du Gardien), {"sac":3} (trois objets dans le sac et 100 Éclats, pour la Forge), {"compter":["duels",2]} (un compteur des objectifs du jour), {"echangeable":1} (un objet échangeable dans le sac), {"legendaire":1} (un objet légendaire, avec son trait, en tête du sac), {"guilde":900} (une guilde fondée, avec cette Influence), {"guerre":"auto"} (une attaque déclarée par ta guilde sur le premier territoire possible, tes trois combats gagnés par l'IA ; ou un identifiant de territoire), {"vieillir":7} (le compte a 7 jours de plus), {"or":500} (de l'Or), {"ameliorer":3} (le premier objet du sac à +3), {"energie":20} (l'énergie du personnage ; 0 : écroulé), {"record":30} (le record de la Tour de ta classe), {"clic":[x,y]}, {"appui":[x,y,secondes]} (appui long), {"tenir":[x,y,secondes,"nom"]} (capture le doigt posé), {"attendre":0.5}, {"capture":"nom"}.
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
			app.show_screen("combat", await app.duel_classe())
		elif etape.has("donjon"):
			# Une descente dans ce donjon (100 Éclats offerts), aux portes ; {"donjon": ["terrier", "vague"]} : la première
			# vague jouée par l'IA, puis l'écran de fin.
			var quoi: Variant = etape["donjon"]
			var id: String = str(quoi[0]) if quoi is Array else str(quoi)
			app.profile.eclats += 100
			app.commencer_donjon(id)
			if quoi is Array and quoi.size() > 1 and str(quoi[1]) == "boss":
				# Le combat du boss, verrouillé à son premier palier, jusqu'à la limite de tours : l'écran de fin dit ce qui a manqué.
				var dj: Donjon = app.donjon_en_cours
				var route := Donjon.route_boss(dj.id, dj.chasse, app.data)
				for k in range(route.size()):
					dj.choisir(Donjon.ordre_portes(dj.graine_joueur, dj.id, dj.chemin, app.data).find(route[k]))
					dj.phase = "portes"
				dj.phase = "combat"
				dj.finale = true
				var e: EtatCombat = dj.combat()
				e.perso("b1")["pv"] = 1
				dj.apres_tour(e)
				e.tour = int(app.data.boss["tours_max"]) + 1
				dj.apres_tour(e)
				app.show_screen("fin", {"etat": e, "donjon": dj, "noms": app.noms_trio(), "trace": {}, "synergies": [], "parts": {}})
			elif quoi is Array and quoi.size() > 1:
				var dj: Donjon = app.donjon_en_cours
				dj.choisir(0)
				var e: EtatCombat = dj.combat()
				while not e.fini:
					e = Regles.resoudre_tour(e, IA.declarer(e))
				app.show_screen("fin", {"etat": e, "donjon": dj, "noms": app.noms_trio(), "trace": {}, "synergies": [], "parts": {}})
			else:
				app.show_screen("donjon")
		elif etape.has("montee"):
			app.show_screen("combat", app.commencer_tour())
		elif etape.has("ouvrir"):
			# Un écran avec ses options : {"ouvrir": ["versus", {"classe": true}]}.
			app.show_screen(str(etape["ouvrir"][0]), etape["ouvrir"][1] if etape["ouvrir"].size() > 1 else {})
		elif etape.has("fin"):
			# Un duel (amical, ou classé avec {"fin": "classe"}) joué jusqu'au bout par l'IA des deux côtés, puis l'écran de fin.
			var options: Dictionary = (await app.duel_classe()) if str(etape["fin"]) == "classe" else app.duel_contre_ia()
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
				var raretes: Array = app.data.objets["raretes"].keys()
				var bases: Array = app.data.objets["bases"].keys()
				app.profile.sac.append(Equipement.tirer(str(bases[(i * 7) % bases.size()]), str(raretes[i % raretes.size()]), app.profile.level, 100 + i, app.data, false))
			app.profile.eclats += 100
			app.profile.save()
		elif etape.has("echangeable"):
			# Un objet échangeable dans le sac (comme un premier passage), pour le Comptoir.
			app.profile.sac.append(Equipement.butin("gardien", app.profile.level, true, 300 + int(etape["echangeable"]), app.data))
			app.profile.save()
		elif etape.has("legendaire"):
			# Un objet légendaire (avec son trait) dans le sac, pour la Forge.
			app.profile.sac.push_front(Equipement.tirer("epee", "legendaire", app.profile.level, 400 + int(etape["legendaire"]), app.data, false))
			app.profile.save()
		elif etape.has("guilde"):
			# Une guilde fondée (avec un peu d'Influence), pour l'écran de la Guilde.
			await app.creer_guilde("Les Nôtres", Guilde.banniere_defaut(app.graine, app.data))
			await app.serveur.influence_guilde(int(etape["guilde"]))
			await app.ma_guilde()
		elif etape.has("territoire"):
			# Ta guilde tient ce territoire cette saison (pour la carte du monde).
			var saison := str(Arene.saison(app.jour(), app.data))
			var tenus: Dictionary = app.profile.serveur.get("territoires", {})
			var liste: Array = tenus.get(saison, [])
			liste.append(str(etape["territoire"]))
			tenus[saison] = liste
			app.profile.serveur["territoires"] = tenus
			app.profile.save()
		elif etape.has("guerre"):
			# Une attaque déclarée par ta guilde sur ce territoire, et tes combats joués par l'IA (gagnés).
			var cible := str(etape["guerre"])
			if cible == "auto":
				# Le premier territoire que ta guilde peut viser ce soir.
				await app.carte_territoires()
				var liste: Array = await app.batailles_du_jour()
				for t in Carte.territoires_ouverts(app.nb_guildes, app.data):
					if app.empeche_guerre(str(t["id"]), liste) == "":
						cible = str(t["id"])
						break
			var b: Dictionary = await app.declarer_guerre(cible)
			for _i in range(3):
				if b.is_empty() or (await app.serveur.combat_guerre(str(b["id"]))).is_empty():
					break
				await app.serveur.resultat_guerre(str(b["id"]), true)
		elif etape.has("vieillir"):
			# Vieillir le compte de n jours (le Marché).
			await app._publier_perso_async()
			app.vieillir_compte(int(etape["vieillir"]))
		elif etape.has("or"):
			app.profile.monnaie_or = int(etape["or"])
			app.profile.save()
		elif etape.has("record"):
			app.profile.tower_records[app.lignee()] = int(etape["record"])
			app.profile.save()
		elif etape.has("energie"):
			app.fatiguer(int(etape["energie"]))
		elif etape.has("ameliorer"):
			if not app.profile.sac.is_empty():
				app.profile.sac[0]["amelioration"] = int(etape["ameliorer"])
				app.profile.save()
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
