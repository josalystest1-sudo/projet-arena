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
	sfx = Sfx.new()
	add_child(sfx)
	sfx.muted = profile.muted
	theme = UiKit.make_theme()
	_build_layout()
	if charger_perso():
		reclamer_revenu()
		show_screen("ville")
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
	destin.mods = Equipement.mods(objets_portes(), data)
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


# ---------------------------------------------------------------------------
# La Forge : l'équipement et les Éclats
# ---------------------------------------------------------------------------

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
	var cout := Equipement.cout_reforge(objet, data)
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
	var aujourd_hui := Time.get_date_string_from_system()
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
	var aujourd_hui := Time.get_date_string_from_system()
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
	var aujourd_hui := Time.get_date_string_from_system()
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
	var aujourd_hui := Time.get_date_string_from_system()
	return {"points": int(a["points"]), "ligue": Arene.ligue(0), "saison": int(a["saison"]), "fin_saison": Arene.fin_de_saison(aujourd_hui, data),
		"restants": maxi(0, int(data.objets_arene["combats_par_jour"]) - int(a["combats_jour"])), "victoires_semaine": int(a["victoires_semaine"]),
		"coffre": Arene.rarete_coffre(int(a["victoires_semaine"]), data), "coffre_reclame": bool(a["coffre_reclame"])}


## Un combat classé : un adversaire généré à ton niveau (classe, graine, niveau, nom, équipement), contre ton trio.
## Vide s'il ne reste plus de combat classé aujourd'hui.
func duel_classe() -> Dictionary:
	if int(etat_arene()["restants"]) <= 0:
		return {}
	var adv := Arene.adversaire(profile.level, _nouvelle_graine(), data)
	var ennemis := Arene.trio_adverse(adv, data)
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
	return maxi(1, int(profile.tower_paliers.get(player_class, 1)))


## Les Faveurs de la Tour de ta classe (identifiant -> nombre de cumuls).
func faveurs() -> Dictionary:
	var out := {}
	for id in profile.tower_faveurs.get(player_class, {}):
		if data.faveurs.has(str(id)) and int(profile.tower_faveurs[player_class][id]) > 0:
			out[str(id)] = int(profile.tower_faveurs[player_class][id])
	return out


## L'XP d'un étage franchi : 40 la première fois, 20 pour un étage déjà franchi (une montée rejouée depuis un palier) ;
## +10 % par Faveur de Savoir.
func xp_etage(n: int) -> int:
	var base := 40 if n >= int(profile.tower_records.get(player_class, 0)) else 20
	return Regles.plancher(float(base) * (1.0 + Tour.valeur_faveur("savoir", int(faveurs().get("savoir", 0)), data)))


## Un étage franchi, dès qu'il l'est (pas en fin de montée seulement : fermer le jeu en pleine montée ne doit rien
## perdre) : le record de la classe et, si c'est un Gardien, le palier. Un Gardien vaincu pour la première fois offre
## une Faveur : le palier n'est alors avancé qu'au choix de la Faveur (choisir_faveur), pour qu'un jeu fermé avant le
## choix la propose encore. Le butin (un objet dans le sac, échangeable au premier passage de l'étage avec cette
## classe, lié sinon) et les Éclats de l'étage. Renvoie {gardien, faveur, propositions, premier, butin, eclats}.
func etage_franchi(t: Tour) -> Dictionary:
	var franchi := t.etage - 1
	var g := int(data.tour["gardien_tous_les"])
	var gardien := g > 0 and franchi % g == 0
	var faveur := Tour.gardien_premiere_fois(franchi, palier(), g)
	var premier := franchi >= int(profile.tower_records.get(player_class, 0))
	if t.atteint > int(profile.tower_records.get(player_class, 0)):
		profile.tower_records[player_class] = t.atteint
	if gardien and not faveur:
		profile.tower_paliers[player_class] = maxi(palier(), Tour.palier_apres(franchi, g))
	var butin := t.butin(franchi, premier)
	if not butin.is_empty():
		profile.sac.append(butin)
	var eclats := Equipement.eclats_etage(franchi, premier, data)
	profile.eclats += eclats
	profile.save()
	compter("etages")
	if gardien:
		compter("gardiens")
	return {"gardien": gardien, "faveur": faveur, "propositions": t.proposer_faveurs(franchi) if faveur else [],
		"premier": premier, "butin": butin, "eclats": eclats}


## Le choix d'une Faveur après le Gardien de l'étage franchi : elle est acquise pour ta classe, ajoutée à la montée en
## cours, et le palier est avancé.
func choisir_faveur(id: String, t: Tour) -> void:
	if not data.faveurs.has(id):
		return
	var acquises: Dictionary = profile.tower_faveurs.get(player_class, {})
	acquises[id] = int(acquises.get(id, 0)) + 1
	profile.tower_faveurs[player_class] = acquises
	profile.tower_paliers[player_class] = maxi(palier(), Tour.palier_apres(t.etage - 1, int(data.tour["gardien_tous_les"])))
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
	return {"xp": xp, "niveaux": int(r["levels"]), "eclats": eclats, "classe": true, "points": int(a["points"]), "points_avant": avant}


## La fin d'une montée : le record de la classe (l'étage atteint) et son palier (l'étage qui suit le dernier Gardien
## franchi). Renvoie {xp} (l'XP des étages est donnée au fil de la montée).
func fin_tour(t: Tour) -> Dictionary:
	if t.atteint > int(profile.tower_records.get(player_class, 0)):
		profile.tower_records[player_class] = t.atteint
	profile.tower_paliers[player_class] = maxi(palier(), Tour.palier_apres(t.atteint - 1, int(data.tour["gardien_tous_les"])))
	profile.save()
	return {"xp": 40 * maxi(0, t.atteint - t.depart)}


func class_label(class_id: String) -> String:
	var cls := data.classe(class_id)
	return "%s · %s" % [cls["nom"], UiKit.ROLE_LABELS[cls["role"]]]
