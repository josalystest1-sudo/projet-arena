## Écran de combat du prototype en duo : toi et ton acolyte (piloté par l'IA) contre un duo IA, ou les étages de la Tour.
## Toute la règle vit dans le moteur (res://engine) ; cet écran affiche, collecte tes choix et anime les événements.
## Il est ouvert par l'application (scenes/app/app.gd) depuis la Vitrine, le face-à-face ou l'écran de la Tour.
extends Control

const INTENT_SECONDS := 12.0
## Quand tu es KO, ton acolyte continue seul : quelques secondes pour lire son annonce.
const KO_PLAYER_SECONDS := 3.0
const CLASS_ORDER := ["guerrier", "mage", "pretre"]
const ROLE_LABELS := {"front": "Front", "degats": "Dégâts", "soutien": "Soutien"}
const TIER_LABELS := {"basique": "Basique", "moyenne": "Moyenne", "forte": "Forte"}
const ACOLYTE_NAMES := ["Lys", "Orme", "Saule", "Iris", "Cèdre", "Aube", "Sorel", "Nima"]
const ENEMY_NAMES := ["Ombre", "Brume", "Cendre", "Givre", "Ronce", "Écume", "Nox", "Bise"]
## Largeur de la colonne de gauche : « Duo adverse » (en haut) et ton acolyte qui joue seul (en bas).
const BG_COLOR := Color("141826")
const PANEL_COLOR := Color("1f2538")
const GOLD := Color("ffd43b")
const ACOLYTE_BLUE := Color("9ad1ff")

var app: ArenaApp
var data: CombatData
var combat: Combat
var rng: RandomNumberGenerator

# Ton duo, gardé d'un combat à l'autre (l'acolyte ne change pas, comme dans le vrai jeu).
var player_class: String = "guerrier"
var player_picks: Dictionary = {}
var acolyte: Dictionary = {}
var acolyte_name: String = ""
var player_id: String = "a1"
var acolyte_id: String = "a2"
## « pvp » : ton duo contre un duo IA ; « tour » : la montée de la Tour (étape 2).
var mode: String = "pvp"
var tower: Tower

# Phase d'Intention.
var phase: String = "menu"   # menu, intent, resolve, end
var time_left: float = 0.0
var selected_tier: String = ""
var selected_target: String = ""
var player_ready: bool = false
## L'annonce de l'acolyte : {action, rule, waiting} (waiting : il garde sa forte pour une Synergie au tour suivant).
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
## Au-dessus des ennemis : qui tu affrontes (« Duo adverse · IA », « Étage 3 · Gobelins »).
var field_label: Label
## La carte du milieu, le seul endroit à lire : l'annonce de ton acolyte pendant le choix, puis chaque action.
var story_panel: PanelContainer
var story_title: Label
var story_main: Label
var story_sub: Label
var overlay: IntentOverlay
var turn_label: Label
var timer_bar: ProgressBar
var timer_label: Label
var sudden_label: Label
var skill_buttons: Dictionary = {}
## Le pas à faire maintenant, en gros : ① compétence, ② cible, ③ Prêt.
var step_label: Label
## L'encadré des Synergies, juste au-dessus des boutons (doré quand une Synergie est possible ou prête).
var synergy_panel: PanelContainer
var synergy_title: Label
var synergy_text: Label
var skill_info: Label
var ready_button: Button
var bottom_panel: PanelContainer
## Les bulles d'aide du premier combat (une fois chacune), et le bouton « ? » qui les rouvre.
var tip_layer: Control
var help_button: Button
var menu_layer: Control
var end_layer: Control
var stage: Control
## La colonne de l'écran de combat, mise à l'échelle pour tenir en entier dans la hauteur disponible.
var layout_root: VBoxContainer
var flash_rect: ColorRect
var cutin: Label
var mute_button: Button
var quit_button: Button
var _quit_armed := false
## Le numéro de l'action en cours pendant la résolution (« Action 2 sur 4 »).
var action_index: int = 0
var action_count: int = 0
## Sous l'action en cours : sa note (provoqué…) et ce qu'elle a fait (« Toi -38 · Saule -20 »).
var story_note: String = ""
var story_results: Array = []


## Appelé par l'application : options = {mode: "pvp" (avec enemy : le duo adverse) ou "tour"}.
func setup(p_app: ArenaApp, options: Dictionary) -> void:
	app = p_app
	data = app.data
	profile = app.profile
	sfx = app.sfx
	rng = app.rng
	player_class = app.player_class
	player_picks = app.player_picks
	acolyte = app.acolyte
	acolyte_name = app.acolyte_name
	_build_layout()
	if str(options.get("mode", "pvp")) == "tour":
		_start_tower()
	else:
		_start_combat(options.get("enemy", []))


# ---------------------------------------------------------------------------
# Construction de l'interface
# ---------------------------------------------------------------------------

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
	root.add_theme_constant_override("separation", 6)
	stage.add_child(root)
	layout_root = root
	# Tout l'écran tient dans la hauteur du téléphone : s'il manque de place, il se réduit au lieu de déborder.
	stage.resized.connect(_fit_layout)

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
	help_button = Button.new()
	help_button.text = "?"
	help_button.custom_minimum_size = Vector2(40, 36)
	help_button.add_theme_font_size_override("font_size", 18)
	help_button.pressed.connect(_show_help)
	top.add_child(help_button)
	quit_button = Button.new()
	quit_button.text = "Quitter"
	quit_button.custom_minimum_size = Vector2(64, 36)
	quit_button.add_theme_font_size_override("font_size", 15)
	quit_button.pressed.connect(_on_quit_pressed)
	top.add_child(quit_button)
	sudden_label = Label.new()
	sudden_label.add_theme_color_override("font_color", Color("ff6b6b"))
	sudden_label.add_theme_font_size_override("font_size", 16)
	sudden_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(sudden_label)

	# Les ennemis en haut, centrés, avec une ligne qui dit qui ils sont.
	field_label = Label.new()
	field_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	field_label.add_theme_font_size_override("font_size", 15)
	field_label.add_theme_color_override("font_color", Color("ff8787"))
	root.add_child(field_label)
	enemy_units = HBoxContainer.new()
	enemy_units.alignment = BoxContainer.ALIGNMENT_CENTER
	enemy_units.add_theme_constant_override("separation", 6)
	root.add_child(enemy_units)

	# Au milieu, une seule carte à lire : ce que fait ton acolyte, puis ce qui se passe pendant le tour.
	var middle := CenterContainer.new()
	middle.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(middle)
	story_panel = PanelContainer.new()
	story_panel.custom_minimum_size = Vector2(500, 132)
	middle.add_child(story_panel)
	var story := VBoxContainer.new()
	story.alignment = BoxContainer.ALIGNMENT_CENTER
	story.add_theme_constant_override("separation", 2)
	story_panel.add_child(story)
	story_title = _story_label(14, Color(0.65, 0.72, 0.9))
	story.add_child(story_title)
	story_main = _story_label(21, Color.WHITE)
	story.add_child(story_main)
	story_sub = _story_label(15, Color(0.8, 0.84, 0.95))
	story_sub.max_lines_visible = 3
	story.add_child(story_sub)
	story_main.max_lines_visible = 2
	_style_story("normal")

	# Ton duo : ton acolyte à gauche, toi à droite.
	ally_units = HBoxContainer.new()
	ally_units.alignment = BoxContainer.ALIGNMENT_CENTER
	ally_units.add_theme_constant_override("separation", 6)
	root.add_child(ally_units)

	# Bas : le pas à faire, l'encadré des Synergies, les 3 compétences, puis sa description et « Prêt ».
	# Toutes les zones de texte ont une hauteur fixe : les boutons ne bougent jamais sous le doigt.
	bottom_panel = PanelContainer.new()
	root.add_child(bottom_panel)
	var bottom := VBoxContainer.new()
	bottom.add_theme_constant_override("separation", 8)
	bottom_panel.add_child(bottom)
	step_label = Label.new()
	step_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	step_label.add_theme_font_size_override("font_size", 23)
	step_label.custom_minimum_size = Vector2(0, 32)
	bottom.add_child(step_label)
	synergy_panel = PanelContainer.new()
	synergy_panel.custom_minimum_size = Vector2(0, 76)
	bottom.add_child(synergy_panel)
	var synergy_box := VBoxContainer.new()
	synergy_box.alignment = BoxContainer.ALIGNMENT_CENTER
	synergy_box.add_theme_constant_override("separation", 0)
	synergy_panel.add_child(synergy_box)
	synergy_title = _story_label(18, GOLD)
	synergy_box.add_child(synergy_title)
	synergy_text = _story_label(15, Color(1, 0.95, 0.8))
	synergy_text.max_lines_visible = 2
	synergy_box.add_child(synergy_text)
	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 8)
	bottom.add_child(buttons)
	for tier in CombatUnit.TIERS:
		var button := Button.new()
		button.custom_minimum_size = Vector2(0, 88)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.add_theme_font_size_override("font_size", 18)
		button.pressed.connect(_on_skill_pressed.bind(tier))
		buttons.add_child(button)
		skill_buttons[tier] = button
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	bottom.add_child(row)
	skill_info = Label.new()
	skill_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	skill_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	skill_info.add_theme_font_size_override("font_size", 15)
	skill_info.add_theme_color_override("font_color", Color(0.8, 0.84, 0.95))
	skill_info.custom_minimum_size = Vector2(0, 60)
	skill_info.max_lines_visible = 3
	skill_info.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(skill_info)
	ready_button = Button.new()
	ready_button.text = "Prêt"
	ready_button.custom_minimum_size = Vector2(130, 60)
	ready_button.add_theme_font_size_override("font_size", 22)
	ready_button.pressed.connect(_on_ready_pressed)
	row.add_child(ready_button)

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


## Met la colonne de l'écran à l'échelle de l'écran : sur un téléphone peu haut (barres du navigateur visibles),
## tout rapetisse un peu, et rien ne passe sous le bas de l'écran.
func _fit_layout() -> void:
	if layout_root == null:
		return
	var margin := 10.0
	var available := stage.size - Vector2(margin, margin) * 2.0
	if available.x <= 0.0 or available.y <= 0.0:
		return
	var needed := layout_root.get_combined_minimum_size()
	var k := minf(1.0, minf(available.y / maxf(needed.y, 1.0), available.x / maxf(needed.x, 1.0)))
	layout_root.scale = Vector2(k, k)
	layout_root.position = Vector2(margin, margin)
	layout_root.size = available / k


func _story_label(font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


## Le cadre d'une carte : « normal », « acolyte » (bleu), « gold » (Synergie), « enemy » (rouge), « off » (rien à dire).
static func _card_style(kind: String) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.set_corner_radius_all(12)
	style.set_content_margin_all(8)
	style.bg_color = Color("1f2538")
	style.border_color = Color("2f3856")
	match kind:
		"acolyte":
			style.border_color = Color("5aa9ff")
			style.bg_color = Color("18233d")
		"gold":
			style.border_color = Color("ffd43b")
			style.bg_color = Color("3a3112")
		"enemy":
			style.border_color = Color("ff6b6b")
			style.bg_color = Color("351a22")
		"off":
			style.bg_color = Color("191e2e")
	style.set_border_width_all(3 if kind in ["gold", "acolyte", "enemy"] else 1)
	return style


func _style_story(kind: String) -> void:
	story_panel.add_theme_stylebox_override("panel", _card_style(kind))


func _set_story(title: String, main: String, sub: String = "", kind: String = "normal") -> void:
	story_title.text = title
	story_main.text = main
	story_sub.text = sub
	_style_story(kind)


func _on_mute_pressed() -> void:
	sfx.muted = not sfx.muted
	profile.muted = sfx.muted
	profile.save()
	_refresh_mute_button()
	sfx.play("clic")


## Quitter demande un second appui. En duel, quitter compte comme une défaite ; à la Tour, la montée s'arrête là.
## (Pas pendant l'animation d'un tour : on attend la phase de choix.)
func _on_quit_pressed() -> void:
	if phase == "resolve":
		return
	if phase == "end" or combat == null:
		app.show_screen("home")
		return
	if not _quit_armed:
		_quit_armed = true
		quit_button.text = "Sûr ?"
		quit_button.modulate = Color(1, 0.6, 0.6)
		return
	phase = "end"
	if mode == "tour":
		tower.reached = tower.current_floor
		_end_climb()
	else:
		profile.record_result(false)
		app.show_screen("home")


func _refresh_mute_button() -> void:
	mute_button.text = "Son : non" if sfx.muted else "Son : oui"


## Grande annonce au centre de l'écran (nom d'une forte, Synergie...). hold : combien de temps elle reste lisible.
func _show_cutin(text: String, color: Color, hold: float = 0.5) -> void:
	cutin.text = text
	cutin.add_theme_color_override("font_color", color)
	cutin.pivot_offset = cutin.size / 2.0
	cutin.scale = Vector2(1.8, 1.8)
	cutin.modulate = Color(1, 1, 1, 1)
	var tween := create_tween()
	tween.tween_property(cutin, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(hold / speed)
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


func _make_layer(separation: int = 12) -> Control:
	var layer := ColorRect.new()
	layer.color = Color(0.05, 0.06, 0.1, 0.94)
	layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(layer)
	# Centrée quand elle tient dans l'écran, elle défile au doigt sinon.
	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	layer.add_child(scroll)
	var center := CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.custom_minimum_size = Vector2(0, get_viewport_rect().size.y)
	scroll.add_child(center)
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

## Un duel : ton duo contre le duo adverse choisi au face-à-face (tiré ici s'il n'y en a pas).
func _start_combat(enemy: Array = []) -> void:
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
	var team_a := app.duo_members()
	# En face : un duo IA (en attendant les Échos de l'étape 5).
	var team_b := enemy
	if team_b.is_empty():
		team_b = Duo.random_duo(data, rng)
		team_b[0]["name"] = ENEMY_NAMES[0]
		team_b[1]["name"] = ENEMY_NAMES[1]
	mode = "pvp"
	combat = Combat.create(data, team_a, team_b, rng.randi_range(0, 1))
	_setup_views([combat.acolyte_of(1), combat.leader_of(1)])
	_begin_intent_phase()


## Les persos à l'écran. Dans ta rangée : la colonne de ton acolyte, ton acolyte, puis toi.
func _setup_views(enemies: Array) -> void:
	player_id = combat.leader_of(0).id
	acolyte_id = combat.acolyte_of(0).id
	views = {}
	_clear_children(enemy_units)
	_clear_children(ally_units)
	field_label.text = "DUO ADVERSE · joué par l'IA" if mode == "pvp" else ""
	var order: Array = []
	order.append_array(enemies)
	order.append(combat.acolyte_of(0))
	order.append(combat.leader_of(0))
	for unit in order:
		var view := UnitView.new()
		view.setup(unit)
		# Un monstre porte déjà son nom d'espèce ; une classe s'écrit à côté du nom du perso.
		view.subtitle = "" if unit.is_monster else data.class_name_of(unit.class_id)
		if unit.team == 1 and enemies.size() >= 4:
			view.set_size_mode("compact")
		elif unit.team == 1 and enemies.size() == 1:
			view.set_size_mode("big")
		view.tapped.connect(_on_unit_tapped)
		(ally_units if unit.team == 0 else enemy_units).add_child(view)
		views[unit.id] = view
		view.sync(unit, data)
		stats[unit.id] = {"damage": 0, "heal": 0, "kos": 0}
	_fit_layout.call_deferred()


# ---------------------------------------------------------------------------
# La Tour : le duo grimpe des étages, PV et recharges gardés d'un étage à l'autre
# ---------------------------------------------------------------------------

func _start_tower() -> void:
	sfx.play("clic")
	tower = Tower.start(data, app.duo_members())
	_start_floor()


func _start_floor() -> void:
	if menu_layer != null:
		menu_layer.queue_free()
		menu_layer = null
	if end_layer != null:
		end_layer.queue_free()
		end_layer = null
	synergies_fired = 0
	stats = {}
	speed = 1.0
	mode = "tour"
	var family := str(data.monster_families.get(tower.planned_family(rng), ""))
	combat = tower.create_combat(rng)
	_setup_views(combat.team_units(1))
	for unit in combat.team_units(1):
		profile.see_monster(unit.class_id)
	if tower.is_boss_floor():
		field_label.text = "ÉTAGE %d · GARDIEN : %s" % [tower.current_floor, combat.team_units(1)[0].display_name.to_upper()]
		_show_cutin("ÉTAGE %d : %s" % [tower.current_floor, combat.team_units(1)[0].display_name.to_upper()], Color("ffa94d"))
	else:
		field_label.text = "ÉTAGE %d · %s" % [tower.current_floor, family.to_upper()]
		_show_cutin("ÉTAGE %d : %s" % [tower.current_floor, family.to_upper()], GOLD)
	_begin_intent_phase()


## Fin d'un étage : on monte (PV +20 %, recharges gardées) ou la montée s'arrête et le record tombe peut-être.
func _show_floor_end() -> void:
	phase = "end"
	var floor_number := tower.current_floor
	var result := tower.finish_floor(combat)
	end_layer = _make_layer()
	var box: VBoxContainer = end_layer.get_meta("box")
	if result["won"] and not tower.finished:
		sfx.play("victoire")
		box.add_child(_label("Étage %d franchi !" % floor_number, 40, GOLD))
		if combat.end_reason == "limite_de_tours":
			box.add_child(_label("Épuisés, les ennemis abandonnent.", 18, Color.WHITE))
		box.add_child(_label("Entre deux étages : 20 % de tes PV max rendus, recharges conservées.", 17, Color(0.8, 0.85, 1)))
		for line in result["report"]:
			var unit := combat.get_unit(line["id"])
			var gain := int(line["after"]) - int(line["before"])
			var text := "%s : %d PV + %d = %d PV" % [_short_name(unit.id), int(line["before"]), gain, int(line["after"])]
			if gain <= 0:
				text = "%s : %d PV, déjà au maximum" % [_short_name(unit.id), int(line["after"])]
			if line["revived"]:
				text = "%s : KO, relevé avec %d PV" % [_short_name(unit.id), int(line["after"])]
			box.add_child(_label(text, 19, Color.WHITE if unit.is_player else ACOLYTE_BLUE))
		var next := tower.current_floor
		box.add_child(_label("Étage %d : %s" % [next, _floor_preview()], 17, Color("ffa94d")))
		box.add_child(_spacer(8))
		var climb := Button.new()
		climb.text = "Monter à l'étage %d" % next
		climb.custom_minimum_size = Vector2(0, 76)
		climb.add_theme_font_size_override("font_size", 28)
		climb.pressed.connect(_start_floor)
		box.add_child(climb)
		var stop := Button.new()
		stop.text = "Abandonner la montée"
		stop.custom_minimum_size = Vector2(0, 50)
		stop.pressed.connect(_end_climb)
		box.add_child(stop)
		return
	_end_climb()


## Les monstres de l'étage à venir, annoncés entre deux étages : « Gardien : Liche, avec Squelette et Goule ».
func _floor_preview() -> String:
	var names: Array = []
	for enemy in tower.plan_floor(rng):
		names.append(str(enemy["name"]))
	if tower.is_boss_floor():
		var rest := names.slice(1)
		return "Gardien : %s%s" % [names[0], (", avec " + ", ".join(rest)) if not rest.is_empty() else ", seul"]
	return "%s — %s" % [str(data.monster_families.get(tower.planned_family(rng), "")), ", ".join(names)]


## La montée est finie (tombé, sommet franchi ou abandon) : l'étage atteint, et le record de ta classe.
func _end_climb() -> void:
	phase = "end"
	if end_layer != null:
		end_layer.queue_free()
	end_layer = _make_layer()
	var box: VBoxContainer = end_layer.get_meta("box")
	var cls_name := data.class_name_of(player_class)
	var previous := int(profile.tower_records.get(player_class, 0))
	var reached := tower.reached
	if reached > previous:
		profile.tower_records[player_class] = reached
		profile.save()
	if tower.cleared_all:
		sfx.play("victoire")
		box.add_child(_label("Sommet atteint !", 44, GOLD))
		box.add_child(_label("Ton duo a franchi les %d étages de la Tour." % tower.floor_count(), 20, Color.WHITE))
	else:
		sfx.play("defaite")
		box.add_child(_label("La montée s'arrête", 40, Color("ff6b6b")))
		box.add_child(_label("Étage atteint : %d sur %d" % [reached, tower.floor_count()], 26, Color.WHITE))
	if reached > previous and previous > 0:
		box.add_child(_label("Nouveau record pour ton %s ! (avant : étage %d)" % [cls_name, previous], 20, Color("51cf66")))
	elif reached > previous:
		box.add_child(_label("Premier record pour ton %s." % cls_name, 20, Color("51cf66")))
	else:
		box.add_child(_label("Record de ton %s : étage %d" % [cls_name, previous], 20, Color("ffa94d")))
	box.add_child(_spacer(10))
	var again := Button.new()
	again.text = "Recommencer la Tour"
	again.custom_minimum_size = Vector2(0, 76)
	again.add_theme_font_size_override("font_size", 28)
	again.pressed.connect(_start_tower)
	box.add_child(again)
	var duel := Button.new()
	duel.text = "Combat en duo"
	duel.custom_minimum_size = Vector2(0, 54)
	duel.pressed.connect(func(): app.show_screen("versus"))
	box.add_child(duel)
	var change := Button.new()
	change.text = "Retour à l'accueil"
	change.custom_minimum_size = Vector2(0, 54)
	change.pressed.connect(func(): app.show_screen("home"))
	box.add_child(change)


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
	if mode == "tour":
		sudden_label.text = "La Tour : étage %d sur %d  ·  ton record : %d" % [tower.current_floor, tower.floor_count(), int(profile.tower_records.get(player_class, 0))]
		if combat.turn >= combat.exhaustion_turn:
			sudden_label.text = "Les ennemis s'épuisent : plus de soins ni de barrières  ·  abandon au tour %d" % combat.forced_end_turn
		sudden_label.add_theme_color_override("font_color", Color("ffa94d"))
	elif combat.is_sudden_death():
		sudden_label.add_theme_color_override("font_color", Color("ff6b6b"))
		sudden_label.text = "MORT SUBITE : soins ÷2, dégâts +%d %%  ·  fin au tour %d" % [int(round((combat.sudden_death_damage_mult() - 1.0) * 100.0)), combat.forced_end_turn]
	elif combat.turn >= combat.sudden_death_turn - 2:
		sudden_label.add_theme_color_override("font_color", Color("ff6b6b"))
		sudden_label.text = "Mort subite au tour %d" % combat.sudden_death_turn
	else:
		sudden_label.text = ""
	bottom_panel.modulate = Color(1, 1, 1, 1 if player.is_alive() else 0.45)
	announce = {}
	_update_announce(true)
	_refresh_skill_buttons()
	_refresh_intents()
	_maybe_show_tips()


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


## L'acolyte annonce son coup au début du tour (il ne dépend jamais de ton choix), et les Synergies que tu peux construire.
func _update_announce(initial: bool) -> void:
	var aco := _acolyte()
	synergy_options = {}
	if aco == null or not aco.is_alive():
		announce = {}
		return
	announce = CombatAI.decide_acolyte(combat, aco)
	for option in CombatAI.synergy_options(combat, _player(), aco):
		synergy_options[option["tier"]] = option
	if initial:
		views[acolyte_id].do_announce()
		sfx.play("clic", 1.6, -6.0)


func _process(delta: float) -> void:
	# Secousse d'écran.
	if shake_amount > 0.0:
		shake_amount = maxf(shake_amount - delta * 40.0, 0.0)
		stage.position = Vector2(randf_range(-shake_amount, shake_amount), randf_range(-shake_amount, shake_amount))
	elif stage.position != Vector2.ZERO:
		stage.position = Vector2.ZERO
	if phase != "intent":
		return
	# Une bulle d'aide ouverte met le chrono en pause.
	if tip_layer != null:
		return
	time_left = maxf(time_left - delta, 0.0)
	if selected_target != "" and not player_ready:
		step_label.text = "3. Appuie sur Prêt (ou attends %d s)" % int(ceil(time_left))
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
	_maybe_show_tips()


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
	skill_info.text = "%s : %s." % [_short_name(unit_id), " · ".join(parts)]
	if unit.passive != "":
		skill_info.text += " Passif : %s." % data.passive_name(unit.passive)
	if unit.is_monster:
		skill_info.text = "%s (%s). %s" % [skill_info.text, data.monster_rank_name(unit.class_id), str(data.monsters[unit.class_id].get("description", ""))]
	if unit_id == acolyte_id:
		skill_info.text += " " + _acolyte_rules_text()


func _on_ready_pressed() -> void:
	if phase != "intent":
		return
	player_ready = true
	sfx.play("clic", 0.8)
	_refresh_skill_buttons()


## La carte du milieu pendant le choix : ce que ton acolyte va jouer, et pourquoi.
func _refresh_story() -> void:
	var aco := _acolyte()
	if not _player().is_alive():
		_set_story("TU ES KO", "%s continue seul" % acolyte_name, "Le tour part tout seul dans quelques secondes.", "off")
		return
	if aco == null or not aco.is_alive():
		_set_story("%s EST KO" % acolyte_name.to_upper(), "Tu joues seul ce tour-ci", "", "off")
		return
	var action: CombatAction = announce.get("action")
	if action == null:
		_set_story("", "", "", "off")
		return
	var sub := _announce_reason()
	if sub == "":
		sub = "Il joue seul, selon son rôle (%s)" % ROLE_LABELS.get(Duo.main_role(data, aco.class_id), "")
	var kind := "acolyte"
	if announce.has("waiting"):
		var waiting: Dictionary = announce["waiting"]
		sub = "Il garde sa forte pour une Synergie au prochain tour (%s, avec ta %s)" % [waiting["synergy"]["name"], data.skill_name(waiting["skill_id"])]
		kind = "gold"
	elif str(announce.get("rule", "")) == "avec_toi":
		sub = "La forte qu'il gardait pour votre Synergie : joue la tienne avec !"
		kind = "gold"
	_set_story("%s VA JOUER" % acolyte_name.to_upper(), "%s %s" % [data.skill_name(action.skill_id), _target_phrase(action)], sub, kind)


func _refresh_skill_buttons() -> void:
	var player := _player()
	var waiting_skill := str(announce.get("waiting", {}).get("skill_id", ""))
	for tier in CombatUnit.TIERS:
		var button: Button = skill_buttons[tier]
		var skill_id: String = player.skills[tier]
		var remaining := combat.cooldown_remaining(player, tier)
		var status: String = TIER_LABELS[tier]
		var used_once: bool = bool(data.skill(skill_id).get("once_per_combat", false)) and bool(player.flags.get("used_" + skill_id, false))
		if used_once:
			status = "Déjà utilisée"
		elif remaining > 0:
			if tier == "forte" and combat.turn < combat.strong_available_from_turn and int(player.cooldown_until.get(tier, 0)) <= combat.turn:
				status = "Dès le tour %d" % combat.strong_available_from_turn
			else:
				status = "Revient dans %d" % remaining
		button.disabled = phase != "intent" or not combat.can_use(player, tier)
		# Le bouton qui déclenche une Synergie avec l'annonce de l'acolyte est bordé d'or et le dit.
		var hot := phase == "intent" and synergy_options.has(tier) and not button.disabled
		if hot:
			status = "SYNERGIE !"
		elif phase == "intent" and waiting_skill == skill_id:
			status = "Synergie au prochain tour"
		button.text = "%s\n%s" % [data.skill_name(skill_id), status]
		_style_skill_button(button, tier == selected_tier, hot)
	_refresh_synergy_panel()
	if selected_tier != "":
		var skill := data.skill(player.skills[selected_tier])
		skill_info.text = "%s : %s" % [skill["name"], data.skill_description(player.skills[selected_tier])]
	elif not player.is_alive():
		skill_info.text = "%s continue seul." % acolyte_name
	else:
		skill_info.text = "Touche une compétence pour la choisir. Touche un perso pour voir ce qu'il sait faire."
	ready_button.disabled = phase != "intent" or player_ready
	ready_button.text = "Validé" if player_ready else "Prêt"
	ready_button.modulate = Color(0.6, 1.0, 0.65) if selected_target != "" and not player_ready and phase == "intent" else Color.WHITE
	_refresh_step()
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


## Le pas à faire maintenant, en gros, au-dessus de tout le reste.
func _refresh_step() -> void:
	var color := Color.WHITE
	if phase == "resolve":
		step_label.text = "Le tour se joue… (touche pour accélérer)"
		color = Color(0.75, 0.8, 0.95)
	elif not _player().is_alive():
		step_label.text = "Tu es KO : %s continue seul" % acolyte_name
		color = Color(0.75, 0.8, 0.95)
	elif player_ready:
		step_label.text = "Validé : le tour commence"
		color = Color("51cf66")
	elif selected_tier == "":
		step_label.text = "1. Choisis une compétence"
	elif selected_target == "":
		step_label.text = "2. Touche une cible (elles clignotent)"
		color = GOLD
	else:
		step_label.text = "3. Appuie sur Prêt (ou attends %d s)" % int(ceil(time_left))
		color = Color("51cf66")
	step_label.add_theme_color_override("font_color", color)


## L'encadré des Synergies : prête, possible (quel bouton jouer et ce que ça fait), au prochain tour, ou vos Synergies.
func _refresh_synergy_panel() -> void:
	var ready := _ready_synergy()
	var kind := "off"
	var title := ""
	var text := ""
	if phase == "intent" and not ready.is_empty():
		kind = "gold"
		title = "SYNERGIE PRÊTE : %s !" % ready["name"]
		text = "Elle se déclenche ce tour-ci. %s" % data.synergy_description(ready)
	elif phase == "intent" and not synergy_options.is_empty():
		kind = "gold"
		var option: Dictionary = synergy_options.get(selected_tier, synergy_options.values()[0])
		var how := "Joue %s (bouton doré)" % data.skill_name(option["skill_id"])
		if option["targets"].size() < combat.valid_targets(_player(), option["skill_id"]).size():
			how += " sur %s" % _names(option["targets"])
		title = "SYNERGIE POSSIBLE : %s" % option["synergy"]["name"]
		text = "%s, avec %s de %s. %s" % [how, data.skill_name(option["acolyte_skill"]), acolyte_name, data.synergy_description(option["synergy"])]
	elif phase == "intent" and announce.has("waiting"):
		kind = "acolyte"
		var waiting: Dictionary = announce["waiting"]
		title = "AU PROCHAIN TOUR : SYNERGIE %s" % str(waiting["synergy"]["name"]).to_upper()
		text = "%s garde sa forte. Ta %s revient au prochain tour : joue-la avec elle." % [acolyte_name, data.skill_name(waiting["skill_id"])]
	else:
		title = "Pas de Synergie ce tour-ci"
		text = _duo_synergies_text()
	synergy_panel.add_theme_stylebox_override("panel", _card_style(kind))
	synergy_title.text = title
	synergy_title.add_theme_color_override("font_color", GOLD if kind == "gold" else (ACOLYTE_BLUE if kind == "acolyte" else Color(0.6, 0.65, 0.8)))
	synergy_text.text = text


## Pendant la résolution, l'encadré rappelle ton choix et la Synergie qu'il doit déclencher.
func _show_my_choice() -> void:
	var mine := _player_action()
	var ready := _ready_synergy()
	synergy_panel.add_theme_stylebox_override("panel", _card_style("gold" if not ready.is_empty() else "off"))
	synergy_title.add_theme_color_override("font_color", GOLD if not ready.is_empty() else Color(0.6, 0.65, 0.8))
	synergy_title.text = "TON CHOIX : %s %s" % [data.skill_name(mine.skill_id), _target_phrase(mine)] if mine != null else "TON CHOIX : ta basique"
	synergy_text.text = "Avec %s de %s : Synergie %s !" % [data.skill_name(announce["action"].skill_id), acolyte_name, ready["name"]] if not ready.is_empty() else ""


## La Synergie que ton choix déclencherait avec l'annonce de l'acolyte (vide sinon).
func _ready_synergy() -> Dictionary:
	var mine := _player_action()
	var aco_action: CombatAction = announce.get("action")
	if mine == null or aco_action == null:
		return {}
	var synergy := data.find_synergy(mine.skill_id, aco_action.skill_id)
	if synergy.is_empty() or (bool(synergy.get("same_target", false)) and mine.target_id != aco_action.target_id):
		return {}
	return synergy


## Les Synergies de ton duo, pour les apprendre : « Bastion = Rempart (toi) + Prière (Saule) ».
func _duo_synergies_text() -> String:
	var player := _player()
	var aco := _acolyte()
	if aco == null:
		return ""
	var parts: Array = []
	for tier in CombatUnit.TIERS:
		for aco_tier in CombatUnit.TIERS:
			var synergy := data.find_synergy(player.skills[tier], aco.skills[aco_tier])
			if not synergy.is_empty():
				parts.append("%s = %s (toi) + %s (%s)" % [synergy["name"], data.skill_name(player.skills[tier]), data.skill_name(aco.skills[aco_tier]), acolyte_name])
	if parts.is_empty():
		return "Ton duo n'a pas de Synergie."
	return "Vos Synergies : " + " · ".join(parts)


## Un bouton de compétence : bordé d'or quand il déclenche une Synergie, éclairé quand il est choisi.
func _style_skill_button(button: Button, selected: bool, hot: bool) -> void:
	for state in ["normal", "hover", "pressed", "focus"]:
		button.remove_theme_stylebox_override(state)
	button.remove_theme_color_override("font_color")
	if button.disabled:
		return
	if not hot and not selected:
		return
	var style := StyleBoxFlat.new()
	style.set_corner_radius_all(10)
	style.set_content_margin_all(6)
	style.bg_color = Color("6b5410") if hot else Color("2f4f86")
	style.border_color = GOLD if hot else Color.WHITE
	style.set_border_width_all(4 if selected else 3)
	if hot and selected:
		style.bg_color = Color("8a6a12")
		style.border_color = Color.WHITE
	for state in ["normal", "hover", "pressed", "focus"]:
		button.add_theme_stylebox_override(state, style)
	button.add_theme_color_override("font_color", Color("fff3bf") if hot else Color.WHITE)


## Les Intentions de ton duo : bulle au-dessus de chacun, trait vers sa cible, lien doré si une Synergie est possible.
func _refresh_intents() -> void:
	overlay.links = []
	for view in views.values():
		if view.team == 0:
			view.intent_text = ""
			view.intent_star = false
			view.aura = 0
	var mine := _player_action()
	var aco_action: CombatAction = announce.get("action")
	var ready := not _ready_synergy().is_empty()
	if mine != null:
		views[player_id].intent_text = data.skill_name(mine.skill_id)
		views[player_id].intent_alpha = 0.75
		_add_intent_links(mine, Color(1, 1, 1, 0.55), ready)
	if aco_action != null:
		var aco_view: UnitView = views[acolyte_id]
		aco_view.intent_text = data.skill_name(aco_action.skill_id)
		aco_view.intent_star = announce.has("waiting")
		aco_view.intent_alpha = 0.6
		_add_intent_links(aco_action, Color(0.6, 0.8, 1.0, 0.55), ready)
	# Une Synergie possible : ton acolyte brille en doré ; prête : vous brillez tous les deux.
	if ready or not synergy_options.is_empty():
		overlay.links.append({"from": views[player_id], "to": views[acolyte_id], "bond": true, "ready": ready})
		views[acolyte_id].aura = 2 if ready else 1
		if ready:
			views[player_id].aura = 2
	_refresh_story()


func _add_intent_links(action: CombatAction, color: Color, synergy: bool) -> void:
	var view: UnitView = views[action.actor_id]
	var skill_target := str(data.skill(action.skill_id).get("target"))
	if skill_target in ["enemies_all", "allies_all", "enemies_2"]:
		for target in combat.valid_targets(combat.get_unit(action.actor_id), action.skill_id):
			overlay.links.append({"from": view, "to": views[target.id], "color": color, "synergy": synergy})
	else:
		overlay.links.append({"from": view, "to": views[action.target_id], "color": color, "synergy": synergy})


## Pourquoi l'acolyte joue ce coup (la règle de son rôle qui a décidé), en quelques mots.
func _announce_reason() -> String:
	var action: CombatAction = announce.get("action")
	if action == null:
		return ""
	var reasons: Dictionary = data.ai.get("reasons", {})
	var rule := str(announce.get("rule", ""))
	var reason := str(reasons.get(rule, "")) if rule != "basique" or combat.is_hostile(action.skill_id) else ""
	return reason.left(1).to_upper() + reason.substr(1) if reason != "" else ""


func _target_phrase(action: CombatAction) -> String:
	match str(data.skill(action.skill_id).get("target")):
		"enemies_all", "enemies_2":
			return "sur les monstres" if mode == "tour" else "sur le duo adverse"
		"allies_all":
			return "sur votre duo"
		"self":
			return "sur toi" if action.actor_id == player_id else "sur lui"
	if action.target_id == player_id:
		return "sur toi"
	if action.target_id == action.actor_id:
		return "sur lui"
	return "sur " + _short_name(action.target_id)


## Comment joue ton acolyte, en clair : les règles de son rôle et la règle d'attente pour les Synergies.
func _acolyte_rules_text() -> String:
	return "%s joue seul : %s %s" % [acolyte_name, data.acolyte_rules(str(acolyte.get("class_id", ""))), str(data.ai.get("synergy_wait", ""))]


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
		# Exactement ce qu'il a annoncé au début du tour.
		var told: CombatAction = announce.get("action")
		actions.append(told if told != null else CombatAI.decide_acolyte(combat, aco)["action"])
	# Le duo adverse : l'annonce de son acolyte, puis le choix de son joueur IA. Tu ne vois rien avant la révélation.
	actions.append_array(CombatAI.choose_team(combat, 1))
	_refresh_skill_buttons()
	var events := combat.resolve_turn(actions)
	_play_events(events)


func _play_events(events: Array) -> void:
	overlay.links = []
	action_index = 0
	action_count = 0
	_refresh_step()
	_show_my_choice()
	for view in views.values():
		view.targetable = false
		view.selected_target = false
		view.synergy_mark = false
		view.preview_text = ""
		view.threat_text = ""
		view.aura = 0
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
			action_count = event["actions"].size()
			story_note = ""
			story_results = []
			_set_story("TOUT LE MONDE A CHOISI", "%d actions ce tour-ci" % action_count, "Elles se jouent de la plus rapide à la plus lente (le numéro sur chaque perso).")
			await _wait(1.3)
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
				target_text = " sur " + _names(targets)
			action_index += 1
			var actor_unit := combat.get_unit(event["actor"])
			var kind := "acolyte" if actor_unit.team == 0 else "enemy"
			story_note = "Provoqué : il doit frapper celui qui l'a provoqué !" if event.get("redirected", false) else ""
			story_results = []
			_set_story("ACTION %d SUR %d" % [action_index, maxi(action_count, action_index)], "%s : %s%s" % [_short_name(event["actor"]), data.skill_name(event["skill"]), target_text], story_note, kind)
			await _wait(0.7)
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
			_add_story_result("%s -%d" % [_short_name(event["target"]), amount])
			await _wait(0.3)
		"heal":
			if int(event["amount"]) > 0:
				var view: UnitView = views[event["target"]]
				view.set_hp(int(event["hp"]))
				view.float_text("+%d" % int(event["amount"]), Color("51cf66"), str(event["kind"]) == "synergie")
				sfx.play("soin", randf_range(0.95, 1.05), -4.0)
				var healer := str(event.get("source", ""))
				if stats.has(healer):
					stats[healer]["heal"] += int(event["amount"])
				_add_story_result("%s +%d" % [_short_name(event["target"]), int(event["amount"])])
				await _wait(0.28)
		"absorbed":
			views[event["target"]].float_text("Bloqué", ACOLYTE_BLUE)
			sfx.play("bloque")
			_add_story_result("%s : coup bloqué" % _short_name(event["target"]))
			await _wait(0.25)
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
			_add_story_result("%s est KO !" % _short_name(event["target"]))
			sfx.play("ko")
			_shake(9.0)
			_flash(Color(1, 0.3, 0.3), 0.25)
			await _wait(0.6)
		"revive":
			var view: UnitView = views[event["target"]]
			view.set_hp(int(event["hp"]))
			view.float_text("Relevé !", Color("51cf66"), true)
			_add_story_result("%s est relevé !" % _short_name(event["target"]))
			sfx.play("releve")
			_flash(Color(0.5, 1, 0.6), 0.3)
			await _wait(0.6)
		"action_lost":
			story_note = "Tombé avant d'agir : son action est perdue."
			story_results = []
			_set_story("ACTION PERDUE", "%s est KO" % _short_name(event["actor"]), story_note, "off")
			await _wait(0.4)
		"synergy":
			# Ta Synergie : grande annonce dorée et son effet. Celle d'en face : en rouge, pour qu'on ne confonde jamais.
			var ours: bool = combat.get_unit(str(event["actors"][0])).team == 0
			var synergy := {}
			for candidate in data.synergies:
				if candidate["name"] == event["name"]:
					synergy = candidate
			if ours:
				synergies_fired += 1
				story_note = data.synergy_description(synergy)
				story_results = []
				_set_story("SYNERGIE DE TON DUO !", str(event["name"]), story_note, "gold")
				_show_cutin("SYNERGIE !\n" + str(event["name"]), GOLD, 1.0)
				_flash(GOLD, 0.4)
			else:
				story_note = data.synergy_description(synergy)
				story_results = []
				_set_story("SYNERGIE DU DUO ADVERSE", str(event["name"]), story_note, "enemy")
				_show_cutin("Synergie adverse\n" + str(event["name"]), Color("ff8787"))
				_flash(Color("ff6b6b"), 0.25)
			for unit_id in event["actors"]:
				views[unit_id].aura = 2 if ours else 0
				views[unit_id].do_announce()
			sfx.play("synergie")
			_shake(7.0)
			await _wait(1.4)
			for unit_id in event["actors"]:
				views[unit_id].aura = 0
		"cooldown_reduced":
			views[event["target"]].float_text("Recharge -%d" % int(event["amount"]), ACOLYTE_BLUE)
		"turn_end":
			await _wait(0.4)


## Ce que l'action en cours a fait, ajouté sous elle dans la carte du milieu (« Toi -38 · Saule -20 »).
func _add_story_result(text: String) -> void:
	story_results.append(text)
	var results := " · ".join(story_results)
	story_sub.text = results if story_note == "" else "%s\n%s" % [story_note, results]


func _short_name(unit_id: String) -> String:
	var unit := combat.get_unit(unit_id)
	if unit.is_player:
		return "Toi"
	return unit.display_name


func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds / speed).timeout


## Pendant la résolution, toucher l'écran accélère l'animation du tour.
func _input(event: InputEvent) -> void:
	if phase == "resolve" and tip_layer == null and event is InputEventMouseButton and event.pressed:
		speed = 3.0
		step_label.text = "Accéléré"


# ---------------------------------------------------------------------------
# Aide : bulles du premier combat (une fois chacune) et bouton « ? »
# ---------------------------------------------------------------------------

## Les bulles d'aide, au bon moment, une seule fois chacune (gardées sur l'appareil). Le chrono est en pause.
func _maybe_show_tips() -> void:
	if phase != "intent" or tip_layer != null or not _player().is_alive():
		return
	var aco := _acolyte()
	if not profile.tips_seen.has("annonce") and aco != null and aco.is_alive():
		_show_tip("annonce", "bottom", "Ton acolyte annonce son coup", "Au début de chaque tour, %s choisit son coup tout seul et te l'annonce : regarde la carte bleue au milieu, et la bulle au-dessus de lui. Tu choisis ensuite le tien en le sachant." % acolyte_name)
	elif not profile.tips_seen.has("choix"):
		_show_tip("choix", "top", "À toi de jouer", "En bas, la ligne blanche te dit quoi faire :\n1. touche une compétence,\n2. touche une cible (elles clignotent),\n3. appuie sur Prêt.\nSans choix au bout de %d secondes, tu fais ta basique." % int(INTENT_SECONDS))
	elif not profile.tips_seen.has("synergie") and (not synergy_options.is_empty() or announce.has("waiting")):
		_show_tip("synergie", "top", "Une Synergie !", "Quand un bouton est bordé d'or et que %s brille, joue cette compétence ce tour-ci : avec son coup, elle déclenche un effet bonus. L'encadré doré te dit laquelle et ce qu'elle fait." % acolyte_name)
	elif mode == "tour" and not profile.tips_seen.has("tour"):
		_show_tip("tour", "bottom", "La Tour", "Tu affrontes des monstres : touche-en un pour voir ce qu'il sait faire. Entre deux étages, tu ne récupères que %d %% de tes PV : économise-toi." % int(round(float(data.tower.get("heal_between_floors", 0.2)) * 100.0)))


func _show_tip(key: String, place: String, title: String, text: String) -> void:
	_open_tip(title, text, place, func():
		profile.tips_seen[key] = true
		profile.save()
		_maybe_show_tips())


## Le bouton « ? » : comment se joue un tour, en clair. Le chrono est en pause pendant la lecture.
func _show_help() -> void:
	if tip_layer != null:
		return
	sfx.play("clic")
	var lines := [
		"Chaque tour, %s annonce son coup en premier (carte bleue au milieu). Il joue seul, selon son rôle." % acolyte_name,
		"Toi : 1. une compétence, 2. une cible, 3. Prêt. Tout le monde agit ensuite, du plus rapide au plus lent.",
		"Synergie : un bouton bordé d'or, joué en même temps que le coup de %s, déclenche un bonus. L'encadré doré te dit lequel." % acolyte_name,
		"Recharges : sur chaque perso, M (moyenne) et F (forte). Vert = prête, un chiffre = tours restants. La forte n'arrive qu'au tour 3.",
		"Touche n'importe quel perso pour voir ce qu'il sait faire.",
	]
	_open_tip("Comment jouer", "\n\n".join(lines), "center", func(): pass)


## place : « top » ou « bottom » pour laisser voir ce que la bulle explique, « center » sinon.
func _open_tip(title: String, text: String, place: String, on_close: Callable) -> void:
	tip_layer = ColorRect.new()
	(tip_layer as ColorRect).color = Color(0.03, 0.04, 0.08, 0.45)
	tip_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	tip_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(tip_layer)
	var column := VBoxContainer.new()
	column.set_anchors_preset(Control.PRESET_FULL_RECT)
	column.offset_top = 60
	column.offset_bottom = -12
	column.alignment = {"top": BoxContainer.ALIGNMENT_BEGIN, "bottom": BoxContainer.ALIGNMENT_END}.get(place, BoxContainer.ALIGNMENT_CENTER)
	tip_layer.add_child(column)
	var center := CenterContainer.new()
	column.add_child(center)
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(470, 0)
	var style := _card_style("gold")
	style.bg_color = Color("1f2538")
	style.set_content_margin_all(18)
	card.add_theme_stylebox_override("panel", style)
	center.add_child(card)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	card.add_child(box)
	var head := _story_label(26, GOLD)
	head.text = title
	box.add_child(head)
	var body := _story_label(18, Color.WHITE)
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	body.text = text
	box.add_child(body)
	var ok := Button.new()
	ok.text = "Compris"
	ok.custom_minimum_size = Vector2(0, 58)
	ok.add_theme_font_size_override("font_size", 22)
	ok.pressed.connect(func():
		sfx.play("clic")
		tip_layer.queue_free()
		tip_layer = null
		on_close.call())
	box.add_child(ok)


# ---------------------------------------------------------------------------
# Fin de combat
# ---------------------------------------------------------------------------

func _show_end() -> void:
	if mode == "tour":
		_show_floor_end()
		return
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
	again.pressed.connect(func(): app.show_screen("versus"))
	box.add_child(again)
	var change := Button.new()
	change.text = "Retour à l'accueil"
	change.custom_minimum_size = Vector2(0, 54)
	change.pressed.connect(func(): app.show_screen("home"))
	box.add_child(change)
