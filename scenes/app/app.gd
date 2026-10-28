## L'application : garde le profil et le duo du joueur, affiche un écran à la fois et la barre de navigation.
## Combat V2 (docs/SPEC-COMBAT-V2.md) : un perso, c'est une classe et une graine (sa roue du Destin en sort à
## l'identique) et la liste des nœuds qu'il a allumés ; son acolyte se déduit de sa classe et de sa graine.
## Écrans : création, rencontre de l'acolyte, Vitrine (accueil), Acolyte, Destin (la roue), Profil, Paramètres ; le
## combat et la Tour sont en reconstruction (étapes 4 et 6 du plan de la spécification).
## Affichage et navigation seulement : toute la règle vit dans res://engine.
class_name ArenaApp
extends Control

const ACOLYTE_NAMES := ["Lys", "Orme", "Saule", "Iris", "Cèdre", "Aube", "Sorel", "Nima"]
const NAV_HEIGHT := 74.0
## Les onglets de la barre du bas : identifiant d'écran, texte.
const NAV := [["home", "Accueil"], ["acolyte", "Acolyte"], ["destin", "Destin"], ["tower", "La Tour"], ["profile", "Profil"]]
const SCREENS := {
	"creation": preload("res://scenes/screens/creation_screen.gd"),
	"meet": preload("res://scenes/screens/meet_screen.gd"),
	"home": preload("res://scenes/screens/home_screen.gd"),
	"acolyte": preload("res://scenes/screens/acolyte_screen.gd"),
	"profile": preload("res://scenes/screens/profile_screen.gd"),
	"settings": preload("res://scenes/screens/settings_screen.gd"),
	"destin": preload("res://scenes/screens/destin_screen.gd"),
	"tower": preload("res://scenes/screens/bientot_screen.gd"),
	"versus": preload("res://scenes/screens/bientot_screen.gd"),
}

var data: Donnees
var profile: PlayerProfile
var sfx: Sfx
var rng := RandomNumberGenerator.new()

# Le duo du joueur : un seul personnage et un seul acolyte par compte (GDD), gardés sur l'appareil.
var player_class: String = ""
## La graine du Destin, tirée une fois à la création (section 4 : le seul hasard du jeu).
var graine: int = 0
## Les nœuds allumés par le joueur, dans l'ordre (« v2.n2 », « v1.e1 »…), un par niveau ; les N1 le sont d'office.
var allumage: Array[String] = []
var acolyte_name: String = ""
## Les deux roues, regénérées depuis la graine, le niveau et les nœuds allumés.
var destin: Destin
var acolyte_destin: Destin

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
	data = Donnees.defaut()
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
	return player_class != "" and destin != null


## Le duo gardé sur l'appareil. Un duo d'avant le combat V2 (sans « version » 2) n'est pas repris : on recrée un perso.
func load_saved_duo() -> bool:
	var saved := profile.duo
	if int(saved.get("version", 0)) != 2 or not data.classes.has(str(saved.get("classe", ""))):
		return false
	player_class = str(saved["classe"])
	graine = int(saved["graine"])
	allumage.clear()
	for cle in saved.get("allumage", []):
		allumage.append(str(cle))
	acolyte_name = str(saved.get("acolyte_nom", ACOLYTE_NAMES[0]))
	_regenerer()
	return true


## Les deux roues, depuis la graine : celle du joueur avec ses nœuds allumés, celle de l'acolyte (allumée seule,
## selon le niveau).
func _regenerer() -> void:
	destin = Generateur.generer(player_class, graine, profile.level, allumage, data)
	acolyte_destin = Generateur.acolyte(player_class, graine, profile.level, data)


func save_duo() -> void:
	profile.duo = {"version": 2, "classe": player_class, "graine": graine, "allumage": Array(allumage), "acolyte_nom": acolyte_name}
	profile.save()


## Création du personnage : sa classe et sa graine. Le Destin et l'acolyte (classe fixée par la sienne) en découlent.
func create_character(class_id: String) -> void:
	player_class = class_id
	graine = _nouvelle_graine()
	allumage.clear()
	profile.level = 1
	profile.xp = 0
	acolyte_name = ACOLYTE_NAMES[rng.randi_range(0, ACOLYTE_NAMES.size() - 1)]
	_regenerer()
	save_duo()


func _nouvelle_graine() -> int:
	return ((rng.randi() & 0x7FFFFFFF) << 32) | rng.randi()


## Prototype seulement : un autre Destin pour la même classe (dans le vrai jeu, il ne change jamais).
func reroll_player() -> void:
	graine = _nouvelle_graine()
	allumage.clear()
	_regenerer()
	save_duo()


## Les points de Destin qui restent à placer : un par niveau.
func destin_points_left() -> int:
	return maxi(0, profile.level - allumage.size())


## Allume un nœud ou un éclat (« v2.n3 », « v1.e1 ») s'il reste un point et que la règle d'allumage le permet.
func allumer(cle: String) -> bool:
	if destin_points_left() <= 0 or not Generateur.peut_allumer(destin, cle):
		return false
	allumage.append(cle)
	_regenerer()
	save_duo()
	return true


## De l'XP après un combat ; l'acolyte monte en même temps. Renvoie {levels, level}.
func gain_xp(amount: int) -> Dictionary:
	var result := profile.gain_xp(amount)
	_regenerer()
	profile.save()
	return result


func acolyte_class() -> String:
	return acolyte_destin.classe_id if acolyte_destin != null else ""


func class_label(class_id: String) -> String:
	var cls := data.classe(class_id)
	return "%s · %s" % [cls["nom"], UiKit.ROLE_LABELS[cls["role"]]]
