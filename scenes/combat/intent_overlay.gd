## Les traits d'Intention : de chaque allié vers sa cible. Une Synergie possible fait clignoter le trait.
class_name IntentOverlay
extends Control

## Liste de {from: UnitView, to: UnitView, color: Color, synergy: bool}
var links: Array = []
var _time: float = 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	for link in links:
		var from: UnitView = link["from"]
		var to: UnitView = link["to"]
		if from == null or to == null:
			continue
		var a := from.anchor_global() - global_position
		var b := to.anchor_global() - global_position
		var color: Color = link["color"]
		var width := 3.0
		if link.get("synergy", false):
			var blink := 0.5 + 0.5 * sin(_time * 10.0)
			color = Color(1.0, 0.85, 0.2, 0.45 + 0.5 * blink)
			width = 5.0
		if from == to:
			draw_arc(a + Vector2(0, -40), 16.0, 0.0, TAU, 24, color, width)
			continue
		draw_line(a, b, color, width, true)
		var dir := (b - a).normalized()
		var tip := b - dir * 30.0
		var side := Vector2(-dir.y, dir.x) * 9.0
		draw_colored_polygon(PackedVector2Array([tip + dir * 14.0, tip + side, tip - side]), color)
