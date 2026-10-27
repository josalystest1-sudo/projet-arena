## La fiche de l'acolyte (GDD, écran « Acolyte ») : lui en pied, ses compétences, ses postures, sa posture de départ.
extends Control

var app: ArenaApp
var posture_buttons: Dictionary = {}


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

	var postures := UiKit.card(column, 8)
	postures.add_child(UiKit.label("Ses postures", 20, UiKit.GOLD, false))
	postures.add_child(UiKit.label("Elles ne coûtent pas d'action et durent jusqu'à nouvel ordre. Touche celle qu'il prendra au début de chaque combat.", 15, UiKit.SOFT, false))
	for posture_id in app.acolyte_postures():
		var button := UiKit.button("", _on_posture.bind(posture_id), 46, 18)
		posture_buttons[posture_id] = button
		postures.add_child(button)
		postures.add_child(UiKit.label(app.posture_text(posture_id), 15, Color.WHITE, false))
	postures.add_child(UiKit.label(str(app.data.postures.get("always", "")), 15, UiKit.SOFT, false))
	_refresh()


func _on_posture(posture_id: String) -> void:
	app.sfx.play("clic")
	app.set_posture(posture_id)
	_refresh()


func _refresh() -> void:
	for posture_id in posture_buttons:
		var chosen: bool = posture_id == app.posture
		var button: Button = posture_buttons[posture_id]
		button.text = ("» %s (au début du combat)" if chosen else "%s") % app.posture_name(posture_id)
		button.modulate = Color(1.0, 0.9, 0.45) if chosen else Color.WHITE
