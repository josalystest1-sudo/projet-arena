## Une des six cases fixes du bas de l'écran de combat (docs/SPEC-COMBAT-V2.md, section 12.2) : le moyeu, ou le
## prochain nœud d'une voie. Elle montre ses pictogrammes et sa cible, son nom, sa ligne chiffrée ; grisée avec la raison
## (sablier, flocon, bâillon, racine, chaînes) si elle ne peut pas être jouée ; un œil barré sous Aveuglé pour un nœud à
## une seule cible ennemie ; dorée, avec le nom de la Synergie, si elle complète une Synergie avec ce que l'acolyte a
## annoncé (« Brisure → Loup » : seulement en visant ce perso). Premier toucher : elle se soulève ; second : elle est
## jouée (verrouillée). Appui long : la fiche du nœud (ou, verrouillée, la déverrouiller). Affichage seulement.
class_name CaseNoeud
extends Control

signal touche(index: int)
signal appui_long(index: int)

const APPUI_LONG := 0.25
const OR := Color("e3b85f")
const TEXTE := Color("efe9d9")
const ATTENUE := Color("aaa49b")
const SURFACE := Color("1c1a28")
const SURFACE_HAUTE := Color("262337")
const BORD := Color("3a3650")

## 0 : le moyeu ; 1 à 5 : les voies.
var index := 0
var nom := ""
var ligne := ""
var pictos: Array = []
var jouable := false
## Ce qui l'empêche : un pictogramme (sablier, flocon, baillon, racine, chaines) ou "".
var raison := ""
var aveugle := false
var cle := false
var choisie := false
var verrouillee := false
var vide := false
## La Synergie que cette case complète avec la cible choisie (« Brisure »), ou "" ; sinon, celle qu'elle compléterait
## en visant un autre perso (« Brisure → Loup »).
var synergie := ""
var synergie_ailleurs := ""
var _t := 0.0
var _appui := -1.0
var _long_fait := false


func _init() -> void:
	custom_minimum_size = Vector2(0, 112)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_STOP


func _process(delta: float) -> void:
	_t += delta
	if _appui >= 0.0 and not _long_fait and _t - _appui >= APPUI_LONG:
		_long_fait = true
		appui_long.emit(index)
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton or event.button_index != MOUSE_BUTTON_LEFT:
		return
	if event.pressed:
		_appui = _t
		_long_fait = false
	else:
		if _appui >= 0.0 and not _long_fait:
			touche.emit(index)
		_appui = -1.0
	accept_event()


func _draw() -> void:
	var police := ThemeDB.fallback_font
	var leve := -6.0 if choisie and not verrouillee else 0.0
	var r := Rect2(Vector2(2, 2 + leve), size - Vector2(4, 4))
	var fond := Color("3a2f12") if verrouillee else (SURFACE_HAUTE if choisie else SURFACE)
	_rect_arrondi(r, fond)
	var bord := OR if (choisie or verrouillee) else (Color("c9a0ff") if cle and jouable else BORD)
	if synergie != "" and jouable:
		bord = OR
		_rect_arrondi(r.grow(2.0 + 1.5 * sin(_t * 5.0)), Color(OR, 0.45), false, 2.0)
	_rect_arrondi(r, bord, false, 3.0 if choisie or verrouillee or (synergie != "" and jouable) else 1.5)
	var alpha := 1.0 if jouable or verrouillee else 0.38
	if vide:
		draw_string(police, Vector2(r.position.x, r.get_center().y + 6), "—", HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 22, Color(ATTENUE, 0.5))
		return
	# Pictogrammes et glyphe de cible, en haut.
	var x := r.position.x + 12.0
	for p in pictos.slice(0, 3):
		Picto.dessiner(self, str(p["pictogramme"]), Vector2(x + 12, r.position.y + 20), 24.0, Color(Color(str(p["couleur"])), alpha))
		x += 30.0
	if not pictos.is_empty():
		Picto.dessiner(self, str(pictos[0]["cible"]), Vector2(r.end.x - 22, r.position.y + 20), 20.0, Color(ATTENUE, alpha))
	if cle:
		var c := Vector2(r.end.x - 48, r.position.y + 20)
		var l := 8.0
		draw_polyline(PackedVector2Array([c + Vector2(0, -l), c + Vector2(l, 0), c + Vector2(0, l), c + Vector2(-l, 0), c + Vector2(0, -l)]), Color(Color("c9a0ff"), alpha), 2.0)
	# Le nom tient sur la case : la police rapetisse pour un nom long (« Coup de pied circulaire concentré »).
	var taille := 19
	while taille > 12 and police.get_string_size(nom, HORIZONTAL_ALIGNMENT_LEFT, -1, taille).x > r.size.x - 14:
		taille -= 1
	if police.get_string_size(nom, HORIZONTAL_ALIGNMENT_LEFT, -1, taille).x > r.size.x - 14:
		var coupe := nom.rfind(" ", nom.length() / 2 + 4)
		draw_string(police, Vector2(r.position.x + 6, r.position.y + 54), nom.substr(0, coupe), HORIZONTAL_ALIGNMENT_CENTER, r.size.x - 12, taille, Color(TEXTE, alpha))
		draw_string(police, Vector2(r.position.x + 6, r.position.y + 70), nom.substr(coupe + 1), HORIZONTAL_ALIGNMENT_CENTER, r.size.x - 12, taille, Color(TEXTE, alpha))
	else:
		draw_string(police, Vector2(r.position.x + 8, r.position.y + 62), nom, HORIZONTAL_ALIGNMENT_CENTER, r.size.x - 16, taille, Color(TEXTE, alpha))
	draw_string(police, Vector2(r.position.x + 6, r.position.y + 88), ligne, HORIZONTAL_ALIGNMENT_CENTER, r.size.x - 12, 13, Color(ATTENUE, alpha))
	if raison != "" and not verrouillee:
		Picto.dessiner(self, raison, Vector2(r.get_center().x, r.position.y + 22), 26.0, Color("c9a0ff"))
	if aveugle and jouable:
		Picto.dessiner(self, "oeil_barre", Vector2(r.position.x + 18, r.end.y - 16), 18.0, Color("c9a0ff"))
	# Le ruban de la Synergie, à cheval sur le bord du haut.
	var ruban := synergie if synergie != "" else synergie_ailleurs
	if ruban != "" and jouable and not verrouillee:
		var taille_r := 13
		while taille_r > 9 and police.get_string_size(ruban, HORIZONTAL_ALIGNMENT_LEFT, -1, taille_r).x > r.size.x - 24:
			taille_r -= 1
		var w := police.get_string_size(ruban, HORIZONTAL_ALIGNMENT_LEFT, -1, taille_r).x + 16.0
		var rr := Rect2(Vector2(r.get_center().x - w / 2.0, r.position.y - 9.0), Vector2(w, 18.0))
		var style := StyleBoxFlat.new()
		style.set_corner_radius_all(9)
		style.bg_color = OR if synergie != "" else Color("2b2410")
		style.border_color = OR
		style.set_border_width_all(1)
		draw_style_box(style, rr)
		draw_string(police, Vector2(rr.position.x, rr.position.y + 13.5), ruban, HORIZONTAL_ALIGNMENT_CENTER, rr.size.x, taille_r,
			Color("0f0e17") if synergie != "" else OR)


func _rect_arrondi(r: Rect2, col: Color, plein: bool = true, epaisseur: float = 1.0) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = col if plein else Color(0, 0, 0, 0)
	style.set_corner_radius_all(12)
	if not plein:
		style.border_color = col
		style.set_border_width_all(int(epaisseur))
		style.draw_center = false
	draw_style_box(style, r)
