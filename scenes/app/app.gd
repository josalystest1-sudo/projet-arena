## L'application : garde le profil et le duo du joueur, affiche un écran à la fois et la barre de navigation.
## Écrans du prototype (GDD, « Écrans et interface ») : création, rencontre de l'acolyte, Vitrine (accueil),
## Acolyte, Compétences, La Tour, Profil, Paramètres, face-à-face avant le combat, combat.
## Affichage et navigation seulement : toute la règle vit dans res://engine.
class_name ArenaApp
extends Control

const ACOLYTE_NAMES := ["Lys", "Orme", "Saule", "Iris", "Cèdre", "Aube", "Sorel", "Nima"]
const NAV_HEIGHT := 74.0
## Les onglets de la barre du bas : identifiant d'écran, texte.
const NAV := [["home", "Accueil"], ["acolyte", "Acolyte"], ["skills", "Compétences"], ["tower", "La Tour"], ["profile", "Profil"]]
const SCREENS := {
	"creation": preload("res://scenes/screens/creation_screen.gd"),
	"meet": preload("res://scenes/screens/meet_screen.gd"),
	"home": preload("res://scenes/screens/home_screen.gd"),
	"acolyte": preload("res://scenes/screens/acolyte_screen.gd"),
	"skills": preload("res://scenes/screens/skills_screen.gd"),
	"tower": preload("res://scenes/screens/tower_screen.gd"),
	"bestiaire": preload("res://scenes/screens/bestiary_screen.gd"),
	"profile": preload("res://scenes/screens/profile_screen.gd"),
	"settings": preload("res://scenes/screens/settings_screen.gd"),
	"destin": preload("res://scenes/screens/destin_screen.gd"),
	"versus": preload("res://scenes/screens/versus_screen.gd"),
	"combat": preload("res://scenes/combat/combat_screen.gd"),
}

var data: CombatData
var profile: PlayerProfile
var sfx: Sfx
var rng := RandomNumberGenerator.new()

# Le duo du joueur : un seul personnage et un seul acolyte par compte (GDD), gardés sur l'appareil.
var player_class: String = ""
var player_picks: Dictionary = {}
var acolyte: Dictionary = {}
var acolyte_name: String = ""
## Le Destin du joueur (l'arbre, regénéré depuis sa graine) et les nœuds pris ; le mini-Destin de l'acolyte (points placés seuls).
var destin: Dictionary = {}
var destin_taken: Array = []
var acolyte_destin: Dictionary = {}
var acolyte_taken: Array = []

var content: Control
var nav_bar: HBoxContainer
var nav_buttons: Dictionary = {}
var current: Control
var current_name: String = ""


func _ready() -> void:
	# Pour tester : une adresse terminée par ?graine=7 rejoue toujours les mêmes tirages.
	var test_seed := _seed_from_url()
	if test_seed != 0:
		rng.seed = test_seed
	else:
		rng.randomize()
	# Sur téléphone, un écran qui défile doit défiler au doigt, même quand le doigt part d'une carte ou d'un bouton.
	get_tree().node_added.connect(_let_scroll_through)
	data = CombatData.load_default()
	profile = PlayerProfile.load_profile()
	sfx = Sfx.new()
	add_child(sfx)
	sfx.muted = profile.muted
	theme = UiKit.make_theme()
	_build_layout()
	show_screen("home" if load_saved_duo() else "creation")


func _seed_from_url() -> int:
	if not OS.has_feature("web"):
		return 0
	var value := str(JavaScriptBridge.eval("new URLSearchParams(window.location.search).get('graine') || ''", true))
	return int(value) if value.is_valid_int() else 0


func _build_layout() -> void:
	var bg := ColorRect.new()
	bg.color = UiKit.BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	content = Control.new()
	content.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(content)
	var bar := PanelContainer.new()
	bar.anchor_left = 0.0
	bar.anchor_right = 1.0
	bar.anchor_top = 1.0
	bar.anchor_bottom = 1.0
	bar.offset_top = -NAV_HEIGHT
	var style := StyleBoxFlat.new()
	style.bg_color = Color("10131f")
	style.border_color = Color("2b3350")
	style.border_width_top = 2
	style.set_content_margin_all(6)
	bar.add_theme_stylebox_override("panel", style)
	add_child(bar)
	nav_bar = HBoxContainer.new()
	nav_bar.add_theme_constant_override("separation", 4)
	bar.add_child(nav_bar)
	for entry in NAV:
		var button := Button.new()
		button.text = entry[1]
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.add_theme_font_size_override("font_size", 15)
		button.pressed.connect(_on_nav.bind(entry[0]))
		nav_bar.add_child(button)
		nav_buttons[entry[0]] = button


## Dans une zone qui défile, les cartes, boutons et espaces laissent passer le doigt jusqu'à elle : sans ça, un
## glisser qui commence sur une carte (qui arrête le doigt par défaut) ne fait rien défiler. Un vrai glisser annule
## l'appui sur un bouton ; un simple toucher le déclenche toujours (zone morte : gui/common/default_scroll_deadzone).
func _let_scroll_through(node: Node) -> void:
	if not node is Control or (node as Control).mouse_filter != Control.MOUSE_FILTER_STOP or node is ScrollContainer:
		return
	var parent := node.get_parent()
	while parent != null:
		if parent is ScrollContainer:
			(node as Control).mouse_filter = Control.MOUSE_FILTER_PASS
			return
		parent = parent.get_parent()


func _on_nav(screen: String) -> void:
	if screen != current_name:
		sfx.play("clic")
		show_screen(screen)


## Affiche un écran (et la barre de navigation s'il en fait partie). options : réglages propres à l'écran.
func show_screen(screen: String, options: Dictionary = {}) -> void:
	if current != null:
		current.queue_free()
	var node: Control = SCREENS[screen].new()
	node.set_anchors_preset(Control.PRESET_FULL_RECT)
	# Le bestiaire s'ouvre depuis La Tour : la barre du bas reste là, sur l'onglet La Tour.
	var nav_key := "tower" if screen == "bestiaire" else screen
	var with_nav := nav_buttons.has(nav_key)
	(nav_bar.get_parent() as Control).visible = with_nav
	content.offset_bottom = -NAV_HEIGHT if with_nav else 0.0
	content.add_child(node)
	current = node
	current_name = screen
	for key in nav_buttons:
		(nav_buttons[key] as Button).modulate = Color(1.0, 0.85, 0.3) if key == nav_key else Color.WHITE
	node.call("setup", self, options)


# ---------------------------------------------------------------------------
# Le duo
# ---------------------------------------------------------------------------

func has_duo() -> bool:
	return player_class != "" and not acolyte.is_empty()


func load_saved_duo() -> bool:
	var saved := profile.duo
	if saved.is_empty() or not data.classes.has(saved.get("player_class", "")) or not data.classes.has(saved.get("acolyte_class", "")):
		return false
	player_class = saved["player_class"]
	player_picks = saved["player_picks"]
	acolyte = {"class_id": saved["acolyte_class"], "picks": saved["acolyte_picks"]}
	acolyte_name = str(saved.get("acolyte_name", ACOLYTE_NAMES[0]))
	# Les profils d'avant le Destin n'en ont pas : on en tire un.
	if profile.destin.is_empty():
		_new_destin()
	if profile.acolyte_destin.is_empty():
		_new_acolyte_destin()
	_load_destins()
	return true


## Regénère les deux arbres depuis leurs graines et relit les points placés.
func _load_destins() -> void:
	destin = Destin.generate(data, player_class, player_picks, int(profile.destin["seed"]))
	destin_taken = profile.destin.get("taken", []).duplicate()
	acolyte_destin = Destin.generate(data, acolyte["class_id"], acolyte["picks"], int(profile.acolyte_destin["seed"]), true)
	acolyte_taken = profile.acolyte_destin.get("taken", []).duplicate()
	_place_acolyte_points()


## Un nouveau Destin : une graine, et le premier point sur la racine (le seul choix possible).
func _new_destin() -> void:
	profile.destin = {"seed": rng.randi(), "taken": [0]}


func _new_acolyte_destin() -> void:
	profile.acolyte_destin = {"seed": rng.randi(), "taken": []}


## Les points de l'acolyte se placent seuls : un tous les deux niveaux (15 points au niveau 30), sur le nœud
## disponible qui vaut le plus.
func _place_acolyte_points() -> void:
	var points := mini(profile.level / 2, int(data.destin_nodes.get("mini_points", 15)))
	var changed := false
	while acolyte_taken.size() < points:
		var next := Destin.auto_take(acolyte_destin, acolyte_taken)
		if next < 0:
			break
		acolyte_taken.append(next)
		changed = true
	if changed:
		profile.acolyte_destin["taken"] = acolyte_taken.duplicate()
		profile.save()


func destin_points_left() -> int:
	return maxi(0, profile.level - destin_taken.size())


## Place un point sur un nœud (relié à un nœud pris, un point par niveau). Renvoie vrai si c'est fait.
func take_destin_node(node_id: int) -> bool:
	if destin_points_left() <= 0 or not Destin.can_take(destin, destin_taken, node_id):
		return false
	destin_taken.append(node_id)
	profile.destin["taken"] = destin_taken.duplicate()
	profile.save()
	return true


## De l'XP après un combat ; l'acolyte monte en même temps. Renvoie {levels, level}.
func gain_xp(amount: int) -> Dictionary:
	var result := profile.gain_xp(amount)
	_place_acolyte_points()
	profile.save()
	return result


func save_duo() -> void:
	profile.duo = {"player_class": player_class, "player_picks": player_picks, "acolyte_class": acolyte["class_id"],
		"acolyte_picks": acolyte["picks"], "acolyte_name": acolyte_name}
	profile.save()


## Création du personnage : sa classe, son Destin tiré au hasard, puis son acolyte (classe complémentaire,
## compétences qui font Synergie avec les siennes).
func create_character(class_id: String) -> void:
	player_class = class_id
	player_picks = CombatUnit.random_picks(rng)
	profile.level = 1
	profile.xp = 0
	_new_destin()
	draw_acolyte()
	_load_destins()
	save_duo()


func draw_acolyte() -> void:
	acolyte = Duo.draw_acolyte(data, player_class, player_picks, rng)
	acolyte_name = ACOLYTE_NAMES[rng.randi_range(0, ACOLYTE_NAMES.size() - 1)]
	_new_acolyte_destin()


## Prototype seulement : un autre tirage pour le joueur (et donc un autre Destin). L'acolyte reste s'il fait toujours Synergie avec lui.
func reroll_player() -> void:
	player_picks = CombatUnit.random_picks(rng)
	_new_destin()
	if Duo.kit_synergies(data, player_class, player_picks, acolyte["class_id"], acolyte["picks"]).is_empty():
		var keep_name := acolyte_name
		draw_acolyte()
		acolyte_name = keep_name
	_load_destins()
	save_duo()


func reroll_acolyte() -> void:
	draw_acolyte()
	_load_destins()
	save_duo()


## Le duo pour le moteur : toi, puis ton acolyte, avec les nœuds de Destin pris.
func duo_members() -> Array:
	var team := Duo.members(player_class, player_picks, acolyte)
	team[0]["name"] = "Toi"
	team[0]["is_player"] = true
	team[1]["name"] = acolyte_name
	var mine := Destin.mods_for(destin, destin_taken)
	team[0]["mods"] = mine["mods"]
	team[0]["skill_mods"] = mine["skill_mods"]
	var theirs := Destin.mods_for(acolyte_destin, acolyte_taken)
	team[1]["mods"] = theirs["mods"]
	team[1]["skill_mods"] = theirs["skill_mods"]
	return team


func player_skills() -> Array[String]:
	return Duo.kit_skills(data, player_class, player_picks)


func player_passive() -> String:
	var pool: Array = data.classes[player_class]["passives"]
	return pool[int(player_picks.get("passive", 0)) % pool.size()]


func acolyte_skills() -> Array[String]:
	return Duo.kit_skills(data, acolyte["class_id"], acolyte["picks"])


func acolyte_passive() -> String:
	var pool: Array = data.classes[acolyte["class_id"]]["passives"]
	return pool[int(acolyte["picks"].get("passive", 0)) % pool.size()]


func duo_synergies() -> Array[Dictionary]:
	return Duo.kit_synergies(data, player_class, player_picks, acolyte["class_id"], acolyte["picks"])


func class_label(class_id: String) -> String:
	var cls: Dictionary = data.classes[class_id]
	return "%s · %s" % [cls["name"], UiKit.ROLE_LABELS[cls["roles"][0]]]
