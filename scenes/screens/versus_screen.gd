## Avant un duel : la recherche d'un adversaire, puis le face-à-face des deux duos (GDD : « File d'attente »).
## En attendant les vrais joueurs (étape 5), l'adversaire est un duo piloté par l'IA, et c'est écrit.
extends Control

const ENEMY_NAMES := ["Ombre", "Brume", "Cendre", "Givre", "Ronce", "Écume", "Nox", "Bise"]

var app: ArenaApp
var enemy: Array = []
var _started := false


func setup(p_app: ArenaApp, _options: Dictionary) -> void:
	app = p_app
	enemy = app.random_enemy_duo()
	var first := app.rng.randi_range(0, ENEMY_NAMES.size() - 1)
	enemy[0]["name"] = ENEMY_NAMES[first]
	enemy[1]["name"] = ENEMY_NAMES[(first + app.rng.randi_range(1, ENEMY_NAMES.size() - 1)) % ENEMY_NAMES.size()]
	var column := UiKit.scroll_column(self, 10)
	var searching := UiKit.label("Recherche d'un adversaire…", 24, UiKit.SOFT)
	column.add_child(UiKit.spacer(40))
	column.add_child(searching)
	var tween := create_tween()
	tween.tween_interval(0.9)
	tween.tween_callback(func(): _show_versus(column, searching))


func _show_versus(column: VBoxContainer, searching: Label) -> void:
	searching.text = "Adversaire trouvé"
	searching.add_theme_color_override("font_color", UiKit.GOLD)
	app.sfx.play("forte", 1.1, -6.0)
	var enemies := HBoxContainer.new()
	enemies.alignment = BoxContainer.ALIGNMENT_CENTER
	enemies.add_theme_constant_override("separation", 12)
	column.add_child(enemies)
	for member in enemy:
		var view := PortraitView.make(member["class_id"], str(member["name"]), app.class_label(member["class_id"]), 8.0, true)
		enemies.add_child(view)
		view.appear()
	column.add_child(UiKit.label("Duo IA (en attendant les vrais joueurs)", 14, Color(0.6, 0.62, 0.7)))
	column.add_child(UiKit.label("contre", 22, Color.WHITE))
	var allies := HBoxContainer.new()
	allies.alignment = BoxContainer.ALIGNMENT_CENTER
	allies.add_theme_constant_override("separation", 12)
	column.add_child(allies)
	var me := PortraitView.make(app.player_class, "Toi", app.class_label(app.player_class), 8.0)
	me.title_color = UiKit.GOLD
	var aco := PortraitView.make(app.acolyte["class_id"], app.acolyte_name, app.class_label(app.acolyte["class_id"]), 8.0)
	aco.title_color = UiKit.ACOLYTE_BLUE
	allies.add_child(aco)
	allies.add_child(me)
	column.add_child(UiKit.main_button("Au combat !", _start))
	var tween := create_tween()
	tween.tween_interval(2.5)
	tween.tween_callback(_start)


func _start() -> void:
	if _started:
		return
	_started = true
	app.show_screen("combat", {"mode": "pvp", "enemy": enemy})
