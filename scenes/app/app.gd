## L'application : garde le profil et le trio du joueur, affiche un écran à la fois et la barre de navigation.
## Combat V2 (docs/SPEC-COMBAT-V2.md) : un perso, c'est une classe et une graine (sa roue du Destin en sort à
## l'identique) et la liste des nœuds qu'il a allumés. Il joue toujours en trio (docs/GDD_V2.md) : avec deux Échos,
## un de chacun des deux autres rôles, proposés par le jeu à son niveau (une graine et un nom chacun, gardés jusqu'à ce
## que le joueur en demande un autre ; amis et guilde viendront avec le serveur).
## Écrans : création, Vitrine (accueil), Trio (composer son trio), Destin (la roue), La Tour et son bestiaire, Profil,
## Paramètres, face-à-face, combat, fin de combat.
## Affichage et navigation seulement : toute la règle vit dans res://engine.
class_name ArenaApp
extends Control

## Les noms des Échos proposés par le jeu (en attendant ceux des vrais joueurs).
const ECHO_NAMES := ["Lys", "Orme", "Saule", "Iris", "Cèdre", "Aube", "Sorel", "Nima", "Bram", "Elio", "Mira", "Tess"]
const NAV_HEIGHT := 74.0
## Les onglets de la barre du bas : identifiant d'écran, texte.
const NAV := [["home", "Accueil"], ["trio", "Trio"], ["destin", "Destin"], ["tower", "La Tour"], ["profile", "Profil"]]
const SCREENS := {
	"creation": preload("res://scenes/screens/creation_screen.gd"),
	"home": preload("res://scenes/screens/home_screen.gd"),
	"trio": preload("res://scenes/screens/trio_screen.gd"),
	"profile": preload("res://scenes/screens/profile_screen.gd"),
	"settings": preload("res://scenes/screens/settings_screen.gd"),
	"destin": preload("res://scenes/screens/destin_screen.gd"),
	"tower": preload("res://scenes/screens/tower_screen.gd"),
	"bestiaire": preload("res://scenes/screens/bestiary_screen.gd"),
	"versus": preload("res://scenes/screens/versus_screen.gd"),
	"combat": preload("res://scenes/combat/combat_screen.gd"),
	"fin": preload("res://scenes/screens/fin_screen.gd"),
}

var data: Donnees
var profile: PlayerProfile
var sfx: Sfx
var rng := RandomNumberGenerator.new()

# Le perso du joueur (un seul par compte, GDD) et ses deux Échos, gardés sur l'appareil.
var player_class: String = ""
## La graine du Destin, tirée une fois à la création (section 4 : le seul hasard du jeu).
var graine: int = 0
## Les nœuds allumés par le joueur, dans l'ordre (« v2.n2 », « v1.e1 »…), un par niveau ; les N1 le sont d'office.
var allumage: Array[String] = []
## Les deux Échos : leur rôle, leur graine et leur nom (« front », « degats » ou « soutien » -> { graine, nom }), et
## leurs roues, dans l'ordre Front, Dégâts, Soutien.
var echos_choisis: Dictionary = {}
var echos: Array[Destin] = []
## Les deux roues, regénérées depuis la graine, le niveau et les nœuds allumés.
var destin: Destin

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
	show_screen("home" if charger_perso() else "creation")


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
# Le perso et son trio
# ---------------------------------------------------------------------------

func has_perso() -> bool:
	return player_class != "" and destin != null


## Le perso gardé sur l'appareil. Un perso d'avant le combat V2 (sans « version » 2 ou plus) n'est pas repris : on en
## recrée un. Un perso d'avant le trio reçoit ses deux Échos.
func charger_perso() -> bool:
	var saved := profile.duo
	if int(saved.get("version", 0)) < 2 or not data.classes.has(str(saved["classe"] if saved.has("classe") else "")):
		return false
	player_class = str(saved["classe"])
	graine = int(saved["graine"])
	allumage.clear()
	for cle in saved.get("allumage", []):
		allumage.append(str(cle))
	echos_choisis = {}
	for role in saved.get("echos", {}):
		echos_choisis[str(role)] = {"graine": int(saved["echos"][role]["graine"]), "nom": str(saved["echos"][role]["nom"])}
	_completer_echos()
	_regenerer()
	sauver_perso()
	return true


## Un Écho proposé par le jeu pour chaque rôle qui n'en a pas (le rôle du joueur exclu).
func _completer_echos() -> void:
	var roles := Trio.roles_des_echos(player_class, data)
	for role in echos_choisis.keys():
		if not role in roles:
			echos_choisis.erase(role)
	for role in roles:
		if not echos_choisis.has(role):
			echos_choisis[role] = {"graine": _nouvelle_graine(), "nom": _nom_d_echo()}


## Un nom d'Écho que le trio n'a pas déjà.
func _nom_d_echo() -> String:
	var pris: Array = []
	for role in echos_choisis:
		pris.append(echos_choisis[role]["nom"])
	var libres: Array = ECHO_NAMES.filter(func(n): return not n in pris)
	return libres[rng.randi_range(0, libres.size() - 1)]


## Les roues, depuis les graines : celle du joueur avec ses nœuds allumés, celles de ses Échos (allumées seules, à son
## niveau).
func _regenerer() -> void:
	destin = Generateur.generer(player_class, graine, profile.level, allumage, data)
	echos.clear()
	for role in Trio.roles_des_echos(player_class, data):
		echos.append(Trio.echo(role, int(echos_choisis[role]["graine"]), profile.level, data))


func sauver_perso() -> void:
	profile.duo = {"version": 3, "classe": player_class, "graine": graine, "allumage": Array(allumage), "echos": echos_choisis.duplicate(true)}
	profile.save()


## Création du personnage : sa classe et sa graine, et deux Échos proposés par le jeu.
func create_character(class_id: String) -> void:
	player_class = class_id
	graine = _nouvelle_graine()
	allumage.clear()
	profile.level = 1
	profile.xp = 0
	echos_choisis = {}
	_completer_echos()
	_regenerer()
	sauver_perso()


## Un autre Écho proposé par le jeu pour ce rôle (une autre classe du rôle, peut-être, et un autre nom).
func changer_echo(role: String) -> void:
	echos_choisis.erase(role)
	_completer_echos()
	_regenerer()
	sauver_perso()


func _nouvelle_graine() -> int:
	return ((rng.randi() & 0x7FFFFFFF) << 32) | rng.randi()


## Prototype seulement : un autre Destin pour la même classe (dans le vrai jeu, il ne change jamais).
func reroll_player() -> void:
	graine = _nouvelle_graine()
	allumage.clear()
	_regenerer()
	sauver_perso()


## Les points de Destin qui restent à placer : un par niveau.
func destin_points_left() -> int:
	return maxi(0, profile.level - allumage.size())


## Allume un nœud ou un éclat (« v2.n3 », « v1.e1 ») s'il reste un point et que la règle d'allumage le permet.
func allumer(cle: String) -> bool:
	if destin_points_left() <= 0 or not Generateur.peut_allumer(destin, cle):
		return false
	allumage.append(cle)
	_regenerer()
	sauver_perso()
	return true


## De l'XP après un combat ; les Échos sont toujours au niveau du joueur. Renvoie {levels, level}.
func gain_xp(amount: int) -> Dictionary:
	var result := profile.gain_xp(amount)
	_regenerer()
	profile.save()
	return result


## Le trio du joueur : lui, puis ses Échos (Front, Dégâts, Soutien moins son rôle).
func trio() -> Array[Destin]:
	var out: Array[Destin] = [destin]
	out.append_array(echos)
	return out


## Les noms du trio en combat.
func noms_trio() -> Dictionary:
	var out := {"a1": "Toi"}
	var roles := Trio.roles_des_echos(player_class, data)
	for i in range(roles.size()):
		out["a%d" % (i + 2)] = str(echos_choisis[roles[i]]["nom"])
	return out


## Un duel contre un trio IA de ton niveau : une classe et une graine au hasard, ses deux Échos (l'étape 5 fera un vrai
## matchmaking).
func duel_contre_ia() -> Dictionary:
	var classe: String = data.ordre_classes[rng.randi_range(0, data.ordre_classes.size() - 1)]
	var ennemis := Trio.camp(Generateur.generer(classe, _nouvelle_graine(), profile.level, Generateur.PAR_DEFAUT, data), profile.level, data)
	var e := Regles.nouveau_combat(trio(), ennemis, profile.level, "pvp", data)
	return {"etat": e, "noms": noms_trio()}


## Une montée de la Tour, à ton niveau, avec ton trio : le combat de son premier étage.
func commencer_tour() -> Dictionary:
	var t := Tour.commencer_camp(trio(), profile.level, _nouvelle_graine(), data)
	return {"etat": t.combat(), "tour": t, "noms": noms_trio()}


## La fin d'un duel : le résultat, la série, l'XP (+120 gagné, +80 perdu). Renvoie {xp, niveaux}.
func fin_duel(gagne: bool) -> Dictionary:
	profile.record_result(gagne)
	var xp := 120 if gagne else 80
	var r := gain_xp(xp)
	return {"xp": xp, "niveaux": int(r["levels"])}


## La fin d'une montée : le record de la classe (l'étage atteint). Renvoie {xp} (l'XP des étages est donnée au fil
## de la montée).
func fin_tour(t: Tour) -> Dictionary:
	if t.atteint > int(profile.tower_records.get(player_class, 0)):
		profile.tower_records[player_class] = t.atteint
	profile.save()
	return {"xp": 40 * maxi(0, t.atteint - 1)}


func class_label(class_id: String) -> String:
	var cls := data.classe(class_id)
	return "%s · %s" % [cls["nom"], UiKit.ROLE_LABELS[cls["role"]]]
