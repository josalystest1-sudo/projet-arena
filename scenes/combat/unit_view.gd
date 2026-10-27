## Affichage d'un personnage en combat : sprite, nom, PV, états, Intention, textes flottants.
## Ne contient aucune règle : il lit l'état du moteur et les événements qu'on lui transmet.
class_name UnitView
extends Control

signal tapped(unit_id: String)

const ALLY_COLOR := Color("3d8bfd")
const ENEMY_COLOR := Color("e5484d")
const SPRITE_PIXEL := 6.0
const BUBBLE_HEIGHT := 34.0

var unit_id: String = ""
var class_id: String = ""
var display_name: String = ""
var team: int = 0
var is_player: bool = false
var max_hp: int = 1
var shown_hp: float = 1.0
var target_hp: int = 1
var barrier: int = 0
var alive: bool = true
var status_tags: Array = []
## Intention affichée au-dessus du perso : texte de compétence (vide = rien).
var intent_text: String = ""
var intent_alpha: float = 0.55
var targetable: bool = false
var selected_target: bool = false
var order_badge: int = 0
var lunge: float = 0.0
var flash: float = 0.0
var _floaters: Array = []
var _time: float = 0.0


func setup(unit: CombatUnit) -> void:
	unit_id = unit.id
	class_id = unit.class_id
	display_name = unit.display_name
	team = unit.team
	is_player = unit.is_player
	max_hp = unit.max_hp
	shown_hp = unit.hp
	target_hp = unit.hp
	custom_minimum_size = Vector2(160, 230)
	mouse_filter = Control.MOUSE_FILTER_STOP


func sync(unit: CombatUnit, data: CombatData) -> void:
	target_hp = unit.hp
	alive = unit.is_alive()
	barrier = unit.barrier_amount()
	status_tags = []
	for status in unit.statuses:
		status_tags.append({"id": status["id"], "name": data.status_name(status["id"]), "negative": data.is_negative_status(status["id"]), "turns": status.get("turns", 0)})
	queue_redraw()


func set_hp(hp: int) -> void:
	target_hp = hp
	alive = hp > 0


func float_text(text: String, color: Color) -> void:
	_floaters.append({"text": text, "color": color, "t": 0.0, "offset": randf_range(-18.0, 18.0)})


func do_lunge() -> void:
	var tween := create_tween()
	tween.tween_property(self, "lunge", 1.0, 0.12)
	tween.tween_property(self, "lunge", 0.0, 0.18)


func do_flash() -> void:
	flash = 1.0


## Point d'ancrage des traits d'Intention (centre du sprite), en coordonnées globales.
func anchor_global() -> Vector2:
	return global_position + Vector2(size.x / 2.0, BUBBLE_HEIGHT + 52.0)


func _process(delta: float) -> void:
	_time += delta
	if absf(shown_hp - target_hp) > 0.5:
		shown_hp = move_toward(shown_hp, target_hp, maxf(absf(shown_hp - target_hp), 40.0) * delta * 4.0)
	else:
		shown_hp = target_hp
	flash = maxf(flash - delta * 4.0, 0.0)
	for floater in _floaters:
		floater["t"] += delta
	_floaters = _floaters.filter(func(f): return f["t"] < 1.1)
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		tapped.emit(unit_id)
		accept_event()


func _draw() -> void:
	var font := ThemeDB.fallback_font
	var team_color := ALLY_COLOR if team == 0 else ENEMY_COLOR
	var w := size.x
	var sprite_size := SPRITE_PIXEL * PixelSprites.GRID
	var dir := -1.0 if team == 0 else 1.0
	var sprite_origin := Vector2((w - sprite_size) / 2.0, BUBBLE_HEIGHT + 4.0) + Vector2(0, dir * 16.0 * lunge)

	# Halo de cible possible / choisie.
	if targetable and alive or targetable and class_id != "" and not alive and selected_target:
		var pulse := 0.35 + 0.25 * sin(_time * 6.0)
		draw_rect(Rect2(Vector2(6, BUBBLE_HEIGHT), Vector2(w - 12, sprite_size + 10)), Color(1, 1, 0.4, pulse), false, 3.0)
	if targetable and not alive:
		var pulse_ko := 0.35 + 0.25 * sin(_time * 6.0)
		draw_rect(Rect2(Vector2(6, BUBBLE_HEIGHT), Vector2(w - 12, sprite_size + 10)), Color(0.6, 1, 0.6, pulse_ko), false, 3.0)
	if selected_target:
		draw_rect(Rect2(Vector2(4, BUBBLE_HEIGHT - 2), Vector2(w - 8, sprite_size + 14)), Color(1, 0.85, 0.2), false, 4.0)

	# Ombre au sol et sprite.
	draw_circle(Vector2(w / 2.0, BUBBLE_HEIGHT + sprite_size + 2), 30.0, Color(0, 0, 0, 0.25))
	PixelSprites.draw(self, class_id, sprite_origin, SPRITE_PIXEL, team_color, team == 1, not alive)
	if flash > 0.0:
		draw_rect(Rect2(sprite_origin, Vector2(sprite_size, sprite_size)), Color(1, 1, 1, flash * 0.6))
	if not alive:
		_draw_centered(font, "KO", Vector2(w / 2.0, BUBBLE_HEIGHT + sprite_size / 2.0 + 10), 34, Color(1, 0.3, 0.3))

	# Intention (bulle translucide).
	if intent_text != "":
		var bubble := Rect2(Vector2(4, 0), Vector2(w - 8, BUBBLE_HEIGHT - 4))
		draw_rect(bubble, Color(0.08, 0.1, 0.18, intent_alpha))
		draw_rect(bubble, Color(team_color, intent_alpha + 0.2), false, 2.0)
		_draw_centered(font, intent_text, Vector2(w / 2.0, 22), 17, Color(1, 1, 1, minf(intent_alpha + 0.35, 1.0)))

	# Pastille d'ordre de passage pendant la résolution.
	if order_badge > 0:
		draw_circle(Vector2(18, BUBBLE_HEIGHT + 16), 14.0, Color(0.1, 0.1, 0.1, 0.85))
		_draw_centered(font, str(order_badge), Vector2(18, BUBBLE_HEIGHT + 23), 18, Color.WHITE)

	# Nom et PV.
	var y := BUBBLE_HEIGHT + sprite_size + 14
	var name_text := display_name + (" (toi)" if is_player else "")
	_draw_centered(font, name_text, Vector2(w / 2.0, y + 14), 17, Color(1, 0.9, 0.4) if is_player else Color.WHITE)
	var bar := Rect2(Vector2(10, y + 22), Vector2(w - 20, 14))
	draw_rect(bar, Color(0.15, 0.15, 0.2))
	var ratio := clampf(shown_hp / float(max_hp), 0.0, 1.0)
	var hp_color := Color("2fbf71") if ratio > 0.5 else (Color("f2c14e") if ratio > 0.25 else Color("e5484d"))
	draw_rect(Rect2(bar.position, Vector2(bar.size.x * ratio, bar.size.y)), hp_color)
	if barrier > 0:
		var barrier_ratio := clampf(float(barrier) / float(max_hp), 0.0, 1.0)
		draw_rect(Rect2(bar.position + Vector2(0, -4), Vector2(bar.size.x * barrier_ratio, 4)), Color("9ad1ff"))
	draw_rect(bar, Color(0, 0, 0), false, 1.0)
	_draw_centered(font, "%d / %d" % [int(round(shown_hp)), max_hp], Vector2(w / 2.0, y + 52), 15, Color(0.85, 0.85, 0.9))

	# États.
	var x := 8.0
	for tag in status_tags:
		var label := "%s %d" % [tag["name"], int(tag["turns"])] if int(tag["turns"]) > 0 else str(tag["name"])
		var text_w := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x + 8
		if x + text_w > w:
			break
		var color := Color("e5484d") if tag["negative"] else Color("2fbf71")
		draw_rect(Rect2(Vector2(x, y + 58), Vector2(text_w, 18)), Color(color, 0.35))
		draw_string(font, Vector2(x + 4, y + 72), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color.WHITE)
		x += text_w + 4

	# Textes flottants (dégâts, soins, Bloqué...).
	for floater in _floaters:
		var t: float = floater["t"]
		var alpha := clampf(1.4 - t * 1.3, 0.0, 1.0)
		var pos := Vector2(w / 2.0 + float(floater["offset"]), BUBBLE_HEIGHT + 40 - t * 50.0)
		_draw_centered(font, floater["text"], pos + Vector2(2, 2), 28, Color(0, 0, 0, alpha))
		_draw_centered(font, floater["text"], pos, 28, Color(floater["color"], alpha))


func _draw_centered(font: Font, text: String, center: Vector2, font_size: int, color: Color) -> void:
	var text_w := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	draw_string(font, Vector2(center.x - text_w / 2.0, center.y), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
