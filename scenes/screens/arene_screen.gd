## L'Arène (docs/GDD_V2.md, § 7 ; docs/PLAN.md, PR 5.3) : tes points et ta ligue, la saison, le classement de la saison
## (le serveur), les combats classés qu'il te reste aujourd'hui, le coffre de la semaine, « Combat classé » et
## « Amical ». Les adversaires sont les personnages des autres joueurs (leurs Échos générés), à défaut un trio généré.
## Affichage seulement : les règles sont dans engine/arene.gd et l'état dans le profil (ArenaApp).
extends Control

var app: ArenaApp


func setup(p_app: ArenaApp, _options: Dictionary) -> void:
	app = p_app
	var a := app.etat_arene()
	var column := UiKit.scroll_column(self, 12)
	column.add_child(UiKit.label("L'Arène", 34, UiKit.GOLD))
	column.add_child(UiKit.label("Des duels en trio contre les personnages des autres joueurs, autour de ton niveau (leurs Échos sont générés).", 15, UiKit.SOFT))
	var classement := UiKit.card(column, 4)
	classement.add_child(UiKit.label("Ton classement", 20, UiKit.GOLD, false))
	classement.add_child(UiKit.label("%d points · ligue des %s" % [int(a["points"]), Arene.nom_ligue(str(a["ligue"]), app.data)], 22, Color.WHITE, false))
	classement.add_child(UiKit.label("Saison %d, jusqu'au %s. À la fin de la saison, les points repartent de zéro." % [int(a["saison"]) + 1, _date_lisible(str(a["fin_saison"]))], 14, UiKit.SOFT, false))
	classement.add_child(UiKit.label("Gagné : +%d · perdu : −%d. Ta ligue suit le rang de ta classe : Aspirants, puis Élus une fois évolué (Ascendants : rang 2 et grimoires)." % [int(app.data.objets_arene["points_gagne"]), int(app.data.objets_arene["points_perdu"])], 14, UiKit.SOFT, false))
	_carte_classement(column, int(a["saison"]), int(a["points"]))
	var restants := int(a["restants"])
	column.add_child(UiKit.main_button("Combat classé (%d restant%s aujourd'hui)" % [restants, "s" if restants > 1 else ""] if restants > 0 else "Plus de combat classé aujourd'hui", _classe, 84))
	(column.get_child(column.get_child_count() - 1) as Button).disabled = restants <= 0
	column.add_child(UiKit.label("Un combat classé rapporte de l'XP, des Éclats et des points. %d par jour." % int(app.data.objets_arene["combats_par_jour"]), 14, UiKit.SOFT))
	# Le coffre de la semaine.
	var coffre := UiKit.card(column, 4)
	coffre.add_child(UiKit.label("Le coffre de la semaine", 20, UiKit.GOLD, false))
	var seuils: Dictionary = app.data.objets_arene["coffre"]
	coffre.add_child(UiKit.label("%d victoire%s classée%s cette semaine. %d : un objet commun, %d : rare, %d : épique (liés)." % [int(a["victoires_semaine"]), "s" if int(a["victoires_semaine"]) > 1 else "", "s" if int(a["victoires_semaine"]) > 1 else "", int(seuils["commun"]), int(seuils["rare"]), int(seuils["epique"])], 15, Color.WHITE, false))
	var rarete := str(a["coffre"])
	if bool(a["coffre_reclame"]):
		coffre.add_child(UiKit.label("Coffre réclamé cette semaine. Continue : une rareté plus haute n'en donne pas un second.", 14, UiKit.SOFT, false))
	elif rarete != "":
		coffre.add_child(UiKit.button("Ouvrir le coffre (objet %s)" % app.data.objets["raretes"][rarete]["nom"]["m"], _coffre, 52))
	else:
		coffre.add_child(UiKit.label("Pas encore de coffre : gagne des combats classés.", 14, UiKit.SOFT, false))
	column.add_child(UiKit.button("Amical (sans XP ni classement)", func():
		app.sfx.play("clic")
		app.show_screen("trio", {"mode": "duel"}), 60))
	column.add_child(UiKit.button("Retour à la ville", func(): app.show_screen("ville"), 52))


## Le classement de la saison (le serveur) : les dix premiers, et ta place.
func _carte_classement(column: VBoxContainer, saison: int, mes_points: int) -> void:
	var carte := UiKit.card(column, 3)
	carte.add_child(UiKit.label("Classement de la saison", 20, UiKit.GOLD, false))
	var fiches: Array = await app.serveur.classement(saison, 10)
	if not is_inside_tree():
		return
	if fiches.is_empty():
		carte.add_child(UiKit.label("Personne de classé pour l'instant%s." % ((" (" + app.serveur.erreur + ")") if app.serveur.erreur != "" else ""), 14, UiKit.SOFT, false))
		return
	var moi := app.serveur.compte_id
	var ma_place := 0
	for i in range(fiches.size()):
		var f: Dictionary = fiches[i]
		var a_moi := str(f.get("id", "")) == moi and moi != ""
		if a_moi:
			ma_place = i + 1
		carte.add_child(UiKit.label("%d. %s · %s · %d points" % [i + 1, "toi" if a_moi else f["pseudo"], app.class_label(str(f["classe"])), int(f.get("points", 0))], 14, UiKit.GOLD if a_moi else Color.WHITE, false))
	if ma_place == 0:
		var devant := 0
		for f in fiches:
			if int(f.get("points", 0)) > mes_points:
				devant += 1
		carte.add_child(UiKit.label("Toi : %d points%s." % [mes_points, (", au-delà des dix premiers" if devant >= 10 else ", %de place si ta fiche était publiée" % (devant + 1))], 14, UiKit.SOFT, false))


func _classe() -> void:
	app.sfx.play("clic")
	app.show_screen("trio", {"mode": "classe"})


func _coffre() -> void:
	var objet := app.reclamer_coffre()
	if objet.is_empty():
		return
	app.sfx.play("victoire")
	app.show_screen("forge", {"ou": "sac", "cle": app.profile.sac.size() - 1})


## « 30 décembre 2026 » depuis « 2026-12-30 ».
func _date_lisible(jour: String) -> String:
	var mois := ["janvier", "février", "mars", "avril", "mai", "juin", "juillet", "août", "septembre", "octobre", "novembre", "décembre"]
	var parts := jour.split("-")
	if parts.size() != 3:
		return jour
	var j := int(parts[2])
	return "%s %s %s" % ["1er" if j == 1 else str(j), mois[clampi(int(parts[1]) - 1, 0, 11)], parts[0]]
