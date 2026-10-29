## Le Tableau (docs/GDD_V2.md, § 11) : les nouvelles du jour. Les trois objectifs du jour (engine/objectifs.gd) avec leur
## avancement et leur récompense à réclamer ; avant le serveur, en local : le revenu de la Tour du jour, les points de
## Destin à placer, les objets du sac, tes records.
extends Control

var app: ArenaApp


func setup(p_app: ArenaApp, _options: Dictionary) -> void:
	app = p_app
	var column := UiKit.scroll_column(self, 12)
	column.add_child(UiKit.label("Le Tableau", 34, UiKit.GOLD))
	column.add_child(UiKit.label("Les nouvelles du jour. Avec le serveur, les événements de tout le monde s'afficheront ici.", 15, UiKit.SOFT))
	# Le revenu du jour, montré une fois.
	if not app.revenu_du_jour.is_empty():
		var r: Dictionary = app.revenu_du_jour
		var revenu := UiKit.card(column, 2)
		revenu.add_child(UiKit.label("Revenu de la Tour", 20, UiKit.GOLD, false))
		revenu.add_child(UiKit.label("+%d Éclats et +%d XP pour ton record (étage %d). Chaque jour, selon ta hauteur." % [int(r["eclats"]), int(r["xp"]), int(r["record"])], 16, Color.WHITE, false))
		app.revenu_du_jour = {}
	# Les objectifs du jour.
	var objectifs := UiKit.card(column, 6)
	objectifs.add_child(UiKit.label("Objectifs du jour", 20, UiKit.GOLD, false))
	objectifs.add_child(UiKit.label("Trois par jour, les mêmes pour tout le monde. Chacun rapporte de l'XP et des Éclats.", 14, UiKit.SOFT, false))
	for o in app.objectifs_du_jour():
		var ligne := "%s · %d / %d" % [o["texte"], o["avancement"], o["cible"]]
		if bool(o["reclame"]):
			objectifs.add_child(UiKit.label(ligne + " · réclamé", 16, Color(0.6, 0.62, 0.7), false))
		elif bool(o["fini"]):
			objectifs.add_child(UiKit.label(ligne, 16, UiKit.GREEN, false))
			objectifs.add_child(UiKit.button("Réclamer : +%d XP, +%d Éclats" % [o["xp"], o["eclats"]], _reclamer.bind(str(o["id"])), 48, 16))
		else:
			objectifs.add_child(UiKit.label(ligne + " (+%d XP, +%d Éclats)" % [o["xp"], o["eclats"]], 16, Color.WHITE, false))
	# À faire aujourd'hui.
	var a_faire := UiKit.card(column, 6)
	a_faire.add_child(UiKit.label("À faire", 20, UiKit.GOLD, false))
	var rien := true
	if app.destin_points_left() > 0:
		rien = false
		a_faire.add_child(UiKit.button("%d point%s de Destin à placer" % [app.destin_points_left(), "s" if app.destin_points_left() > 1 else ""], func(): app.show_screen("destin"), 48, 16))
	if not app.profile.sac.is_empty():
		rien = false
		a_faire.add_child(UiKit.button("%d objet%s dans ton sac, à voir à la Forge" % [app.profile.sac.size(), "s" if app.profile.sac.size() > 1 else ""], func(): app.show_screen("forge"), 48, 16))
	if rien:
		a_faire.add_child(UiKit.label("Rien d'urgent : la Tour t'attend.", 16, UiKit.SOFT, false))
	# Tes records.
	var profile := app.profile
	var records := UiKit.card(column, 4)
	records.add_child(UiKit.label("Tes records", 20, UiKit.GOLD, false))
	var un := false
	for class_id in app.data.ordre_classes:
		var value := int(profile.tower_records.get(class_id, 0))
		if value > 0:
			un = true
			records.add_child(UiKit.label("Tour, %s : étage %d (palier %d)" % [app.data.classe(class_id)["nom"], value, int(profile.tower_paliers.get(class_id, 1))], 16, Color.WHITE, false))
	if profile.best_streak > 0:
		un = true
		records.add_child(UiKit.label("Meilleure série de duels : %d" % profile.best_streak, 16, Color.WHITE, false))
	if not un:
		records.add_child(UiKit.label("Aucun encore : monte la Tour, gagne un duel.", 16, UiKit.SOFT, false))
	column.add_child(UiKit.button("Retour à la ville", func(): app.show_screen("ville"), 56))


func _reclamer(id: String) -> void:
	if not app.reclamer_objectif(id).is_empty():
		app.sfx.play("victoire")
	app.show_screen("tableau")
