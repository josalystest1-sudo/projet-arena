## Boîte à outils de l'interface : thème commun, couleurs et petits constructeurs (textes, boutons, cartes).
## Affichage seulement : aucune règle du jeu ici.
class_name UiKit
extends RefCounted

const BG := Color("141826")
const PANEL := Color("1f2538")
const GOLD := Color("ffd43b")
const ACOLYTE_BLUE := Color("9ad1ff")
const SOFT := Color(0.8, 0.85, 1)
const GREEN := Color("51cf66")
const RED := Color("ff6b6b")
const ORANGE := Color("ffa94d")
const ROLE_LABELS := {"front": "Front", "degats": "Dégâts", "soutien": "Soutien"}
const TIER_LABELS := {"basique": "Basique", "moyenne": "Moyenne", "forte": "Forte"}


static func make_theme() -> Theme:
	var t := Theme.new()
	t.default_font_size = 20
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("2b3350")
	normal.set_corner_radius_all(10)
	normal.set_content_margin_all(8)
	var hover := normal.duplicate()
	hover.bg_color = Color("36406a")
	var pressed := normal.duplicate()
	pressed.bg_color = Color("4a5590")
	var disabled := normal.duplicate()
	disabled.bg_color = Color("1c2033")
	t.set_stylebox("normal", "Button", normal)
	t.set_stylebox("hover", "Button", hover)
	t.set_stylebox("pressed", "Button", pressed)
	t.set_stylebox("disabled", "Button", disabled)
	t.set_stylebox("focus", "Button", StyleBoxEmpty.new())
	t.set_color("font_disabled_color", "Button", Color(0.55, 0.55, 0.6))
	var panel := StyleBoxFlat.new()
	panel.bg_color = PANEL
	panel.set_corner_radius_all(14)
	panel.set_content_margin_all(12)
	t.set_stylebox("panel", "PanelContainer", panel)
	return t


static func label(text: String, font_size: int = 18, color: Color = Color.WHITE, centered: bool = true) -> Label:
	var node := Label.new()
	node.text = text
	node.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if centered else HORIZONTAL_ALIGNMENT_LEFT
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	node.add_theme_font_size_override("font_size", font_size)
	node.add_theme_color_override("font_color", color)
	return node


static func button(text: String, callback: Callable, height: float = 56.0, font_size: int = 20) -> Button:
	var node := Button.new()
	node.text = text
	node.custom_minimum_size = Vector2(0, height)
	node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	node.add_theme_font_size_override("font_size", font_size)
	node.pressed.connect(callback)
	return node


## Un gros bouton doré, pour l'action principale d'un écran.
static func main_button(text: String, callback: Callable, height: float = 78.0) -> Button:
	var node := button(text, callback, height, 28)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("8a6d12")
	style.set_corner_radius_all(14)
	style.set_content_margin_all(8)
	style.border_color = GOLD
	style.set_border_width_all(2)
	node.add_theme_stylebox_override("normal", style)
	var hover := style.duplicate()
	hover.bg_color = Color("a3831a")
	node.add_theme_stylebox_override("hover", hover)
	node.add_theme_stylebox_override("pressed", hover)
	return node


static func spacer(height: float) -> Control:
	var node := Control.new()
	node.custom_minimum_size = Vector2(0, height)
	return node


## Une carte (panneau arrondi) contenant une colonne ; renvoie la colonne pour y ajouter du contenu.
static func card(parent: Node, separation: int = 6) -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", separation)
	panel.add_child(column)
	return column


## Un écran qui défile verticalement, avec des marges : renvoie la colonne de contenu.
static func scroll_column(parent: Control, separation: int = 12) -> VBoxContainer:
	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	parent.add_child(scroll)
	var margin := MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 16)
	scroll.add_child(margin)
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", separation)
	margin.add_child(column)
	return column


## La fiche d'un nœud (section 12.4) : nom, classe · voie · rang, pictogrammes, ligne chiffrée, phrase, ce que font
## ses états, et ce qui vient après. `fiche` vient de Texte.fiche_destin.
static func fiche_noeud(parent: Node, fiche: Dictionary, accent: Color = GOLD) -> void:
	parent.add_child(label(str(fiche["nom"]), 21, accent, false))
	parent.add_child(label(str(fiche["sous_titre"]), 14, SOFT, false))
	parent.add_child(rangee_pictos(fiche["pictos"]))
	parent.add_child(label(str(fiche["ligne"]) + ("  " + str(fiche["eclat"]) if str(fiche.get("eclat", "")) != "" else ""), 17, Color.WHITE, false))
	parent.add_child(label(str(fiche["phrase"]), 16, SOFT, false))
	for ligne_etat in fiche["etats"]:
		parent.add_child(label(str(ligne_etat), 14, Color("c9a0ff"), false))
	if str(fiche.get("apres", "")) != "":
		parent.add_child(label(str(fiche["apres"]), 14, Color(0.6, 0.65, 0.8), false))


## Une rangée de pictogrammes : pour chaque effet, son dessin, sa cible et son nombre.
static func rangee_pictos(pictos: Array, taille: float = 26.0) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	for p in pictos:
		var groupe := HBoxContainer.new()
		groupe.add_theme_constant_override("separation", 2)
		groupe.add_child(Picto.make(str(p["pictogramme"]), Color(str(p["couleur"])), taille))
		groupe.add_child(Picto.make(str(p["cible"]), Color("aaa49b"), taille * 0.8))
		if str(p["texte"]) != "":
			var nombre := Label.new()
			nombre.text = str(p["texte"])
			nombre.add_theme_font_size_override("font_size", 16)
			groupe.add_child(nombre)
		for enfant in groupe.get_children():
			(enfant as Control).size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(groupe)
	return row


## Une voie en une ligne : ses quatre nœuds (nom et forme), allumés ou à venir.
static func voie_resume(parent: Node, destin: Destin, voie: int, accent: Color = GOLD) -> void:
	var v: Dictionary = destin.voies[voie]
	parent.add_child(label(str(v["nom"]), 18, accent, false))
	var noms: Array[String] = []
	for n in v["noeuds"]:
		noms.append(("" if bool(n["allume"]) else "○ ") + Texte.nom(n))
	parent.add_child(label(" → ".join(noms), 15, Color.WHITE, false))


## Comment joue l'acolyte (section 10) : en premier, sans ordre, toujours le même choix dans la même situation.
static func acolyte_rules_card(parent: Node, acolyte_name: String) -> void:
	var how := card(parent, 4)
	how.add_child(label("Comment joue %s" % acolyte_name, 20, ACOLYTE_BLUE, false))
	how.add_child(label("Il choisit en premier, et tu vois son choix avant de jouer le tien. Tu ne lui donnes aucun ordre.", 16, Color.WHITE, false))
	how.add_child(label("À chaque tour, il joue l'action qui rapporte le plus : frapper, soigner, protéger, ou couper une menace adverse. Dans la même situation, il fait toujours la même chose.", 15, SOFT, false))
