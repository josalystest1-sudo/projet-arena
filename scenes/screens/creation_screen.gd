## Création du personnage (GDD) : le choix de la classe, puis la révélation de son Destin : sa roue de 5 voies, dont
## chaque nœud a pris une forme tirée au hasard, une seule fois (docs/SPEC-COMBAT-V2.md, section 4).
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
	for class_id in app.data.ordre_classes:
		var cls := app.data.classe(class_id)
		var card := UiKit.card(column)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		card.add_child(row)
		row.add_child(PortraitView.make(class_id, "", "", 6.0))
		var text := VBoxContainer.new()
		text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(text)
		text.add_child(UiKit.label(str(cls["nom"]), 24, UiKit.GOLD, false))
		text.add_child(UiKit.label("%s · acolyte : %s" % [UiKit.ROLE_LABELS[cls["role"]], app.data.classe(str(cls["acolyte"]))["nom"]], 15, UiKit.SOFT, false))
		var voies: Array[String] = []
		for voie in cls["voies"]:
			voies.append(str(voie["nom"]).trim_prefix("Voie ").trim_prefix("du ").trim_prefix("de la ").trim_prefix("de l'").trim_prefix("des "))
		text.add_child(UiKit.label("Ses voies : " + ", ".join(voies), 15, Color.WHITE, false))
		card.add_child(UiKit.button("Devenir %s" % cls["nom"], _on_class_chosen.bind(class_id), 52))


func _on_class_chosen(class_id: String) -> void:
	app.sfx.play("clic")
	app.create_character(class_id)
	_reveal_destiny()


## La naissance du perso : sa roue se dévoile, une voie après l'autre.
func _reveal_destiny() -> void:
	_reset()
	var cls := app.data.classe(app.player_class)
	column.add_child(UiKit.label("Ton Destin", 34, UiKit.GOLD))
	column.add_child(UiKit.label("Il est tiré une seule fois, il n'existe nulle part ailleurs et ne changera jamais.", 16, UiKit.SOFT))
	var portrait := PortraitView.make(app.player_class, str(cls["nom"]), "Toi", 10.0)
	portrait.title_color = UiKit.GOLD
	column.add_child(portrait)
	portrait.appear()
	var card := UiKit.card(column, 8)
	var blocks: Array = []
	var moyeu := VBoxContainer.new()
	moyeu.add_child(UiKit.label("Au centre, ton moyeu : %s, toujours jouable." % Texte.nom(app.destin.moyeu), 16, UiKit.SOFT, false))
	blocks.append(moyeu)
	for v in range(app.destin.voies.size()):
		var block := VBoxContainer.new()
		UiKit.voie_resume(block, app.destin, v)
		blocks.append(block)
	var aide := VBoxContainer.new()
	aide.add_child(UiKit.label("Jouer, c'est avancer d'un nœud sur une voie, jusqu'à sa Clé. Tu allumes un nœud de plus à chaque niveau (○ : pas encore allumé).", 15, UiKit.SOFT, false))
	blocks.append(aide)
	var next := UiKit.main_button("Rencontrer ton acolyte", func(): app.show_screen("meet"))
	next.modulate.a = 0.0
	for block in blocks:
		block.modulate.a = 0.0
		card.add_child(block)
	column.add_child(next)
	# Les voies apparaissent une à une.
	var tween := create_tween()
	for block in blocks:
		tween.tween_interval(0.45)
		tween.tween_callback(func(): app.sfx.play("tour", 1.2))
		tween.tween_property(block, "modulate:a", 1.0, 0.3)
	tween.tween_interval(0.3)
	tween.tween_property(next, "modulate:a", 1.0, 0.3)
