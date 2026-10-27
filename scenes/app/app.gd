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
	"profile": preload("res://scenes/screens/profile_screen.gd"),
	"settings": preload("res://scenes/screens/settings_screen.gd"),
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
## La posture que l'acolyte prend au début de chaque combat (on la change aussi pendant le combat).
var posture: String = CombatAI.LIBRE

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
	data = CombatData.load_default()
	profile = PlayerProfile.load_profile()
	sfx = Sfx.new()
	add_child(sfx)
	sfx.muted = profile.muted
	posture = profile.posture
	theme = UiKit.make_theme()
	_build_layout()
	var has_duo := load_saved_duo()
	_check_posture()
	show_screen("home" if has_duo else "creation")


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
	var with_nav := nav_buttons.has(screen)
	(nav_bar.get_parent() as Control).visible = with_nav
	content.offset_bottom = -NAV_HEIGHT if with_nav else 0.0
	content.add_child(node)
	current = node
	current_name = screen
	for key in nav_buttons:
		(nav_buttons[key] as Button).modulate = Color(1.0, 0.85, 0.3) if key == screen else Color.WHITE
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
	return true


func save_duo() -> void:
	profile.duo = {"player_class": player_class, "player_picks": player_picks, "acolyte_class": acolyte["class_id"],
		"acolyte_picks": acolyte["picks"], "acolyte_name": acolyte_name}
	profile.save()


## Création du personnage : sa classe, son Destin tiré au hasard, puis son acolyte (classe complémentaire,
## compétences qui font Synergie avec les siennes).
func create_character(class_id: String) -> void:
	player_class = class_id
	player_picks = CombatUnit.random_picks(rng)
	draw_acolyte()
	save_duo()


func draw_acolyte() -> void:
	acolyte = Duo.draw_acolyte(data, player_class, player_picks, rng)
	acolyte_name = ACOLYTE_NAMES[rng.randi_range(0, ACOLYTE_NAMES.size() - 1)]
	_check_posture()


## Les postures de ton acolyte : elles dépendent de son rôle (Libre, les deux de son rôle, Garde ta forte).
func acolyte_postures() -> Array:
	if acolyte.is_empty():
		return [CombatAI.LIBRE, CombatAI.GARDE_TA_FORTE]
	return CombatAI.postures_for(data, acolyte["class_id"])


## Une posture gardée qui n'existe pas pour ce rôle (autre acolyte, ancienne sauvegarde) redevient Libre.
func _check_posture() -> void:
	if not acolyte_postures().has(posture):
		set_posture(CombatAI.LIBRE)


## Prototype seulement : un autre tirage pour le joueur. L'acolyte reste s'il fait toujours Synergie avec lui.
func reroll_player() -> void:
	player_picks = CombatUnit.random_picks(rng)
	if Duo.kit_synergies(data, player_class, player_picks, acolyte["class_id"], acolyte["picks"]).is_empty():
		var keep_name := acolyte_name
		draw_acolyte()
		acolyte_name = keep_name
	save_duo()


func reroll_acolyte() -> void:
	draw_acolyte()
	save_duo()


func set_posture(posture_id: String) -> void:
	posture = posture_id
	profile.posture = posture_id
	profile.save()


## Le duo pour le moteur : toi, puis ton acolyte.
func duo_members() -> Array:
	var team := Duo.members(player_class, player_picks, acolyte)
	team[0]["name"] = "Toi"
	team[0]["is_player"] = true
	team[1]["name"] = acolyte_name
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


## Le texte d'une posture pour cet acolyte (en Libre, la règle dépend de son rôle).
func posture_text(posture_id: String) -> String:
	return data.posture_description(posture_id, str(acolyte.get("class_id", "")))


func posture_name(posture_id: String) -> String:
	return str(data.postures.get("postures", {}).get(posture_id, {}).get("name", posture_id))
