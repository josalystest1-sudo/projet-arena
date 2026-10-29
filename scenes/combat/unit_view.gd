## Un personnage dans l'arène du combat V2 (docs/SPEC-COMBAT-V2.md, section 12.2) : son sprite (de face s'il est
## ennemi, tourné vers l'adversaire s'il est allié) et sa plaque : la barre de PV (rouge côté ennemi, teal côté allié),
## puis ses menaces (un allié seulement : l'adversaire est caché) et ses états en pastilles (3 de chaque au plus, « +n »
## au-delà). Un ennemi dont la Clé est prête a un halo violet qui pulse, une étiquette « CLÉ PRÊTE » au-dessus de
## lui et une pastille « Clé » en tête des autres. Anneau doré en pointillé : la
## cible ennemie choisie ; teal : la cible alliée. Toucher : le choisir pour cible ; appui long : sa fiche. Toucher
## (ou appui long sur) une pastille : ce qu'elle fait. Affichage seulement.
class_name UnitView
extends Control

signal touche(id: String)
signal appui_long(id: String)
## Une pastille touchée (tenu : par un appui long, la fiche se ferme au relâchement) ; index dans les pastilles
## affichées (voir contenu_pastille).
signal pastille(id: String, index: int, ancre: Vector2, tenu: bool)

const APPUI_LONG := 0.25
const PASTILLE := 26.0
const OR := Color("e3b85f")
const TEAL := Color("5cc8b8")
const ROUGE := Color("d35b5b")
const VIOLET := Color("c9a0ff")
## Le violet vif du halo « Clé prête » : il doit ressortir sur le fond sombre de l'arène.
const VIOLET_VIF := Color("e2c6ff")
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
## Les menaces ({pictogramme, couleur, cible, echeance, barre, voie, rang}) et les états ({nom, pictogramme, couleur,
## tours}).
var menaces: Array = []
var etats: Array = []
var cible_ennemie := false
var cible_alliee := false
## La Clé d'un ennemi est prête (jouable ce tour-ci) : la lueur.
var cle_prete := false
## Un boss de donjon verrouillé par un palier (GDD V2, § 8.5) : une étiquette rouge.
var verrou := false
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
		var index := _pastille_sous(_appui_pos)
		if index >= 0:
			pastille.emit(id, index, global_position + _rect_pastille(index).get_center(), true)
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
			var index := _pastille_sous(_appui_pos)
			if index >= 0:
				pastille.emit(id, index, global_position + _rect_pastille(index).get_center(), false)
			else:
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
	var pouls := 0.5 + 0.5 * sin(_t * 5.0)
	if cle_prete and not ko:
		# Le halo : un disque violet, un anneau vif et une onde qui s'éloigne.
		draw_circle(rs.get_center(), rs.size.x * 0.54, Color(VIOLET, 0.28 + 0.22 * pouls))
		draw_arc(rs.get_center(), rs.size.x * 0.54, 0.0, TAU, 48, VIOLET_VIF, 4.0)
		var onde := fmod(_t * 0.8, 1.0)
		draw_arc(rs.get_center(), rs.size.x * (0.56 + 0.22 * onde), 0.0, TAU, 48, Color(VIOLET_VIF, 0.8 * (1.0 - onde)), 3.0)
	if cible_ennemie or cible_alliee:
		_anneau(rs.get_center(), rs.size.x * 0.56, OR if cible_ennemie else TEAL)
	var teinte := TEAL if allie else ROUGE
	PixelSprites.draw(self, sprite, rs.position + Vector2(dx, souffle + (rs.size.y * 0.35 if ko else 0.0)), pixel, teinte, not allie, ko)
	if _flash > 0.0:
		draw_rect(rs, Color(1, 1, 1, 0.45 * _flash))
	if cle_prete and not ko:
		# L'étiquette au-dessus de la tête.
		var texte_cle := "CLÉ PRÊTE"
		var l := police.get_string_size(texte_cle, HORIZONTAL_ALIGNMENT_LEFT, -1, 15).x + 18.0
		var r := Rect2(rs.get_center().x - l / 2.0, rs.position.y - 26.0 - 2.0 * pouls, l, 24.0)
		var style := StyleBoxFlat.new()
		style.bg_color = VIOLET_VIF
		style.set_corner_radius_all(12)
		draw_style_box(style, r)
		draw_string(police, Vector2(r.position.x, r.position.y + 17.0), texte_cle, HORIZONTAL_ALIGNMENT_CENTER, l, 15, Color("0f0e17"))
	if verrou and not ko:
		var texte_v := "VERROUILLÉ"
		var lv := police.get_string_size(texte_v, HORIZONTAL_ALIGNMENT_LEFT, -1, 15).x + 18.0
		var rv := Rect2(rs.get_center().x - lv / 2.0, rs.position.y - 26.0 - (26.0 if cle_prete else 0.0), lv, 24.0)
		var sv := StyleBoxFlat.new()
		sv.bg_color = Color("c93b3b")
		sv.set_corner_radius_all(12)
		draw_style_box(sv, rv)
		draw_string(police, Vector2(rv.position.x, rv.position.y + 17.0), texte_v, HORIZONTAL_ALIGNMENT_CENTER, lv, 15, Color.WHITE)
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
	for i in range(_nb_pastilles()):
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
		if p.has("libelle"):
			draw_string(police, Vector2(r.position.x, r.position.y + r.size.y * 0.72), str(p["libelle"]), HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 14, VIOLET)
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


## Ce que montre la pastille i : { type : « cle » (la Clé d'un ennemi est prête), « menace », « etat » ou « plus »,
## i : son rang dans menaces ou etats }.
func contenu_pastille(i: int) -> Dictionary:
	if cle_prete and not ko:
		if i == 0:
			return {"type": "cle", "i": 0}
		i -= 1
	var nm := mini(menaces.size(), 3)
	if i < nm:
		return {"type": "menace", "i": i}
	if i - nm < mini(etats.size(), 3):
		return {"type": "etat", "i": i - nm}
	return {"type": "plus", "i": 0}


func _nb_pastilles() -> int:
	var n := mini(menaces.size(), 3) + mini(etats.size(), 3) + (1 if menaces.size() > 3 or etats.size() > 3 else 0)
	return n + (1 if cle_prete and not ko else 0)


func _pastille(i: int) -> Dictionary:
	var c := contenu_pastille(i)
	if c["type"] == "cle":
		return {"libelle": "Clé", "bord": VIOLET, "halo": true}
	if c["type"] == "menace":
		var m: Dictionary = menaces[c["i"]]
		return {"pictogramme": m["pictogramme"], "couleur": m["couleur"], "cible": m["cible"], "texte": str(m["echeance"]),
			"bord": VIOLET if allie else ROUGE, "halo": int(m["echeance"]) == 1 and not m["barre"], "barre": m["barre"]}
	if c["type"] == "etat":
		var s: Dictionary = etats[c["i"]]
		return {"pictogramme": s["pictogramme"], "couleur": s["couleur"], "texte": str(s["tours"]), "bord": BORD}
	return {"texte": "+%d" % (maxi(0, menaces.size() - 3) + maxi(0, etats.size() - 3)), "bord": BORD}


func _rect_pastille(i: int) -> Rect2:
	var rs := rect_sprite()
	var y := rs.end.y + 30.0
	var largeur := PASTILLE * 1.9
	var total := float(_nb_pastilles()) * (largeur + 4.0) - 4.0
	var x0 := (size.x - total) / 2.0
	return Rect2(x0 + float(i) * (largeur + 4.0), y, largeur, PASTILLE)


func _pastille_sous(pos: Vector2) -> int:
	for i in range(_nb_pastilles()):
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
