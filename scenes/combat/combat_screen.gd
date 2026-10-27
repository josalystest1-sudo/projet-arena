## Écran de combat du prototype en duo : toi et ton acolyte (piloté par l'IA) contre un duo IA.
## Toute la règle vit dans le moteur (res://engine) ; cet écran affiche, collecte tes choix et anime les événements.
extends Control

const INTENT_SECONDS := 12.0
## Quand tu es KO, ton acolyte continue seul : tu as quelques secondes pour changer sa posture.
const KO_PLAYER_SECONDS := 6.0
const CLASS_ORDER := ["guerrier", "mage", "pretre"]
const ROLE_LABELS := {"front": "Front", "degats": "Dégâts", "soutien": "Soutien"}
const TIER_LABELS := {"basique": "Basique", "moyenne": "Moyenne", "forte": "Forte"}
const ACOLYTE_NAMES := ["Lys", "Orme", "Saule", "Iris", "Cèdre", "Aube", "Sorel", "Nima"]
const ENEMY_NAMES := ["Ombre", "Brume", "Cendre", "Givre", "Ronce", "Écume", "Nox", "Bise"]
## Largeur de la colonne de gauche : sélecteur de posture (en bas) et posture adverse révélée (en haut).
const SIDE_WIDTH := 150.0
const BG_COLOR := Color("141826")
const PANEL_COLOR := Color("1f2538")
const GOLD := Color("ffd43b")
const ACOLYTE_BLUE := Color("9ad1ff")

var data: CombatData
var combat: Combat
var rng := RandomNumberGenerator.new()

# Ton duo, gardé d'un combat à l'autre (l'acolyte ne change pas, comme dans le vrai jeu).
var player_class: String = "guerrier"
var player_picks: Dictionary = {}
var acolyte: Dictionary = {}
var acolyte_name: String = ""
var posture: String = CombatAI.LIBRE
var player_id: String = "a1"
var acolyte_id: String = "a2"

# Phase d'Intention.
var phase: String = "menu"   # menu, intent, resolve, end
var time_left: float = 0.0
var selected_tier: String = ""
var selected_target: String = ""
var player_ready: bool = false
## L'annonce de l'acolyte : {action, rule, held_forte}.
var announce: Dictionary = {}
## Les Synergies que tu peux construire ce tour avec l'annonce de ton acolyte : palier -> option.
var synergy_options: Dictionary = {}
var synergies_fired: int = 0
## Statistiques du combat en cours, par unit_id : dégâts, soins, KO portés.
var stats: Dictionary = {}
## Accélération de la résolution (le joueur touche l'écran).
var speed: float = 1.0
var last_tick: int = -1
var shake_amount: float = 0.0
var profile: PlayerProfile
var sfx: Sfx

# Nœuds.
var views: Dictionary = {}
var enemy_units: HBoxContainer
var ally_units: HBoxContainer
var enemy_posture_label: Label
var posture_title: Label
var posture_buttons: Dictionary = {}
var overlay: IntentOverlay
var turn_label: Label
var timer_bar: ProgressBar
var timer_label: Label
var sudden_label: Label
var banner: Label
var log_label: Label
var skill_buttons: Dictionary = {}
var skill_info: Label
var passive_info: Label
var ready_button: Button
var hint_label: Label
var bottom_panel: PanelContainer
var menu_layer: Control
var end_layer: Control
var stage: Control
var flash_rect: ColorRect
var cutin: Label
var mute_button: Button
var synergy_labels: Dictionary = {}


func _ready() -> void:
	# Pour tester : une adresse terminée par ?graine=7 rejoue toujours les mêmes tirages.
	var test_seed := _seed_from_url()
	if test_seed != 0:
		rng.seed = test_seed
	else:
		rng.randomize()
	data = CombatData.load_default()
	profile = PlayerProfile.load_profile()
	sfx = Sfx.new()
	add_child(sfx)
	sfx.muted = profile.muted
	if CombatAI.POSTURES.has(profile.posture):
		posture = profile.posture
	theme = _make_theme()
	_build_layout()
	_show_menu()


func _seed_from_url() -> int:
	if not OS.has_feature("web"):
		return 0
	var value := str(JavaScriptBridge.eval("new URLSearchParams(window.location.search).get('graine') || ''", true))
	return int(value) if value.is_valid_int() else 0


# ---------------------------------------------------------------------------
# Construction de l'interface
# ---------------------------------------------------------------------------

func _make_theme() -> Theme:
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
	panel.bg_color = PANEL_COLOR
	panel.set_corner_radius_all(14)
	panel.set_content_margin_all(10)
	t.set_stylebox("panel", "PanelContainer", panel)
	return t


func _build_layout() -> void:
	var bg := ColorRect.new()
	bg.color = BG_COLOR
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	stage = Control.new()
	stage.set_anchors_preset(Control.PRESET_FULL_RECT)
	stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(stage)
	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 10
	root.offset_right = -10
	root.offset_top = 10
	root.offset_bottom = -10
	root.add_theme_constant_override("separation", 6)
	stage.add_child(root)

	# Barre du haut : tour, timer, son.
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 10)
	root.add_child(top)
	turn_label = Label.new()
	turn_label.text = "Tour 1"
	turn_label.custom_minimum_size = Vector2(90, 0)
	turn_label.add_theme_font_size_override("font_size", 24)
	top.add_child(turn_label)
	timer_bar = ProgressBar.new()
	timer_bar.max_value = INTENT_SECONDS
	timer_bar.show_percentage = false
	timer_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	timer_bar.custom_minimum_size = Vector2(0, 26)
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color("f2c14e")
	fill.set_corner_radius_all(8)
	var back := StyleBoxFlat.new()
	back.bg_color = Color("2b3350")
	back.set_corner_radius_all(8)
	timer_bar.add_theme_stylebox_override("fill", fill)
	timer_bar.add_theme_stylebox_override("background", back)
	top.add_child(timer_bar)
	timer_label = Label.new()
	timer_label.custom_minimum_size = Vector2(44, 0)
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	timer_label.add_theme_font_size_override("font_size", 24)
	top.add_child(timer_label)
	mute_button = Button.new()
	mute_button.custom_minimum_size = Vector2(64, 36)
	mute_button.add_theme_font_size_override("font_size", 15)
	mute_button.pressed.connect(_on_mute_pressed)
	top.add_child(mute_button)
	_refresh_mute_button()
	sudden_label = Label.new()
	sudden_label.add_theme_color_override("font_color", Color("ff6b6b"))
	sudden_label.add_theme_font_size_override("font_size", 16)
	sudden_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(sudden_label)

	# Le duo adverse en haut : sa posture révélée à gauche, puis son acolyte et son joueur.
	var enemy_row := HBoxContainer.new()
	enemy_row.alignment = BoxContainer.ALIGNMENT_CENTER
	enemy_row.add_theme_constant_override("separation", 8)
	root.add_child(enemy_row)
	var enemy_side := VBoxContainer.new()
	enemy_side.custom_minimum_size = Vector2(SIDE_WIDTH, 0)
	enemy_side.alignment = BoxContainer.ALIGNMENT_CENTER
	enemy_row.add_child(enemy_side)
	enemy_side.add_child(_side_label("Duo adverse", 16, Color("ff8787")))
	enemy_posture_label = _side_label("", 14, Color(0.8, 0.82, 0.9))
	enemy_side.add_child(enemy_posture_label)
	enemy_units = HBoxContainer.new()
	enemy_units.add_theme_constant_override("separation", 6)
	enemy_row.add_child(enemy_units)

	# Zone centrale : bannière (Synergies, résultat) et journal (annonce de l'acolyte, résolution).
	var middle := VBoxContainer.new()
	middle.size_flags_vertical = Control.SIZE_EXPAND_FILL
	middle.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_child(middle)
	banner = Label.new()
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.add_theme_font_size_override("font_size", 22)
	banner.add_theme_color_override("font_color", GOLD)
	banner.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	middle.add_child(banner)
	log_label = Label.new()
	log_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	log_label.add_theme_font_size_override("font_size", 18)
	log_label.add_theme_color_override("font_color", Color(0.85, 0.87, 0.95))
	middle.add_child(log_label)

	# Ton duo : le sélecteur de posture à gauche, puis ton acolyte et toi.
	var ally_row := HBoxContainer.new()
	ally_row.alignment = BoxContainer.ALIGNMENT_CENTER
	ally_row.add_theme_constant_override("separation", 8)
	root.add_child(ally_row)
	var posture_panel := VBoxContainer.new()
	posture_panel.custom_minimum_size = Vector2(SIDE_WIDTH, 0)
	posture_panel.alignment = BoxContainer.ALIGNMENT_CENTER
	posture_panel.add_theme_constant_override("separation", 4)
	ally_row.add_child(posture_panel)
	posture_title = _side_label("Posture", 15, ACOLYTE_BLUE)
	posture_panel.add_child(posture_title)
	for posture_id in CombatAI.POSTURES:
		var button := Button.new()
		button.text = _posture_name(posture_id)
		button.custom_minimum_size = Vector2(SIDE_WIDTH, 44)
		button.add_theme_font_size_override("font_size", 16)
		button.pressed.connect(_on_posture_pressed.bind(posture_id))
		posture_panel.add_child(button)
		posture_buttons[posture_id] = button
	ally_units = HBoxContainer.new()
	ally_units.add_theme_constant_override("separation", 6)
	ally_row.add_child(ally_units)

	# Bas : les 3 compétences, puis l'aide au choix de cible.
	bottom_panel = PanelContainer.new()
	root.add_child(bottom_panel)
	var bottom := VBoxContainer.new()
	bottom.add_theme_constant_override("separation", 6)
	bottom_panel.add_child(bottom)
	skill_info = Label.new()
	skill_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	skill_info.add_theme_font_size_override("font_size", 16)
	# Hauteur fixe : les boutons ne doivent jamais bouger sous le doigt quand le texte change.
	skill_info.custom_minimum_size = Vector2(0, 66)
	skill_info.max_lines_visible = 3
	bottom.add_child(skill_info)
	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 8)
	bottom.add_child(buttons)
	for tier in CombatUnit.TIERS:
		var column := VBoxContainer.new()
		column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		column.add_theme_constant_override("separation", 2)
		buttons.add_child(column)
		var button := Button.new()
		button.custom_minimum_size = Vector2(0, 84)
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.add_theme_font_size_override("font_size", 18)
		button.pressed.connect(_on_skill_pressed.bind(tier))
		column.add_child(button)
		skill_buttons[tier] = button
		var synergy_label := Label.new()
		synergy_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		synergy_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		synergy_label.custom_minimum_size = Vector2(0, 34)
		synergy_label.max_lines_visible = 2
		synergy_label.add_theme_font_size_override("font_size", 13)
		synergy_label.add_theme_color_override("font_color", GOLD)
		column.add_child(synergy_label)
		synergy_labels[tier] = synergy_label
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	bottom.add_child(row)
	hint_label = Label.new()
	hint_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint_label.add_theme_font_size_override("font_size", 16)
	hint_label.add_theme_color_override("font_color", GOLD)
	hint_label.max_lines_visible = 2
	row.add_child(hint_label)
	ready_button = Button.new()
	ready_button.text = "Prêt"
	ready_button.custom_minimum_size = Vector2(110, 50)
	ready_button.pressed.connect(_on_ready_pressed)
	row.add_child(ready_button)
	passive_info = Label.new()
	passive_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	passive_info.add_theme_font_size_override("font_size", 14)
	passive_info.add_theme_color_override("font_color", Color(0.7, 0.75, 0.9))
	passive_info.custom_minimum_size = Vector2(0, 38)
	passive_info.max_lines_visible = 2
	bottom.add_child(passive_info)

	overlay = IntentOverlay.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	stage.add_child(overlay)

	# Grande annonce (forte, Synergie) et flash d'écran, au-dessus de tout.
	cutin = Label.new()
	cutin.set_anchors_preset(Control.PRESET_CENTER)
	cutin.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cutin.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cutin.custom_minimum_size = Vector2(520, 80)
	cutin.position = Vector2(-260, -40)
	cutin.add_theme_font_size_override("font_size", 46)
	cutin.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	cutin.add_theme_constant_override("outline_size", 12)
	cutin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cutin.modulate = Color(1, 1, 1, 0)
	add_child(cutin)
	flash_rect = ColorRect.new()
	flash_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash_rect.color = Color(1, 1, 1, 0)
	add_child(flash_rect)


func _side_label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(SIDE_WIDTH, 0)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


func _on_mute_pressed() -> void:
	sfx.muted = not sfx.muted
	profile.muted = sfx.muted
	profile.save()
	_refresh_mute_button()
	sfx.play("clic")


func _refresh_mute_button() -> void:
	mute_button.text = "Son : non" if sfx.muted else "Son : oui"


## Grande annonce au centre de l'écran (nom d'une forte, Synergie...).
func _show_cutin(text: String, color: Color) -> void:
	cutin.text = text
	cutin.add_theme_color_override("font_color", color)
	cutin.pivot_offset = cutin.size / 2.0
	cutin.scale = Vector2(1.8, 1.8)
	cutin.modulate = Color(1, 1, 1, 1)
	var tween := create_tween()
	tween.tween_property(cutin, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.5 / speed)
	tween.tween_property(cutin, "modulate:a", 0.0, 0.25)


func _flash(color: Color, strength: float = 0.35) -> void:
	flash_rect.color = Color(color, strength)
	var tween := create_tween()
	tween.tween_property(flash_rect, "color:a", 0.0, 0.35)


func _shake(amount: float) -> void:
	shake_amount = maxf(shake_amount, amount)


func _clear_children(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()


# ---------------------------------------------------------------------------
# Menu : ton personnage et la rencontre de ton acolyte (prototype)
# ---------------------------------------------------------------------------

func _show_menu() -> void:
	phase = "menu"
	if menu_layer != null:
		menu_layer.queue_free()
	menu_layer = _make_layer()
	var box: VBoxContainer = menu_layer.get_meta("box")
	box.add_child(_label("Projet Arena", 40, GOLD))
	box.add_child(_label("Prototype de combat en duo", 20, Color(0.8, 0.85, 1)))
	if profile.wins + profile.losses > 0:
		box.add_child(_label("%d victoire%s · %d défaite%s · record : %d d'affilée" % [profile.wins, "s" if profile.wins > 1 else "", profile.losses, "s" if profile.losses > 1 else "", profile.best_streak], 17, Color(0.75, 0.9, 0.75)))
	box.add_child(_spacer(6))
	if _load_saved_duo():
		var resume := Button.new()
		resume.text = "Continuer avec ton duo\n%s et %s (%s)" % [data.class_name_of(player_class), acolyte_name, data.class_name_of(acolyte["class_id"])]
		resume.custom_minimum_size = Vector2(0, 76)
		resume.add_theme_font_size_override("font_size", 22)
		resume.pressed.connect(_show_kit)
		box.add_child(resume)
		box.add_child(_spacer(4))
		box.add_child(_label("Ou un nouveau personnage :", 18, Color.WHITE))
	else:
		box.add_child(_label("Choisis ton personnage :", 22, Color.WHITE))
	for class_id in CLASS_ORDER:
		var cls: Dictionary = data.classes[class_id]
		var button := Button.new()
		var roles: Array = cls["roles"]
		button.text = "%s  ·  %s / %s\n%s" % [cls["name"], ROLE_LABELS[roles[0]], ROLE_LABELS[roles[1]], cls["identity"]]
		button.custom_minimum_size = Vector2(0, 80)
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.pressed.connect(_on_class_chosen.bind(class_id))
		box.add_child(button)


func _load_saved_duo() -> bool:
	var saved := profile.duo
	if saved.is_empty() or not data.classes.has(saved.get("player_class", "")) or not data.classes.has(saved.get("acolyte_class", "")):
		return false
	player_class = saved["player_class"]
	player_picks = saved["player_picks"]
	acolyte = {"class_id": saved["acolyte_class"], "picks": saved["acolyte_picks"]}
	acolyte_name = str(saved.get("acolyte_name", ACOLYTE_NAMES[0]))
	return true


func _save_duo() -> void:
	profile.duo = {"player_class": player_class, "player_picks": player_picks, "acolyte_class": acolyte["class_id"], "acolyte_picks": acolyte["picks"], "acolyte_name": acolyte_name}
	profile.save()


func _on_class_chosen(class_id: String) -> void:
	sfx.play("clic")
	player_class = class_id
	player_picks = CombatUnit.random_picks(rng)
	_draw_acolyte()
	_save_duo()
	_show_kit()


## L'acolyte est tiré une fois : une classe qui complète ton rôle, et des compétences qui font Synergie avec les tiennes.
func _draw_acolyte() -> void:
	acolyte = Duo.draw_acolyte(data, player_class, player_picks, rng)
	acolyte_name = ACOLYTE_NAMES[rng.randi_range(0, ACOLYTE_NAMES.size() - 1)]


## Prototype seulement : un autre tirage pour toi. Ton acolyte reste s'il fait toujours Synergie avec toi.
func _on_reroll_player() -> void:
	sfx.play("clic")
	player_picks = CombatUnit.random_picks(rng)
	if Duo.kit_synergies(data, player_class, player_picks, acolyte["class_id"], acolyte["picks"]).is_empty() \
			or not Duo.acolyte_classes(data, player_class).has(acolyte["class_id"]):
		var keep_name := acolyte_name
		_draw_acolyte()
		acolyte_name = keep_name
	_save_duo()
	_show_kit()


func _on_reroll_acolyte() -> void:
	sfx.play("clic")
	_draw_acolyte()
	_save_duo()
	_show_kit()


func _show_kit() -> void:
	if menu_layer != null:
		menu_layer.queue_free()
	menu_layer = _make_layer(8)
	var box: VBoxContainer = menu_layer.get_meta("box")
	var cls: Dictionary = data.classes[player_class]
	box.add_child(_label("Toi : %s" % cls["name"], 32, GOLD))
	box.add_child(_label("Ton Destin (tiré au hasard)", 17, Color(0.8, 0.85, 1)))
	for skill_id in Duo.kit_skills(data, player_class, player_picks):
		var skill := data.skill(skill_id)
		box.add_child(_label("%s — %s : %s" % [TIER_LABELS[skill["tier"]], skill["name"], skill["description"]], 16, Color.WHITE))
	var passive_id: String = cls["passives"][int(player_picks["passive"]) % cls["passives"].size()]
	box.add_child(_label("Passif — %s : %s" % [data.passive_name(passive_id), data.passives[passive_id]["description"]], 16, Color(0.75, 0.9, 0.75)))

	var aco_cls: Dictionary = data.classes[acolyte["class_id"]]
	box.add_child(_spacer(4))
	box.add_child(_label("Ton acolyte : %s, %s (%s)" % [acolyte_name, aco_cls["name"], ROLE_LABELS[aco_cls["roles"][0]]], 24, ACOLYTE_BLUE))
	var names: Array = []
	for skill_id in Duo.kit_skills(data, acolyte["class_id"], acolyte["picks"]):
		names.append(data.skill_name(skill_id))
	var aco_passive: String = aco_cls["passives"][int(acolyte["picks"]["passive"]) % aco_cls["passives"].size()]
	box.add_child(_label("%s · passif %s" % [" · ".join(names), data.passive_name(aco_passive)], 16, Color.WHITE))
	box.add_child(_label("Il joue seul : tu ne choisis jamais ses sorts. Au début de chaque tour, il annonce son coup au-dessus de lui ; tu choisis le tien en le sachant. Ses 4 postures, à gauche de l'écran, changent sa façon de jouer.", 15, Color(0.8, 0.85, 1)))

	var synergies := Duo.kit_synergies(data, player_class, player_picks, acolyte["class_id"], acolyte["picks"])
	box.add_child(_label("Vos Synergies (à jouer le même tour) :", 17, GOLD))
	for synergy in synergies:
		box.add_child(_label("• %s : %s + %s. %s" % [synergy["name"], data.skill_name(synergy["skills"][0]), data.skill_name(synergy["skills"][1]), synergy["description"]], 15, Color(1, 0.9, 0.6)))
	box.add_child(_spacer(4))
	var fight := Button.new()
	fight.text = "Combattre"
	fight.custom_minimum_size = Vector2(0, 66)
	fight.add_theme_font_size_override("font_size", 28)
	fight.pressed.connect(_start_combat)
	box.add_child(fight)
	var rerolls := HBoxContainer.new()
	rerolls.add_theme_constant_override("separation", 8)
	box.add_child(rerolls)
	for entry in [["Autre tirage\npour toi", _on_reroll_player], ["Autre\nacolyte", _on_reroll_acolyte], ["Changer\nde classe", _show_menu]]:
		var button := Button.new()
		button.text = entry[0]
		button.custom_minimum_size = Vector2(0, 58)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.add_theme_font_size_override("font_size", 16)
		button.pressed.connect(entry[1])
		rerolls.add_child(button)
	box.add_child(_label("(Les nouveaux tirages n'existent que dans le prototype : en vrai, ton Destin et ton acolyte ne changent jamais.)", 13, Color(0.6, 0.62, 0.7)))


func _make_layer(separation: int = 12) -> Control:
	var layer := ColorRect.new()
	layer.color = Color(0.05, 0.06, 0.1, 0.94)
	layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(layer)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(center)
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(480, 0)
	box.add_theme_constant_override("separation", separation)
	center.add_child(box)
	layer.set_meta("box", box)
	return layer


func _label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(460, 0)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


func _spacer(height: float) -> Control:
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, height)
	return spacer


# ---------------------------------------------------------------------------
# Démarrage d'un combat
# ---------------------------------------------------------------------------

func _start_combat() -> void:
	if menu_layer != null:
		menu_layer.queue_free()
		menu_layer = null
	if end_layer != null:
		end_layer.queue_free()
		end_layer = null
	synergies_fired = 0
	stats = {}
	speed = 1.0
	sfx.play("clic")
	var team_a := Duo.members(player_class, player_picks, acolyte)
	team_a[0]["name"] = "Toi"
	team_a[0]["is_player"] = true
	team_a[1]["name"] = acolyte_name
	# En face : un duo IA tiré au hasard (en attendant les Échos de l'étape 5).
	var team_b := Duo.random_duo(data, rng)
	var first := rng.randi_range(0, ENEMY_NAMES.size() - 1)
	team_b[0]["name"] = ENEMY_NAMES[first]
	team_b[1]["name"] = ENEMY_NAMES[(first + rng.randi_range(1, ENEMY_NAMES.size() - 1)) % ENEMY_NAMES.size()]
	combat = Combat.create(data, team_a, team_b, rng.randi_range(0, 1))
	player_id = combat.leader_of(0).id
	acolyte_id = combat.acolyte_of(0).id

	views = {}
	_clear_children(enemy_units)
	_clear_children(ally_units)
	# Dans chaque rangée : l'acolyte à côté de la colonne des postures, puis le joueur.
	for team in [1, 0]:
		for unit in [combat.acolyte_of(team), combat.leader_of(team)]:
			var view := UnitView.new()
			view.setup(unit)
			view.subtitle = data.class_name_of(unit.class_id)
			view.tapped.connect(_on_unit_tapped)
			(ally_units if team == 0 else enemy_units).add_child(view)
			views[unit.id] = view
			view.sync(unit, data)
			stats[unit.id] = {"damage": 0, "heal": 0, "kos": 0}
	enemy_posture_label.text = "Posture de %s : ?" % combat.acolyte_of(1).display_name
	_begin_intent_phase()


func _player() -> CombatUnit:
	return combat.get_unit(player_id)


func _acolyte() -> CombatUnit:
	return combat.get_unit(acolyte_id)


# ---------------------------------------------------------------------------
# Phase d'Intention (12 s) : l'acolyte annonce d'abord, tu choisis ensuite
# ---------------------------------------------------------------------------

func _begin_intent_phase() -> void:
	phase = "intent"
	var player := _player()
	time_left = INTENT_SECONDS if player.is_alive() else KO_PLAYER_SECONDS
	selected_tier = ""
	selected_target = ""
	player_ready = false
	speed = 1.0
	last_tick = -1
	for view in views.values():
		var unit := combat.get_unit(view.unit_id)
		view.intent_text = ""
		view.intent_star = false
		view.order_badge = 0
		view.selected_target = false
		view.targetable = false
		view.synergy_mark = false
		view.preview_text = ""
		view.sync(unit, data)
		view.cooldowns = _cooldowns_of(unit)
		# Anticipation : on voit quand la forte d'un ennemi est prête (pas ce qu'il va jouer).
		view.threat_text = "FORTE PRÊTE" if unit.team == 1 and combat.can_use(unit, "forte") else ""
	turn_label.text = "Tour %d" % combat.turn
	sfx.play("tour")
	banner.text = ""
	if combat.is_sudden_death():
		sudden_label.text = "MORT SUBITE : soins ÷2, dégâts +%d %%  ·  fin au tour %d" % [int(round((combat.sudden_death_damage_mult() - 1.0) * 100.0)), combat.forced_end_turn]
	elif combat.turn >= combat.sudden_death_turn - 2:
		sudden_label.text = "Mort subite au tour %d" % combat.sudden_death_turn
	else:
		sudden_label.text = ""
	bottom_panel.modulate = Color(1, 1, 1, 1 if player.is_alive() else 0.45)
	announce = {}
	_update_announce(true)
	_refresh_posture_panel()
	_refresh_skill_buttons()
	_refresh_intents()


## Recharges affichées sur un perso : 0 = prête, n = tours restants, -1 = déjà utilisée (une fois par combat).
func _cooldowns_of(unit: CombatUnit) -> Dictionary:
	var result := {}
	for tier in ["moyenne", "forte"]:
		var skill_id: String = unit.skills[tier]
		if bool(data.skill(skill_id).get("once_per_combat", false)) and bool(unit.flags.get("used_" + skill_id, false)):
			result[tier] = -1
		else:
			result[tier] = combat.cooldown_remaining(unit, tier)
	return result


## L'acolyte (ré)annonce son coup selon sa posture et ton Intention du moment.
func _update_announce(initial: bool) -> void:
	var aco := _acolyte()
	synergy_options = {}
	if aco == null or not aco.is_alive():
		announce = {}
		return
	var previous: CombatAction = announce.get("action")
	announce = CombatAI.decide_acolyte(combat, aco, posture, _player_action())
	for option in CombatAI.synergy_options(combat, _player(), aco, posture):
		synergy_options[option["tier"]] = option
	var now: CombatAction = announce["action"]
	if initial:
		views[acolyte_id].do_announce()
		sfx.play("clic", 1.6, -6.0)
	elif previous == null or previous.skill_id != now.skill_id or previous.target_id != now.target_id:
		views[acolyte_id].do_announce()
		views[acolyte_id].float_text("Revu", ACOLYTE_BLUE)
		sfx.play("clic", 1.4)


func _process(delta: float) -> void:
	# Secousse d'écran.
	if shake_amount > 0.0:
		shake_amount = maxf(shake_amount - delta * 40.0, 0.0)
		stage.position = Vector2(randf_range(-shake_amount, shake_amount), randf_range(-shake_amount, shake_amount))
	elif stage.position != Vector2.ZERO:
		stage.position = Vector2.ZERO
	if phase != "intent":
		return
	time_left = maxf(time_left - delta, 0.0)
	timer_bar.value = time_left
	timer_label.text = "%d" % int(ceil(time_left))
	# Les 3 dernières secondes : le timer rougit et fait tic.
	var seconds := int(ceil(time_left))
	var urgent := seconds <= 3 and _player().is_alive() and not player_ready
	(timer_bar.get_theme_stylebox("fill") as StyleBoxFlat).bg_color = Color("ff6b6b") if urgent else Color("f2c14e")
	if urgent and seconds != last_tick and seconds > 0:
		last_tick = seconds
		sfx.play("tic")
	# L'acolyte a déjà annoncé : on n'attend que toi.
	if time_left <= 0.0 or player_ready:
		_submit_turn()


func _player_action() -> CombatAction:
	if selected_tier == "" or selected_target == "":
		return null
	var player := _player()
	return CombatAction.make(player.id, player.skills[selected_tier], selected_target)


func _on_posture_pressed(posture_id: String) -> void:
	var aco := _acolyte()
	if combat == null or phase != "intent" or aco == null or not aco.is_alive():
		return
	sfx.play("clic")
	if posture_id != posture:
		posture = posture_id
		profile.posture = posture_id
		profile.save()
		views[acolyte_id].float_text(_posture_name(posture_id), ACOLYTE_BLUE)
		_update_announce(false)
	_refresh_posture_panel()
	_refresh_skill_buttons()
	_refresh_intents()
	skill_info.text = _posture_text(posture_id)


func _on_skill_pressed(tier: String) -> void:
	if phase != "intent" or not _player().is_alive():
		return
	var player := _player()
	if not combat.can_use(player, tier):
		return
	sfx.play("clic")
	selected_tier = tier
	selected_target = ""
	player_ready = false
	var skill_id: String = player.skills[tier]
	var targets := combat.valid_targets(player, skill_id)
	var target_type := str(data.skill(skill_id).get("target"))
	if target_type in ["enemies_all", "allies_all", "self"] and not targets.is_empty():
		selected_target = targets[0].id
	elif targets.size() == 1:
		selected_target = targets[0].id
	_update_announce(false)
	_refresh_skill_buttons()
	_refresh_intents()


func _on_unit_tapped(unit_id: String) -> void:
	if phase != "intent":
		return
	if selected_tier == "" or not _player().is_alive():
		_show_unit_info(unit_id)
		return
	var player := _player()
	var skill_id: String = player.skills[selected_tier]
	var target := combat.get_unit(unit_id)
	if not combat.valid_targets(player, skill_id).has(target):
		_show_unit_info(unit_id)
		return
	selected_target = unit_id
	player_ready = false
	sfx.play("clic", 1.25)
	_update_announce(false)
	_refresh_skill_buttons()
	_refresh_intents()


## Toucher un perso sans compétence choisie : on voit son kit et ses recharges (jamais ses Intentions).
func _show_unit_info(unit_id: String) -> void:
	var unit := combat.get_unit(unit_id)
	var parts: Array = []
	for tier in CombatUnit.TIERS:
		var skill_id: String = unit.skills[tier]
		var remaining := combat.cooldown_remaining(unit, tier)
		var state: String = "prête" if combat.can_use(unit, tier) else ("dans %d tour%s" % [remaining, "s" if remaining > 1 else ""] if remaining > 0 else "utilisée")
		parts.append("%s (%s)" % [data.skill_name(skill_id), state] if tier != "basique" else data.skill_name(skill_id))
	skill_info.text = "%s : %s. Passif : %s." % [_short_name(unit_id), " · ".join(parts), data.passive_name(unit.passive)]
	if unit_id == acolyte_id:
		skill_info.text += " " + _posture_text(posture)


func _on_ready_pressed() -> void:
	if phase != "intent":
		return
	player_ready = true
	sfx.play("clic", 0.8)
	_refresh_skill_buttons()


func _refresh_posture_panel() -> void:
	var aco := _acolyte()
	var active := phase == "intent" and aco != null and aco.is_alive()
	posture_title.text = "Posture de %s" % acolyte_name if aco == null or aco.is_alive() else "%s est KO" % acolyte_name
	for posture_id in posture_buttons:
		var button: Button = posture_buttons[posture_id]
		var chosen: bool = posture_id == posture
		button.text = ("» " if chosen else "") + _posture_name(posture_id)
		button.disabled = not active
		button.modulate = Color(1.0, 0.9, 0.45) if chosen else Color.WHITE


func _refresh_skill_buttons() -> void:
	var player := _player()
	var aco := _acolyte()
	for tier in CombatUnit.TIERS:
		var button: Button = skill_buttons[tier]
		var skill_id: String = player.skills[tier]
		var remaining := combat.cooldown_remaining(player, tier)
		var label := "%s\n%s" % [data.skill_name(skill_id), TIER_LABELS[tier]]
		var used_once: bool = bool(data.skill(skill_id).get("once_per_combat", false)) and bool(player.flags.get("used_" + skill_id, false))
		if used_once:
			label = "%s\nDéjà utilisée" % data.skill_name(skill_id)
		elif remaining > 0:
			if tier == "forte" and combat.turn < combat.strong_available_from_turn and int(player.cooldown_until.get(tier, 0)) <= combat.turn:
				label = "%s\nDès le tour %d" % [data.skill_name(skill_id), combat.strong_available_from_turn]
			else:
				label = "%s\nRecharge : %d" % [data.skill_name(skill_id), remaining]
		button.text = label
		button.disabled = phase != "intent" or not combat.can_use(player, tier)
		button.modulate = Color(1.0, 0.9, 0.45) if tier == selected_tier else Color.WHITE
		# Sous le bouton : la Synergie que cette compétence construirait avec l'annonce de l'acolyte.
		var hint := ""
		var hot := false
		if phase == "intent" and synergy_options.has(tier):
			var option: Dictionary = synergy_options[tier]
			hint = "Synergie %s avec %s" % [option["synergy"]["name"], acolyte_name]
			if option["targets"].size() < combat.valid_targets(player, skill_id).size():
				hint = "Synergie %s : vise %s" % [option["synergy"]["name"], _names(option["targets"])]
			hot = true
		elif phase == "intent" and tier == "forte" and posture == CombatAI.GARDE_TA_FORTE and bool(announce.get("held_forte", false)) and combat.can_use(player, "forte"):
			hint = "%s lance %s avec toi" % [acolyte_name, data.skill_name(aco.skills["forte"])]
			hot = true
		elif aco != null and aco.is_alive():
			for aco_tier in CombatUnit.TIERS:
				var synergy := data.find_synergy(skill_id, aco.skills[aco_tier])
				if not synergy.is_empty():
					hint = "%s : avec sa %s" % [synergy["name"], data.skill_name(aco.skills[aco_tier])]
					break
		var synergy_label: Label = synergy_labels[tier]
		synergy_label.text = hint
		synergy_label.add_theme_color_override("font_color", GOLD if hot else Color(1, 0.83, 0.23, 0.5))
		if hot and not button.disabled and tier != selected_tier:
			button.modulate = Color(1.0, 0.95, 0.7)
	passive_info.text = "Ton passif : %s — %s" % [data.passive_name(player.passive), data.passives[player.passive]["description"]]
	if selected_tier != "":
		var skill := data.skill(player.skills[selected_tier])
		skill_info.text = "%s : %s" % [skill["name"], skill["description"]]
	elif not player.is_alive():
		skill_info.text = "%s continue seul. Tu peux encore changer sa posture." % acolyte_name
	else:
		skill_info.text = "Lis l'annonce de %s, puis choisis ta compétence. Sans choix : ta basique sur la même cible." % acolyte_name
	ready_button.disabled = phase != "intent" or player_ready
	ready_button.text = "Validé" if player_ready else "Prêt"
	if not player.is_alive():
		hint_label.text = "Tu es KO."
	elif selected_tier == "":
		hint_label.text = "1. Choisis une compétence"
	elif selected_target == "":
		hint_label.text = "2. Touche une cible (en surbrillance)"
	else:
		hint_label.text = "Intention prête. Tu peux encore changer."
		var forecast := combat.preview(player, player.skills[selected_tier], combat.get_unit(selected_target))
		if forecast["lethal"]:
			hint_label.text = "Coup fatal si personne ne le soigne avant !"
	# Cibles possibles en surbrillance, avec la prévision du coup et l'étoile des Synergies.
	var valid: Array = []
	var synergy_targets: Array = []
	if phase == "intent" and selected_tier != "" and player.is_alive():
		valid = combat.valid_targets(player, player.skills[selected_tier])
		if synergy_options.has(selected_tier) and synergy_options[selected_tier]["targets"].size() < valid.size():
			synergy_targets = synergy_options[selected_tier]["targets"]
	for view in views.values():
		var unit := combat.get_unit(view.unit_id)
		view.targetable = valid.has(unit)
		view.selected_target = view.unit_id == selected_target and phase == "intent"
		view.synergy_mark = synergy_targets.has(view.unit_id)
		view.preview_text = ""
		if view.targetable:
			var forecast := combat.preview(player, player.skills[selected_tier], unit)
			if forecast["revive"]:
				view.preview_text = "Relever"
				view.preview_color = Color("51cf66")
			elif forecast["blocked"]:
				view.preview_text = "Bloqué"
				view.preview_color = ACOLYTE_BLUE
			elif forecast["lethal"]:
				view.preview_text = "KO !"
				view.preview_color = Color("ff6b6b")
			elif int(forecast["damage"]) > 0:
				view.preview_text = "-%d" % int(forecast["damage"])
				view.preview_color = Color("ffa94d")
			elif int(forecast["heal"]) > 0:
				view.preview_text = "+%d" % int(forecast["heal"])
				view.preview_color = Color("51cf66")


## Les Intentions de ton duo : bulle au-dessus de chacun, trait vers sa cible, lien doré si une Synergie est possible.
func _refresh_intents() -> void:
	overlay.links = []
	for view in views.values():
		if view.team == 0:
			view.intent_text = ""
			view.intent_star = false
	var mine := _player_action()
	var aco_action: CombatAction = announce.get("action")
	var ready_synergy := {}
	if mine != null and aco_action != null:
		var synergy := data.find_synergy(mine.skill_id, aco_action.skill_id)
		if not synergy.is_empty() and (not bool(synergy.get("same_target", false)) or mine.target_id == aco_action.target_id):
			ready_synergy = synergy
	var ready := not ready_synergy.is_empty()
	if mine != null:
		views[player_id].intent_text = data.skill_name(mine.skill_id)
		views[player_id].intent_alpha = 0.75
		_add_intent_links(mine, Color(1, 1, 1, 0.55), ready)
	if aco_action != null:
		var aco_view: UnitView = views[acolyte_id]
		aco_view.intent_text = data.skill_name(aco_action.skill_id)
		aco_view.intent_star = bool(announce.get("held_forte", false))
		aco_view.intent_alpha = 0.6
		_add_intent_links(aco_action, Color(0.6, 0.8, 1.0, 0.55), ready)
	if ready or not synergy_options.is_empty():
		overlay.links.append({"from": views[player_id], "to": views[acolyte_id], "bond": true, "ready": ready})
	# Bannière : la Synergie prête, sinon la première Synergie possible et comment la jouer.
	if ready:
		banner.text = "Synergie prête : %s !" % ready_synergy["name"]
	elif not synergy_options.is_empty():
		var option: Dictionary = synergy_options.values()[0]
		var how := "joue %s" % data.skill_name(option["skill_id"])
		if option["targets"].size() < combat.valid_targets(_player(), option["skill_id"]).size():
			how += " sur %s" % _names(option["targets"])
		banner.text = "Synergie possible : %s — %s" % [option["synergy"]["name"], how]
	else:
		banner.text = ""
	log_label.text = _announce_sentence()


func _add_intent_links(action: CombatAction, color: Color, synergy: bool) -> void:
	var view: UnitView = views[action.actor_id]
	var skill_target := str(data.skill(action.skill_id).get("target"))
	if skill_target in ["enemies_all", "allies_all", "enemies_2"]:
		for target in combat.valid_targets(combat.get_unit(action.actor_id), action.skill_id):
			overlay.links.append({"from": view, "to": views[target.id], "color": color, "synergy": synergy})
	else:
		overlay.links.append({"from": view, "to": views[action.target_id], "color": color, "synergy": synergy})


## L'annonce de l'acolyte en une phrase : ce qu'il fait, sur qui, et la règle de sa posture qui l'a décidé.
func _announce_sentence() -> String:
	var aco := _acolyte()
	if aco == null or not aco.is_alive():
		return "%s est KO : à toi de jouer seul." % acolyte_name if _player().is_alive() else ""
	var action: CombatAction = announce.get("action")
	if action == null:
		return ""
	var sentence := "%s (%s) : %s %s" % [acolyte_name, _posture_name(posture), data.skill_name(action.skill_id), _target_phrase(action)]
	var rule := str(announce.get("rule", ""))
	if rule == "basique" and not combat.is_hostile(action.skill_id):
		rule = "basique_allie"
	var reason := str(data.postures.get("reasons", {}).get(rule, ""))
	if reason != "":
		sentence += " — " + reason
	if bool(announce.get("held_forte", false)):
		sentence += ". Il garde %s pour ta forte." % data.skill_name(aco.skills["forte"])
	return sentence


func _target_phrase(action: CombatAction) -> String:
	match str(data.skill(action.skill_id).get("target")):
		"enemies_all", "enemies_2":
			return "sur le duo adverse"
		"allies_all":
			return "sur votre duo"
		"self":
			return "sur lui"
	if action.target_id == player_id:
		return "sur toi"
	if action.target_id == action.actor_id:
		return "sur lui"
	return "sur " + _short_name(action.target_id)


func _posture_name(posture_id: String) -> String:
	return str(data.postures.get("postures", {}).get(posture_id, {}).get("name", posture_id))


## Ce que fait l'acolyte dans une posture, en clair (pour la posture Libre : selon son rôle).
func _posture_text(posture_id: String) -> String:
	var info: Dictionary = data.postures.get("postures", {}).get(posture_id, {})
	var detail := str(info.get("description", ""))
	if posture_id == CombatAI.LIBRE and not acolyte.is_empty():
		detail = str(info.get("roles", {}).get(Duo.main_role(data, acolyte["class_id"]), ""))
	return "%s — %s %s" % [info.get("name", posture_id), info.get("summary", ""), detail]


func _names(unit_ids: Array) -> String:
	var names: Array = []
	for unit_id in unit_ids:
		names.append(_short_name(unit_id))
	return ", ".join(names)


# ---------------------------------------------------------------------------
# Résolution animée
# ---------------------------------------------------------------------------

func _submit_turn() -> void:
	phase = "resolve"
	timer_bar.value = 0
	timer_label.text = ""
	var player := _player()
	var actions: Array = []
	var mine := _player_action()
	if mine == null and player.is_alive():
		mine = combat.default_action(player)
	if mine != null:
		actions.append(mine)
	var aco := _acolyte()
	if aco != null and aco.is_alive():
		actions.append(CombatAI.decide_acolyte(combat, aco, posture, mine)["action"])
	# Le duo adverse : sa posture, l'annonce de son acolyte, puis le choix de son joueur IA. Tu ne vois rien avant la révélation.
	var plan := CombatAI.plan_team(combat, 1)
	actions.append_array(plan["actions"])
	var enemy_acolyte := combat.acolyte_of(1)
	if enemy_acolyte != null and enemy_acolyte.is_alive():
		enemy_posture_label.set_meta("next", "Posture de %s : %s" % [enemy_acolyte.display_name, _posture_name(plan["posture"])])
	_refresh_posture_panel()
	_refresh_skill_buttons()
	var events := combat.resolve_turn(actions)
	_play_events(events)


func _play_events(events: Array) -> void:
	overlay.links = []
	hint_label.text = "Touche l'écran pour accélérer"
	for view in views.values():
		view.targetable = false
		view.selected_target = false
		view.synergy_mark = false
		view.preview_text = ""
		view.threat_text = ""
	for event in events:
		await _play_event(event)
	for view in views.values():
		view.order_badge = 0
		view.sync(combat.get_unit(view.unit_id), data)
	if combat.finished:
		_show_end()
	else:
		_begin_intent_phase()


func _play_event(event: Dictionary) -> void:
	match str(event["type"]):
		"reveal":
			for action_dict in event["actions"]:
				var view: UnitView = views[action_dict["actor"]]
				view.intent_text = data.skill_name(action_dict["skill"])
				view.intent_star = false
				view.intent_alpha = 0.8
			if enemy_posture_label.has_meta("next"):
				enemy_posture_label.text = str(enemy_posture_label.get_meta("next"))
				enemy_posture_label.remove_meta("next")
			log_label.text = "Révélation : les 4 actions"
			await _wait(1.1)
		"order":
			var index := 1
			for unit_id in event["order"]:
				views[unit_id].order_badge = index
				index += 1
		"action":
			var actor: UnitView = views[event["actor"]]
			actor.do_lunge()
			if event["tier"] == "forte":
				sfx.play("forte")
				_show_cutin(data.skill_name(event["skill"]).to_upper() + " !", Color("ffa94d") if combat.get_unit(event["actor"]).team == 1 else ACOLYTE_BLUE)
				_shake(6.0)
				await _wait(0.35)
			var targets: Array = event["targets"]
			var target_text := ""
			if targets.size() == 1 and targets[0] != event["actor"]:
				target_text = " sur " + _short_name(targets[0])
			elif targets.size() > 1:
				target_text = " (%d cibles)" % targets.size()
			log_label.text = "%s : %s%s" % [_short_name(event["actor"]), data.skill_name(event["skill"]), target_text]
			if event.get("redirected", false):
				log_label.text += " — provoqué !"
			await _wait(0.45)
		"damage":
			var view: UnitView = views[event["target"]]
			var amount := int(event["amount"])
			var big: bool = amount >= 60 or str(event["kind"]) == "synergie"
			view.set_hp(int(event["hp"]))
			view.do_hurt(1.6 if big else 1.0)
			var color := Color("ff6b6b")
			if event["kind"] == "dot":
				color = Color("ff9f43")
			elif event["kind"] == "synergie":
				color = GOLD
			view.float_text("-%d" % amount, color, big)
			sfx.play("gros_coup" if big else "coup", randf_range(0.9, 1.1))
			if big:
				_shake(5.0)
			var source := str(event.get("source", ""))
			if stats.has(source):
				stats[source]["damage"] += amount
				if int(event["hp"]) <= 0:
					stats[source]["kos"] += 1
			await _wait(0.24)
		"heal":
			if int(event["amount"]) > 0:
				var view: UnitView = views[event["target"]]
				view.set_hp(int(event["hp"]))
				view.float_text("+%d" % int(event["amount"]), Color("51cf66"), str(event["kind"]) == "synergie")
				sfx.play("soin", randf_range(0.95, 1.05), -4.0)
				var healer := str(event.get("source", ""))
				if stats.has(healer):
					stats[healer]["heal"] += int(event["amount"])
				await _wait(0.22)
		"absorbed":
			views[event["target"]].float_text("Bloqué", ACOLYTE_BLUE)
			sfx.play("bloque")
			await _wait(0.2)
		"status":
			var view: UnitView = views[event["target"]]
			var unit := combat.get_unit(event["target"])
			view.float_text(data.status_name(event["status"]), Color("e599f7"))
			view.sync(unit, data)
			view.set_hp(view.target_hp)
		"taunt":
			for unit_id in event["targets"]:
				views[unit_id].float_text("Provoqué", Color("ffa94d"))
		"push_back":
			if event.get("effect", false):
				views[event["target"]].float_text("Repoussé", Color("ffa94d"))
		"ko":
			views[event["target"]].set_hp(0)
			views[event["target"]].float_text("KO", Color("ff6b6b"), true)
			log_label.text = "%s est KO !" % _short_name(event["target"])
			sfx.play("ko")
			_shake(9.0)
			_flash(Color(1, 0.3, 0.3), 0.25)
			await _wait(0.6)
		"revive":
			var view: UnitView = views[event["target"]]
			view.set_hp(int(event["hp"]))
			view.float_text("Relevé !", Color("51cf66"), true)
			log_label.text = "%s est relevé !" % _short_name(event["target"])
			sfx.play("releve")
			_flash(Color(0.5, 1, 0.6), 0.3)
			await _wait(0.6)
		"action_lost":
			log_label.text = "%s est KO : son action est perdue." % _short_name(event["actor"])
			await _wait(0.4)
		"synergy":
			var ours: bool = combat.get_unit(str(event["actors"][0])).team == 0
			banner.text = "SYNERGIE : %s !" % event["name"]
			if ours:
				synergies_fired += 1
			for unit_id in event["actors"]:
				views[unit_id].float_text("Synergie", GOLD, true)
			sfx.play("synergie")
			_show_cutin("SYNERGIE !\n" + str(event["name"]), GOLD if ours else Color("ff8787"))
			_flash(GOLD if ours else Color("ff6b6b"), 0.35)
			_shake(7.0)
			await _wait(1.0)
		"cooldown_reduced":
			views[event["target"]].float_text("Recharge -%d" % int(event["amount"]), ACOLYTE_BLUE)
		"turn_end":
			await _wait(0.4)


func _short_name(unit_id: String) -> String:
	var unit := combat.get_unit(unit_id)
	if unit.is_player:
		return "Toi"
	return unit.display_name


func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds / speed).timeout


## Pendant la résolution, toucher l'écran accélère l'animation du tour.
func _input(event: InputEvent) -> void:
	if phase == "resolve" and event is InputEventMouseButton and event.pressed:
		speed = 3.0
		hint_label.text = "Accéléré"


# ---------------------------------------------------------------------------
# Fin de combat
# ---------------------------------------------------------------------------

func _show_end() -> void:
	phase = "end"
	end_layer = _make_layer()
	var box: VBoxContainer = end_layer.get_meta("box")
	var won := combat.winner == 0
	var result := profile.record_result(won)
	sfx.play("victoire" if won else "defaite")
	box.add_child(_label("Victoire !" if won else "Défaite", 48, GOLD if won else Color("ff6b6b")))
	var reason := "Le duo adverse est KO." if won else "Ton duo est KO."
	if combat.end_reason != "ko":
		reason = "Fin forcée : le duo avec le plus de PV l'emporte (%d contre %d)." % [combat.team_total_hp(0), combat.team_total_hp(1)]
	box.add_child(_label(reason, 20, Color.WHITE))
	box.add_child(_label("%d tours  ·  %d Synergie%s de ton duo" % [combat.turn, synergies_fired, "s" if synergies_fired > 1 else ""], 18, GOLD if synergies_fired > 0 else Color(0.8, 0.85, 1)))
	# Ta part du combat, celle de ton acolyte, et le meilleur des 4.
	for unit_id in [player_id, acolyte_id]:
		var line: Dictionary = stats.get(unit_id, {"damage": 0, "heal": 0, "kos": 0})
		box.add_child(_label("%s : %d dégâts · %d soins · %d KO" % [_short_name(unit_id), line["damage"], line["heal"], line["kos"]], 18, Color.WHITE if unit_id == player_id else ACOLYTE_BLUE))
	var best_id := player_id
	var best_score := -1.0
	for unit_id in stats:
		var score := float(stats[unit_id]["damage"]) + float(stats[unit_id]["heal"]) + 40.0 * float(stats[unit_id]["kos"])
		if score > best_score:
			best_score = score
			best_id = unit_id
	var best_text := "Meilleur du combat : toi !" if best_id == player_id else "Meilleur du combat : %s" % _short_name(best_id)
	box.add_child(_label(best_text, 18, GOLD if best_id == player_id else Color(0.8, 0.85, 1)))
	# La série : la raison de relancer.
	var streak_text := ""
	if won:
		streak_text = "Série : %d victoire%s d'affilée" % [profile.streak, "s" if profile.streak > 1 else ""]
		if result["new_record"]:
			streak_text += " — nouveau record !"
		else:
			streak_text += " (record : %d)" % profile.best_streak
	elif int(result["previous_streak"]) > 0:
		streak_text = "Série brisée après %d victoire%s. Record : %d" % [result["previous_streak"], "s" if int(result["previous_streak"]) > 1 else "", profile.best_streak]
	else:
		streak_text = "Record : %d victoire%s d'affilée" % [profile.best_streak, "s" if profile.best_streak > 1 else ""]
	box.add_child(_label(streak_text, 20, Color("51cf66") if won else Color("ffa94d")))
	box.add_child(_spacer(10))
	var again := Button.new()
	again.text = "Rejouer" if not won else "Combat suivant"
	again.custom_minimum_size = Vector2(0, 76)
	again.add_theme_font_size_override("font_size", 30)
	again.pressed.connect(_start_combat)
	box.add_child(again)
	var change := Button.new()
	change.text = "Changer de personnage"
	change.custom_minimum_size = Vector2(0, 54)
	change.pressed.connect(_show_menu)
	box.add_child(change)
