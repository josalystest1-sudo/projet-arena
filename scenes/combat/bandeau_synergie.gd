## Le bandeau des Synergies, au-dessus des cases de l'écran de combat (hauteur fixe : les cases ne bougent jamais sous
## le doigt). Quatre façons de se montrer :
## - « prete » : la case choisie complète une Synergie avec ce que l'acolyte a annoncé (fond doré) ;
## - « possible » : une case au moins la compléterait (bord doré ; ces cases sont dorées) ;
## - « ailleurs » : seulement en visant un autre perso (bord doré pâle) ;
## - « aucune » : un rappel des quatre Synergies (atténué).
## Trois lignes : le titre, ce que joue l'acolyte, la règle et son effet. Affichage seulement : l'écran de combat
## les remplit.
class_name BandeauSynergie
extends Control

const OR := Color("e3b85f")
const TEXTE := Color("efe9d9")
const ATTENUE := Color("aaa49b")
const NUIT := Color("0f0e17")
const SURFACE := Color("1c1a28")

var etat := ""
var titre := ""
var ligne := ""
var ligne2 := ""
var _t := 0.0


func _init() -> void:
	custom_minimum_size = Vector2(0, 70)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(delta: float) -> void:
	_t += delta
	if etat in ["prete", "possible"]:
		queue_redraw()


func maj(p_etat: String, p_titre: String, p_ligne: String, p_ligne2: String = "") -> void:
	etat = p_etat
	titre = p_titre
	ligne = p_ligne
	ligne2 = p_ligne2
	queue_redraw()


func _draw() -> void:
	if etat == "":
		return
	var police := ThemeDB.fallback_font
	var r := Rect2(Vector2(2, 2), size - Vector2(4, 4))
	var style := StyleBoxFlat.new()
	style.set_corner_radius_all(10)
	var couleur_titre := OR
	var couleur_ligne := TEXTE
	match etat:
		"prete":
			style.bg_color = Color(OR, 0.85 + 0.15 * sin(_t * 5.0))
			couleur_titre = NUIT
			couleur_ligne = NUIT
		"possible":
			style.bg_color = Color("2b2410")
			style.border_color = Color(OR, 0.7 + 0.3 * sin(_t * 4.0))
			style.set_border_width_all(2)
		"ailleurs":
			style.bg_color = SURFACE
			style.border_color = Color(OR, 0.5)
			style.set_border_width_all(1)
		_:
			style.bg_color = Color(SURFACE, 0.6)
			couleur_titre = ATTENUE
			couleur_ligne = Color(ATTENUE, 0.85)
	draw_style_box(style, r)
	_texte(police, titre, Vector2(r.position.x + 10, r.position.y + 20), r.size.x - 20, 16, couleur_titre)
	_texte(police, ligne, Vector2(r.position.x + 10, r.position.y + 40), r.size.x - 20, 14, couleur_ligne)
	_texte(police, ligne2, Vector2(r.position.x + 10, r.position.y + 58), r.size.x - 20, 13, couleur_ligne)


## Une ligne qui tient dans la largeur : la police rapetisse, puis la ligne est coupée.
func _texte(police: Font, s: String, pos: Vector2, largeur: float, taille: int, couleur: Color) -> void:
	var t := taille
	while t > 10 and police.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, t).x > largeur:
		t -= 1
	draw_string(police, pos, s, HORIZONTAL_ALIGNMENT_LEFT, largeur, t, couleur)
