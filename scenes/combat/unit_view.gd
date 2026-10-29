## Un personnage dans l'arène du combat V2 (docs/SPEC-COMBAT-V2.md, section 12.2) : son sprite (de face s'il est
## ennemi, tourné vers l'adversaire s'il est allié) et sa plaque : la barre de PV (rouge côté ennemi, teal côté allié),
## puis ses menaces et ses états en pastilles (3 de chaque au plus, « +n » au-delà). Anneau doré en pointillé : la
## cible ennemie choisie ; teal : la cible alliée. Toucher : le choisir pour cible ; appui long : sa fiche (ou celle de
## la menace touchée). Affichage seulement.
class_name UnitView
extends Control

signal touche(id: String)
signal appui_long(id: String)
signal appui_menace(id: String, index: int, ancre: Vector2)

const APPUI_LONG := 0.25
const PASTILLE := 26.0
const OR := Color("e3b85f")
const TEAL := Color("5cc8b8")
const ROUGE := Color("d35b5b")
const VIOLET := Color("c9a0ff")
const TEXTE := Color("efe9d9")
const SURFACE := Color("1c1a28")
const BORD := Color("3a3650")

var id := ""
var allie := true
var pixel := 8.0
var sprite := ""
var nom := ""
var pv := 0
var pv_max := 1
var barriere := 0
var ko := false
## Les menaces ({pictogramme, couleur, cible, echeance, barre}) et les états ({pictogramme, couleur, tours}).
var menaces: Array = []
var etats: Array = []
var cible_ennemie := false
var cible_alliee := false
var _t := 0.0
var _phase := 0.0
var _appui := -1.0
var _appui_pos := Vector2.ZERO
var _appui_long_fait := false
var _flash := 0.0
var _secousse := 0.0
## Des nombres qui montent et s'effacent : [texte, couleur, âge].
var _flottants: Array = []


static func make(p_id: String, p_sprite: String, p_nom: String, p_pixel: float, p_allie: bool) -> UnitView:
	var v := UnitView.new()
	v.id = p_id
	v.sprite = p_sprite
	v.nom = p_nom
	v.pixel = p_pixel
	v.allie = p_allie
	v._phase = float(p_id.hash() % 100) * 0.07
	var cote := p_pixel * PixelSprites.GRID
	v.custom_minimum_size = Vector2(maxf(cote, 3.0 * PASTILLE + 20.0), cote + 22.0 + PASTILLE + 8.0)
	v.size = v.custom_minimum_size
	v.mouse_filter = Control.MOUSE_FILTER_STOP
	return v


## La place du sprite (en haut, centré) et celle de la plaque, dans la vue.
func rect_sprite() -> Rect2:
	var cote := pixel * PixelSprites.GRID
	return Rect2(Vector2((size.x - cote) / 2.0, 0.0), Vector2(cote, cote))


## Le centre du sprite, dans les coordonnées du parent (pour les traits d'annonce).
func centre() -> Vector2:
	return position + rect_sprite().get_center()


func flash() -> void:
	_flash = 1.0


func secouer() -> void:
	_secousse = 1.0


func flottant(texte: String, couleur: Color) -> void:
	_flottants.append([texte, couleur, 0.0 - 0.18 * float(_flottants.size())])


func _process(delta: float) -> void:
	_t += delta
	_flash = maxf(0.0, _flash - delta * 3.0)
	_secousse = maxf(0.0, _secousse - delta * 4.0)
	for f in _flottants:
		f[2] += delta
	_flottants = _flottants.filter(func(f): return f[2] < 1.4)
	if _appui >= 0.0 and not _appui_long_fait and _t - _appui >= APPUI_LONG:
		_appui_long_fait = true
		var index := _menace_sous(_appui_pos)
		if index >= 0:
			appui_menace.emit(id, index, global_position + _rect_pastille(index).get_center())
		else:
			appui_long.emit(id)
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton or event.button_index != MOUSE_BUTTON_LEFT:
		return
	if event.pressed:
		_appui = _t
		_appui_pos = event.position
		_appui_long_fait = false
	else:
		if _appui >= 0.0 and not _appui_long_fait:
			touche.emit(id)
		_appui = -1.0
	accept_event()


func _draw() -> void:
	var police := ThemeDB.fallback_font
	var rs := rect_sprite()
	var dx := sin(_t * 40.0) * 6.0 * _secousse
	var souffle := 0.0 if ko else roundf(sin(_t * 2.2 + _phase) * 1.2) * 2.0
	# Ombre au sol.
	draw_set_transform(Vector2(rs.get_center().x, rs.end.y - 2.0), 0.0, Vector2(1.0, 0.25))
	draw_circle(Vector2.ZERO, rs.size.x * 0.32, Color(0, 0, 0, 0.35))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if cible_ennemie or cible_alliee:
		_anneau(rs.get_center(), rs.size.x * 0.56, OR if cible_ennemie else TEAL)
	var teinte := TEAL if allie else ROUGE
	PixelSprites.draw(self, sprite, rs.position + Vector2(dx, souffle + (rs.size.y * 0.35 if ko else 0.0)), pixel, teinte, not allie, ko)
	if _flash > 0.0:
		draw_rect(rs, Color(1, 1, 1, 0.45 * _flash))
	# La plaque : PV.
	var y := rs.end.y + 4.0
	var largeur := minf(size.x - 8.0, maxf(rs.size.x, 110.0))
	var x0 := (size.x - largeur) / 2.0
	draw_rect(Rect2(x0, y, largeur, 8.0), Color("0f0e17"))
	var part := clampf(float(pv) / float(maxi(1, pv_max)), 0.0, 1.0)
	draw_rect(Rect2(x0, y, largeur * part, 8.0), teinte if not ko else BORD)
	if barriere > 0:
		var bp := clampf(float(barriere) / float(maxi(1, pv_max)), 0.0, 1.0)
		draw_rect(Rect2(x0, y - 3.0, largeur * bp, 3.0), Color("9bd3ca"))
	var texte_pv := "KO" if ko else "%d" % pv
	var largeur_pv := police.get_string_size(texte_pv, HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x
	# Le nom tient à côté des PV : la police rapetisse pour un nom long (« Loup gris » sous un petit monstre).
	var place := largeur - largeur_pv - 6.0
	var taille_nom := 14
	while taille_nom > 9 and police.get_string_size(nom, HORIZONTAL_ALIGNMENT_LEFT, -1, taille_nom).x > place:
		taille_nom -= 1
	# Encore trop long (« Chaman gobelin » sous un petit monstre) : coupé, avec un point.
	var affiche := nom
	while affiche.length() > 3 and police.get_string_size(affiche, HORIZONTAL_ALIGNMENT_LEFT, -1, taille_nom).x > place:
		affiche = affiche.substr(0, affiche.length() - 2) + "."
	draw_string(police, Vector2(x0, y + 22.0), affiche, HORIZONTAL_ALIGNMENT_LEFT, place, taille_nom, TEXTE)
	draw_string(police, Vector2(x0, y + 22.0), texte_pv, HORIZONTAL_ALIGNMENT_RIGHT, largeur, 14, Color("aaa49b"))
	# Les pastilles : menaces, puis états.
	var n := mini(menaces.size(), 3) + mini(etats.size(), 3) + (1 if menaces.size() > 3 or etats.size() > 3 else 0)
	for i in range(n):
		var r := _rect_pastille(i)
		var p := _pastille(i)
		var bord: Color = p.get("bord", BORD)
		draw_rect(r, SURFACE)
		if p.get("halo", false):
			draw_rect(r.grow(2.0 + sin(_t * 6.0) * 1.0), Color(bord, 0.35), false, 2.0)
		draw_rect(r, bord, false, 1.5)
		if p.has("pictogramme"):
			Picto.dessiner(self, str(p["pictogramme"]), r.position + Vector2(r.size.y * 0.5, r.size.y * 0.5), r.size.y * 0.66, Color(str(p["couleur"])))
		if p.has("cible"):
			Picto.dessiner(self, str(p["cible"]), r.position + Vector2(r.size.y * 1.15, r.size.y * 0.55), r.size.y * 0.45, Color("aaa49b"))
		draw_string(police, Vector2(r.end.x - 13.0, r.position.y + r.size.y * 0.72), str(p.get("texte", "")), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, TEXTE)
		if p.get("barre", false):
			draw_line(r.position + Vector2(3, r.size.y - 3), r.end - Vector2(3, r.size.y - 3), ROUGE, 2.0)
	# Les nombres qui montent.
	for f in _flottants:
		if f[2] < 0.0:
			continue
		var a := 1.0 - clampf(f[2] / 1.4, 0.0, 1.0)
		var pos := rs.get_center() + Vector2(-20.0, -rs.size.y * 0.3 - f[2] * 40.0)
		draw_string(police, pos + Vector2(2, 2), str(f[0]), HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color(0, 0, 0, a))
		draw_string(police, pos, str(f[0]), HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color(f[1], a))


func _pastille(i: int) -> Dictionary:
	var nm := mini(menaces.size(), 3)
	if i < nm:
		var m: Dictionary = menaces[i]
		return {"pictogramme": m["pictogramme"], "couleur": m["couleur"], "cible": m["cible"], "texte": str(m["echeance"]),
			"bord": VIOLET if allie else ROUGE, "halo": int(m["echeance"]) == 1 and not m["barre"], "barre": m["barre"]}
	var j := i - nm
	if j < mini(etats.size(), 3):
		var s: Dictionary = etats[j]
		return {"pictogramme": s["pictogramme"], "couleur": s["couleur"], "texte": str(s["tours"]), "bord": BORD}
	return {"texte": "+%d" % (maxi(0, menaces.size() - 3) + maxi(0, etats.size() - 3)), "bord": BORD}


func _rect_pastille(i: int) -> Rect2:
	var rs := rect_sprite()
	var y := rs.end.y + 30.0
	var largeur := PASTILLE * 1.9
	var n := mini(menaces.size(), 3) + mini(etats.size(), 3) + (1 if menaces.size() > 3 or etats.size() > 3 else 0)
	var total := float(n) * (largeur + 4.0) - 4.0
	var x0 := (size.x - total) / 2.0
	return Rect2(x0 + float(i) * (largeur + 4.0), y, largeur, PASTILLE)


func _menace_sous(pos: Vector2) -> int:
	for i in range(mini(menaces.size(), 3)):
		if _rect_pastille(i).grow(4.0).has_point(pos):
			return i
	return -1


func _anneau(c: Vector2, r: float, col: Color) -> void:
	var segments := 24
	for i in range(segments):
		if i % 2 == 1:
			continue
		var a0 := TAU * float(i) / float(segments) + _t * 0.6
		draw_arc(c, r, a0, a0 + TAU / float(segments), 4, col, 2.5)
