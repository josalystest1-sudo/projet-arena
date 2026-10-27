## Les traits d'Intention : de chaque membre du duo vers sa cible. Une Synergie possible relie le joueur et
## son acolyte par un lien doré avec une étoile ; une Synergie prête fait clignoter les traits en doré.
class_name IntentOverlay
extends Control

## Liste de {from: UnitView, to: UnitView, color: Color, synergy: bool, bond: bool, ready: bool}
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
		if from == null or to == null or not is_instance_valid(from) or not is_instance_valid(to):
			continue
		var a := from.anchor_global() - global_position
		var b := to.anchor_global() - global_position
		if link.get("bond", false):
			_draw_bond(a, b, bool(link.get("ready", false)))
			continue
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


## Lien du duo : un arc doré entre le joueur et son acolyte, une étoile au milieu.
func _draw_bond(a: Vector2, b: Vector2, ready: bool) -> void:
	var speed := 10.0 if ready else 4.0
	var blink := 0.5 + 0.5 * sin(_time * speed)
	var color := Color(1.0, 0.85, 0.2, (0.55 if ready else 0.3) + 0.4 * blink)
	# Courbe de Bézier : le point de contrôle au-dessus des deux persos fait passer l'arc par-dessus leurs bulles.
	var control := (a + b) / 2.0 + Vector2(0, -190)
	var points := PackedVector2Array()
	for i in range(17):
		var t := float(i) / 16.0
		points.append(a.lerp(control, t).lerp(control.lerp(b, t), t))
	draw_polyline(points, color, 4.0 if ready else 3.0, true)
	var mid := a * 0.25 + control * 0.5 + b * 0.25
	var star := PackedVector2Array()
	var radius := 13.0 + (4.0 * blink if ready else 0.0)
	for i in range(10):
		var r := radius if i % 2 == 0 else radius * 0.45
		var angle := -PI / 2.0 + float(i) * PI / 5.0
		star.append(mid + Vector2(cos(angle), sin(angle)) * r)
	draw_colored_polygon(star, Color(1.0, 0.85, 0.2, minf(color.a + 0.3, 1.0)))
