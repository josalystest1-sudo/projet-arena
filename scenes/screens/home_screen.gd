## La Vitrine, l'écran d'accueil (GDD) : le duo en grand, animé, et deux boutons dominants : Combattre, La Tour.
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

	# Le duo, en grand.
	var duo := HBoxContainer.new()
	duo.alignment = BoxContainer.ALIGNMENT_CENTER
	duo.add_theme_constant_override("separation", 16)
	column.add_child(duo)
	var me := PortraitView.make(app.player_class, "Toi", app.class_label(app.player_class), 11.0)
	me.title_color = UiKit.GOLD
	var aco := PortraitView.make(app.acolyte["class_id"], app.acolyte_name, app.class_label(app.acolyte["class_id"]), 11.0)
	aco.title_color = UiKit.ACOLYTE_BLUE
	duo.add_child(me)
	duo.add_child(aco)

	var profile := app.profile
	var record := int(profile.tower_records.get(app.player_class, 0))
	var facts: Array = ["niveau %d" % profile.level]
	if profile.wins + profile.losses > 0:
		facts.append("%d victoire%s · %d défaite%s" % [profile.wins, "s" if profile.wins > 1 else "", profile.losses, "s" if profile.losses > 1 else ""])
		facts.append("série : %d (record %d)" % [profile.streak, profile.best_streak])
	facts.append("Tour : étage %d" % record if record > 0 else "Tour : pas encore tentée")
	column.add_child(UiKit.label(" · ".join(facts), 16, UiKit.SOFT))
	if app.destin_points_left() > 0:
		column.add_child(UiKit.button("%d point%s de Destin à placer" % [app.destin_points_left(), "s" if app.destin_points_left() > 1 else ""], func(): app.show_screen("destin"), 48, 17))
	var synergies := app.duo_synergies()
	if not synergies.is_empty():
		var names: Array = []
		for synergy in synergies:
			names.append(synergy["name"])
		column.add_child(UiKit.label("Vos Synergies : " + ", ".join(names), 16, UiKit.GOLD))

	column.add_child(UiKit.spacer(6))
	column.add_child(UiKit.main_button("Combattre", _fight, 92))
	column.add_child(UiKit.label("Duel en duo : toi et %s contre un autre duo." % app.acolyte_name, 15, UiKit.SOFT))
	var tower := UiKit.main_button("La Tour", func(): app.show_screen("tower"), 78)
	column.add_child(tower)
	column.add_child(UiKit.label("10 étages à gravir sans jamais être soigné à fond. Bats ton record.", 15, UiKit.SOFT))


func _fight() -> void:
	app.sfx.play("clic")
	app.show_screen("versus")
