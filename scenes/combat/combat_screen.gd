## Écran de combat du prototype : le joueur contre 5 IA (2 alliés, 3 ennemis).
## Toute la règle vit dans le moteur (res://engine) ; cet écran affiche, collecte les choix et anime les événements.
extends Control

const INTENT_SECONDS := 12.0
const KO_PLAYER_SECONDS := 3.0
const CLASS_ORDER := ["guerrier", "mage", "pretre"]
const ROLE_LABELS := {"front": "Front", "degats": "Dégâts", "soutien": "Soutien"}
const TIER_LABELS := {"basique": "Basique", "moyenne": "Moyenne", "forte": "Forte"}
const ENEMY_NAMES := ["Ombre", "Brume", "Cendre", "Givre", "Ronce", "Écume"]
const ALLY_NAMES := ["Lys", "Orme", "Saule", "Iris", "Cèdre", "Aube"]
const BG_COLOR := Color("141826")
const PANEL_COLOR := Color("1f2538")

var data: CombatData
var combat: Combat
var rng := RandomNumberGenerator.new()

var player_class: String = "guerrier"
var player_picks: Dictionary = {}
var player_id: String = "a1"

# État de la phase d'Intention.
var phase: String = "menu"   # menu, intent, resolve, end
var time_left: float = 0.0
var selected_tier: String = ""
var selected_target: String = ""
var player_ready: bool = false
## unit_id -> CombatAction (Intentions des alliés, visibles du joueur)
var ally_intents: Dictionary = {}
## unit_id -> secondes avant que l'allié IA ne (re)décide
var ally_think: Dictionary = {}
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
var enemy_row: HBoxContainer
var ally_row: HBoxContainer
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
	rng.randomize()
	data = CombatData.load_default()
	profile = PlayerProfile.load_profile()
	sfx = Sfx.new()
	add_child(sfx)
	sfx.muted = profile.muted
	theme = _make_theme()
	_build_layout()
	_show_menu()


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

	# Barre du haut : tour, timer, mort subite.
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

	# Ennemis en haut.
	enemy_row = HBoxContainer.new()
	enemy_row.alignment = BoxContainer.ALIGNMENT_CENTER
	enemy_row.add_theme_constant_override("separation", 6)
	root.add_child(enemy_row)

	# Zone centrale : bannière (Synergies, résultat) et journal.
	var middle := VBoxContainer.new()
	middle.size_flags_vertical = Control.SIZE_EXPAND_FILL
	middle.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_child(middle)
	banner = Label.new()
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.add_theme_font_size_override("font_size", 26)
	banner.add_theme_color_override("font_color", Color("ffd43b"))
	banner.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	middle.add_child(banner)
	log_label = Label.new()
	log_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	log_label.add_theme_font_size_override("font_size", 18)
	log_label.add_theme_color_override("font_color", Color(0.85, 0.87, 0.95))
	middle.add_child(log_label)

	# Alliés au milieu.
	ally_row = HBoxContainer.new()
	ally_row.alignment = BoxContainer.ALIGNMENT_CENTER
	ally_row.add_theme_constant_override("separation", 6)
	root.add_child(ally_row)

	# Bas : les 3 compétences, puis l'aide au choix de cible.
	bottom_panel = PanelContainer.new()
	root.add_child(bottom_panel)
	var bottom := VBoxContainer.new()
	bottom.add_theme_constant_override("separation", 6)
	bottom_panel.add_child(bottom)
	skill_info = Label.new()
	skill_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	skill_info.add_theme_font_size_override("font_size", 17)
	skill_info.custom_minimum_size = Vector2(0, 48)
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
		button.custom_minimum_size = Vector2(0, 88)
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.add_theme_font_size_override("font_size", 18)
		button.pressed.connect(_on_skill_pressed.bind(tier))
		column.add_child(button)
		skill_buttons[tier] = button
		var synergy_label := Label.new()
		synergy_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		synergy_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		synergy_label.custom_minimum_size = Vector2(0, 20)
		synergy_label.add_theme_font_size_override("font_size", 13)
		synergy_label.add_theme_color_override("font_color", Color("ffd43b"))
		column.add_child(synergy_label)
		synergy_labels[tier] = synergy_label
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	bottom.add_child(row)
	hint_label = Label.new()
	hint_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint_label.add_theme_font_size_override("font_size", 16)
	hint_label.add_theme_color_override("font_color", Color("ffd43b"))
	row.add_child(hint_label)
	ready_button = Button.new()
	ready_button.text = "Prêt"
	ready_button.custom_minimum_size = Vector2(110, 50)
	ready_button.pressed.connect(_on_ready_pressed)
	row.add_child(ready_button)
	passive_info = Label.new()
	passive_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	passive_info.add_theme_font_size_override("font_size", 15)
	passive_info.add_theme_color_override("font_color", Color(0.7, 0.75, 0.9))
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
# Menu : choix du personnage (prototype) et écran de fin
# ---------------------------------------------------------------------------

func _show_menu() -> void:
	phase = "menu"
	if menu_layer != null:
		menu_layer.queue_free()
	menu_layer = _make_layer()
	var box: VBoxContainer = menu_layer.get_meta("box")
	var title := _label("Projet Arena", 40, Color("ffd43b"))
	box.add_child(title)
	box.add_child(_label("Prototype de combat 3 contre 3", 20, Color(0.8, 0.85, 1)))
	if profile.wins + profile.losses > 0:
		box.add_child(_label("%d victoire%s · %d défaite%s · record : %d d'affilée" % [profile.wins, "s" if profile.wins > 1 else "", profile.losses, "s" if profile.losses > 1 else "", profile.best_streak], 17, Color(0.75, 0.9, 0.75)))
	box.add_child(_spacer(10))
	box.add_child(_label("Choisis ton personnage :", 22, Color.WHITE))
	for class_id in CLASS_ORDER:
		var cls: Dictionary = data.classes[class_id]
		var button := Button.new()
		var roles: Array = cls["roles"]
		button.text = "%s  ·  %s / %s\n%s" % [cls["name"], ROLE_LABELS[roles[0]], ROLE_LABELS[roles[1]], cls["identity"]]
		button.custom_minimum_size = Vector2(0, 86)
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.pressed.connect(_on_class_chosen.bind(class_id))
		box.add_child(button)


func _on_class_chosen(class_id: String) -> void:
	sfx.play("clic")
	player_class = class_id
	player_picks = CombatUnit.random_picks(rng)
	_show_kit()


func _show_kit() -> void:
	if menu_layer != null:
		menu_layer.queue_free()
	menu_layer = _make_layer()
	var box: VBoxContainer = menu_layer.get_meta("box")
	var cls: Dictionary = data.classes[player_class]
	box.add_child(_label(str(cls["name"]), 36, Color("ffd43b")))
	box.add_child(_label("Ton Destin (tiré au hasard) :", 20, Color(0.8, 0.85, 1)))
	for tier in CombatUnit.TIERS:
		var pool: Array = cls["skills"][tier]
		var skill_id: String = pool[int(player_picks[tier]) % pool.size()]
		var skill := data.skill(skill_id)
		box.add_child(_label("%s — %s\n%s" % [TIER_LABELS[tier], skill["name"], skill["description"]], 18, Color.WHITE))
	var passive_pool: Array = cls["passives"]
	var passive_id: String = passive_pool[int(player_picks["passive"]) % passive_pool.size()]
	box.add_child(_label("Passif — %s\n%s" % [data.passive_name(passive_id), data.passives[passive_id]["description"]], 18, Color(0.75, 0.9, 0.75)))
	box.add_child(_label("Astuce : sous tes boutons, une ligne dorée annonce une Synergie avec un allié. Jouez-la le même tour !", 15, Color("ffd43b")))
	box.add_child(_spacer(8))
	var fight := Button.new()
	fight.text = "Combattre"
	fight.custom_minimum_size = Vector2(0, 70)
	fight.add_theme_font_size_override("font_size", 28)
	fight.pressed.connect(_start_combat)
	box.add_child(fight)
	var reroll := Button.new()
	reroll.text = "Autre tirage (prototype seulement)"
	reroll.custom_minimum_size = Vector2(0, 50)
	reroll.pressed.connect(_on_class_chosen.bind(player_class))
	box.add_child(reroll)
	var back := Button.new()
	back.text = "Changer de classe"
	back.custom_minimum_size = Vector2(0, 50)
	back.pressed.connect(_show_menu)
	box.add_child(back)


func _make_layer() -> Control:
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
	box.add_theme_constant_override("separation", 12)
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
	# L'équipe du joueur a toujours un Front, un Dégâts et un Soutien (une classe de chaque).
	var ally_names := ALLY_NAMES.duplicate()
	var enemy_names := ENEMY_NAMES.duplicate()
	ally_names.shuffle()
	enemy_names.shuffle()
	var team_a: Array = []
	var team_b: Array = []
	for i in range(CLASS_ORDER.size()):
		var class_id: String = CLASS_ORDER[i]
		var cls_name: String = data.class_name_of(class_id)
		if class_id == player_class:
			team_a.append({"class_id": class_id, "picks": player_picks, "name": "Toi", "is_player": true})
		else:
			team_a.append({"class_id": class_id, "picks": CombatUnit.random_picks(rng), "name": "%s %s" % [cls_name, ally_names[i]]})
		team_b.append({"class_id": class_id, "picks": CombatUnit.random_picks(rng), "name": "%s %s" % [cls_name, enemy_names[i]]})
	combat = Combat.create(data, team_a, team_b, rng.randi_range(0, 1))
	for unit in combat.units:
		if unit.is_player:
			player_id = unit.id
			unit.display_name = data.class_name_of(unit.class_id)

	views = {}
	_clear_children(enemy_row)
	_clear_children(ally_row)
	for unit in combat.units:
		var view := UnitView.new()
		view.setup(unit)
		view.tapped.connect(_on_unit_tapped)
		(ally_row if unit.team == 0 else enemy_row).add_child(view)
		views[unit.id] = view
		view.sync(unit, data)
		stats[unit.id] = {"damage": 0, "heal": 0, "kos": 0}
	_begin_intent_phase()


func _player() -> CombatUnit:
	return combat.get_unit(player_id)


# ---------------------------------------------------------------------------
# Phase d'Intention (12 s)
# ---------------------------------------------------------------------------

func _begin_intent_phase() -> void:
	phase = "intent"
	var player := _player()
	time_left = INTENT_SECONDS if player.is_alive() else KO_PLAYER_SECONDS
	selected_tier = ""
	selected_target = ""
	player_ready = false
	ally_intents = {}
	ally_think = {}
	for ally in combat.team_units(0, true):
		if ally.id != player_id:
			ally_think[ally.id] = rng.randf_range(0.6, 2.5) if player.is_alive() else rng.randf_range(0.3, 1.2)
	speed = 1.0
	last_tick = -1
	for view in views.values():
		view.intent_text = ""
		view.order_badge = 0
		view.selected_target = false
		view.targetable = false
		view.preview_text = ""
		view.sync(combat.get_unit(view.unit_id), data)
		# Anticipation : on voit quand la forte d'un ennemi est prête (pas ce qu'il va jouer).
		var unit := combat.get_unit(view.unit_id)
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
	if player.is_alive():
		log_label.text = "Choisis une compétence, puis une cible."
	else:
		log_label.text = "Tu es KO. Tes alliés continuent le combat…"
	bottom_panel.modulate = Color(1, 1, 1, 1 if player.is_alive() else 0.45)
	_refresh_skill_buttons()
	_refresh_intents()


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
	# Les alliés IA décident (ou ajustent) leur Intention en voyant les autres.
	for ally_id in ally_think.keys():
		ally_think[ally_id] = float(ally_think[ally_id]) - delta
		if float(ally_think[ally_id]) <= 0.0:
			ally_think.erase(ally_id)
			_ally_decide(ally_id)
	var everyone_decided := ally_think.is_empty() and ally_intents.size() == combat.team_units(0, true).size() - (1 if _player().is_alive() else 0)
	if time_left <= 0.0 or (player_ready and everyone_decided) or (not _player().is_alive() and everyone_decided and time_left <= KO_PLAYER_SECONDS - 1.5):
		_submit_turn()


func _ally_decide(ally_id: String) -> void:
	var unit := combat.get_unit(ally_id)
	if unit == null or not unit.is_alive():
		return
	var known: Array = []
	var mine := _player_action()
	if mine != null:
		known.append(mine)
	for other_id in ally_intents.keys():
		if other_id != ally_id:
			known.append(ally_intents[other_id])
	var choice := CombatAI.choose(combat, unit, known)
	var previous: CombatAction = ally_intents.get(ally_id)
	ally_intents[ally_id] = choice
	if previous != null and (previous.skill_id != choice.skill_id or previous.target_id != choice.target_id):
		views[ally_id].float_text("Ajuste", Color("9ad1ff"))
	_refresh_intents()
	if phase == "intent":
		_refresh_skill_buttons()


## Les alliés qui ont déjà décidé revoient leur choix peu après un changement d'Intention.
func _allies_reconsider(except_id: String = "") -> void:
	for ally_id in ally_intents.keys():
		if ally_id != except_id and not ally_think.has(ally_id):
			ally_think[ally_id] = rng.randf_range(0.6, 1.4)


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
	_refresh_skill_buttons()
	_refresh_intents()
	if selected_target != "":
		_allies_reconsider()


func _on_unit_tapped(unit_id: String) -> void:
	if phase != "intent":
		return
	if selected_tier == "":
		_show_unit_info(unit_id)
		return
	var player := _player()
	var skill_id: String = player.skills[selected_tier]
	var target := combat.get_unit(unit_id)
	if not combat.valid_targets(player, skill_id).has(target):
		return
	selected_target = unit_id
	player_ready = false
	sfx.play("clic", 1.25)
	_refresh_skill_buttons()
	_refresh_intents()
	_allies_reconsider()


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


func _on_ready_pressed() -> void:
	if phase != "intent":
		return
	player_ready = true
	sfx.play("clic", 0.8)
	_refresh_skill_buttons()


func _refresh_skill_buttons() -> void:
	var player := _player()
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
		# Synergies : avec quel allié cette compétence se combine, et s'il la prépare déjà.
		var hint := ""
		var hot := false
		for partner in combat.synergy_partners(player).get(tier, []):
			var intent: CombatAction = ally_intents.get(partner["ally_id"])
			if intent != null and intent.skill_id == partner["skill_id"] and combat.can_use(player, tier):
				var synergy := data.find_synergy(skill_id, partner["skill_id"])
				var ally_name: String = _short_name(partner["ally_id"]).split(" ")[0]
				if bool(synergy.get("same_target", false)):
					hint = "%s prépare %s : vise %s !" % [ally_name, data.skill_name(partner["skill_id"]), _short_name(intent.target_id)]
				else:
					hint = "%s prépare %s !" % [ally_name, data.skill_name(partner["skill_id"])]
				hot = true
				break
			hint = "Synergie : %s" % data.skill_name(partner["skill_id"])
		var synergy_label: Label = synergy_labels[tier]
		synergy_label.text = hint
		synergy_label.add_theme_color_override("font_color", Color("ffd43b") if hot else Color(1, 0.83, 0.23, 0.6))
		if hot and not button.disabled and tier != selected_tier:
			button.modulate = Color(1.0, 0.95, 0.7)
	passive_info.text = "Passif : %s — %s" % [data.passive_name(player.passive), data.passives[player.passive]["description"]]
	if selected_tier != "":
		var skill := data.skill(player.skills[selected_tier])
		skill_info.text = "%s : %s" % [skill["name"], skill["description"]]
	else:
		skill_info.text = "Pas de choix à la fin du temps : ta basique sur la même cible qu'au tour précédent."
	ready_button.disabled = phase != "intent" or player_ready or not player.is_alive()
	ready_button.text = "Validé" if player_ready else "Prêt"
	if not player.is_alive():
		hint_label.text = ""
	elif selected_tier == "":
		hint_label.text = "1. Choisis une compétence"
	elif selected_target == "":
		hint_label.text = "2. Touche une cible (en surbrillance)"
	else:
		hint_label.text = "Intention prête. Tu peux encore changer."
		var target_unit := combat.get_unit(selected_target)
		var forecast := combat.preview(player, player.skills[selected_tier], target_unit)
		if forecast["lethal"]:
			hint_label.text = "Coup fatal si personne ne le soigne avant !"
	# Cibles possibles en surbrillance.
	var valid: Array = []
	if phase == "intent" and selected_tier != "" and player.is_alive():
		valid = combat.valid_targets(player, player.skills[selected_tier])
	for view in views.values():
		var unit := combat.get_unit(view.unit_id)
		view.targetable = valid.has(unit)
		view.selected_target = view.unit_id == selected_target and phase == "intent"
		view.preview_text = ""
		if view.targetable:
			var forecast := combat.preview(player, player.skills[selected_tier], unit)
			if forecast["revive"]:
				view.preview_text = "Relever"
				view.preview_color = Color("51cf66")
			elif forecast["blocked"]:
				view.preview_text = "Bloqué"
				view.preview_color = Color("9ad1ff")
			elif forecast["lethal"]:
				view.preview_text = "KO !"
				view.preview_color = Color("ff6b6b")
			elif int(forecast["damage"]) > 0:
				view.preview_text = "-%d" % int(forecast["damage"])
				view.preview_color = Color("ffa94d")
			elif int(forecast["heal"]) > 0:
				view.preview_text = "+%d" % int(forecast["heal"])
				view.preview_color = Color("51cf66")


## Les Intentions alliées : bulle translucide au-dessus de chaque allié et trait vers sa cible.
func _refresh_intents() -> void:
	var actions: Array = []
	var mine := _player_action()
	if mine != null:
		actions.append(mine)
	for action in ally_intents.values():
		actions.append(action)
	var synergy_pairs := combat.find_synergies(actions)
	var synergy_actors := {}
	var synergy_names: Array = []
	for pair in synergy_pairs:
		for actor_id in pair["actors"]:
			synergy_actors[actor_id] = true
		synergy_names.append(pair["synergy"]["name"])
	overlay.links = []
	for view in views.values():
		if view.team == 0:
			view.intent_text = ""
	for action in actions:
		var view: UnitView = views[action.actor_id]
		view.intent_text = data.skill_name(action.skill_id)
		view.intent_alpha = 0.75 if action.actor_id == player_id else 0.5
		var color := Color(1, 1, 1, 0.55) if action.actor_id == player_id else Color(0.6, 0.8, 1.0, 0.4)
		var skill_target := str(data.skill(action.skill_id).get("target"))
		if skill_target in ["enemies_all", "allies_all"]:
			for target in combat.valid_targets(combat.get_unit(action.actor_id), action.skill_id):
				overlay.links.append({"from": view, "to": views[target.id], "color": color, "synergy": synergy_actors.has(action.actor_id)})
		else:
			overlay.links.append({"from": view, "to": views[action.target_id], "color": color, "synergy": synergy_actors.has(action.actor_id)})
	for ally_id in ally_think.keys():
		if not ally_intents.has(ally_id):
			views[ally_id].intent_text = "…"
			views[ally_id].intent_alpha = 0.35
	banner.text = ("Synergie possible : " + ", ".join(synergy_names)) if not synergy_names.is_empty() else ""


# ---------------------------------------------------------------------------
# Résolution animée
# ---------------------------------------------------------------------------

func _submit_turn() -> void:
	phase = "resolve"
	timer_bar.value = 0
	timer_label.text = ""
	var actions: Array = []
	var mine := _player_action()
	if mine != null:
		actions.append(mine)
	for ally in combat.team_units(0, true):
		if ally.id == player_id:
			continue
		if not ally_intents.has(ally.id):
			_ally_decide(ally.id)
		if ally_intents.has(ally.id):
			actions.append(ally_intents[ally.id])
	# Les ennemis décident entre eux, sans voir nos Intentions.
	actions.append_array(CombatAI.choose_team(combat, 1))
	_refresh_skill_buttons()
	var events := combat.resolve_turn(actions)
	_play_events(events)


func _play_events(events: Array) -> void:
	overlay.links = []
	hint_label.text = "Touche l'écran pour accélérer"
	for view in views.values():
		view.targetable = false
		view.selected_target = false
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
				view.intent_alpha = 0.8
			log_label.text = "Révélation des Intentions"
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
				_show_cutin(data.skill_name(event["skill"]).to_upper() + " !", Color("ffa94d") if combat.get_unit(event["actor"]).team == 1 else Color("9ad1ff"))
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
			var big: bool = amount >= 45 or str(event["kind"]) == "synergie"
			view.set_hp(int(event["hp"]))
			view.do_hurt(1.6 if big else 1.0)
			var color := Color("ff6b6b")
			if event["kind"] == "dot":
				color = Color("ff9f43")
			elif event["kind"] == "synergie":
				color = Color("ffd43b")
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
				view.float_text("+%d" % int(event["amount"]), Color("51cf66"))
				sfx.play("soin", randf_range(0.95, 1.05), -4.0)
				var healer := str(event.get("source", ""))
				if stats.has(healer):
					stats[healer]["heal"] += int(event["amount"])
				await _wait(0.22)
		"absorbed":
			views[event["target"]].float_text("Bloqué", Color("9ad1ff"))
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
				views[unit_id].float_text("Synergie", Color("ffd43b"), true)
			sfx.play("synergie")
			_show_cutin("SYNERGIE !\n" + str(event["name"]), Color("ffd43b") if ours else Color("ff8787"))
			_flash(Color("ffd43b") if ours else Color("ff6b6b"), 0.35)
			_shake(7.0)
			await _wait(1.0)
		"cooldown_reduced":
			views[event["target"]].float_text("Recharge -%d" % int(event["amount"]), Color("9ad1ff"))
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
	box.add_child(_label("Victoire !" if won else "Défaite", 48, Color("ffd43b") if won else Color("ff6b6b")))
	var reason := "Toute l'équipe adverse est KO." if combat.end_reason == "ko" else "Fin forcée : l'équipe avec le plus de PV l'emporte (%d contre %d)." % [combat.team_total_hp(0), combat.team_total_hp(1)]
	if combat.end_reason == "ko" and not won:
		reason = "Toute ton équipe est KO."
	box.add_child(_label(reason, 20, Color.WHITE))
	box.add_child(_label("%d tours  ·  %d Synergie%s déclenchée%s par ton équipe" % [combat.turn, synergies_fired, "s" if synergies_fired > 1 else "", "s" if synergies_fired > 1 else ""], 18, Color(0.8, 0.85, 1)))
	# Ta part du combat, et le meilleur des 6.
	var mine: Dictionary = stats.get(player_id, {"damage": 0, "heal": 0, "kos": 0})
	box.add_child(_label("Toi : %d dégâts · %d soins · %d KO" % [mine["damage"], mine["heal"], mine["kos"]], 18, Color.WHITE))
	var best_id := player_id
	var best_score := -1.0
	for unit_id in stats:
		var score := float(stats[unit_id]["damage"]) + float(stats[unit_id]["heal"]) + 40.0 * float(stats[unit_id]["kos"])
		if score > best_score:
			best_score = score
			best_id = unit_id
	var best_text := "Meilleur du combat : toi !" if best_id == player_id else "Meilleur du combat : %s" % _short_name(best_id)
	box.add_child(_label(best_text, 18, Color("ffd43b") if best_id == player_id else Color(0.8, 0.85, 1)))
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
