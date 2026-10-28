## L'arbre du Destin (GDD, écran « Destin ») : l'arbre entier, les nœuds pris allumés, et le placement des points.
## Affichage seulement : les règles (qui peut être pris, ce que vaut un nœud) sont dans engine/destin.gd.
extends Control

const TYPE_COLORS := {"stat": Color("9ad1ff"), "evolution": Color("ffd43b"), "pivot": Color("51cf66"), "cle": Color("da77f2")}
const TYPE_LABELS := {"stat": "Stat", "evolution": "Évolution de compétence", "pivot": "Pivot (rôle secondaire)", "cle": "Clé"}
const RADIUS := 17.0
const ROW := 84.0

var app: ArenaApp
var tree: Dictionary = {}
var taken: Array = []
var positions: Dictionary = {}
var selected: int = -1
var canvas: Control
var info_title: Label
var info_text: Label
var take_button: Button
var header: Label
var _time: float = 0.0


func setup(p_app: ArenaApp, _options: Dictionary) -> void:
	app = p_app
	tree = app.destin
	taken = app.destin_taken
	var column := VBoxContainer.new()
	column.set_anchors_preset(Control.PRESET_FULL_RECT)
	column.add_theme_constant_override("separation", 6)
	add_child(column)
	var margin := MarginContainer.new()
	for side in ["left", "right", "top"]:
		margin.add_theme_constant_override("margin_" + side, 12)
	column.add_child(margin)
	var head := VBoxContainer.new()
	margin.add_child(head)
	head.add_child(UiKit.label("Ton Destin", 28, UiKit.GOLD))
	header = UiKit.label("", 16, UiKit.SOFT)
	head.add_child(header)
	# L'arbre, dans une zone qui défile.
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	# Les rangées les plus larges débordent du téléphone : l'arbre défile aussi de gauche à droite.
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	column.add_child(scroll)
	canvas = Control.new()
	canvas.mouse_filter = Control.MOUSE_FILTER_STOP
	canvas.draw.connect(_draw_tree)
	canvas.gui_input.connect(_on_canvas_input)
	scroll.add_child(canvas)
	_layout()
	# À l'ouverture, la racine est au milieu de l'écran (l'arbre peut être plus large que lui).
	scroll.ready.connect(func(): scroll.set_deferred("scroll_horizontal", int((canvas.custom_minimum_size.x - scroll.size.x) / 2.0)))
	# Le nœud choisi, et le bouton pour y placer un point.
	var panel := PanelContainer.new()
	column.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	panel.add_child(box)
	info_title = UiKit.label("Touche un nœud", 19, Color.WHITE, false)
	box.add_child(info_title)
	info_text = UiKit.label("Les nœuds allumés sont pris. Tu peux prendre un nœud relié à un nœud pris, un par niveau.", 15, UiKit.SOFT, false)
	box.add_child(info_text)
	take_button = UiKit.button("Placer un point", _take, 54)
	take_button.disabled = true
	box.add_child(take_button)
	var legend := HBoxContainer.new()
	legend.alignment = BoxContainer.ALIGNMENT_CENTER
	legend.add_theme_constant_override("separation", 10)
	box.add_child(legend)
	for type in ["stat", "evolution", "pivot", "cle"]:
		legend.add_child(UiKit.label({"stat": "S : Stat", "evolution": "É : Évolution", "pivot": "P : Pivot", "cle": "C : Clé"}[type], 13, TYPE_COLORS[type]))
	_refresh_header()


## Les nœuds rangés par profondeur, chaque rangée répartie sur la largeur, dans l'ordre de leurs parents.
func _layout() -> void:
	positions = {}
	var rows := {}
	var max_depth := 0
	for node in tree.get("nodes", []):
		var depth := int(node["depth"])
		max_depth = maxi(max_depth, depth)
		if not rows.has(depth):
			rows[depth] = []
		rows[depth].append(node)
	var widest := 1
	for depth in rows:
		widest = maxi(widest, rows[depth].size())
	var width := maxf(520.0, float(widest) * 50.0)
	for depth in range(max_depth + 1):
		var row: Array = rows.get(depth, [])
		row.sort_custom(func(a, b):
			var pa: float = positions.get(int(a["parent"]), Vector2.ZERO).x
			var pb: float = positions.get(int(b["parent"]), Vector2.ZERO).x
			return pa < pb or (pa == pb and int(a["id"]) < int(b["id"])))
		for i in range(row.size()):
			positions[int(row[i]["id"])] = Vector2((float(i) + 0.5) * width / float(row.size()), 40.0 + float(depth) * ROW)
	canvas.custom_minimum_size = Vector2(width, 80.0 + float(max_depth + 1) * ROW)


func _refresh_header() -> void:
	var left := app.destin_points_left()
	header.text = "Niveau %d · %d nœud%s pris sur %d · %s" % [app.profile.level, taken.size(), "s" if taken.size() > 1 else "", tree.get("nodes", []).size(),
		("%d point%s à placer" % [left, "s" if left > 1 else ""]) if left > 0 else "aucun point à placer (un par niveau)"]
	if take_button != null:
		take_button.disabled = selected < 0 or left <= 0 or not Destin.can_take(tree, taken, selected)
		take_button.text = "Placer un point" if left > 0 else "Gagne un niveau pour placer un point"


func _process(delta: float) -> void:
	_time += delta
	if canvas != null:
		canvas.queue_redraw()


func _draw_tree() -> void:
	var font := ThemeDB.fallback_font
	var available: Array = Destin.available(tree, taken)
	var points_left := app.destin_points_left()
	# Les liens d'abord.
	for node in tree.get("nodes", []):
		var parent := int(node["parent"])
		if parent < 0:
			continue
		var both := taken.has(int(node["id"])) and taken.has(parent)
		canvas.draw_line(positions[parent], positions[int(node["id"])], Color(1, 0.85, 0.3, 0.9) if both else Color(0.35, 0.4, 0.55), 3.0 if both else 2.0)
	for node in tree.get("nodes", []):
		var id := int(node["id"])
		var pos: Vector2 = positions[id]
		var color: Color = TYPE_COLORS.get(str(node["type"]), Color.WHITE)
		var is_taken := taken.has(id)
		var is_available := available.has(id) and points_left > 0
		var radius := RADIUS * (1.25 if str(node["type"]) == "cle" else 1.0)
		if is_taken:
			canvas.draw_circle(pos, radius + 5.0, Color(color, 0.25))
			canvas.draw_circle(pos, radius, color)
		elif is_available:
			var pulse := 0.5 + 0.5 * sin(_time * 5.0)
			canvas.draw_circle(pos, radius + 4.0 * pulse, Color(color, 0.18 + 0.15 * pulse))
			canvas.draw_circle(pos, radius, Color(0.12, 0.14, 0.22))
			canvas.draw_arc(pos, radius, 0.0, TAU, 32, color, 3.0, true)
		else:
			canvas.draw_circle(pos, radius, Color(0.12, 0.14, 0.22))
			canvas.draw_arc(pos, radius, 0.0, TAU, 32, Color(color, 0.45), 1.5, true)
		if id == selected:
			canvas.draw_arc(pos, radius + 7.0, 0.0, TAU, 32, Color.WHITE, 3.0, true)
		var letter: String = {"stat": "S", "evolution": "É", "pivot": "P", "cle": "C"}.get(str(node["type"]), "?")
		var text_w := font.get_string_size(letter, HORIZONTAL_ALIGNMENT_LEFT, -1, 15).x
		canvas.draw_string(font, pos + Vector2(-text_w / 2.0, 6), letter, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(0.05, 0.05, 0.1) if is_taken else Color.WHITE)


func _on_canvas_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var best := -1
		var best_distance := RADIUS * 2.0
		for id in positions:
			var distance: float = positions[id].distance_to(event.position)
			if distance < best_distance:
				best = int(id)
				best_distance = distance
		if best >= 0:
			_select(best)
			app.sfx.play("clic")


func _select(id: int) -> void:
	selected = id
	var node := Destin.node_of(tree, id)
	var state := "pris" if taken.has(id) else ("disponible" if Destin.can_take(tree, taken, id) else "hors de portée (prends d'abord un nœud relié)")
	info_title.text = "%s — %s (%s)" % [str(node["name"]), TYPE_LABELS.get(str(node["type"]), ""), state]
	var text := str(node.get("description", ""))
	if str(node["type"]) == "cle":
		text += " Une Clé se gagne au bout d'un chemin de 3 nœuds."
	info_text.text = text
	_refresh_header()


func _take() -> void:
	if selected < 0 or not app.take_destin_node(selected):
		return
	app.sfx.play("releve")
	taken = app.destin_taken
	_select(selected)
