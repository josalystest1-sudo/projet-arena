## La bande d'une voie (docs/SPEC-COMBAT-V2.md, section 12.2) : ses 4 nœuds reliés, le jalon en point doré épais, les
## nœuds éteints en pointillé, les nœuds pas allumés grisés, la Clé en losange ; à droite, « Clé » et son échéance.
## Sert au bas de l'écran de combat et à la fiche d'un personnage. Appui long sur un point : la fiche du nœud.
## Affichage seulement.
class_name BandeVoie
extends Control

signal appui_long_noeud(voie: int, rang: int, ancre: Vector2)

const APPUI_LONG := 0.25
const OR := Color("e3b85f")
const TEXTE := Color("efe9d9")
const ATTENUE := Color("aaa49b")
const BORD := Color("3a3650")
const SURFACE := Color("1c1a28")

var voie := 0
var titre := ""
## Le pictogramme de la voie (celui de son premier nœud).
var picto := {}
var jalon := 0
## Par rang (1 à 4) : allumé ? éteint ? (tours d'extinction restants) ; l'échéance de la Clé (0 : pas de Clé).
var allumes: Array = [true, true, true, true]
var eteints: Array = [0, 0, 0, 0]
var echeance_cle := 0
var cle_barree := false
var _t := 0.0
var _appui := -1.0
var _appui_rang := 0
var _long_fait := false


func _init() -> void:
	custom_minimum_size = Vector2(0, 46)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_STOP


func _process(delta: float) -> void:
	_t += delta
	if _appui >= 0.0 and not _long_fait and _t - _appui >= APPUI_LONG and _appui_rang > 0:
		_long_fait = true
		appui_long_noeud.emit(voie, _appui_rang, global_position + _point(_appui_rang))
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton or event.button_index != MOUSE_BUTTON_LEFT:
		return
	if event.pressed:
		_appui = _t
		_long_fait = false
		_appui_rang = 0
		for r in range(1, 5):
			if _point(r).distance_to(event.position) < 22.0:
				_appui_rang = r
	else:
		_appui = -1.0
	accept_event()


func _point(rang: int) -> Vector2:
	var x0 := 56.0
	var x1 := size.x - 96.0
	return Vector2(x0 + (x1 - x0) * float(rang - 1) / 3.0, size.y / 2.0)


func _draw() -> void:
	var police := ThemeDB.fallback_font
	if not picto.is_empty():
		Picto.dessiner(self, str(picto["pictogramme"]), Vector2(22, size.y / 2.0), 24.0, Color(str(picto["couleur"])))
	for r in range(1, 4):
		draw_line(_point(r), _point(r + 1), OR if r < jalon else BORD, 3.0 if r < jalon else 2.0)
	for r in range(1, 5):
		var p := _point(r)
		var col := OR if r <= jalon else (TEXTE if bool(allumes[r - 1]) else Color(ATTENUE, 0.4))
		var rayon := 11.0 if r == jalon else 7.0
		if r == 4:
			var l := 12.0
			var losange := PackedVector2Array([p + Vector2(0, -l), p + Vector2(l, 0), p + Vector2(0, l), p + Vector2(-l, 0)])
			draw_colored_polygon(losange, SURFACE)
			draw_polyline(losange + PackedVector2Array([losange[0]]), Color("c9a0ff") if bool(allumes[3]) else Color(ATTENUE, 0.4), 2.5)
		elif r == jalon:
			draw_circle(p, rayon, OR)
			draw_arc(p, rayon + 3.0 + sin(_t * 5.0), 0.0, TAU, 20, Color(OR, 0.4), 2.0)
		elif int(eteints[r - 1]) > 0:
			for i in range(8):
				if i % 2 == 0:
					draw_arc(p, rayon, TAU * float(i) / 8.0, TAU * float(i + 1) / 8.0, 3, col, 2.0)
		else:
			draw_circle(p, rayon, SURFACE)
			draw_arc(p, rayon, 0.0, TAU, 16, col, 2.0)
	if bool(allumes[3]):
		var txt := "Clé %d" % echeance_cle if echeance_cle > 0 else "Clé"
		draw_string(police, Vector2(size.x - 80, size.y / 2.0 + 7), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, ATTENUE)
		if cle_barree:
			draw_line(Vector2(size.x - 82, size.y / 2.0 + 10), Vector2(size.x - 20, size.y / 2.0 - 10), Color("d35b5b"), 2.0)
	if titre != "":
		draw_string(police, Vector2(56, 12), titre, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, ATTENUE)
