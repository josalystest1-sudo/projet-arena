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
const SIDE_WIDTH := 150.0
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
var enemy_side: VBoxContainer
var acolyte_title: Label
var acolyte_info: Label
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
var quit_button: Button
var _quit_armed := false
var synergy_labels: Dictionary = {}


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

	# Le duo adverse en haut : son nom à gauche, puis son acolyte et son joueur.
	var enemy_row := HBoxContainer.new()
	enemy_row.alignment = BoxContainer.ALIGNMENT_CENTER
	enemy_row.add_theme_constant_override("separation", 8)
	root.add_child(enemy_row)
	enemy_side = VBoxContainer.new()
	enemy_side.custom_minimum_size = Vector2(SIDE_WIDTH, 0)
	enemy_side.alignment = BoxContainer.ALIGNMENT_CENTER
	enemy_row.add_child(enemy_side)
	enemy_side.add_child(_side_label("Duo adverse", 16, Color("ff8787")))
	enemy_side.add_child(_side_label("Duo IA", 14, Color(0.8, 0.82, 0.9)))
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

	# Ton duo : à gauche, ton acolyte qui joue seul (et ce qu'il prépare), puis ton acolyte et toi.
	var ally_row := HBoxContainer.new()
	ally_row.alignment = BoxContainer.ALIGNMENT_CENTER
	ally_row.add_theme_constant_override("separation", 8)
	root.add_child(ally_row)
	var acolyte_panel := VBoxContainer.new()
	acolyte_panel.custom_minimum_size = Vector2(SIDE_WIDTH, 0)
	acolyte_panel.alignment = BoxContainer.ALIGNMENT_CENTER
	acolyte_panel.add_theme_constant_override("separation", 4)
	ally_row.add_child(acolyte_panel)
	acolyte_title = _side_label("", 16, ACOLYTE_BLUE)
	acolyte_panel.add_child(acolyte_title)
	acolyte_info = _side_label("", 14, Color(0.8, 0.82, 0.9))
	acolyte_info.custom_minimum_size = Vector2(SIDE_WIDTH, 80)
	acolyte_panel.add_child(acolyte_info)
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
	enemy_side.visible = mode == "pvp"
	var order: Array = []
	order.append_array(enemies)
	order.append(combat.acolyte_of(0))
	order.append(combat.leader_of(0))
	for unit in order:
		var view := UnitView.new()
		view.setup(unit)
		view.subtitle = data.class_name_of(unit.class_id)
		view.tapped.connect(_on_unit_tapped)
		(ally_units if unit.team == 0 else enemy_units).add_child(view)
		views[unit.id] = view
		view.sync(unit, data)
		stats[unit.id] = {"damage": 0, "heal": 0, "kos": 0}


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
	combat = tower.create_combat(rng)
	_setup_views(combat.team_units(1))
	if tower.is_boss_floor():
		_show_cutin("ÉTAGE %d : GARDIEN" % tower.current_floor, Color("ffa94d"))
	else:
		_show_cutin("ÉTAGE %d" % tower.current_floor, GOLD)
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
		box.add_child(_label("Étage %d : %d ennemis%s" % [next, int(tower.floor_info()["enemies"]), ", dont un Gardien" if tower.is_boss_floor() else ""], 17, Color("ffa94d")))
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
	banner.text = ""
	if mode == "tour":
		sudden_label.text = "La Tour — étage %d sur %d  ·  record : %d" % [tower.current_floor, tower.floor_count(), int(profile.tower_records.get(player_class, 0))]
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
	_refresh_acolyte_panel()
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
		skill_info.text += " " + _acolyte_rules_text()


func _on_ready_pressed() -> void:
	if phase != "intent":
		return
	player_ready = true
	sfx.play("clic", 0.8)
	_refresh_skill_buttons()


## La colonne de ton acolyte : il joue seul ; s'il garde sa forte pour une Synergie, il le dit.
func _refresh_acolyte_panel() -> void:
	var aco := _acolyte()
	if aco != null and not aco.is_alive():
		acolyte_title.text = "%s est KO" % acolyte_name
		acolyte_info.text = ""
		return
	acolyte_title.text = acolyte_name
	var waiting: Dictionary = announce.get("waiting", {})
	if not waiting.is_empty():
		acolyte_info.text = "Garde sa forte pour la Synergie %s au prochain tour" % waiting["synergy"]["name"]
	elif str(announce.get("rule", "")) == "avec_toi":
		acolyte_info.text = "Joue la forte qu'il gardait : à toi de jouer la Synergie"
	else:
		acolyte_info.text = "Joue seul selon son rôle (%s)" % ROLE_LABELS.get(Duo.main_role(data, acolyte.get("class_id", "")), "")


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
		elif phase == "intent" and str(announce.get("waiting", {}).get("skill_id", "")) == skill_id:
			hint = "Au prochain tour : Synergie %s avec %s" % [announce["waiting"]["synergy"]["name"], acolyte_name]
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
	passive_info.text = "Ton passif : %s — %s" % [data.passive_name(player.passive), data.passive_description(player.passive)]
	if selected_tier != "":
		var skill := data.skill(player.skills[selected_tier])
		skill_info.text = "%s : %s" % [skill["name"], data.skill_description(player.skills[selected_tier])]
	elif not player.is_alive():
		skill_info.text = "%s continue seul." % acolyte_name
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
		aco_view.intent_star = announce.has("waiting")
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


## L'annonce de l'acolyte en une phrase : ce qu'il fait, sur qui, et la règle qui l'a décidé.
func _announce_sentence() -> String:
	var aco := _acolyte()
	if aco == null or not aco.is_alive():
		return "%s est KO : à toi de jouer seul." % acolyte_name if _player().is_alive() else ""
	var action: CombatAction = announce.get("action")
	if action == null:
		return ""
	var sentence := "%s : %s %s" % [acolyte_name, data.skill_name(action.skill_id), _target_phrase(action)]
	var reasons: Dictionary = data.ai.get("reasons", {})
	var rule := str(announce.get("rule", ""))
	var reason := str(reasons.get(rule, "")) if rule != "basique" or combat.is_hostile(action.skill_id) else ""
	if announce.has("waiting"):
		var waiting: Dictionary = announce["waiting"]
		reason = str(reasons.get("attend_synergie", "")).replace("{synergy}", str(waiting["synergy"]["name"])).replace("{skill}", data.skill_name(waiting["skill_id"]))
	if reason != "":
		sentence += " — " + reason
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
	_refresh_acolyte_panel()
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
