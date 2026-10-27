## Un personnage en grand, animé (il respire), avec son nom et sa classe en dessous : Vitrine, fiches, face-à-face.
class_name PortraitView
extends Control

const ALLY_COLOR := Color("3d8bfd")
const ENEMY_COLOR := Color("e5484d")

var class_id: String = ""
var title: String = ""
var subtitle: String = ""
var title_color: Color = Color.WHITE
var enemy: bool = false
var pixel: float = 9.0
var _time: float = 0.0
var _phase: float = 0.0
var _appear: float = 1.0


static func make(p_class_id: String, p_title: String, p_subtitle: String, p_pixel: float = 9.0, p_enemy: bool = false) -> PortraitView:
	var view := PortraitView.new()
	view.class_id = p_class_id
	view.title = p_title
	view.subtitle = p_subtitle
	view.pixel = p_pixel
	view.enemy = p_enemy
	view._phase = randf() * TAU
	var sprite := p_pixel * PixelSprites.GRID
	view.custom_minimum_size = Vector2(maxf(sprite + 20.0, 150.0), sprite + 70.0)
	view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return view


## Petite apparition (la révélation du Destin, l'arrivée de l'acolyte).
func appear() -> void:
	_appear = 0.0


func _process(delta: float) -> void:
	_time += delta
	_appear = minf(_appear + delta * 2.5, 1.0)
	queue_redraw()


func _draw() -> void:
	var font := ThemeDB.fallback_font
	var sprite := pixel * PixelSprites.GRID
	var bob: float = roundf(sin(_time * 2.4 + _phase) * 1.5) * 2.0
	var lift := (1.0 - _appear) * 40.0
	var origin := Vector2((size.x - sprite) / 2.0, 6.0 + bob + lift)
	# Ombre au sol : un ovale aplati sous les pieds.
	draw_set_transform(Vector2(size.x / 2.0, 6.0 + sprite), 0.0, Vector2(1.0, 0.25))
	draw_circle(Vector2.ZERO, sprite * 0.3, Color(0, 0, 0, 0.35 * _appear))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var tint := ENEMY_COLOR if enemy else ALLY_COLOR
	PixelSprites.draw(self, class_id, origin, pixel, tint, enemy, false)
	if _appear < 1.0:
		draw_rect(Rect2(origin, Vector2(sprite, sprite)), Color(1, 1, 1, (1.0 - _appear) * 0.8))
	var y := 6.0 + sprite + 26.0
	_centered(font, title, y, 20, title_color)
	if subtitle != "":
		_centered(font, subtitle, y + 24.0, 15, Color(0.75, 0.78, 0.9))


func _centered(font: Font, text: String, y: float, font_size: int, color: Color) -> void:
	var width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	draw_string(font, Vector2((size.x - width) / 2.0, y), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
