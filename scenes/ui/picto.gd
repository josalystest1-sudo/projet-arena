## Les pictogrammes du combat V2 (docs/SPEC-COMBAT-V2.md, sections 7.1 et 12.1) : un dessin par effet et par état
## (épée, cœur, bouclier, flamme, goutte, fiole, patte, chaînes, flocon…) et les glyphes de cible (une silhouette, deux,
## cerclée, avec un cœur). Dessinés en traits simples, en attendant l'art (étape 6 de la feuille de route).
## Affichage seulement.
class_name Picto
extends Control

var nom: String = ""
var couleur: Color = Color.WHITE
## Un nombre ou un chiffre d'échéance à côté (vide : rien).
var texte: String = ""
var halo: bool = false
var barre: bool = false


static func make(p_nom: String, p_couleur: Color, taille: float = 26.0, p_texte: String = "") -> Picto:
	var p := Picto.new()
	p.nom = p_nom
	p.couleur = p_couleur
	p.texte = p_texte
	p.custom_minimum_size = Vector2(taille + (taille * 0.9 if p_texte != "" else 0.0), taille)
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return p


func _draw() -> void:
	var cote := size.y
	if halo:
		draw_circle(Vector2(cote / 2.0, cote / 2.0), cote * 0.55, Color(couleur, 0.25))
	dessiner(self, nom, Vector2(cote / 2.0, cote / 2.0), cote * 0.8, couleur)
	if barre:
		draw_line(Vector2(cote * 0.1, cote * 0.9), Vector2(cote * 0.9, cote * 0.1), Color("d35b5b"), maxf(2.0, cote / 10.0))
	if texte != "":
		var police := ThemeDB.fallback_font
		var t := int(cote * 0.62)
		draw_string(police, Vector2(cote + 2.0, cote * 0.72), texte, HORIZONTAL_ALIGNMENT_LEFT, -1, t, Color("efe9d9"))


## Dessine un pictogramme centré en `c`, dans un carré de côté `taille`.
static func dessiner(ci: CanvasItem, p_nom: String, c: Vector2, taille: float, col: Color) -> void:
	var s := taille / 2.0
	var w := maxf(1.5, taille / 9.0)
	match p_nom:
		"epee":
			ci.draw_line(c + Vector2(-0.7, 0.7) * s, c + Vector2(0.75, -0.75) * s, col, w * 1.3)
			ci.draw_line(c + Vector2(-0.6, 0.15) * s, c + Vector2(-0.15, 0.6) * s, col, w)
		"epee_brisee":
			ci.draw_line(c + Vector2(-0.7, 0.7) * s, c + Vector2(-0.05, 0.05) * s, col, w * 1.3)
			ci.draw_line(c + Vector2(0.15, -0.15) * s, c + Vector2(0.75, -0.75) * s, col, w * 1.3)
			ci.draw_line(c + Vector2(-0.6, 0.15) * s, c + Vector2(-0.15, 0.6) * s, col, w)
		"coeur":
			_coeur(ci, c, s, col)
		"bouclier", "bouclier_pointe":
			var pts := PackedVector2Array([c + Vector2(-0.7, -0.75) * s, c + Vector2(0.7, -0.75) * s, c + Vector2(0.7, 0.05) * s, c + Vector2(0.0, 0.85) * s, c + Vector2(-0.7, 0.05) * s])
			ci.draw_colored_polygon(pts, Color(col, 0.35))
			ci.draw_polyline(pts + PackedVector2Array([pts[0]]), col, w)
			if p_nom == "bouclier_pointe":
				ci.draw_line(c + Vector2(0.0, -0.45) * s, c + Vector2(0.0, 0.35) * s, col, w)
				ci.draw_line(c + Vector2(-0.3, -0.15) * s, c + Vector2(0.0, -0.45) * s, col, w)
				ci.draw_line(c + Vector2(0.3, -0.15) * s, c + Vector2(0.0, -0.45) * s, col, w)
		"flamme":
			var pts := PackedVector2Array([c + Vector2(0.0, -0.85) * s, c + Vector2(0.45, -0.1) * s, c + Vector2(0.5, 0.4) * s, c + Vector2(0.0, 0.85) * s, c + Vector2(-0.5, 0.4) * s, c + Vector2(-0.35, -0.2) * s])
			ci.draw_colored_polygon(pts, col)
		"goutte":
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(0.0, -0.85) * s, c + Vector2(0.45, 0.15) * s, c + Vector2(-0.45, 0.15) * s]), col)
			ci.draw_circle(c + Vector2(0.0, 0.3) * s, 0.48 * s, col)
		"fiole":
			ci.draw_rect(Rect2(c + Vector2(-0.18, -0.85) * s, Vector2(0.36, 0.5) * s), col, false, w)
			ci.draw_circle(c + Vector2(0.0, 0.3) * s, 0.55 * s, col)
		"patte", "patte_coeur":
			ci.draw_circle(c + Vector2(0.0, 0.25) * s, 0.42 * s, col)
			for d in [Vector2(-0.55, -0.35), Vector2(-0.2, -0.65), Vector2(0.2, -0.65), Vector2(0.55, -0.35)]:
				ci.draw_circle(c + d * s, 0.17 * s, col)
			if p_nom == "patte_coeur":
				_coeur(ci, c + Vector2(0.55, 0.55) * s, s * 0.45, Color("efe9d9"))
		"chaines":
			ci.draw_arc(c + Vector2(-0.3, 0.0) * s, 0.38 * s, 0.0, TAU, 16, col, w)
			ci.draw_arc(c + Vector2(0.3, 0.0) * s, 0.38 * s, 0.0, TAU, 16, col, w)
		"flocon":
			for a in [0.0, PI / 3.0, 2.0 * PI / 3.0]:
				var d := Vector2(cos(a), sin(a)) * 0.85 * s
				ci.draw_line(c - d, c + d, col, w)
		"baillon":
			ci.draw_arc(c, 0.75 * s, 0.0, TAU, 20, col, w)
			ci.draw_rect(Rect2(c + Vector2(-0.8, -0.18) * s, Vector2(1.6, 0.36) * s), col)
		"racine":
			ci.draw_line(c + Vector2(0.0, -0.85) * s, c + Vector2(0.0, 0.2) * s, col, w * 1.2)
			ci.draw_line(c + Vector2(0.0, 0.2) * s, c + Vector2(-0.6, 0.8) * s, col, w)
			ci.draw_line(c + Vector2(0.0, 0.2) * s, c + Vector2(0.6, 0.8) * s, col, w)
			ci.draw_line(c + Vector2(0.0, 0.2) * s, c + Vector2(0.0, 0.85) * s, col, w)
		"oeil_barre":
			ci.draw_arc(c, 0.7 * s, PI * 0.15, PI * 0.85, 12, col, w)
			ci.draw_arc(c, 0.7 * s, PI * 1.15, PI * 1.85, 12, col, w)
			ci.draw_circle(c, 0.22 * s, col)
			ci.draw_line(c + Vector2(-0.8, 0.8) * s, c + Vector2(0.8, -0.8) * s, col, w)
		"fleche_arriere":
			ci.draw_line(c + Vector2(0.75, 0.0) * s, c + Vector2(-0.6, 0.0) * s, col, w * 1.2)
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(-0.85, 0.0) * s, c + Vector2(-0.3, -0.5) * s, c + Vector2(-0.3, 0.5) * s]), col)
		"etoile", "etoile_fendue":
			var pts := PackedVector2Array()
			for i in range(10):
				var r := (0.85 if i % 2 == 0 else 0.38) * s
				var a := -PI / 2.0 + float(i) * PI / 5.0
				pts.append(c + Vector2(cos(a), sin(a)) * r)
			ci.draw_colored_polygon(pts, col)
			if p_nom == "etoile_fendue":
				ci.draw_line(c + Vector2(-0.1, -0.85) * s, c + Vector2(0.15, 0.85) * s, Color("0f0e17"), w * 1.2)
		"rayon", "rayon_barre":
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(0.15, -0.85) * s, c + Vector2(-0.45, 0.1) * s, c + Vector2(0.0, 0.1) * s, c + Vector2(-0.15, 0.85) * s, c + Vector2(0.45, -0.1) * s, c + Vector2(0.0, -0.1) * s]), col)
			if p_nom == "rayon_barre":
				ci.draw_line(c + Vector2(-0.8, -0.8) * s, c + Vector2(0.8, 0.8) * s, col, w)
		"sablier":
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(-0.55, -0.8) * s, c + Vector2(0.55, -0.8) * s, c, c + Vector2(0.55, 0.8) * s, c + Vector2(-0.55, 0.8) * s, c]), Color(col, 0.6))
			ci.draw_polyline(PackedVector2Array([c + Vector2(-0.55, -0.8) * s, c + Vector2(0.55, -0.8) * s, c + Vector2(-0.55, 0.8) * s, c + Vector2(0.55, 0.8) * s, c + Vector2(-0.55, -0.8) * s]), col, w)
		"silhouette":
			_silhouette(ci, c, s, col)
		"deux_silhouettes":
			_silhouette(ci, c + Vector2(-0.35, 0.0) * s, s * 0.8, col)
			_silhouette(ci, c + Vector2(0.4, 0.05) * s, s * 0.8, col)
		"silhouette_cerclee":
			_silhouette(ci, c, s * 0.75, col)
			ci.draw_arc(c, 0.9 * s, 0.0, TAU, 20, col, w * 0.8)
		"silhouette_coeur":
			_silhouette(ci, c + Vector2(-0.2, 0.0) * s, s * 0.85, col)
			_coeur(ci, c + Vector2(0.5, 0.45) * s, s * 0.4, col)
		_:
			ci.draw_circle(c, 0.5 * s, col)


static func _coeur(ci: CanvasItem, c: Vector2, s: float, col: Color) -> void:
	ci.draw_circle(c + Vector2(-0.33, -0.25) * s, 0.38 * s, col)
	ci.draw_circle(c + Vector2(0.33, -0.25) * s, 0.38 * s, col)
	ci.draw_colored_polygon(PackedVector2Array([c + Vector2(-0.7, -0.1) * s, c + Vector2(0.7, -0.1) * s, c + Vector2(0.0, 0.8) * s]), col)


static func _silhouette(ci: CanvasItem, c: Vector2, s: float, col: Color) -> void:
	ci.draw_circle(c + Vector2(0.0, -0.45) * s, 0.28 * s, col)
	ci.draw_colored_polygon(PackedVector2Array([c + Vector2(-0.5, 0.85) * s, c + Vector2(-0.4, 0.0) * s, c + Vector2(0.4, 0.0) * s, c + Vector2(0.5, 0.85) * s]), col)
