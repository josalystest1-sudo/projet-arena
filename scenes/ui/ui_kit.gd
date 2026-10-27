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


## Une compétence en clair : « Moyenne — Trait de givre » puis sa description.
static func skill_block(parent: Node, data: CombatData, skill_id: String, accent: Color = Color.WHITE) -> void:
	var skill := data.skill(skill_id)
	parent.add_child(label("%s — %s" % [TIER_LABELS.get(skill.get("tier", ""), ""), skill.get("name", skill_id)], 19, accent, false))
	parent.add_child(label(data.skill_description(skill_id), 16, SOFT, false))


static func passive_block(parent: Node, data: CombatData, passive_id: String) -> void:
	parent.add_child(label("Passif — %s" % data.passive_name(passive_id), 19, Color(0.75, 0.9, 0.75), false))
	parent.add_child(label(data.passive_description(passive_id), 16, SOFT, false))


## Le budget de puissance du Destin : un kit dont les pièces se complètent moins bien reçoit un peu plus de PV et de
## puissance, et inversement (aucun Destin ne doit dominer). Rien n'est affiché quand l'ajustement est nul.
static func destin_balance(parent: Node, data: CombatData, skill_ids: Array, passive_id: String, own_class: String, partner_class: String) -> void:
	var bonus := data.kit_bonus(skill_ids, passive_id, own_class, partner_class)
	var percent := int(round(bonus * 100.0))
	if percent == 0:
		return
	var why := "ce kit et ce duo vont moins bien ensemble que d'autres" if percent > 0 else "ce kit et ce duo vont particulièrement bien ensemble"
	parent.add_child(label("Équilibre du Destin : %s%d %% de PV et de puissance, parce que %s." % ["+" if percent > 0 else "-", absi(percent), why], 14, Color(0.6, 0.65, 0.8), false))
