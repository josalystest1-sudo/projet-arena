## Le bandeau « en face », en haut de l'écran de combat : une ligne par ennemi, toujours visible, sans rien toucher.
## Pour chacun, ce qu'il peut jouer ce tour-ci (ses actions légales, en jetons : pictogrammes et nombre ; la Clé bordée
## de violet ; doré : ce coup compléterait une Synergie avec ce que son acolyte a annoncé), ou, pour un acolyte qui a
## déjà annoncé, ce qu'il va jouer et sur qui. Toucher (ou appui long sur) un jeton : la fiche du nœud. Affichage
## seulement : les lignes sont remplies par l'écran de combat.
class_name BandeAdverse
extends Control

## tenu : par un appui long (la fiche se ferme au relâchement).
signal jeton_touche(id: String, voie: int, rang: int, ancre: Vector2, tenu: bool)

const APPUI_LONG := 0.25
const LIGNE := 30.0
const OR := Color("e3b85f")
const ROUGE := Color("d35b5b")
const VIOLET := Color("c9a0ff")
const TEXTE := Color("efe9d9")
const ATTENUE := Color("aaa49b")
const SURFACE := Color("1c1a28")
const BORD := Color("3a3650")

## Les lignes : { id, nom, titre (« peut jouer », « va jouer »), note (à droite : « sur Toi », « Synergie : Brisure »,
## « Étourdi »), ko, jetons : [{ voie, rang, pictos, texte, cle, synergie, annonce }] }.
var lignes: Array = []
var _t := 0.0
var _appui := -1.0
var _appui_jeton := []
var _long_fait := false


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP


func hauteur(nb_lignes: int) -> float:
	return LIGNE * float(nb_lignes) + 6.0


func _process(delta: float) -> void:
	_t += delta
	if _appui >= 0.0 and not _long_fait and _t - _appui >= APPUI_LONG and not _appui_jeton.is_empty():
		_long_fait = true
		_emettre(true)
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton or event.button_index != MOUSE_BUTTON_LEFT:
		return
	if event.pressed:
		_appui = _t
		_long_fait = false
		_appui_jeton = _jeton_sous(event.position)
	else:
		if _appui >= 0.0 and not _long_fait and not _appui_jeton.is_empty():
			_emettre(false)
		_appui = -1.0
	accept_event()


func _emettre(tenu: bool) -> void:
	var l: Dictionary = lignes[_appui_jeton[0]]
	var j: Dictionary = l["jetons"][_appui_jeton[1]]
	var r: Rect2 = _rects(_appui_jeton[0])[_appui_jeton[1]]
	jeton_touche.emit(str(l["id"]), int(j["voie"]), int(j["rang"]), global_position + Vector2(r.get_center().x, r.end.y), tenu)


func _jeton_sous(pos: Vector2) -> Array:
	for i in range(lignes.size()):
		var rects := _rects(i)
		for k in range(rects.size()):
			if rects[k].grow(3.0).has_point(pos):
				return [i, k]
	return []


## La place du nom, à gauche de chaque ligne : celle du plus long, 110 au plus.
func _largeur_nom() -> float:
	var police := ThemeDB.fallback_font
	var w := 40.0
	for l in lignes:
		w = maxf(w, police.get_string_size(str(l["nom"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 15).x + 10.0)
	return minf(w, minf(110.0, size.x * 0.24))


## La largeur d'un jeton : ses pictogrammes et son nombre.
func _largeur_jeton(j: Dictionary, police: Font) -> float:
	var n := mini(j["pictos"].size(), 2)
	return 10.0 + 20.0 * float(n) + (police.get_string_size(str(j["texte"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x + 4.0 if str(j["texte"]) != "" else 0.0)


## Les rectangles des jetons de la ligne i (ceux qui tiennent dans la largeur).
func _rects(i: int) -> Array[Rect2]:
	var police := ThemeDB.fallback_font
	var out: Array[Rect2] = []
	var l: Dictionary = lignes[i]
	var y := 3.0 + LIGNE * float(i) + 2.0
	var x := _largeur_nom() + 4.0
	if str(l.get("titre", "")) != "":
		x += police.get_string_size(str(l["titre"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x + 6.0
	for j in l["jetons"]:
		var w := _largeur_jeton(j, police)
		if x + w > size.x:
			break
		out.append(Rect2(x, y, w, LIGNE - 6.0))
		x += w + 5.0
	return out


func _draw() -> void:
	var police := ThemeDB.fallback_font
	draw_rect(Rect2(Vector2.ZERO, size), Color(SURFACE, 0.85))
	draw_line(Vector2(0, size.y - 1), Vector2(size.x, size.y - 1), BORD, 1.0)
	for i in range(lignes.size()):
		var l: Dictionary = lignes[i]
		var y := 3.0 + LIGNE * float(i)
		var base := y + LIGNE * 0.5 + 5.0
		# Le nom (coupé avec un point s'il est trop long).
		var nom := str(l["nom"])
		while nom.length() > 3 and police.get_string_size(nom, HORIZONTAL_ALIGNMENT_LEFT, -1, 15).x > _largeur_nom() - 4.0:
			nom = nom.substr(0, nom.length() - 2) + "."
		draw_string(police, Vector2(6, base), nom, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, ATTENUE if l.get("ko", false) else ROUGE)
		if l.get("ko", false):
			draw_string(police, Vector2(_largeur_nom() + 4.0, base), "KO", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, ATTENUE)
			continue
		var x := _largeur_nom() + 4.0
		if str(l.get("titre", "")) != "":
			draw_string(police, Vector2(x, base - 1), str(l["titre"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, ATTENUE)
		var rects := _rects(i)
		for k in range(rects.size()):
			_jeton(rects[k], l["jetons"][k], police)
		var fin := rects[-1].end.x + 8.0 if not rects.is_empty() else x + 4.0
		if rects.size() < l["jetons"].size():
			draw_string(police, Vector2(size.x - 24.0, base), "+%d" % (l["jetons"].size() - rects.size()), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, ATTENUE)
		elif str(l.get("note", "")) != "" and fin < size.x - 30.0:
			draw_string(police, Vector2(fin, base), str(l["note"]), HORIZONTAL_ALIGNMENT_LEFT, size.x - fin - 4.0, 13,
				OR if l.get("note_or", false) else ATTENUE)


func _jeton(r: Rect2, j: Dictionary, police: Font) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("262337") if j.get("annonce", false) else SURFACE
	style.set_corner_radius_all(8)
	var bord := BORD
	if j.get("synergie", false):
		bord = OR
	elif j.get("cle", false):
		bord = VIOLET
	elif j.get("annonce", false):
		bord = ROUGE
	style.border_color = bord
	style.set_border_width_all(2 if bord != BORD else 1)
	draw_style_box(style, r)
	if j.get("synergie", false):
		draw_rect(r.grow(2.0 + sin(_t * 6.0)), Color(OR, 0.3), false, 2.0)
	var x := r.position.x + 5.0
	for p in j["pictos"].slice(0, 2):
		Picto.dessiner(self, str(p["pictogramme"]), Vector2(x + 9.0, r.get_center().y), 17.0, Color(str(p["couleur"])))
		x += 20.0
	if str(j["texte"]) != "":
		draw_string(police, Vector2(x + 1.0, r.get_center().y + 5.0), str(j["texte"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, TEXTE)
