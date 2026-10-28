## Rencontre de l'acolyte (GDD) : il arrive, se présente, montre ses trois voies et comment il joue.
extends Control

var app: ArenaApp


func setup(p_app: ArenaApp, _options: Dictionary) -> void:
	app = p_app
	var column := UiKit.scroll_column(self, 12)
	var aco_class := app.data.classe(app.acolyte_class())
	column.add_child(UiKit.label("Ton acolyte arrive", 30, UiKit.ACOLYTE_BLUE))
	var portrait := PortraitView.make(app.acolyte_class(), app.acolyte_name, app.class_label(app.acolyte_class()), 10.0)
	portrait.title_color = UiKit.ACOLYTE_BLUE
	column.add_child(portrait)
	portrait.appear()
	app.sfx.play("releve")
	column.add_child(UiKit.label("%s se battra à tes côtés dans tous tes combats, en duel comme à la Tour. Sa classe complète la tienne : toi %s, lui %s." % [
		app.acolyte_name, UiKit.ROLE_LABELS[app.data.classe(app.player_class)["role"]], UiKit.ROLE_LABELS[aco_class["role"]]], 17))
	var card := UiKit.card(column, 6)
	card.add_child(UiKit.label("Ses trois voies", 20, UiKit.ACOLYTE_BLUE, false))
	for v in range(app.acolyte_destin.voies.size()):
		UiKit.voie_resume(card, app.acolyte_destin, v, UiKit.ACOLYTE_BLUE)
	UiKit.acolyte_rules_card(column, app.acolyte_name)
	var syn := UiKit.card(column, 4)
	syn.add_child(UiKit.label("Jouer ensemble", 20, UiKit.GOLD, false))
	syn.add_child(UiKit.label("Le même tour, vos coups se répondent : un contrôle et un coup sur la même cible (Brisure), deux brûlures ou saignements sur la même cible (Embrasement), une barrière et un soin sur le même allié (Bastion), un renfort et un coup (Harmonie).", 15, UiKit.SOFT, false))
	column.add_child(UiKit.main_button("Entrer dans l'Arène", func(): app.show_screen("home")))
