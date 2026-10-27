## La fiche de l'acolyte (GDD, écran « Acolyte ») : lui en pied, ses compétences, et comment il joue.
## Il joue seul, comme un second joueur : on ne lui donne aucun ordre (décision du 27 octobre : plus de postures).
extends Control

var app: ArenaApp


func setup(p_app: ArenaApp, _options: Dictionary) -> void:
	app = p_app
	var column := UiKit.scroll_column(self, 12)
	var portrait := PortraitView.make(app.acolyte["class_id"], app.acolyte_name, app.class_label(app.acolyte["class_id"]), 10.0)
	portrait.title_color = UiKit.ACOLYTE_BLUE
	column.add_child(portrait)
	column.add_child(UiKit.label("Ton acolyte, piloté par l'IA. Même niveau que toi, toujours.", 16, UiKit.SOFT))
	var kit := UiKit.card(column, 6)
	kit.add_child(UiKit.label("Ses compétences", 20, UiKit.GOLD, false))
	for skill_id in app.acolyte_skills():
		UiKit.skill_block(kit, app.data, skill_id, UiKit.ACOLYTE_BLUE)
	UiKit.passive_block(kit, app.data, app.acolyte_passive())
	UiKit.destin_balance(kit, app.data, app.acolyte_skills(), app.acolyte_passive(), app.acolyte["class_id"], app.player_class, true)
	UiKit.acolyte_rules_card(column, app.data, app.acolyte["class_id"], app.acolyte_name)
