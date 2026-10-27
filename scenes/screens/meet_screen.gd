## Rencontre de l'acolyte (GDD) : il arrive, se présente, et le joueur découvre ce qu'ils pourront faire ensemble.
extends Control

var app: ArenaApp


func setup(p_app: ArenaApp, _options: Dictionary) -> void:
	app = p_app
	var column := UiKit.scroll_column(self, 12)
	var aco_class: Dictionary = app.data.classes[app.acolyte["class_id"]]
	column.add_child(UiKit.label("Ton acolyte arrive", 30, UiKit.ACOLYTE_BLUE))
	var portrait := PortraitView.make(app.acolyte["class_id"], app.acolyte_name, app.class_label(app.acolyte["class_id"]), 10.0)
	portrait.title_color = UiKit.ACOLYTE_BLUE
	column.add_child(portrait)
	portrait.appear()
	app.sfx.play("releve")
	column.add_child(UiKit.label("%s se battra à tes côtés dans tous tes combats, en duel comme à la Tour. Sa classe complète la tienne : toi %s, lui %s." % [
		app.acolyte_name, UiKit.ROLE_LABELS[app.data.classes[app.player_class]["roles"][0]], UiKit.ROLE_LABELS[aco_class["roles"][0]]], 17))
	var card := UiKit.card(column, 6)
	for skill_id in app.acolyte_skills():
		UiKit.skill_block(card, app.data, skill_id, UiKit.ACOLYTE_BLUE)
	UiKit.passive_block(card, app.data, app.acolyte_passive())
	var how := UiKit.card(column, 6)
	how.add_child(UiKit.label("Comment il joue", 20, UiKit.GOLD, false))
	how.add_child(UiKit.label("Tu ne choisis jamais ses sorts. Au début de chaque tour, il annonce son coup au-dessus de lui ; tu choisis le tien en le sachant. Tu peux lui donner une posture : Libre, Protège-moi, Fonce ou Garde ta forte.", 16, UiKit.SOFT, false))
	var synergies := app.duo_synergies()
	if not synergies.is_empty():
		var syn := UiKit.card(column, 6)
		syn.add_child(UiKit.label("Vos Synergies (à jouer le même tour)", 20, UiKit.GOLD, false))
		for synergy in synergies:
			syn.add_child(UiKit.label("%s : %s + %s" % [synergy["name"], app.data.skill_name(synergy["skills"][0]), app.data.skill_name(synergy["skills"][1])], 17, Color.WHITE, false))
			syn.add_child(UiKit.label(app.data.synergy_description(synergy), 15, UiKit.SOFT, false))
	column.add_child(UiKit.main_button("Entrer dans l'Arène", func(): app.show_screen("home")))
