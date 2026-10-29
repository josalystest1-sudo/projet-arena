## La Vitrine, l'écran d'accueil (GDD) : le trio en grand, animé, et deux boutons dominants : Combattre, La Tour.
extends Control

var app: ArenaApp


func setup(p_app: ArenaApp, _options: Dictionary) -> void:
	app = p_app
	var column := UiKit.scroll_column(self, 12)
	var top := HBoxContainer.new()
	column.add_child(top)
	var title := UiKit.label("Projet Arena", 30, UiKit.GOLD, false)
	top.add_child(title)
	var gear := Button.new()
	gear.text = "Paramètres"
	gear.add_theme_font_size_override("font_size", 15)
	gear.pressed.connect(func(): app.show_screen("settings"))
	top.add_child(gear)

	# Le trio, en grand : toi au milieu, tes deux Échos de part et d'autre.
	column.add_child(UiKit.rangee_trio(app, 7.5))

	var profile := app.profile
	var record := int(profile.tower_records.get(app.player_class, 0))
	var facts: Array = ["niveau %d" % profile.level]
	if profile.wins + profile.losses > 0:
		facts.append("%d victoire%s · %d défaite%s" % [profile.wins, "s" if profile.wins > 1 else "", profile.losses, "s" if profile.losses > 1 else ""])
		facts.append("série : %d (record %d)" % [profile.streak, profile.best_streak])
	facts.append("Tour : étage %d" % record if record > 0 else "Tour : pas encore tentée")
	facts.append("%d Éclat%s" % [profile.eclats, "s" if profile.eclats > 1 else ""])
	column.add_child(UiKit.label(" · ".join(facts), 16, UiKit.SOFT))
	# Le revenu passif du jour, montré une fois (GDD V2, § 6 : des Éclats et un peu d'XP selon la hauteur).
	if not app.revenu_du_jour.is_empty():
		var r: Dictionary = app.revenu_du_jour
		var revenu := UiKit.card(column, 2)
		revenu.add_child(UiKit.label("Revenu de la Tour", 18, UiKit.GOLD, false))
		revenu.add_child(UiKit.label("+%d Éclats et +%d XP pour ton record (étage %d). Chaque jour, selon ta hauteur." % [int(r["eclats"]), int(r["xp"]), int(r["record"])], 15, UiKit.SOFT, false))
		app.revenu_du_jour = {}
	if app.destin_points_left() > 0:
		column.add_child(UiKit.button("%d point%s de Destin à placer" % [app.destin_points_left(), "s" if app.destin_points_left() > 1 else ""], func(): app.show_screen("destin"), 48, 17))

	column.add_child(UiKit.spacer(6))
	column.add_child(UiKit.main_button("Combattre", _fight, 92))
	var noms := app.noms_trio()
	column.add_child(UiKit.label("Duel en trio : toi, %s et %s contre un autre trio." % [noms["a2"], noms["a3"]], 15, UiKit.SOFT))
	var tower := UiKit.main_button("La Tour", func(): app.show_screen("tower"), 78)
	column.add_child(tower)
	column.add_child(UiKit.label("Grimpe les étages avec tes deux Échos. Bats ton record.", 15, UiKit.SOFT))


func _fight() -> void:
	app.sfx.play("clic")
	app.show_screen("trio", {"mode": "duel"})
