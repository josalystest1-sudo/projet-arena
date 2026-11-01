## L'application : garde le profil et le trio du joueur, affiche un écran à la fois et la barre de navigation.
## Combat V2 (docs/SPEC-COMBAT-V2.md) : un perso, c'est une classe et une graine (sa roue du Destin en sort à
## l'identique) et la liste des nœuds qu'il a allumés. Il joue toujours en trio (docs/GDD_V2.md) : avec deux Échos,
## un de chacun des deux autres rôles, proposés par le jeu à son niveau (une graine et un nom chacun, gardés jusqu'à ce
## que le joueur en demande un autre ; amis et guilde viendront avec le serveur).
## Écrans : création, la ville (l'accueil : une carte à bâtiments, data/ville.json), Trio (composer son trio), Destin
## (la roue), la Forge (l'équipement), La Tour et son bestiaire, le Tableau (les nouvelles du jour), Profil, Paramètres,
## face-à-face, combat, fin de combat. La barre du bas : Ville, Chat (grisé jusqu'au serveur), Profil ; tout le reste
## s'ouvre depuis la ville, à deux touchers (GDD V2, § 11).
## L'équipement (GDD V2, § 10 ; PR 3.2) : les objets portés et le sac vivent dans le profil ; les bonus des objets portés
## entrent dans la roue du joueur (`Destin.mods`) à chaque régénération ; le butin tombe à la fin des étages de la Tour ;
## les Éclats (monnaie liée) viennent des duels, des étages et du revenu passif, et paient la reforge.
## Les évolutions (GDD V2, § 3 ; PR 8.1) : au niveau 30, le perso peut évoluer (engine/evolution.gd) ; sa classe devient
## l'évolution, sa roue repart à zéro, un point par niveau de 31 à 60 ; la graine, les Échos (adaptés au rôle) et la
## lignée (les records, paliers et Faveurs de la Tour sont ceux de la classe de base) restent.
## Le serveur (phase 5, PR 5.1 ; scenes/net/serveur.gd) : un compte anonyme par appareil, un pseudo, et la fiche du
## perso publiée à chaque changement (classe, graine, niveau, nœuds allumés, équipement) ; simulé tant que
## data/serveur.json n'a pas d'adresse.
## Affichage et navigation seulement : toute la règle vit dans res://engine.
class_name ArenaApp
extends Control

## Les noms des Échos proposés par le jeu (en attendant ceux des vrais joueurs).
const ECHO_NAMES := ["Lys", "Orme", "Saule", "Iris", "Cèdre", "Aube", "Sorel", "Nima", "Bram", "Elio", "Mira", "Tess"]
const NAV_HEIGHT := 74.0
## Les onglets de la barre du bas : identifiant d'écran, texte ; un identifiant sans écran est grisé (le Chat, phase 5).
const NAV := [["ville", "Ville"], ["chat", "Chat"], ["profile", "Profil"]]
## Les écrans sans barre du bas (plein écran) ; tous les autres la montrent, l'onglet Ville allumé quand ils en viennent.
const SANS_NAV := ["creation", "versus", "combat", "fin"]
const SCREENS := {
	"creation": preload("res://scenes/screens/creation_screen.gd"),
	"ville": preload("res://scenes/screens/ville_screen.gd"),
	"tableau": preload("res://scenes/screens/tableau_screen.gd"),
	"arene": preload("res://scenes/screens/arene_screen.gd"),
	"donjon": preload("res://scenes/screens/donjon_screen.gd"),
	"comptoir": preload("res://scenes/screens/comptoir_screen.gd"),
	"marche": preload("res://scenes/screens/marche_screen.gd"),
	"trio": preload("res://scenes/screens/trio_screen.gd"),
	"profile": preload("res://scenes/screens/profile_screen.gd"),
	"settings": preload("res://scenes/screens/settings_screen.gd"),
	"destin": preload("res://scenes/screens/destin_screen.gd"),
	"forge": preload("res://scenes/screens/forge_screen.gd"),
	"tower": preload("res://scenes/screens/tower_screen.gd"),
	"bestiaire": preload("res://scenes/screens/bestiary_screen.gd"),
	"versus": preload("res://scenes/screens/versus_screen.gd"),
	"combat": preload("res://scenes/combat/combat_screen.gd"),
	"fin": preload("res://scenes/screens/fin_screen.gd"),
	"guilde": preload("res://scenes/screens/guilde_screen.gd"),
	"carte": preload("res://scenes/screens/carte_screen.gd"),
}

var data: Donnees
var profile: PlayerProfile
var sfx: Sfx
## Le lien au serveur (simulé ou Supabase) ; `publication` : ce qu'a donné la dernière publication (vide avant).
var serveur: Serveur
## Ta guilde, telle que lue au serveur la dernière fois (engine/guilde.gd) ; vide sans guilde.
var guilde: Dictionary = {}
## La carte du monde (engine/carte.gd) : qui tient quoi, telle que lue la dernière fois, et le nombre de guildes.
var carte_etat: Dictionary = {}
var nb_guildes: int = 0
var publication := ""
var rng := RandomNumberGenerator.new()

# Le perso du joueur (un seul par compte, GDD) et ses deux Échos, gardés sur l'appareil.
var player_class: String = ""
## La graine du Destin, tirée une fois à la création (section 4 : le seul hasard du jeu).
var graine: int = 0
## Les nœuds allumés par le joueur, dans l'ordre (« v2.n2 », « v1.e1 »…), un par niveau ; les N1 le sont d'office.
var allumage: Array[String] = []
## Les deux Échos : leur rôle, leur graine et leur nom (« front », « degats » ou « soutien » -> { graine, nom }) ; un
## vrai Écho (PR 5.2 : le personnage d'un autre joueur, pris sur le serveur) porte en plus sa `fiche` (classe, graine,
## niveau, nœuds allumés, équipement : il joue à son vrai niveau) ; et leurs roues, dans l'ordre Front, Dégâts, Soutien.
var echos_choisis: Dictionary = {}
var echos: Array[Destin] = []
## Les deux roues, regénérées depuis la graine, le niveau et les nœuds allumés.
var destin: Destin
## La descente de donjon en cours (null entre deux) ; elle vit le temps de l'application (fermer le jeu l'abandonne,
## la carte est gardée au fil des vagues).
var donjon_en_cours: Donjon = null
## Le revenu passif réclamé à l'ouverture du jeu ({eclats, xp, record} ; vide s'il n'y en a pas eu), montré une fois par
## l'accueil.
var revenu_du_jour: Dictionary = {}

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
	_nettoyer_objets()
	sfx = Sfx.new()
	add_child(sfx)
	sfx.muted = profile.muted
	serveur = Serveur.creer(data, profile)
	add_child(serveur)
	theme = UiKit.make_theme()
	_build_layout()
	if charger_perso():
		reclamer_revenu()
		show_screen("ville")
		publier_perso()
	else:
		show_screen("creation")


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
		if not SCREENS.has(entry[0]):
			button.disabled = true
			button.text += " (bientôt)"
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
	# Tout ce qui s'ouvre depuis la ville garde la barre du bas, l'onglet Ville allumé.
	var nav_key := screen if nav_buttons.has(screen) else "ville"
	var with_nav := not screen in SANS_NAV
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
		var e: Dictionary = saved["echos"][role]
		var choix := {"graine": int(e["graine"]), "nom": str(e["nom"])}
		if e.get("fiche") is Dictionary and Serveur.fiche_valide(e["fiche"], data) and str(e["fiche"]["role"]) == str(role):
			choix["fiche"] = e["fiche"].duplicate(true)
		echos_choisis[str(role)] = choix
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
	destin.mods = Equipement.mods(objets_portes(), data)
	destin.traits = Equipement.traits(objets_portes(), data)
	echos.clear()
	for role in Trio.roles_des_echos(player_class, data):
		var choix: Dictionary = echos_choisis[role]
		if choix.has("fiche"):
			echos.append(Serveur.destin_de(choix["fiche"], data))
		else:
			echos.append(Trio.echo(role, int(choix["graine"]), profile.level, data))


func sauver_perso() -> void:
	profile.duo = {"version": 3, "classe": player_class, "graine": graine, "allumage": Array(allumage), "echos": echos_choisis.duplicate(true)}
	profile.save()
	publier_perso()


# ---------------------------------------------------------------------------
# Le serveur : le compte, le pseudo, la fiche publiée
# ---------------------------------------------------------------------------

## Ton pseudo (tiré avec la graine du perso la première fois ; modifiable au profil).
func pseudo() -> String:
	if str(profile.serveur.get("pseudo", "")) == "":
		profile.serveur["pseudo"] = Serveur.pseudo_defaut(graine, data)
	return str(profile.serveur["pseudo"])


## Changer de pseudo (2 à 16 caractères) ; la fiche est republiée. Faux s'il ne convient pas.
func changer_pseudo(nouveau: String) -> bool:
	if not Serveur.pseudo_valide(nouveau):
		return false
	profile.serveur["pseudo"] = nouveau.strip_edges()
	profile.save()
	publier_perso()
	return true


## La fiche publique du perso : ce que les autres joueurs en verront (sans l'identifiant : le serveur le pose).
func fiche_publique() -> Dictionary:
	return {"id": "", "pseudo": pseudo(), "classe": player_class, "role": str(data.classe(player_class)["role"]), "graine": str(graine),
		"niveau": profile.level, "allumage": Array(allumage), "equipement": objets_portes().duplicate(true),
		"points": int(_arene()["points"]), "saison": int(_arene()["saison"])}


## Publier la fiche (après connexion s'il le faut). Sans attendre : le résultat arrive dans `publication`.
func publier_perso() -> void:
	if not has_perso() or serveur == null:
		return
	_publier_perso_async()


func _publier_perso_async() -> void:
	if not serveur.est_connecte() and not await serveur.connecter():
		publication = "hors ligne : " + serveur.erreur
		return
	if str(profile.serveur.get("compte_jour", "")) == "":
		profile.serveur["compte_jour"] = profile.aujourd_hui()
		profile.save()
	publication = "publié" if await serveur.publier(fiche_publique()) else "non publié : " + serveur.erreur
	await ma_guilde()


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


## Prendre le personnage d'un autre joueur comme Écho de ce rôle (GDD V2, § 5) : sa fiche, telle que le serveur la
## donne ; il joue à son vrai niveau, avec ses nœuds et son équipement. Le serveur note la sélection. Faux si la
## fiche ne convient pas (rôle, classe, clés).
func choisir_echo_reel(role: String, fiche: Dictionary) -> bool:
	if not role in Trio.roles_des_echos(player_class, data) or str(fiche.get("role", "")) != role or not Serveur.fiche_valide(fiche, data):
		return false
	echos_choisis[role] = {"graine": int(str(fiche["graine"])), "nom": str(fiche["pseudo"]), "fiche": fiche.duplicate(true)}
	serveur.selectionner(str(fiche["id"]))
	_regenerer()
	sauver_perso()
	return true


## L'Écho de ce rôle est-il le personnage d'un autre joueur ?
func echo_reel(role: String) -> bool:
	return echos_choisis.get(role, {}).has("fiche")


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


## Outil du prototype : le jeu passe au lendemain (objectifs, Arène, Marché, guerres, revenus).
func passer_au_lendemain() -> void:
	profile.jours_avance += 1
	profile.save()


## Outil du prototype : monter de n niveaux d'un coup (jusqu'au plafond du rang), sans passer par l'XP.
func monter_niveaux(n: int) -> void:
	profile.level = clampi(profile.level + n, 1, niveau_max())
	profile.xp = 0
	gain_xp(0)


## Outil du prototype : le perso repart au niveau 1 avec une roue neuve (même classe, même Destin ; l'équipement,
## les Éclats et le reste du profil sont gardés). Une évolution redevient sa classe de base.
func remettre_perso_a_zero() -> void:
	player_class = Evolution.base(player_class, data)
	allumage.clear()
	profile.level = 1
	profile.xp = 0
	_regenerer()
	sauver_perso()


## Les points de Destin qui restent à placer : un par niveau au-dessus du plancher du rang (engine/evolution.gd).
func destin_points_left() -> int:
	return maxi(0, Evolution.points(profile.level, rang_perso(), data) - allumage.size())


## Le rang de la classe du perso : 0 (classe de base) ou 1 (évolution).
func rang_perso() -> int:
	return Evolution.rang(player_class, data)


## La lignée du perso : sa classe de base (elle porte les records, les paliers et les Faveurs de la Tour).
func lignee() -> String:
	return Evolution.base(player_class, data)


## Le niveau le plus haut du perso : 30 pour une classe de base (l'XP attend alors l'évolution), 60 pour une évolution.
func niveau_max() -> int:
	return Evolution.niveau_max(rang_perso(), data)


## Le perso peut-il évoluer maintenant (au niveau 30, classe de base) ?
func peut_evoluer() -> bool:
	return Evolution.peut_evoluer(player_class, profile.level, data)


## Les évolutions possibles de sa classe (une pour l'instant).
func evolutions_possibles() -> Array[String]:
	return Evolution.evolutions_jouables(player_class, data)


## Évoluer : la classe devient l'évolution, nouvelle roue (même graine), zéro point ; les Échos sont complétés selon le
## nouveau rôle. Faux si ce n'est pas possible.
func evoluer(evolution_id: String) -> bool:
	if not peut_evoluer() or not evolution_id in evolutions_possibles():
		return false
	player_class = evolution_id
	allumage.clear()
	profile.xp = 0
	_completer_echos()
	_regenerer()
	sauver_perso()
	return true


## Allume un nœud ou un éclat (« v2.n3 », « v1.e1 ») s'il reste un point et que la règle d'allumage le permet.
func allumer(cle: String) -> bool:
	if destin_points_left() <= 0 or not Generateur.peut_allumer(destin, cle):
		return false
	allumage.append(cle)
	_regenerer()
	sauver_perso()
	return true


## De l'XP après un combat ; les Échos sont toujours au niveau du joueur. Renvoie {levels, level}.
## Le Savoir de guilde ajoute sa part à toute XP gagnée.
func gain_xp(amount: int) -> Dictionary:
	var result := profile.gain_xp(Regles.plancher(float(amount) * (1.0 + Guilde.bonus(guilde, "xp", data))), niveau_max())
	_regenerer()
	profile.save()
	if int(result["levels"]) > 0:
		publier_perso()
	return result


# ---------------------------------------------------------------------------
# La Forge : l'équipement et les Éclats
# ---------------------------------------------------------------------------

## Les objets d'un profil d'avant la refonte de l'équipement (1er novembre : huit emplacements, d'autres bases) qui ne
## correspondent plus aux données sont retirés (le Talisman et ses bases, par exemple) : un prototype, pas de migration.
func _nettoyer_objets() -> void:
	var change := false
	for e in profile.portes.keys():
		var o: Dictionary = profile.portes[e]
		if not data.objets["emplacements"].has(e) or not Equipement.valide(o, data) or Equipement.emplacement(o, data) != str(e):
			profile.portes.erase(e)
			change = true
	var sac: Array = profile.sac.filter(func(o): return o is Dictionary and Equipement.valide(o, data))
	if sac.size() != profile.sac.size():
		profile.sac = sac
		change = true
	if change:
		profile.save()


## Les objets portés (un par emplacement au plus).
func objets_portes() -> Array:
	var out: Array = []
	for e in data.objets["emplacements"]:
		if profile.portes.has(e):
			out.append(profile.portes[e])
	return out


## Les bonus de ce qu'on porte (ligne -> fraction).
func bonus_portes() -> Dictionary:
	return Equipement.mods(objets_portes(), data)


## Équiper un objet du sac : il prend la place de son emplacement (l'objet porté retourne au sac) et devient lié.
func equiper(index_sac: int) -> bool:
	if index_sac < 0 or index_sac >= profile.sac.size():
		return false
	var objet: Dictionary = profile.sac[index_sac]
	var e := Equipement.emplacement(objet, data)
	profile.sac.remove_at(index_sac)
	if profile.portes.has(e):
		profile.sac.append(profile.portes[e])
	profile.portes[e] = Equipement.equiper(objet)
	_regenerer()
	profile.save()
	compter("equipes")
	return true


## Retirer l'objet porté d'un emplacement : il retourne au sac (toujours lié).
func retirer(emplacement: String) -> bool:
	if not profile.portes.has(emplacement):
		return false
	profile.sac.append(profile.portes[emplacement])
	profile.portes.erase(emplacement)
	_regenerer()
	profile.save()
	return true


## Recycler un objet du sac : il disparaît contre des Éclats (selon sa rareté). Renvoie les Éclats rendus (0 : rien fait).
func recycler(index_sac: int) -> int:
	if index_sac < 0 or index_sac >= profile.sac.size():
		return 0
	var rendu := Equipement.recyclage(profile.sac[index_sac], data)
	profile.sac.remove_at(index_sac)
	profile.eclats += rendu
	profile.save()
	compter("recycles")
	return rendu


## L'objet désigné par un endroit (« sac » ou « porte ») et une clé (l'index du sac, ou l'emplacement) ; vide sinon.
func objet_a(ou: String, cle: Variant) -> Dictionary:
	if ou == "sac" and int(cle) >= 0 and int(cle) < profile.sac.size():
		return profile.sac[int(cle)]
	if ou == "porte" and profile.portes.has(str(cle)):
		return profile.portes[str(cle)]
	return {}


## Reforger une ligne d'un objet (porté ou du sac) contre des Éclats, à coût croissant. Faux s'il manque des Éclats.
func reforger(ou: String, cle: Variant, ligne: int) -> bool:
	var objet := objet_a(ou, cle)
	if objet.is_empty() or ligne < 0 or ligne >= objet["lignes"].size():
		return false
	var cout := cout_reforge(objet)
	if profile.eclats < cout:
		return false
	var neuf := Equipement.reforger(objet, ligne, _nouvelle_graine(), data)
	if ou == "sac":
		profile.sac[int(cle)] = neuf
	else:
		profile.portes[str(cle)] = neuf
		_regenerer()
	profile.eclats -= cout
	profile.save()
	compter("reforges")
	return true


# ---------------------------------------------------------------------------
# Les objectifs du jour
# ---------------------------------------------------------------------------

## Le jour des objectifs : quand la date change, les compteurs et les objectifs réclamés repartent de zéro.
func _jour_objectifs() -> String:
	var aujourd_hui := profile.aujourd_hui()
	if profile.objectifs_jour != aujourd_hui:
		profile.objectifs_jour = aujourd_hui
		profile.compteurs = {}
		profile.objectifs_reclames = []
		profile.save()
	return aujourd_hui


## Un compteur du jour qui monte (duels, étages, Clés jouées…), pour les objectifs.
func compter(compteur: String, n: int = 1) -> void:
	if n <= 0 or not compteur in Objectifs.COMPTEURS:
		return
	_jour_objectifs()
	profile.compteurs[compteur] = int(profile.compteurs.get(compteur, 0)) + n
	profile.save()
	if INFLUENCE_PAR_COMPTEUR.has(compteur):
		influence(str(INFLUENCE_PAR_COMPTEUR[compteur]), n)


## Ce qu'un combat fini compte : les Clés jouées par le joueur (son tracé) et les Synergies de son camp.
func compter_combat(options: Dictionary) -> void:
	var cles := 0
	for pas in options.get("trace", {}).get("a1", []):
		if bool(pas.get("cle", false)):
			cles += 1
	compter("cles", cles)
	compter("synergies", options.get("synergies", []).size())


## Les objectifs du jour, prêts à afficher.
func objectifs_du_jour() -> Array[Dictionary]:
	return Objectifs.etat_du_jour(_jour_objectifs(), profile.compteurs, profile.objectifs_reclames, data)


## Y a-t-il un objectif fini et pas encore réclamé ?
func objectif_a_reclamer() -> bool:
	for o in objectifs_du_jour():
		if bool(o["fini"]) and not bool(o["reclame"]):
			return true
	return false


## Réclamer la récompense d'un objectif fini : une fois par jour. Renvoie {xp, eclats} (vide si rien à réclamer).
func reclamer_objectif(id: String) -> Dictionary:
	_jour_objectifs()
	if not id in Objectifs.du_jour(profile.objectifs_jour, data) or profile.objectifs_reclames.has(id) or not Objectifs.fini(id, profile.compteurs, data):
		return {}
	var r := Objectifs.recompense(id, data)
	profile.objectifs_reclames.append(id)
	profile.eclats += int(r["eclats"])
	gain_xp(int(r["xp"]))
	return r


# ---------------------------------------------------------------------------
# Les donjons (en solo, en attendant le serveur)
# ---------------------------------------------------------------------------

## La carte d'un donjon pour ce joueur : {chasse, explorees, revelees, boss}.
func carte_donjon(id: String) -> Dictionary:
	if not profile.donjons.has(id):
		profile.donjons[id] = {"chasse": 0, "explorees": [], "revelees": [], "boss": 0, "secrets": []}
	return profile.donjons[id]


## Entrer dans un donjon : l'entrée en Éclats, puis la descente commence (aux portes). Faux s'il manque des Éclats.
func commencer_donjon(id: String) -> bool:
	var def := Donjon.definition(id, data)
	if def.is_empty() or profile.eclats < int(def["entree"]):
		return false
	profile.eclats -= int(def["entree"])
	# Une part de l'entrée va à la guilde qui tient le territoire du donjon cette semaine (la tienne : en Influence).
	var ou := Carte.territoire_du_donjon(id, Arene.semaine(jour()), nb_guildes, data)
	if ou != "" and not guilde.is_empty() and str(carte_etat.get(ou, {}).get("guilde", "")) == str(guilde["id"]):
		var part := Carte.part_entree(int(def["entree"]), data)
		guilde = Guilde.gagner(guilde, part)
		serveur.influence_guilde(part)
	var carte := carte_donjon(id)
	donjon_en_cours = Donjon.commencer(id, trio(), profile.level, graine, int(carte["chasse"]), data)
	profile.save()
	return true


## La fin d'un combat de donjon : la carte retient le chemin ; une descente finie donne sa récompense (l'objet dans le
## sac, les Éclats, les fragments qui révèlent une porte du boss ; le boss vaincu lance une nouvelle chasse et remet la
## carte à zéro). Renvoie {resultat, butin, eclats, fragments, revelee, suite} (suite : « portes », « fini »).
func fin_combat_donjon(dj: Donjon, e: EtatCombat) -> Dictionary:
	dj.terminer(e)
	var carte := carte_donjon(dj.id)
	for c in dj.chemins_explores():
		if not carte["explorees"].has(c):
			carte["explorees"].append(c)
	var out := {"resultat": dj.resultat, "butin": {}, "eclats": 0, "fragments": 0, "revelee": "", "suite": "portes" if dj.phase == "portes" else "fini", "manque": dj.manque}
	# Les secrets du boss trouvés (ses paliers franchis) restent sur la carte, d'une chasse à l'autre.
	if not carte.has("secrets"):
		carte["secrets"] = []
	for s in dj.secrets_trouves():
		if not carte["secrets"].has(s):
			carte["secrets"].append(s)
	if dj.phase == "fini":
		var r := dj.recompense()
		if not r.is_empty():
			var objet := dj.butin(_nouvelle_graine())
			profile.sac.append(objet)
			profile.eclats += int(r["eclats"])
			out["butin"] = objet
			out["eclats"] = int(r["eclats"])
			out["fragments"] = int(r["fragments"])
			for i in range(int(r["fragments"])):
				var cle := Donjon.reveler(dj.id, dj.chasse, carte, data)
				if cle != "":
					carte["revelees"].append(cle)
					out["revelee"] = cle
			if dj.resultat == "boss":
				carte["boss"] = int(carte["boss"]) + 1
				carte["chasse"] = int(carte["chasse"]) + 1
				carte["explorees"] = []
				carte["revelees"] = []
				compter("gardiens")
		donjon_en_cours = null
	profile.save()
	return out


## Abandonner la descente en cours (entre deux vagues, ou en plein combat) : la carte est gardée.
func abandonner_donjon() -> void:
	if donjon_en_cours != null:
		donjon_en_cours.abandonner()
		donjon_en_cours = null
	profile.save()


# ---------------------------------------------------------------------------
# Le Marché (engine/marche.gd ; les annonces sur le serveur)
# ---------------------------------------------------------------------------

## L'âge du compte en jours (depuis la première connexion ; les outils du prototype peuvent le vieillir).
func jours_compte() -> int:
	var jour := str(profile.serveur.get("compte_jour", ""))
	if jour == "":
		return 0
	return maxi(0, Arene.jours(profile.aujourd_hui()) - Arene.jours(jour))


## Prototype : vieillir le compte de n jours (pour ouvrir le Marché sans attendre).
func vieillir_compte(n: int) -> void:
	var jour := str(profile.serveur.get("compte_jour", profile.aujourd_hui()))
	var unix := (Arene.jours(jour) - n) * 86400
	profile.serveur["compte_jour"] = Time.get_datetime_string_from_unix_time(unix).substr(0, 10)
	profile.save()


func marche_ouvert() -> bool:
	return Marche.ouvert(profile.level, jours_compte(), data)


func marche_manque() -> String:
	return Marche.manque(profile.level, jours_compte(), data)


## Mettre un objet du sac en vente à ce prix (dans sa fourchette ; annonces_max au plus). L'objet quitte le sac.
func deposer_annonce(index_sac: int, prix: int) -> bool:
	if not marche_ouvert() or index_sac < 0 or index_sac >= profile.sac.size():
		return false
	var objet: Dictionary = profile.sac[index_sac]
	if not Marche.prix_valide(objet, prix, data) or not serveur.est_connecte():
		return false
	if reste_du_jour("depots") <= 0:
		return false
	var miennes := 0
	for a in await serveur.annonces(1000):
		if bool(a.get("mienne", false)):
			miennes += 1
	if miennes >= int(data.marche["annonces_max"]):
		return false
	var id := "%s-%d-%d" % [serveur.compte_id, Time.get_unix_time_from_system(), rng.randi_range(0, 9999)]
	if not await serveur.deposer(Marche.annonce(objet, prix, serveur.compte_id, id)):
		return false
	profile.sac.remove_at(index_sac)
	_compter_jour("depots")
	profile.save()
	return true


## Retirer une de ses annonces : l'objet revient dans le sac.
func retirer_annonce(id: String) -> bool:
	var a: Dictionary = await serveur.retirer(id)
	if a.is_empty():
		return false
	profile.sac.append(a["objet"].duplicate(true))
	profile.save()
	return true


## Acheter une annonce à ce prix : l'Or part, l'objet arrive dans le sac, encore échangeable. Faux si l'Or manque ou si
## l'annonce est déjà partie (au premier acheteur).
func acheter_annonce(id: String, prix: int) -> bool:
	if not marche_ouvert() or profile.monnaie_or < prix or reste_du_jour("achats") <= 0:
		return false
	var a: Dictionary = await serveur.acheter(id)
	if a.is_empty() or int(a["prix"]) != prix:
		return false
	profile.monnaie_or -= prix
	_compter_jour("achats")
	serveur.mouvement(Economie.mouvement("achat", prix, jour()))
	var objet: Dictionary = a["objet"].duplicate(true)
	objet["lie"] = false
	profile.sac.append(objet)
	profile.save()
	return true


## Encaisser ses ventes : l'Or net (après la taxe de la semaine) arrive ; la taxe est notée comme détruite. Renvoie
## [{annonce, net}].
func encaisser_ventes() -> Array:
	if not serveur.est_connecte():
		return []
	var taux: float = await taux_taxe()
	var ventes: Array = await serveur.encaisser(taux)
	for v in ventes:
		profile.monnaie_or += int(v["net"])
		serveur.mouvement(Economie.mouvement("taxe", int(v["annonce"]["prix"]) - int(v["net"]), jour()))
	if not ventes.is_empty():
		profile.save()
	return ventes


# ---------------------------------------------------------------------------
# Le Comptoir et l'Or
# ---------------------------------------------------------------------------

## L'étal du jour (deux objets liés à ton niveau), avec « achete » pour ceux déjà pris aujourd'hui.
func etal_du_jour() -> Array:
	var aujourd_hui := profile.aujourd_hui()
	if profile.etal_jour != aujourd_hui:
		profile.etal_jour = aujourd_hui
		profile.etal_achetes = []
		profile.save()
	var out := Comptoir.etal_du_jour(aujourd_hui, profile.level, data)
	for i in range(out.size()):
		out[i]["achete"] = profile.etal_achetes.has(i)
	return out


## Acheter un objet de l'étal contre des Éclats : il va dans le sac, lié. Faux s'il est déjà acheté ou s'il manque des
## Éclats.
func acheter_etal(index: int) -> bool:
	var etal := etal_du_jour()
	if index < 0 or index >= etal.size() or bool(etal[index]["achete"]):
		return false
	var objet: Dictionary = etal[index]
	var prix := Comptoir.prix_etal(objet, data)
	if profile.eclats < prix:
		return false
	profile.eclats -= prix
	objet.erase("achete")
	profile.sac.append(objet)
	profile.etal_achetes.append(index)
	profile.save()
	return true


## Vendre un objet échangeable du sac au prix plancher : l'Or gagné (0 : rien vendu, ou la limite du jour atteinte).
## L'Or créé est noté au serveur (engine/economie.gd).
func vendre(index_sac: int) -> int:
	if index_sac < 0 or index_sac >= profile.sac.size() or not Comptoir.vendable(profile.sac[index_sac]) or reste_du_jour("ventes") <= 0:
		return 0
	var prix := Comptoir.prix_plancher(profile.sac[index_sac], data)
	profile.sac.remove_at(index_sac)
	profile.monnaie_or += prix
	_compter_jour("ventes")
	profile.save()
	serveur.mouvement(Economie.mouvement("comptoir", prix, jour()))
	return prix


# ---------------------------------------------------------------------------
# L'économie (engine/economie.gd)
# ---------------------------------------------------------------------------

## Le jour d'aujourd'hui (« AAAA-MM-JJ »).
func jour() -> String:
	return profile.aujourd_hui()


## Ce qu'il reste aujourd'hui d'une action limitée (« ventes », « depots », « achats »).
func reste_du_jour(quoi: String) -> int:
	return Economie.reste(profile.compteurs_jour, jour(), quoi, data)


func _compter_jour(quoi: String) -> void:
	profile.compteurs_jour = Economie.compter(profile.compteurs_jour, jour(), quoi)


## Le taux de taxe du Marché cette semaine, d'après le bilan de la semaine passée lu au serveur (gardé dans le profil
## pour la semaine) ; le taux de base sans serveur.
func taux_taxe() -> float:
	var semaine := Arene.semaine(jour())
	var cache: Dictionary = profile.serveur.get("taxe", {})
	if int(cache.get("semaine", -1)) == semaine:
		return float(cache["taux"])
	if not serveur.est_connecte():
		return float(data.marche["taxe"])
	var passe: Dictionary = await serveur.bilan(semaine - 1)
	var taux := Economie.taux_taxe(int(passe["entre"]), int(passe["detruit"]), data)
	profile.serveur["taxe"] = {"semaine": semaine, "taux": taux, "bilan": passe}
	profile.save()
	return taux


## Le bilan de la semaine passée, tel que le taux l'a lu (vide si pas encore lu).
func bilan_passe() -> Dictionary:
	return profile.serveur.get("taxe", {}).get("bilan", {})


## Le meilleur record de la Tour, toutes classes confondues (la « hauteur » du revenu passif).
func meilleur_record() -> int:
	var record := 0
	for c in profile.tower_records:
		record = maxi(record, int(profile.tower_records[c]))
	return record


## Le revenu passif du jour (GDD V2, § 6 ; reporté ici par Gautier) : une fois par jour de calendrier, des Éclats et un
## peu d'XP selon le meilleur record, plafonnés (Tour.revenu). Renvoie {eclats, xp, record}, ou vide si déjà réclamé ou
## sans record.
func reclamer_revenu() -> Dictionary:
	var aujourd_hui := profile.aujourd_hui()
	if profile.revenu_jour == aujourd_hui:
		return {}
	profile.revenu_jour = aujourd_hui
	var record := meilleur_record()
	var r := Tour.revenu(record, data)
	if int(r["eclats"]) <= 0 and int(r["xp"]) <= 0:
		profile.save()
		return {}
	profile.eclats += int(r["eclats"])
	gain_xp(int(r["xp"]))
	revenu_du_jour = {"eclats": int(r["eclats"]), "xp": int(r["xp"]), "record": record}
	return revenu_du_jour


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


# ---------------------------------------------------------------------------
# L'Arène classée (hors ligne, en attendant le serveur)
# ---------------------------------------------------------------------------

## L'état de l'Arène, remis d'aplomb : les points repartent de zéro au changement de saison, les combats du jour au
## changement de jour, les victoires et le coffre au changement de semaine.
func _arene() -> Dictionary:
	var aujourd_hui := profile.aujourd_hui()
	var a: Dictionary = profile.arene
	if a.is_empty():
		a = {"points": 0, "saison": Arene.saison(aujourd_hui, data), "jour": aujourd_hui, "combats_jour": 0, "semaine": Arene.semaine(aujourd_hui), "victoires_semaine": 0, "coffre_reclame": false}
	if int(a["saison"]) != Arene.saison(aujourd_hui, data):
		a["saison"] = Arene.saison(aujourd_hui, data)
		a["points"] = 0
	if str(a["jour"]) != aujourd_hui:
		a["jour"] = aujourd_hui
		a["combats_jour"] = 0
	if int(a["semaine"]) != Arene.semaine(aujourd_hui):
		a["semaine"] = Arene.semaine(aujourd_hui)
		a["victoires_semaine"] = 0
		a["coffre_reclame"] = false
	profile.arene = a
	return a


## L'Arène prête à afficher : points, ligue, saison et sa fin, combats classés restants aujourd'hui, victoires de la
## semaine, rareté du coffre, coffre réclamé.
func etat_arene() -> Dictionary:
	var a := _arene()
	var aujourd_hui := profile.aujourd_hui()
	return {"points": int(a["points"]), "ligue": Arene.ligue(rang_perso()), "saison": int(a["saison"]), "fin_saison": Arene.fin_de_saison(aujourd_hui, data),
		"restants": maxi(0, int(data.objets_arene["combats_par_jour"]) - int(a["combats_jour"])), "victoires_semaine": int(a["victoires_semaine"]),
		"coffre": Arene.rarete_coffre(int(a["victoires_semaine"]), data), "coffre_reclame": bool(a["coffre_reclame"])}


## Un combat classé : le personnage d'un autre joueur autour de ton niveau (le serveur ; ses Échos sont générés à son
## niveau), ou, s'il n'y en a pas, un adversaire généré (classe, graine, niveau, nom, équipement), contre ton trio.
## À lire avec `await`. Vide s'il ne reste plus de combat classé aujourd'hui.
func duel_classe() -> Dictionary:
	if int(etat_arene()["restants"]) <= 0:
		return {}
	var adv: Dictionary
	var ennemis: Array[Destin]
	var fiches: Array = await serveur.adversaires(profile.level, 5)
	if fiches.is_empty():
		adv = Arene.adversaire(profile.level, _nouvelle_graine(), data)
		ennemis = Arene.trio_adverse(adv, data)
	else:
		var f: Dictionary = fiches[rng.randi_range(0, fiches.size() - 1)]
		adv = {"classe": str(f["classe"]), "graine": int(str(f["graine"])), "niveau": int(f["niveau"]), "nom": str(f["pseudo"]),
			"equipement": "porté" if not f["equipement"].is_empty() else "", "reel": true, "points": int(f.get("points", 0))}
		var joueur := Serveur.destin_de(f, data)
		joueur.echo = false
		ennemis = Trio.camp(joueur, int(f["niveau"]), data)
	var e := Regles.nouveau_combat(trio(), ennemis, profile.level, "pvp", data)
	var noms := noms_trio()
	noms["b1"] = str(adv["nom"])
	return {"etat": e, "noms": noms, "classe": true, "adversaire": adv}


## Le coffre de la semaine : un objet lié dans le sac, une fois par semaine. Vide s'il n'y a pas de coffre ou s'il est
## déjà réclamé.
func reclamer_coffre() -> Dictionary:
	var a := _arene()
	if bool(a["coffre_reclame"]):
		return {}
	var objet := Arene.coffre(int(a["victoires_semaine"]), profile.level, _nouvelle_graine(), data)
	if objet.is_empty():
		return {}
	a["coffre_reclame"] = true
	profile.sac.append(objet)
	profile.save()
	return objet


## Un duel amical contre un trio IA de ton niveau : une classe et une graine au hasard, ses deux Échos.
func duel_contre_ia() -> Dictionary:
	var classe: String = data.ordre_classes[rng.randi_range(0, data.ordre_classes.size() - 1)]
	var ennemis := Trio.camp(Generateur.generer(classe, _nouvelle_graine(), profile.level, Generateur.PAR_DEFAUT, data), profile.level, data)
	var e := Regles.nouveau_combat(trio(), ennemis, profile.level, "pvp", data)
	return {"etat": e, "noms": noms_trio()}


## Une montée de la Tour avec ton trio, depuis un palier (par défaut le plus haut), avec les Faveurs de ta classe :
## le combat de son premier étage.
func commencer_tour(depart: int = 0) -> Dictionary:
	var t := Tour.commencer_camp(trio(), profile.level, _nouvelle_graine(), data, depart if depart >= 1 else palier(), faveurs())
	return {"etat": t.combat(), "tour": t, "noms": noms_trio()}


## L'étage d'où ta classe reprend la Tour (après le dernier Gardien franchi).
func palier() -> int:
	return maxi(1, int(profile.tower_paliers.get(lignee(), 1)))


## Les Faveurs de la Tour de ta classe (identifiant -> nombre de cumuls).
func faveurs() -> Dictionary:
	var out := {}
	for id in profile.tower_faveurs.get(lignee(), {}):
		if data.faveurs.has(str(id)) and int(profile.tower_faveurs[lignee()][id]) > 0:
			out[str(id)] = int(profile.tower_faveurs[lignee()][id])
	return out


## L'XP d'un étage franchi : 40 la première fois, 20 pour un étage déjà franchi (une montée rejouée depuis un palier) ;
## +10 % par Faveur de Savoir.
func xp_etage(n: int) -> int:
	var base := 40 if n >= int(profile.tower_records.get(lignee(), 0)) else 20
	return Regles.plancher(float(base) * (1.0 + Tour.valeur_faveur("savoir", int(faveurs().get("savoir", 0)), data)))


## Un étage franchi, dès qu'il l'est (pas en fin de montée seulement : fermer le jeu en pleine montée ne doit rien
## perdre) : le record de la classe et, si c'est un Gardien, le palier. Un Gardien vaincu pour la première fois offre
## une Faveur : le palier n'est alors avancé qu'au choix de la Faveur (choisir_faveur), pour qu'un jeu fermé avant le
## choix la propose encore. Le butin (un objet dans le sac, échangeable au premier passage de l'étage avec cette
## classe, lié sinon) et les Éclats de l'étage. Renvoie {gardien, grand, faveur, propositions, premier, butin, eclats}.
func etage_franchi(t: Tour) -> Dictionary:
	var franchi := t.etage - 1
	var g := int(data.tour["gardien_tous_les"])
	var sorte := t.gardien_de(franchi)
	var gardien := sorte != ""
	var faveur := Tour.gardien_premiere_fois(franchi, palier(), g)
	var premier := franchi >= int(profile.tower_records.get(lignee(), 0))
	if t.atteint > int(profile.tower_records.get(lignee(), 0)):
		profile.tower_records[lignee()] = t.atteint
	if gardien and not faveur:
		profile.tower_paliers[lignee()] = maxi(palier(), Tour.palier_apres(franchi, g))
	var butin := t.butin(franchi, premier, Guilde.bonus(guilde, "butin", data))
	if not butin.is_empty():
		profile.sac.append(butin)
	var eclats := Equipement.eclats_etage(franchi, premier, data)
	profile.eclats += eclats
	profile.save()
	compter("etages")
	if gardien:
		compter("gardiens")
	return {"gardien": gardien, "grand": sorte == "grand", "faveur": faveur, "propositions": t.proposer_faveurs(franchi) if faveur else [],
		"premier": premier, "butin": butin, "eclats": eclats}


## Le choix d'une Faveur après le Gardien de l'étage franchi : elle est acquise pour ta classe, ajoutée à la montée en
## cours, et le palier est avancé.
func choisir_faveur(id: String, t: Tour) -> void:
	if not data.faveurs.has(id):
		return
	var acquises: Dictionary = profile.tower_faveurs.get(lignee(), {})
	acquises[id] = int(acquises.get(id, 0)) + 1
	profile.tower_faveurs[lignee()] = acquises
	profile.tower_paliers[lignee()] = maxi(palier(), Tour.palier_apres(t.etage - 1, int(data.tour["gardien_tous_les"])))
	profile.save()
	t.faveurs = faveurs()


## La fin d'un duel : le résultat et la série ; un combat classé rapporte l'XP (+120 gagné, +80 perdu), les Éclats et
## des points de classement, et compte dans le jour et la semaine ; un amical ne rapporte rien (GDD V2, § 7, proposé)
## mais compte pour les objectifs. Renvoie {xp, niveaux, eclats, classe, points, points_avant}.
func fin_duel(gagne: bool, classe: bool = false) -> Dictionary:
	profile.record_result(gagne)
	compter("duels")
	if gagne:
		compter("duels_gagnes")
	if not classe:
		return {"xp": 0, "niveaux": 0, "eclats": 0, "classe": false, "points": 0, "points_avant": 0}
	var a := _arene()
	var avant := int(a["points"])
	a["points"] = Arene.points_apres(avant, gagne, data)
	a["combats_jour"] = int(a["combats_jour"]) + 1
	if gagne:
		a["victoires_semaine"] = int(a["victoires_semaine"]) + 1
	var xp := 120 if gagne else 80
	var eclats := Equipement.eclats_duel(gagne, data)
	profile.eclats += eclats
	var r := gain_xp(xp)
	publier_perso()
	return {"xp": xp, "niveaux": int(r["levels"]), "eclats": eclats, "classe": true, "points": int(a["points"]), "points_avant": avant}


## La fin d'une montée : le record de la classe (l'étage atteint) et son palier (l'étage qui suit le dernier Gardien
## franchi). Renvoie {xp} (l'XP des étages est donnée au fil de la montée).
func fin_tour(t: Tour) -> Dictionary:
	if t.atteint > int(profile.tower_records.get(lignee(), 0)):
		profile.tower_records[lignee()] = t.atteint
	profile.tower_paliers[lignee()] = maxi(palier(), Tour.palier_apres(t.atteint - 1, int(data.tour["gardien_tous_les"])))
	profile.save()
	return {"xp": 40 * maxi(0, t.atteint - t.depart)}


# ---------------------------------------------------------------------------
# La guilde (engine/guilde.gd ; sur le serveur)
# ---------------------------------------------------------------------------

## Ce que l'activité comptée apporte en Influence à la guilde (compteur des objectifs -> activité de guilde).
const INFLUENCE_PAR_COMPTEUR := {"duels": "duel", "duels_gagnes": "duel_gagne", "etages": "etage", "gardiens": "gardien"}


## Ta fiche de membre : ce que la guilde garde de toi.
func fiche_membre() -> Dictionary:
	return {"id": serveur.compte_id, "pseudo": pseudo(), "classe": player_class, "niveau": profile.level}


## Ta guilde, relue au serveur (vide sans guilde).
func ma_guilde() -> Dictionary:
	if not serveur.est_connecte():
		return guilde
	guilde = await serveur.ma_guilde()
	# Les Sanctuaires de la guilde : l'XP des jours passés (engine/carte.gd, revenus ; résolue par les guerres).
	var xp: int = await serveur.xp_territoires()
	if xp > 0:
		gain_xp(xp)
	return guilde


func creer_guilde(nom: String, banniere: Dictionary) -> bool:
	if not Guilde.nom_valide(nom, data) or not Guilde.banniere_valide(banniere, data) or not serveur.est_connecte():
		return false
	var g: Dictionary = await serveur.creer_guilde(nom, banniere, fiche_membre())
	if g.is_empty():
		return false
	guilde = g
	return true


func rejoindre_guilde(id: String) -> bool:
	if not serveur.est_connecte():
		return false
	var g: Dictionary = await serveur.rejoindre_guilde(id, fiche_membre())
	if g.is_empty():
		return false
	guilde = g
	return true


func quitter_guilde() -> bool:
	var ok: bool = await serveur.quitter_guilde()
	if ok:
		guilde = {}
	return ok


## De l'Influence pour ta guilde, d'après une activité (sans attendre le serveur).
func influence(activite: String, n: int = 1) -> void:
	var gain := Guilde.influence_de(activite, n, data)
	if guilde.is_empty() or gain <= 0:
		return
	guilde = Guilde.gagner(guilde, gain)
	serveur.influence_guilde(gain)


func acheter_effet_guilde(effet: String) -> bool:
	var g: Dictionary = await serveur.acheter_effet(effet)
	if g.is_empty():
		return false
	guilde = g
	return true


func role_guilde(membre: String, role: String) -> bool:
	var g: Dictionary = await serveur.role_guilde(membre, role)
	if g.is_empty():
		return false
	guilde = g
	return true


func exclure_guilde(membre: String) -> bool:
	var g: Dictionary = await serveur.exclure_guilde(membre)
	if g.is_empty():
		return false
	guilde = g
	return true


## Les rôles libres (décision de Gautier du 1er novembre) et le recrutement : chaque appel rend vrai si le serveur a
## accepté, et garde la guilde relue.
func _garder(g: Dictionary) -> bool:
	if g.is_empty():
		return false
	guilde = g
	return true


func definir_role_guilde(r: Dictionary) -> bool:
	return _garder(await serveur.definir_role(r))


func supprimer_role_guilde(id_role: String) -> bool:
	return _garder(await serveur.supprimer_role(id_role))


func annonce_guilde(texte: String) -> bool:
	return _garder(await serveur.annonce_guilde(texte))


func recrutement_guilde(ouvert: bool) -> bool:
	return _garder(await serveur.recrutement_guilde(ouvert))


func banniere_guilde(b: Dictionary) -> bool:
	return _garder(await serveur.banniere_guilde(b))


func inviter_guilde(fiche: Dictionary) -> bool:
	return _garder(await serveur.inviter_guilde({"id": str(fiche["id"]), "pseudo": str(fiche.get("pseudo", "")), "classe": str(fiche.get("classe", "")), "niveau": int(fiche.get("niveau", 1))}))


# ---------------------------------------------------------------------------
# La carte du monde (engine/carte.gd ; qui tient quoi sur le serveur)
# ---------------------------------------------------------------------------

## Qui tient quoi cette saison, relu au serveur (et gardé), avec le nombre de guildes.
func carte_territoires() -> Dictionary:
	if not serveur.est_connecte():
		return carte_etat
	nb_guildes = await serveur.nombre_guildes()
	carte_etat = await serveur.territoires(Arene.saison(jour(), data))
	return carte_etat


## Où les donjons apparaissent cette semaine ({territoire -> donjon}).
func donjons_de_la_semaine() -> Dictionary:
	return Carte.donjons_de_la_semaine(Arene.semaine(jour()), nb_guildes, data)


# ---------------------------------------------------------------------------
# Les guerres de guilde (engine/guerre.gd ; les batailles sur le serveur)
# ---------------------------------------------------------------------------

## Les batailles de ce soir (les soirs passés sont résolus au passage).
func batailles_du_jour() -> Array:
	return await serveur.batailles(jour())


## Pourquoi ta guilde ne peut pas attaquer ce territoire ce soir ("" si elle le peut).
func empeche_guerre(territoire: String, batailles: Array) -> String:
	return Guerre.empeche(carte_etat, serveur.protections(), guilde, territoire, jour(), batailles, data)


## Déclarer une attaque : la bataille (vide si refusée ; `serveur.erreur` dit pourquoi).
func declarer_guerre(territoire: String) -> Dictionary:
	return await serveur.declarer_guerre(territoire)


## Un combat de guerre dans une bataille : ton trio contre celui du défenseur (ou d'un garde). Les options du combat
## (comme duel_classe), vides s'il ne te reste pas de combat.
func duel_guerre(id: String) -> Dictionary:
	var c: Dictionary = await serveur.combat_guerre(id)
	if c.is_empty():
		return {}
	var adv: Dictionary = c["adversaire"]
	var chef := Serveur.destin_de(adv, data)
	chef.echo = false
	var ennemis := Trio.camp(chef, int(adv["niveau"]), data)
	var e := Regles.nouveau_combat(trio(), ennemis, profile.level, "pvp", data)
	var noms := noms_trio()
	noms["b1"] = str(adv["pseudo"])
	return {"etat": e, "noms": noms, "guerre": id, "bataille": c["bataille"], "adversaire": {"nom": str(adv["pseudo"]), "niveau": int(adv["niveau"]), "garde": str(adv["id"]).begins_with("garde-")}}


## La fin d'un combat de guerre : le résultat noté dans la bataille ; un combat de guerre rapporte l'XP d'un amical (rien)
## et compte comme un duel. Renvoie la bataille (vide si rien n'était en cours).
func fin_guerre(id: String, gagne: bool) -> Dictionary:
	fin_duel(gagne, false)
	return await serveur.resultat_guerre(id, gagne)


## Les territoires que tient ta guilde (vide sans guilde).
func territoires_de_ma_guilde() -> Array[String]:
	if guilde.is_empty():
		return [] as Array[String]
	return Carte.tenus_par(carte_etat, str(guilde["id"]))


## Ai-je ce pouvoir dans ma guilde ?
func peut_guilde(pouvoir: String) -> bool:
	return Guilde.peut(guilde, serveur.compte_id, pouvoir)


## Le coût d'une reforge pour toi : celui de l'objet, moins la Forge de guilde.
func cout_reforge(objet: Dictionary) -> int:
	return maxi(1, Regles.plancher(float(Equipement.cout_reforge(objet, data)) * (1.0 - Guilde.bonus(guilde, "reforge", data))))


func class_label(class_id: String) -> String:
	var cls := data.classe(class_id)
	return "%s · %s" % [cls["nom"], UiKit.ROLE_LABELS[cls["role"]]]
