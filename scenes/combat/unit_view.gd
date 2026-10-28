## Affichage d'un personnage en combat : sprite animé, nom, PV, recharges, états, Intention, prévision, textes flottants.
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
## Ligne sous le nom : la classe (et « acolyte » pour l'acolyte).
var subtitle: String = ""
var team: int = 0
var is_player: bool = false
var is_acolyte: bool = false
var max_hp: int = 1
var shown_hp: float = 1.0
var target_hp: int = 1
var ghost_hp: float = 1.0
var barrier: int = 0
var alive: bool = true
var status_tags: Array = []
## Intention affichée au-dessus du perso : texte de compétence (vide = rien).
var intent_text: String = ""
var intent_alpha: float = 0.55
## Petite étoile dorée dans la bulle : l'acolyte garde sa forte un tour pour une Synergie avec le joueur.
var intent_star: bool = false
## Badge au-dessus d'un ennemi quand sa forte est prête (anticipation).
var threat_text: String = ""
## Prévision affichée quand le joueur vise ce perso : {text, color}.
var preview_text: String = ""
var preview_color: Color = Color.WHITE
var targetable: bool = false
var selected_target: bool = false
## Cible qui déclencherait une Synergie avec l'annonce de l'acolyte.
var synergy_mark: bool = false
## Aura dorée derrière le perso : 1 = une Synergie est possible avec lui, 2 = elle est prête (ou se déclenche).
var aura: int = 0
## Recharges visibles : {"moyenne": n, "forte": n} ; 0 = prête, -1 = déjà utilisée (une fois par combat).
var cooldowns: Dictionary = {}
## Petit effet quand l'acolyte annonce ou révise son coup.
var announce_pop: float = 0.0
var order_badge: int = 0
var lunge: float = 0.0
var flash: float = 0.0
var shake: float = 0.0
var ko_angle: float = 0.0
## Taille d'un pixel du sprite : plus petit quand 4 monstres se partagent la rangée, plus grand pour un Gardien seul.
var pixel: float = SPRITE_PIXEL
## Taille du nom (plus petite en rangée de 4).
var name_size: int = 16
var _floaters: Array = []
var _time: float = 0.0
var _phase: float = 0.0


func setup(unit: CombatUnit) -> void:
	unit_id = unit.id
	class_id = unit.class_id
	display_name = unit.display_name
	team = unit.team
	is_player = unit.is_player
	is_acolyte = unit.is_acolyte
	max_hp = unit.max_hp
	shown_hp = unit.hp
	ghost_hp = unit.hp
	target_hp = unit.hp
	_phase = float(unit.slot) * 1.7 + float(unit.team) * 0.9
	custom_minimum_size = Vector2(160, 236)
	mouse_filter = Control.MOUSE_FILTER_STOP


## « compact » : 4 monstres dans la rangée (le téléphone fait 540 de large) ; « big » : un Gardien seul.
func set_size_mode(mode: String) -> void:
	match mode:
		"compact":
			pixel = 5.0
			name_size = 13
			custom_minimum_size = Vector2(126, 220)
		"big":
			pixel = 8.0
			custom_minimum_size = Vector2(200, 268)
		_:
			pixel = SPRITE_PIXEL
			name_size = 16
			custom_minimum_size = Vector2(160, 236)


func sync(unit: CombatUnit, data: CombatData) -> void:
	set_hp(unit.hp)
	barrier = unit.barrier_amount()
	status_tags = []
	for status in unit.statuses:
		status_tags.append({"id": status["id"], "name": data.status_name(status["id"]), "negative": data.is_negative_status(status["id"]), "turns": status.get("turns", 0)})
	queue_redraw()


func set_hp(hp: int) -> void:
	var was_alive := alive
	target_hp = hp
	alive = hp > 0
	if was_alive and not alive:
		var tween := create_tween()
		tween.tween_property(self, "ko_angle", 1.0, 0.35).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	elif alive and not was_alive:
		ko_angle = 0.0
		ghost_hp = hp
		shown_hp = hp


## Texte flottant. « big » pour les gros coups, les Synergies, les KO.
func float_text(text: String, color: Color, big: bool = false) -> void:
	_floaters.append({"text": text, "color": color, "t": 0.0, "offset": randf_range(-20.0, 20.0), "size": 40 if big else 27})


func do_lunge() -> void:
	var tween := create_tween()
	tween.tween_property(self, "lunge", 1.0, 0.1).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "lunge", 0.0, 0.2)


func do_announce() -> void:
	announce_pop = 1.0


func do_hurt(strength: float = 1.0) -> void:
	flash = 1.0
	shake = maxf(shake, 7.0 * strength)


## Point d'ancrage des traits d'Intention (centre du sprite), en coordonnées globales.
func anchor_global() -> Vector2:
	return global_position + Vector2(size.x / 2.0, BUBBLE_HEIGHT + pixel * PixelSprites.GRID / 2.0 + 4.0)


func _process(delta: float) -> void:
	_time += delta
	# Les PV descendent vite ; la « trace » claire suit plus lentement pour montrer le coup reçu.
	shown_hp = move_toward(shown_hp, target_hp, maxf(absf(shown_hp - target_hp), 30.0) * delta * 6.0)
	if ghost_hp < shown_hp:
		ghost_hp = shown_hp
	else:
		ghost_hp = move_toward(ghost_hp, shown_hp, maxf(absf(ghost_hp - shown_hp), 20.0) * delta * 1.5)
	flash = maxf(flash - delta * 5.0, 0.0)
	announce_pop = maxf(announce_pop - delta * 3.0, 0.0)
	shake = maxf(shake - delta * 30.0, 0.0)
	for floater in _floaters:
		floater["t"] += delta
	_floaters = _floaters.filter(func(f): return f["t"] < 1.2)
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		tapped.emit(unit_id)
		accept_event()


func _draw() -> void:
	var font := ThemeDB.fallback_font
	var team_color := ALLY_COLOR if team == 0 else ENEMY_COLOR
	var w := size.x
	var sprite_size := pixel * PixelSprites.GRID
	var dir := -1.0 if team == 0 else 1.0
	var bob: float = 0.0 if not alive else round(sin(_time * 2.6 + _phase) * 1.5) * 2.0
	var jitter: Vector2 = Vector2(randf_range(-shake, shake), 0.0) if shake > 0.0 else Vector2.ZERO
	var sprite_origin := Vector2((w - sprite_size) / 2.0, BUBBLE_HEIGHT + 4.0 + bob) + Vector2(0, dir * 22.0 * lunge) + jitter

	# Halo de cible possible / choisie.
	var halo := Rect2(Vector2(6, BUBBLE_HEIGHT), Vector2(w - 12, sprite_size + 10))
	if targetable:
		var pulse := 0.35 + 0.3 * sin(_time * 7.0)
		draw_rect(halo, Color(1, 1, 0.4, pulse) if alive else Color(0.6, 1, 0.6, pulse), false, 3.0)
	if selected_target:
		draw_rect(halo.grow(2), Color(1, 0.85, 0.2), false, 4.0)
	if synergy_mark and alive:
		var glow := 0.5 + 0.5 * sin(_time * 9.0)
		draw_rect(halo.grow(5), Color(1, 0.85, 0.2, 0.35 + 0.5 * glow), false, 3.0)
		_draw_star(Vector2(w / 2.0, BUBBLE_HEIGHT + 2), 11.0, Color(1, 0.85, 0.2, 0.7 + 0.3 * glow))

	# Aura dorée d'une Synergie : derrière le sprite, elle pulse plus vite quand la Synergie est prête.
	if aura > 0 and alive:
		var beat := 0.5 + 0.5 * sin(_time * (9.0 if aura == 2 else 4.5))
		var center := Vector2(w / 2.0, BUBBLE_HEIGHT + sprite_size / 2.0 + 4.0)
		var radius := sprite_size * 0.62 + 6.0 * beat
		for ring in range(4):
			draw_circle(center, radius - ring * 7.0, Color(1.0, 0.82, 0.2, (0.10 if aura == 1 else 0.16) + 0.06 * beat))
		draw_arc(center, radius, 0.0, TAU, 48, Color(1.0, 0.85, 0.2, 0.55 + 0.4 * beat), 3.0 if aura == 1 else 5.0, true)

	# Ombre au sol et sprite (couché s'il est KO).
	var feet := Vector2(w / 2.0, BUBBLE_HEIGHT + sprite_size + 2)
	draw_circle(feet, pixel * 5.0 - 3.0 * bob / 2.0, Color(0, 0, 0, 0.25))
	if ko_angle > 0.0:
		var angle := -dir * ko_angle * PI / 2.0 * 0.92
		draw_set_transform(feet, angle, Vector2.ONE)
		PixelSprites.draw(self, class_id, sprite_origin - feet, pixel, team_color, team == 1, true)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	else:
		PixelSprites.draw(self, class_id, sprite_origin, pixel, team_color, team == 1, false)
		if flash > 0.0:
			draw_rect(Rect2(sprite_origin, Vector2(sprite_size, sprite_size)), Color(1, 1, 1, flash * 0.7))
	if not alive:
		_draw_centered(font, "KO", Vector2(w / 2.0, BUBBLE_HEIGHT + sprite_size / 2.0 + 10), 34, Color(1, 0.3, 0.3))

	# Intention (bulle translucide), ou menace d'un ennemi dont la forte est prête.
	if intent_text != "":
		var bubble := Rect2(Vector2(4, 0), Vector2(w - 8, BUBBLE_HEIGHT - 4)).grow(4.0 * announce_pop)
		draw_rect(bubble, Color(0.08, 0.1, 0.18, intent_alpha))
		draw_rect(bubble, Color(team_color, intent_alpha + 0.2).lerp(Color(1, 1, 1), announce_pop), false, 2.0 + 2.0 * announce_pop)
		_draw_centered(font, intent_text, Vector2(w / 2.0, 22), 17, Color(1, 1, 1, minf(intent_alpha + 0.35, 1.0)))
		if intent_star:
			_draw_star(bubble.position + Vector2(bubble.size.x - 10, 10), 8.0, Color(1, 0.85, 0.2))
	elif threat_text != "" and alive:
		var pulse_t := 0.55 + 0.3 * sin(_time * 5.0)
		var tag := Rect2(Vector2(18, 2), Vector2(w - 36, BUBBLE_HEIGHT - 8))
		draw_rect(tag, Color(0.6, 0.05, 0.1, pulse_t))
		_draw_centered(font, threat_text, Vector2(w / 2.0, 21), 15, Color.WHITE)

	# Pastille d'ordre de passage pendant la résolution.
	if order_badge > 0:
		draw_circle(Vector2(18, BUBBLE_HEIGHT + 16), 14.0, Color(0.1, 0.1, 0.1, 0.85))
		_draw_centered(font, str(order_badge), Vector2(18, BUBBLE_HEIGHT + 23), 18, Color.WHITE)

	# Recharges de la moyenne et de la forte, sur le côté du sprite : on sait quand la forte revient.
	if alive and not cooldowns.is_empty():
		var chip_y := BUBBLE_HEIGHT + 30.0
		for tier in ["moyenne", "forte"]:
			var left := int(cooldowns.get(tier, 0))
			var chip := Rect2(Vector2(w - 34, chip_y), Vector2(30, 22))
			var ready := left == 0
			draw_rect(chip, Color("2fbf71", 0.85) if ready else Color(0.1, 0.1, 0.14, 0.85))
			draw_rect(chip, Color(1, 0.85, 0.2) if ready and tier == "forte" else Color(0, 0, 0, 0.6), false, 1.5)
			var label := ("M" if tier == "moyenne" else "F") + ("" if ready else ("×" if left < 0 else str(left)))
			_draw_centered(font, label, chip.position + Vector2(15, 16), 14, Color.WHITE if ready else Color(0.75, 0.75, 0.8))
			chip_y += 26.0

	# Prévision du coup quand le joueur vise ce perso.
	if preview_text != "" and targetable:
		var text_w := font.get_string_size(preview_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 20).x + 14
		var box := Rect2(Vector2(w - text_w - 4, BUBBLE_HEIGHT + 4), Vector2(text_w, 28))
		draw_rect(box, Color(0.05, 0.05, 0.08, 0.85))
		draw_rect(box, preview_color, false, 2.0)
		draw_string(font, box.position + Vector2(7, 21), preview_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, preview_color)

	# Nom et PV.
	var y := BUBBLE_HEIGHT + sprite_size + 14
	var name_text := display_name if subtitle == "" else "%s · %s" % [display_name, subtitle]
	_draw_centered(font, name_text, Vector2(w / 2.0, y + 14), name_size, Color(1, 0.9, 0.4) if is_player else (Color("9ad1ff") if is_acolyte and team == 0 else Color.WHITE))
	var bar := Rect2(Vector2(10, y + 22), Vector2(w - 20, 14))
	draw_rect(bar, Color(0.15, 0.15, 0.2))
	var ratio := clampf(shown_hp / float(max_hp), 0.0, 1.0)
	var ghost_ratio := clampf(ghost_hp / float(max_hp), 0.0, 1.0)
	draw_rect(Rect2(bar.position, Vector2(bar.size.x * ghost_ratio, bar.size.y)), Color(1, 0.95, 0.85, 0.8))
	var hp_color := Color("2fbf71") if ratio > 0.5 else (Color("f2c14e") if ratio > 0.25 else Color("e5484d"))
	draw_rect(Rect2(bar.position, Vector2(bar.size.x * ratio, bar.size.y)), hp_color)
	if barrier > 0:
		var barrier_ratio := clampf(float(barrier) / float(max_hp), 0.0, 1.0)
		draw_rect(Rect2(bar.position + Vector2(0, -5), Vector2(bar.size.x * barrier_ratio, 5)), Color("9ad1ff"))
	draw_rect(bar, Color(0, 0, 0), false, 1.0)
	_draw_centered(font, "%d / %d" % [int(round(shown_hp)), max_hp], Vector2(w / 2.0, y + 52), 15, Color(0.85, 0.85, 0.9))

	# États.
	var x := 8.0
	for tag_info in status_tags:
		var label := "%s %d" % [tag_info["name"], int(tag_info["turns"])] if int(tag_info["turns"]) > 0 else str(tag_info["name"])
		var text_w := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x + 8
		if x + text_w > w:
			break
		var color := Color("e5484d") if tag_info["negative"] else Color("2fbf71")
		draw_rect(Rect2(Vector2(x, y + 58), Vector2(text_w, 18)), Color(color, 0.35))
		draw_string(font, Vector2(x + 4, y + 72), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color.WHITE)
		x += text_w + 4

	# Textes flottants (dégâts, soins, Bloqué...), avec un petit effet de « pop ».
	for floater in _floaters:
		var t: float = floater["t"]
		var alpha := clampf(1.5 - t * 1.3, 0.0, 1.0)
		var pop := 1.0 + 0.5 * clampf(1.0 - t * 6.0, 0.0, 1.0)
		var font_size := int(float(floater["size"]) * pop)
		var pos := Vector2(w / 2.0 + float(floater["offset"]), BUBBLE_HEIGHT + 44 - t * 46.0)
		_draw_centered(font, floater["text"], pos + Vector2(2, 2), font_size, Color(0, 0, 0, alpha))
		_draw_centered(font, floater["text"], pos, font_size, Color(floater["color"], alpha))


func _draw_star(center: Vector2, radius: float, color: Color) -> void:
	var points := PackedVector2Array()
	for i in range(10):
		var r := radius if i % 2 == 0 else radius * 0.45
		var angle := -PI / 2.0 + float(i) * PI / 5.0
		points.append(center + Vector2(cos(angle), sin(angle)) * r)
	draw_colored_polygon(points, color)


func _draw_centered(font: Font, text: String, center: Vector2, font_size: int, color: Color) -> void:
	var text_w := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	draw_string(font, Vector2(center.x - text_w / 2.0, center.y), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
