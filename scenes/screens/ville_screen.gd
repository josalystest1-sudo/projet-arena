## La ville (docs/GDD_V2.md, § 11 ; docs/PLAN.md, PR 4.1) : l'écran d'accueil, une carte en portrait à bâtiments, chacun
## un lieu du jeu (la Tour, l'Arène, la Forge, la Maison, le Tableau ; le Donjon, la Guilde, le Comptoir et la Boutique
## grisés jusqu'au serveur). La carte vient de data/ville.json (nom, texte, écran ouvert, position, disponible) : ajouter
## un lieu ne demande qu'une ligne de données. En haut : ton trio, tes chiffres, les Paramètres. Tout est à deux touchers.
## Les bâtiments sont dessinés en pixels provisoires (phase 10 : l'art).
extends Control

const BATIMENT_TAILLE := Vector2(150, 92)
const SOL := Color("1a2033")
const ROUTE := Color("2b3350")
const MUR := Color("4a5578")
const MUR_GRIS := Color("2e3448")
const TOIT := Color("b35a3c")
const TOIT_GRIS := Color("4a4a58")
const BOIS := Color("8a6a3f")

var app: ArenaApp
var carte: Control
var batiments: Array = []


func setup(p_app: ArenaApp, _options: Dictionary) -> void:
	app = p_app
	var colonne := VBoxContainer.new()
	colonne.set_anchors_preset(Control.PRESET_FULL_RECT)
	colonne.add_theme_constant_override("separation", 4)
	add_child(colonne)
	# Le haut : le titre, les Paramètres, le trio et les chiffres.
	var haut := MarginContainer.new()
	for side in ["left", "right", "top"]:
		haut.add_theme_constant_override("margin_" + side, 12)
	colonne.add_child(haut)
	var haut_col := VBoxContainer.new()
	haut_col.add_theme_constant_override("separation", 2)
	haut.add_child(haut_col)
	var titre := HBoxContainer.new()
	haut_col.add_child(titre)
	var nom := UiKit.label("Projet Arena", 26, UiKit.GOLD, false)
	nom.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	titre.add_child(nom)
	var gear := Button.new()
	gear.text = "Paramètres"
	gear.add_theme_font_size_override("font_size", 14)
	gear.pressed.connect(func(): app.show_screen("settings"))
	titre.add_child(gear)
	haut_col.add_child(UiKit.rangee_trio(app, 4.5))
	var profile := app.profile
	var record := app.meilleur_record()
	var facts: Array = ["niveau %d" % profile.level, "%d Éclat%s" % [profile.eclats, "s" if profile.eclats > 1 else ""]]
	if profile.monnaie_or > 0:
		facts.append("%d Or" % profile.monnaie_or)
	facts.append("Tour : étage %d" % record if record > 0 else "Tour : pas encore tentée")
	haut_col.add_child(UiKit.label(" · ".join(facts), 15, UiKit.SOFT))
	# La carte : le reste de l'écran.
	carte = Control.new()
	carte.size_flags_vertical = Control.SIZE_EXPAND_FILL
	carte.draw.connect(_dessiner_carte)
	carte.resized.connect(_placer)
	colonne.add_child(carte)
	batiments = app.data.ville["batiments"]
	for b in batiments:
		carte.add_child(_batiment(b))
	_placer()


## Un bâtiment : un bouton avec son nom, son sous-titre et une pastille (points de Destin à placer, objets dans le sac,
## revenu du jour à voir) ; grisé s'il n'est pas encore disponible.
func _batiment(b: Dictionary) -> Button:
	var bouton := Button.new()
	bouton.custom_minimum_size = BATIMENT_TAILLE
	bouton.size = BATIMENT_TAILLE
	var dispo := bool(b["dispo"])
	var texte := str(b["texte"])
	var pastille := _pastille(str(b["id"]))
	# Le nom et le sous-titre sous la silhouette (une étiquette, pour laisser le haut du bouton au dessin).
	var etiquette := Label.new()
	etiquette.text = "%s\n%s" % [b["nom"], texte]
	etiquette.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	etiquette.add_theme_font_size_override("font_size", 14)
	etiquette.set_anchors_preset(Control.PRESET_FULL_RECT)
	etiquette.offset_top = 42
	etiquette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bouton.add_child(etiquette)
	bouton.disabled = not dispo
	if not dispo:
		bouton.modulate = Color(0.55, 0.55, 0.6)
	bouton.set_meta("forme", str(b.get("forme", "maison")))
	bouton.set_meta("dispo", dispo)
	bouton.set_meta("pastille", pastille)
	bouton.draw.connect(_dessiner_batiment.bind(bouton))
	bouton.pressed.connect(_ouvrir.bind(b))
	return bouton


## Ce qu'un bâtiment signale : la Maison, les points de Destin à placer ; la Forge, les objets du sac ; le Tableau, le
## revenu du jour pas encore lu.
func _pastille(id: String) -> String:
	match id:
		"maison":
			if app.peut_evoluer():
				return "!"
			return "+%d" % app.destin_points_left() if app.destin_points_left() > 0 else ""
		"forge":
			return str(app.profile.sac.size()) if not app.profile.sac.is_empty() else ""
		"tableau":
			return "!" if not app.revenu_du_jour.is_empty() or app.objectif_a_reclamer() else ""
	return ""


func _placer() -> void:
	var taille := carte.size
	for i in range(batiments.size()):
		var b: Dictionary = batiments[i]
		var bouton: Control = carte.get_child(i)
		bouton.position = Vector2(float(b["x"]) * taille.x - BATIMENT_TAILLE.x / 2.0, float(b["y"]) * taille.y - BATIMENT_TAILLE.y / 2.0 - 10.0)
		bouton.position.x = clampf(bouton.position.x, 6.0, taille.x - BATIMENT_TAILLE.x - 6.0)
		bouton.position.y = clampf(bouton.position.y, 6.0, taille.y - BATIMENT_TAILLE.y - 6.0)
	carte.queue_redraw()


## Le sol et les routes entre les bâtiments (de chaque bâtiment vers le plus proche en dessous).
func _dessiner_carte() -> void:
	carte.draw_rect(Rect2(Vector2.ZERO, carte.size), SOL)
	var centres: Array[Vector2] = []
	for i in range(batiments.size()):
		var bouton: Control = carte.get_child(i)
		centres.append(bouton.position + BATIMENT_TAILLE / 2.0)
	for i in range(centres.size()):
		var proche := -1
		var d_min := INF
		for j in range(centres.size()):
			if j != i and centres[j].y > centres[i].y + 20.0 and centres[i].distance_to(centres[j]) < d_min:
				d_min = centres[i].distance_to(centres[j])
				proche = j
		if proche >= 0:
			carte.draw_line(centres[i], centres[proche], ROUTE, 10.0)
			carte.draw_line(centres[i], centres[proche], ROUTE.lightened(0.08), 4.0)


## La silhouette d'un bâtiment, en pixels, au-dessus de son nom : selon sa forme (tour, arène, maison, forge, donjon,
## guilde, comptoir, tableau, boutique).
func _dessiner_batiment(bouton: Button) -> void:
	var dispo: bool = bouton.get_meta("dispo")
	var mur := MUR if dispo else MUR_GRIS
	var toit := TOIT if dispo else TOIT_GRIS
	var w := bouton.size.x
	var y0 := 6.0
	var h := 28.0
	var cx := w / 2.0
	match str(bouton.get_meta("forme")):
		"tour":
			bouton.draw_rect(Rect2(cx - 14, y0, 28, h), mur)
			for i in range(3):
				bouton.draw_rect(Rect2(cx - 14 + i * 10, y0 - 6, 6, 6), mur)
			bouton.draw_rect(Rect2(cx - 4, y0 + 12, 8, 10), toit)
		"arene":
			bouton.draw_rect(Rect2(cx - 34, y0 + 10, 68, h - 10), mur)
			for i in range(5):
				bouton.draw_rect(Rect2(cx - 32 + i * 14, y0 + 2, 8, 10), toit)
		"donjon":
			bouton.draw_rect(Rect2(cx - 26, y0 + 8, 52, h - 8), mur)
			bouton.draw_rect(Rect2(cx - 8, y0 + 14, 16, 14), SOL)
			bouton.draw_rect(Rect2(cx - 30, y0, 10, 10), mur)
			bouton.draw_rect(Rect2(cx + 20, y0, 10, 10), mur)
		"forge":
			bouton.draw_rect(Rect2(cx - 24, y0 + 10, 48, h - 10), mur)
			bouton.draw_rect(Rect2(cx - 28, y0 + 6, 56, 6), toit)
			bouton.draw_rect(Rect2(cx + 10, y0 - 4, 8, 12), mur)
			bouton.draw_rect(Rect2(cx - 6, y0 + 16, 12, 8), Color("ff9d3c") if dispo else TOIT_GRIS)
		"guilde":
			bouton.draw_rect(Rect2(cx - 28, y0 + 10, 56, h - 10), mur)
			bouton.draw_rect(Rect2(cx - 32, y0 + 4, 64, 6), toit)
			bouton.draw_rect(Rect2(cx - 3, y0 - 6, 6, 12), BOIS)
			bouton.draw_rect(Rect2(cx + 3, y0 - 6, 10, 7), toit)
		"comptoir":
			bouton.draw_rect(Rect2(cx - 26, y0 + 12, 52, h - 12), mur)
			for i in range(4):
				bouton.draw_rect(Rect2(cx - 26 + i * 13, y0 + 4, 13, 8), toit if i % 2 == 0 else Color("e8dcc0") if dispo else MUR_GRIS)
		"tableau":
			bouton.draw_rect(Rect2(cx - 24, y0, 48, 24), BOIS)
			bouton.draw_rect(Rect2(cx - 20, y0 + 4, 40, 16), Color("e8dcc0") if dispo else MUR_GRIS)
			bouton.draw_rect(Rect2(cx - 2, y0 + 24, 4, 8), BOIS)
		"boutique":
			bouton.draw_rect(Rect2(cx - 22, y0 + 10, 44, h - 10), mur)
			bouton.draw_rect(Rect2(cx - 26, y0 + 4, 52, 8), Color("c94c6a") if dispo else TOIT_GRIS)
			bouton.draw_rect(Rect2(cx - 10, y0 + 16, 20, 10), Color("ffe08a") if dispo else MUR_GRIS)
		_:
			bouton.draw_rect(Rect2(cx - 20, y0 + 10, 40, h - 10), mur)
			bouton.draw_colored_polygon(PackedVector2Array([Vector2(cx - 26, y0 + 12), Vector2(cx, y0 - 4), Vector2(cx + 26, y0 + 12)]), toit)
			bouton.draw_rect(Rect2(cx - 4, y0 + 18, 8, 10), SOL)
	var pastille := str(bouton.get_meta("pastille"))
	if pastille != "":
		var c := Vector2(w - 16, 14)
		bouton.draw_circle(c, 12, UiKit.GOLD)
		var police := bouton.get_theme_default_font()
		bouton.draw_string(police, c + Vector2(-police.get_string_size(pastille, HORIZONTAL_ALIGNMENT_CENTER, -1, 13).x / 2.0, 5), pastille, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("1a1a1a"))


func _ouvrir(b: Dictionary) -> void:
	if not bool(b["dispo"]) or str(b["ecran"]) == "":
		return
	app.sfx.play("clic")
	app.show_screen(str(b["ecran"]), b.get("options", {}))
