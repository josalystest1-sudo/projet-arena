## Création du personnage (GDD) : le choix de la classe, puis la révélation du Destin, une compétence après l'autre.
extends Control

var app: ArenaApp
var column: VBoxContainer


func setup(p_app: ArenaApp, _options: Dictionary) -> void:
	app = p_app
	_show_classes()


func _reset() -> void:
	for child in get_children():
		child.queue_free()
	column = UiKit.scroll_column(self, 14)


func _show_classes() -> void:
	_reset()
	column.add_child(UiKit.spacer(10))
	column.add_child(UiKit.label("Projet Arena", 42, UiKit.GOLD))
	column.add_child(UiKit.label("Un seul personnage, un Destin unique, un acolyte à tes côtés.", 18, UiKit.SOFT))
	column.add_child(UiKit.label("Choisis ta classe :", 22))
	for class_id in app.data.class_ids:
		var cls: Dictionary = app.data.classes[class_id]
		var card := UiKit.card(column)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		card.add_child(row)
		row.add_child(PortraitView.make(class_id, "", "", 6.0))
		var text := VBoxContainer.new()
		text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(text)
		var roles: Array = cls["roles"]
		text.add_child(UiKit.label(str(cls["name"]), 24, UiKit.GOLD, false))
		text.add_child(UiKit.label("%s, puis %s" % [UiKit.ROLE_LABELS[roles[0]], UiKit.ROLE_LABELS[roles[1]].to_lower()], 15, UiKit.SOFT, false))
		text.add_child(UiKit.label(str(cls["identity"]), 16, Color.WHITE, false))
		card.add_child(UiKit.button("Devenir %s" % cls["name"], _on_class_chosen.bind(class_id), 52))


func _on_class_chosen(class_id: String) -> void:
	app.sfx.play("clic")
	app.create_character(class_id)
	_reveal_destiny()


## La naissance du perso : son Destin se dévoile, une compétence après l'autre.
func _reveal_destiny() -> void:
	_reset()
	var cls: Dictionary = app.data.classes[app.player_class]
	column.add_child(UiKit.label("Ton Destin", 34, UiKit.GOLD))
	column.add_child(UiKit.label("Il est tiré une seule fois, il n'existe nulle part ailleurs et ne changera jamais.", 16, UiKit.SOFT))
	var portrait := PortraitView.make(app.player_class, str(cls["name"]), "Toi", 10.0)
	portrait.title_color = UiKit.GOLD
	column.add_child(portrait)
	portrait.appear()
	var card := UiKit.card(column, 8)
	var blocks: Array = []
	for skill_id in app.player_skills():
		var block := VBoxContainer.new()
		UiKit.skill_block(block, app.data, skill_id)
		blocks.append(block)
	var passive := VBoxContainer.new()
	UiKit.passive_block(passive, app.data, app.player_passive())
	blocks.append(passive)
	var tree := VBoxContainer.new()
	tree.add_child(UiKit.label("Ton arbre de Destin : %d nœuds, tirés une seule fois. Tu y placeras un point par niveau." % app.destin.get("nodes", []).size(), 15, UiKit.SOFT, false))
	blocks.append(tree)
	var next := UiKit.main_button("Rencontrer ton acolyte", func(): app.show_screen("meet"))
	next.modulate.a = 0.0
	for block in blocks:
		block.modulate.a = 0.0
		card.add_child(block)
	column.add_child(next)
	# Les compétences apparaissent une à une.
	var tween := create_tween()
	for block in blocks:
		tween.tween_interval(0.55)
		tween.tween_callback(func(): app.sfx.play("tour", 1.2))
		tween.tween_property(block, "modulate:a", 1.0, 0.35)
	tween.tween_interval(0.3)
	tween.tween_property(next, "modulate:a", 1.0, 0.3)
