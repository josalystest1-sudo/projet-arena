## L'écran de combat V2 (docs/SPEC-COMBAT-V2.md, section 12.2) : une seule scène d'arène, à 3 contre X (docs/GDD_V2.md) :
## le trio ennemi en haut (à la Tour, de 1 à 6 monstres, le plus gros au centre), le trio du joueur en bas, lui au
## milieu, ses deux Échos de part et d'autre. En haut : le tour, le chrono, « Quitter ». En bas : le bandeau des
## Synergies, la bande de la voie en cours, les six cases fixes (moyeu en bas à gauche, puis les voies ; dorées si elles
## complètent une Synergie avec ce qu'un Écho a annoncé), une ligne d'aide (ce que fait la case choisie). Les deux
## Échos annoncent leur choix avant le joueur (pastille et trait vers la cible). Jouer : toucher une case, puis la toucher encore. Toucher une pastille ou un point d'une voie : sa
## fiche, jusqu'au toucher suivant ; un appui long : la même, tant que le doigt reste posé.
## L'adversaire est caché (décision de Gautier du 29 octobre, docs/GDD_V2.md § 4.2) : ni ses voies, ni ses menaces, ni
## l'annonce de son acolyte ; seulement son nom, sa classe, ses PV, ses états (avec leurs tours) et une lueur quand sa
## Clé est prête. On le découvre en le regardant jouer : sa fiche (appui long) liste ce qu'on l'a vu jouer.
## Affichage seulement : toute la règle vient de res://engine (Regles, IA, Texte, Tour).
extends Control

const ResolutionVue := preload("res://scenes/combat/resolution_view.gd")

const HAUT := 52.0
const HUD_H := 410.0
const OR := Color("e3b85f")
const TEAL := Color("5cc8b8")
const ROUGE := Color("d35b5b")
const VIOLET := Color("c9a0ff")
const TEXTE := Color("efe9d9")
const ATTENUE := Color("aaa49b")
const NUIT := Color("0f0e17")
const SURFACE := Color("1c1a28")
const SURFACE_HAUTE := Color("262337")
## L'ordre des cases : la rangée du haut (voies 3, 4, 5), puis celle du bas (moyeu, voies 1, 2).
const ORDRE_CASES := [3, 4, 5, 0, 1, 2]
## Les places des deux trios dans l'arène (fractions de sa largeur et de sa hauteur) et la taille de leur pixel : le
## joueur au milieu et devant, ses Échos de part et d'autre ; de même en face (ou un acolyte, dans un ancien duo).
const PLACES := {"a1": [0.50, 0.75, 7.5], "a2": [0.20, 0.66, 6.0], "a3": [0.80, 0.66, 6.0],
	"b1": [0.50, 0.26, 6.5], "b2": [0.20, 0.17, 6.0], "b3": [0.80, 0.17, 6.0]}
## À la Tour, les places des monstres selon leur nombre, le plus gros d'abord (au centre, devant).
const PLACES_MONSTRES := {
	1: [[0.50, 0.24]],
	2: [[0.32, 0.22], [0.68, 0.22]],
	3: [[0.50, 0.26], [0.18, 0.17], [0.82, 0.17]],
	4: [[0.35, 0.34], [0.65, 0.34], [0.20, 0.13], [0.80, 0.13]],
	5: [[0.50, 0.34], [0.20, 0.30], [0.80, 0.30], [0.35, 0.11], [0.65, 0.11]],
	6: [[0.20, 0.34], [0.50, 0.34], [0.80, 0.34], [0.20, 0.11], [0.50, 0.11], [0.80, 0.11]]}

var app: ArenaApp
var e: EtatCombat
var tour: Tour = null
## Une descente de donjon (une vague, l'élite ou le boss), ou null ; et le dernier message du boss à paliers.
var donjon: Donjon = null
var message_boss := ""
var noms := {}
## Un combat classé de l'Arène (ses points en jeu) ou un amical.
var classe := false
var vues := {}
var declarations := {}
var choisie := -1
var verrouillee := false
var chrono := -1.0
var phase := "choix"
var arene: Control
var traits: Control
var lbl_tour: Label
var lbl_chrono: Label
var btn_quitter: Button
var bande: BandeVoie
var bandeau: BandeauSynergie
var cases := {}
var aide: Label
var popup: PanelContainer = null
## La fiche ouverte se ferme au relâchement (appui long) ou au toucher suivant ; un toucher sur ce qui vient de la
## fermer ne la rouvre pas.
var popup_tenu := true
var _popup_cle := ""
var _fermee := {"cle": "", "t": -10.0}
## Les Synergies que chaque case compléterait avec l'annonce de l'acolyte : index -> { exact, ailleurs, cible }.
var _syn := {}
## Les pastilles d'annonce des acolytes (dans l'arène), pour les toucher.
var _annonces := {}
var feuille: Control = null
## Le tracé des deux joueurs sur leur roue (pour la fin du combat), les Synergies du trio, et la part de chacun des trois
## (dégâts infligés, soins, dégâts absorbés par ses barrières).
var trace := {"a1": [], "b1": []}
## Ce qu'on a vu jouer chaque ennemi, dans l'ordre, sans doublon (sa fiche le rappelle).
var vus := {}
var parts := {}
## Qui a posé la barrière de chaque allié (pour la part de chacun).
var _poseurs := {}
var synergies: Array = []
var _quitter_arme := 0.0
var _dernier_tic := 0
var _t := 0.0


func setup(p_app: ArenaApp, options: Dictionary) -> void:
	app = p_app
	e = options["etat"]
	tour = options.get("tour", null)
	donjon = options.get("donjon", null)
	noms = options.get("noms", {})
	classe = bool(options.get("classe", false))
	_construire()
	_debut_tour()


# --- Construction ------------------------------------------------------------------

func _construire() -> void:
	arene = Control.new()
	arene.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(arene)
	traits = Control.new()
	traits.mouse_filter = Control.MOUSE_FILTER_IGNORE
	traits.draw.connect(_dessiner_traits)
	arene.add_child(traits)
	for id in e.ordre:
		var fiche := e.fiche(id)
		var allie: bool = fiche["camp"] == "a"
		var pixel := 6.0
		if PLACES.has(id) and not (tour != null and id.begins_with("b")):
			pixel = PLACES[id][2]
		elif tour != null and id.begins_with("b"):
			# À partir de 4 monstres, l'arène est pleine : ils restent petits.
			pixel = 4.5 + 2.0 * _pv_mult(str(fiche["sprite"]))
			if e.vivants("b").size() + _ko_en_face() >= 4:
				pixel = minf(pixel, 5.0)
		var v := UnitView.make(id, str(fiche["sprite"]), str(noms.get(id, fiche["nom"])), pixel, allie)
		v.touche.connect(_on_perso_touche)
		v.appui_long.connect(_on_perso_appui_long)
		v.pastille.connect(_on_pastille)
		arene.add_child(v)
		vues[id] = v
	# Le haut : le tour, le chrono, Quitter.
	lbl_tour = UiKit.label("", 18, ATTENUE, false)
	lbl_tour.position = Vector2(16, 14)
	lbl_tour.size = Vector2(240, 30)
	add_child(lbl_tour)
	lbl_chrono = UiKit.label("", 34, OR)
	lbl_chrono.position = Vector2(0, 4)
	add_child(lbl_chrono)
	btn_quitter = Button.new()
	btn_quitter.text = "Quitter"
	btn_quitter.flat = true
	btn_quitter.add_theme_font_size_override("font_size", 18)
	btn_quitter.add_theme_color_override("font_color", ATTENUE)
	btn_quitter.pressed.connect(_on_quitter)
	add_child(btn_quitter)
	# Le bas : le bandeau des Synergies, la bande de la voie, les six cases, l'aide.
	var hud := VBoxContainer.new()
	hud.name = "hud"
	hud.add_theme_constant_override("separation", 6)
	add_child(hud)
	bandeau = BandeauSynergie.new()
	hud.add_child(bandeau)
	bande = BandeVoie.new()
	bande.noeud_touche.connect(func(v, r, ancre, tenu): _ouvrir_fiche(_fiche_noeud("a1", v, r), ancre, tenu, "a1|%d|%d" % [v, r]))
	hud.add_child(bande)
	var grille := GridContainer.new()
	grille.columns = 3
	grille.add_theme_constant_override("h_separation", 8)
	grille.add_theme_constant_override("v_separation", 8)
	hud.add_child(grille)
	for i in ORDRE_CASES:
		var c := CaseNoeud.new()
		c.index = i
		c.touche.connect(_on_case_touche)
		c.appui_long.connect(_on_case_appui_long)
		grille.add_child(c)
		cases[i] = c
	aide = UiKit.label("", 14, ATTENUE)
	aide.custom_minimum_size = Vector2(0, 40)
	aide.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	aide.max_lines_visible = 2
	hud.add_child(aide)
	resized.connect(_placer)
	_placer()


func _ko_en_face() -> int:
	var n := 0
	for id in e.ordre:
		if e.camp(id) == "b" and not e.vivant(id):
			n += 1
	return n


func _pv_mult(sprite: String) -> float:
	var monstres: Dictionary = app.data.bestiaire["monstres"]
	return float(monstres[sprite]["pv_mult"]) if monstres.has(sprite) else 1.0


func _placer() -> void:
	var hud: Control = get_node("hud")
	hud.position = Vector2(12, size.y - HUD_H)
	hud.size = Vector2(size.x - 24, HUD_H - 8)
	lbl_chrono.size = Vector2(size.x, 44)
	btn_quitter.position = Vector2(size.x - 110, 10)
	btn_quitter.size = Vector2(100, 36)
	arene.position = Vector2(0, HAUT)
	arene.size = Vector2(size.x, size.y - HUD_H - arene.position.y)
	traits.size = arene.size
	var monstres: Array = []
	for id in e.ordre:
		if tour != null and id.begins_with("b"):
			monstres.append(id)
	# À la Tour : le plus gros monstre au centre, les autres de part et d'autre.
	monstres.sort_custom(func(x, y): return _pv_mult(str(e.fiche(x)["sprite"])) > _pv_mult(str(e.fiche(y)["sprite"])))
	var places_tour: Array = PLACES_MONSTRES[clampi(monstres.size(), 1, 6)]
	for id in e.ordre:
		var v: UnitView = vues[id]
		var f := Vector2.ZERO
		if tour != null and id.begins_with("b"):
			var k := mini(monstres.find(id), places_tour.size() - 1)
			f = Vector2(places_tour[k][0], places_tour[k][1])
		else:
			f = Vector2(PLACES[id][0], PLACES[id][1])
		var centre := Vector2(arene.size.x * f.x, arene.size.y * f.y)
		v.position = centre - Vector2(v.size.x / 2.0, v.rect_sprite().size.y / 2.0)


func _draw() -> void:
	# Le ciel et le sol de l'arène.
	draw_rect(Rect2(Vector2.ZERO, size), NUIT)
	var haut_sol := arene.position.y + arene.size.y * 0.35
	for i in range(12):
		var t := float(i) / 12.0
		draw_rect(Rect2(0, t * haut_sol, size.x, haut_sol / 12.0 + 1.0), NUIT.lerp(Color("2a2140"), t * 0.8))
	draw_rect(Rect2(0, haut_sol, size.x, size.y - haut_sol), Color("1a1726"))
	draw_set_transform(Vector2(size.x * 0.5, haut_sol + (size.y - HUD_H - haut_sol) * 0.55), 0.0, Vector2(1.0, 0.32))
	draw_circle(Vector2.ZERO, size.x * 0.62, Color("221d33"))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_rect(Rect2(0, size.y - HUD_H - 6, size.x, HUD_H + 6), Color(NUIT, 0.92))
	draw_line(Vector2(0, size.y - HUD_H - 6), Vector2(size.x, size.y - HUD_H - 6), Color("3a3650"), 1.0)


# --- Un tour ------------------------------------------------------------------------

func _debut_tour() -> void:
	phase = "choix"
	choisie = -1
	verrouillee = false
	declarations = IA.declarer(e, ["a1"])
	chrono = float(e.regles["chrono_s"]) if tour == null else -1.0
	_dernier_tic = 0
	_maj()
	if message_boss != "":
		aide.text = message_boss
		message_boss = ""
	if Regles.actions_legales(e, "a1").is_empty():
		# KO ou Étourdi : les Échos jouent seuls, le tour part tout seul.
		aide.text = "Tu ne peux pas jouer ce tour-ci : tes Échos jouent seuls." if e.vivant("a1") else "Tu es KO : tes Échos continuent seuls."

		var t := create_tween()
		t.tween_interval(1.4)
		t.tween_callback(_resoudre)


func _process(delta: float) -> void:
	_t += delta
	_quitter_arme = maxf(0.0, _quitter_arme - delta)
	if _quitter_arme <= 0.0 and btn_quitter.text != "Quitter":
		btn_quitter.text = "Quitter"
	if phase == "choix" and chrono > 0.0 and not verrouillee:
		chrono -= delta
		var s := ceili(maxf(chrono, 0.0))
		lbl_chrono.text = str(s)
		if s <= 5 and s != _dernier_tic and s > 0:
			_dernier_tic = s
			app.sfx.play("tic")
		if chrono <= 0.0:
			_resoudre()
	traits.queue_redraw()


## Tout ce qui se voit : les persos, leurs plaques, les cases, la bande, l'aide.
func _maj() -> void:
	lbl_tour.text = ("Étage %d · tour %d" % [tour.etage, e.tour]) if tour != null else "Tour %d" % e.tour
	lbl_chrono.text = "" if chrono < 0.0 else str(ceili(chrono))
	var cible_e := str(e.perso("a1")["cible_ennemie"])
	var cible_a := str(e.perso("a1")["cible_alliee"])
	if cible_e == "" or not e.vivant(cible_e):
		cible_e = Regles.cible_ennemie(e, "a1") if e.vivant("a1") else ""
	if cible_a == "" or not e.vivant(cible_a):
		cible_a = Regles.cible_alliee(e, "a1") if e.vivant("a1") else ""
	e.perso("a1")["cible_ennemie"] = cible_e
	e.perso("a1")["cible_alliee"] = cible_a
	for id in e.ordre:
		var v: UnitView = vues[id]
		var p := e.perso(id)
		v.pv = int(p["pv"])
		v.pv_max = int(e.fiche(id)["pv_max"])
		v.barriere = int(p["barriere"])
		v.ko = bool(p["ko"])
		v.cible_ennemie = id == cible_e and phase == "choix"
		v.cible_alliee = id == cible_a and phase == "choix" and id != "a1"
		v.menaces = []
		# L'adversaire est caché : pas de menaces, seulement la lueur quand sa Clé est prête.
		v.cle_prete = e.camp(id) == "b" and phase == "choix" and _cle_prete(id)
		v.verrou = donjon != null and id == "b1" and donjon.verrou >= 0
		for m in Regles.menaces(e, id) if e.camp(id) == "a" else []:
			var n := e.noeud(id, int(m["voie"]), int(m["rang"]))
			var pic := Texte.picto(n["effets"][0])
			pic["cible"] = str(app.data.textes["pictos"]["cibles"][str(n["effets"][0]["cible"])])
			pic["echeance"] = int(m["echeance"])
			pic["barre"] = bool(m["barre"])
			pic["voie"] = int(m["voie"])
			pic["rang"] = int(m["rang"])
			v.menaces.append(pic)
		v.etats = []
		for nom in p["etats"]:
			var restants := e.tours_restants(id, str(nom))
			if restants <= 0:
				continue
			var def: Dictionary = e.defs_etats[nom]
			v.etats.append({"nom": nom, "pictogramme": def["pictogramme"], "couleur": def["couleur"], "tours": restants})
	_calculer_synergies()
	_maj_cases()
	_maj_bandeau()
	_maj_aide()


## La ligne d'aide : ce que fait la case choisie, sinon la cible et comment jouer.
func _maj_aide() -> void:
	if not e.vivant("a1") or Regles.actions_legales(e, "a1").is_empty():
		return
	var cible_e := str(e.perso("a1")["cible_ennemie"])
	var nom_cible := _nom(cible_e) if cible_e != "" else "—"
	if choisie < 0 or not cases.has(choisie) or cases[choisie].vide:
		aide.text = "Cible : %s · touche une case pour voir ce qu'elle fait, deux fois pour la jouer" % nom_cible
		return
	var voie := choisie - 1
	var rang := 0 if choisie == 0 else int(e.perso("a1")["jalons"][voie]) + 1
	var a := Regles.action("a1", "moyeu" if choisie == 0 else "voie", voie, rang, cible_e, str(e.perso("a1")["cible_alliee"]))
	var cible := _cible_de("a1", a)
	var sur := (" (sur %s)" % ("toi" if cible == "a1" else _nom(cible))) if cible != "" else ""
	aide.text = "%s : %s%s%s" % [cases[choisie].nom, Texte.ligne_en_combat(e, "a1", voie, rang), sur,
		" · touche encore pour jouer" if not verrouillee else " · verrouillé (appui long pour changer)"]


func _maj_cases() -> void:
	var legales := {}
	for a in Regles.actions_legales(e, "a1"):
		legales[0 if a["source"] == "moyeu" else int(a["voie"]) + 1] = a
	var p := e.perso("a1")
	for i in cases:
		var c: CaseNoeud = cases[i]
		c.choisie = i == choisie
		c.verrouillee = verrouillee and i == choisie
		c.aveugle = e.a_etat("a1", "aveugle")
		c.raison = ""
		var voie: int = i - 1
		var rang := 0
		if i > 0:
			rang = int(p["jalons"][voie]) + 1
			if rang > 4 or not bool(e.noeud("a1", voie, rang)["allume"]):
				c.vide = true
				c.jouable = false
				c.synergie = ""
				c.synergie_ailleurs = ""
				continue
		c.vide = false
		var n := e.noeud("a1", voie, rang)
		c.nom = Texte.nom(n)
		c.ligne = _ligne_courte(n, voie, rang)
		c.pictos = Texte.pictos(n)
		for pic in c.pictos:
			pic["cible"] = str(app.data.textes["pictos"]["cibles"][str(n["effets"][c.pictos.find(pic)]["cible"])])
		c.cle = rang == 4
		c.jouable = legales.has(i)
		var s: Dictionary = _syn.get(i, {})
		c.synergie = " · ".join(s.get("exact", []))
		c.synergie_ailleurs = ""
		if c.synergie == "" and not s.get("ailleurs", []).is_empty():
			c.synergie_ailleurs = "%s : vise %s" % [s["ailleurs"][0], _nom(str(s["cible"]))]
		if not c.jouable and e.vivant("a1"):
			c.raison = _raison(voie, rang)
		if c.aveugle:
			var mono := false
			for ef in n["effets"]:
				mono = mono or ef["cible"] == "un_ennemi"
			c.aveugle = mono
	# La bande : la voie choisie, sinon la dernière jouée, sinon la première.
	var v := choisie - 1 if choisie > 0 else (int(p["last_voie"]) if int(p["last_voie"]) >= 0 else 0)
	_maj_bande(bande, "a1", v)


## « 60 + 30×3 » : les nombres seuls, avec le niveau, le multiplicateur de classe et les éclats.
func _ligne_courte(_n: Dictionary, voie: int, rang: int) -> String:
	var morceaux: Array[String] = []
	for p in _pictos_en_combat("a1", voie, rang):
		if str(p["texte"]) != "":
			morceaux.append(str(p["texte"]))
	return " + ".join(morceaux)


## Les pictogrammes d'un nœud d'un perso, avec ses chiffres en combat (niveau, multiplicateur de classe, éclats).
func _pictos_en_combat(id: String, voie: int, rang: int) -> Array[Dictionary]:
	var fiche := e.fiche(id)
	var bonus := 0.0 if rang == 0 else float(fiche["bonus"][voie][rang - 1])
	return Texte.pictos(e.noeud(id, voie, rang), Regles.multiplicateur_niveau(e) * float(fiche["k"]) * (1.0 + bonus), 1.0 + bonus, null, fiche.get("mods", {}), rang, bonus)


func _nom(id: String) -> String:
	return str(noms.get(id, e.fiche(id)["nom"])) if id != "" else ""


## Le perso que vise une action (celui de son premier effet à une seule cible ; soi), ou "" (tous, le duo).
func _cible_de(id: String, a: Dictionary) -> String:
	for ef in Regles.noeud_de(e, a)["effets"]:
		match str(ef["cible"]):
			"un_ennemi":
				return str(a["cible_ennemie"])
			"un_allie":
				return str(a["cible_alliee"])
			"soi":
				return id
	return ""


## Ceux qui annoncent avant un joueur dans son camp (ses deux Échos, ou un acolyte) et qui ont annoncé ce tour-ci.
func _annonceurs(id: String) -> Array[String]:
	var out: Array[String] = []
	for autre in e.ordre:
		if autre != id and e.camp(autre) == e.camp(id) and e.fiche(autre)["place"] in ["acolyte", "echo"] and declarations.has(autre):
			out.append(autre)
	return out


# --- Les Synergies -----------------------------------------------------------------------

## Les Synergies que chaque case du joueur compléterait avec l'annonce d'un de ses Échos (avec la cible choisie :
## exact ; seulement en visant un autre perso : ailleurs).
func _calculer_synergies() -> void:
	_syn = {}
	if not e.vivant("a1") or phase != "choix":
		return
	var ce := str(e.perso("a1")["cible_ennemie"])
	var ca := str(e.perso("a1")["cible_alliee"])
	var possibles: Array[Dictionary] = []
	for x in _annonceurs("a1"):
		possibles.append_array(Regles.synergies_possibles(e, "a1", declarations[x]))
	for o in possibles:
		var a: Dictionary = o["action"]
		var i := 0 if a["source"] == "moyeu" else int(a["voie"]) + 1
		if not _syn.has(i):
			_syn[i] = {"exact": [], "ailleurs": [], "cible": ""}
		var s: Dictionary = _syn[i]
		var exact := str(a["cible_ennemie"]) == ce and str(a["cible_alliee"]) == ca
		for nom_syn in o["noms"]:
			if exact and not nom_syn in s["exact"]:
				s["exact"].append(nom_syn)
			elif not exact and not nom_syn in s["ailleurs"]:
				s["ailleurs"].append(nom_syn)
				if s["cible"] == "":
					s["cible"] = str(a["cible_ennemie"]) if str(a["cible_ennemie"]) != ce else str(a["cible_alliee"])


## Le bandeau des Synergies : prête (la case choisie en complète une), possible (des cases dorées), en visant un autre
## perso, ou un rappel des quatre.
func _maj_bandeau() -> void:
	var annonceurs := _annonceurs("a1")
	if phase != "choix" or not e.vivant("a1") or Regles.actions_legales(e, "a1").is_empty():
		bandeau.maj("", "", "")
		return
	if annonceurs.is_empty():
		bandeau.maj("aucune", "Pas de Synergie ce tour-ci : tes Échos ne jouent pas", _rappel_synergies()[0], _rappel_synergies()[1])
		return
	var jeux: Array[String] = []
	for x in annonceurs:
		jeux.append("%s joue %s" % [_nom(x), Texte.nom(Regles.noeud_de(e, declarations[x]))])
	var joue := " · ".join(jeux)
	var exact: Array = []
	var ailleurs: Array = []
	var cible_ailleurs := ""
	for i in _syn:
		for n in _syn[i]["exact"]:
			if not n in exact:
				exact.append(n)
		for n in _syn[i]["ailleurs"]:
			if not n in ailleurs:
				ailleurs.append(n)
				if cible_ailleurs == "":
					cible_ailleurs = str(_syn[i]["cible"])
	var choisies: Array = _syn.get(choisie, {}).get("exact", []) if choisie >= 0 else []
	if not choisies.is_empty():
		var s := Texte.synergie(str(choisies[0]))
		bandeau.maj("prete", "SYNERGIE PRÊTE : %s ! Touche encore pour jouer" % " · ".join(choisies).to_upper(), joue + " + ta case dorée",
			"%s : %s" % [s["regle"].substr(0, 1).to_upper() + s["regle"].substr(1), s["effet"]])
	elif not exact.is_empty():
		var s := Texte.synergie(str(exact[0]))
		bandeau.maj("possible", "SYNERGIE POSSIBLE : %s · joue une case dorée" % " · ".join(exact).to_upper(), joue,
			"%s : %s" % [s["regle"].substr(0, 1).to_upper() + s["regle"].substr(1), s["effet"]])
	elif not ailleurs.is_empty():
		var s := Texte.synergie(str(ailleurs[0]))
		bandeau.maj("ailleurs", "Synergie %s possible : vise %s" % [" · ".join(ailleurs), _nom(cible_ailleurs)], joue,
			"%s : %s" % [s["regle"].substr(0, 1).to_upper() + s["regle"].substr(1), s["effet"]])
	else:
		bandeau.maj("aucune", "%s : pas de Synergie avec ce coup" % joue, _rappel_synergies()[0], _rappel_synergies()[1])


## Le rappel des quatre Synergies, quand aucune n'est possible.
func _rappel_synergies() -> Array[String]:
	return ["Synergies : contrôle + coup · deux DoT · barrière + soin · Renfort + coup",
		"(toi et un Écho, ou tes deux Échos, le même tour ; sur la même cible, sauf Renfort + coup)"]


## Un ennemi a-t-il sa Clé prête (jouable ce tour-ci) ? Le seul signal qu'on voit de ses voies.
func _cle_prete(id: String) -> bool:
	for a in Regles.actions_legales(e, id):
		if a["source"] == "voie" and int(a["rang"]) == 4:
			return true
	return false


func _raison(voie: int, rang: int) -> String:
	if e.a_etat("a1", "etourdi"):
		return "chaines"
	if e.a_etat("a1", "gele") and rang > 0:
		return "flocon"
	if rang == 0:
		return ""
	if int(e.perso("a1")["spent_until"][voie][rang - 1]) > e.tour:
		return "sablier"
	if rang == 4 and e.a_etat("a1", "silencie"):
		return "baillon"
	return "racine"


func _maj_bande(b: BandeVoie, id: String, voie: int) -> void:
	var p := e.perso(id)
	b.voie = voie
	b.jalon = int(p["jalons"][voie])
	var n1 := e.noeud(id, voie, 1)
	b.picto = Texte.picto(n1["effets"][0])
	for r in range(1, 5):
		b.allumes[r - 1] = bool(e.noeud(id, voie, r)["allume"])
		b.eteints[r - 1] = maxi(0, int(p["spent_until"][voie][r - 1]) - e.tour)
	b.echeance_cle = Regles.echeance(e, id, voie, 4) if b.allumes[3] and b.jalon < 4 else 0
	b.cle_barree = Regles._empeche(e, id, voie, 4, e.tour + b.echeance_cle - 1) if b.echeance_cle > 0 else false
	b.titre = str(e.fiche(id)["voies"][voie]["nom"])


# --- Toucher ------------------------------------------------------------------------

func _on_case_touche(i: int) -> void:
	_fermer_popup()
	if phase != "choix" or verrouillee:
		return
	var c: CaseNoeud = cases[i]
	if not c.jouable:
		app.sfx.play("bloque", 1.2, -8.0)
		return
	if choisie == i:
		verrouillee = true
		app.sfx.play("clic", 0.8)
		_maj_cases()
		_maj_aide()
		var rang := 0 if i == 0 else int(e.perso("a1")["jalons"][i - 1]) + 1
		declarations["a1"] = Regles.action("a1", "moyeu" if i == 0 else "voie", i - 1, rang, str(e.perso("a1")["cible_ennemie"]), str(e.perso("a1")["cible_alliee"]))
		# Contre l'IA, personne d'autre à attendre : le tour part tout de suite.
		var t := create_tween()
		t.tween_interval(0.25)
		t.tween_callback(_resoudre)
	else:
		choisie = i
		app.sfx.play("clic", 1.3, -6.0)
		_maj_cases()
		_maj_bandeau()
		_maj_aide()


func _on_case_appui_long(i: int) -> void:
	if phase != "choix":
		return
	if verrouillee and i == choisie:
		verrouillee = false
		_maj_cases()
		_maj_aide()
		return
	var c: CaseNoeud = cases[i]
	if c.vide:
		return
	var rang := 0 if i == 0 else int(e.perso("a1")["jalons"][i - 1]) + 1
	_ouvrir_fiche(_fiche_noeud("a1", i - 1, rang), c.global_position + Vector2(c.size.x / 2.0, 0))


func _on_perso_touche(id: String) -> void:
	_fermer_popup()
	if phase != "choix" or not e.vivant(id) or not e.vivant("a1"):
		return
	if e.camp(id) == "b":
		e.perso("a1")["cible_ennemie"] = id
	else:
		e.perso("a1")["cible_alliee"] = id
	app.sfx.play("clic", 1.1, -8.0)
	_maj()


func _on_perso_appui_long(id: String) -> void:
	_ouvrir_feuille(id)


## Une pastille sous un perso : la Clé prête d'un ennemi, la fiche de la menace (le nœud), de l'état, ou la liste de
## tout ce qu'il porte.
func _on_pastille(id: String, index: int, ancre: Vector2, tenu: bool) -> void:
	var v: UnitView = vues[id]
	var c := v.contenu_pastille(index)
	var cle := "%s|pastille|%d" % [id, index]
	match str(c["type"]):
		"cle":
			var box := _nouveau_popup(tenu, cle, VIOLET)
			if box == null:
				return
			box.add_child(UiKit.label("Clé prête", 21, VIOLET, false))
			box.add_child(UiKit.label("%s peut lancer son gros coup ce tour-ci. Tu ne sais pas lequel : ses voies sont cachées." % _nom(id), 17, TEXTE, false))
			_montrer_popup(box, ancre)
		"menace":
			var m: Dictionary = v.menaces[c["i"]]
			_ouvrir_fiche(_fiche_noeud(id, int(m["voie"]), int(m["rang"])), ancre, tenu, cle)
		"etat":
			_ouvrir_fiche_etat(id, str(v.etats[c["i"]]["nom"]), ancre, tenu, cle)
		_:
			_ouvrir_liste(id, ancre, tenu, cle)


func _input(event: InputEvent) -> void:
	if popup == null or not event is InputEventMouseButton or event.button_index != MOUSE_BUTTON_LEFT:
		return
	# Une fiche ouverte par un appui long se ferme au relâchement ; par un toucher, au toucher suivant.
	if popup_tenu and not event.pressed:
		_fermer_popup()
	elif not popup_tenu and event.pressed:
		_fermee = {"cle": _popup_cle, "t": _t}
		_fermer_popup()


## Toucher la pastille d'annonce d'un acolyte : la fiche du nœud annoncé.
func _gui_input(event: InputEvent) -> void:
	if phase != "choix" or not event is InputEventMouseButton or event.button_index != MOUSE_BUTTON_LEFT or event.pressed:
		return
	var pos: Vector2 = event.position - arene.position
	for id in _annonces:
		if (_annonces[id] as Rect2).grow(6.0).has_point(pos) and declarations.has(id):
			var a: Dictionary = declarations[id]
			var rang := int(a["rang"]) if a["source"] == "voie" else 0
			_ouvrir_fiche(_fiche_noeud(id, int(a["voie"]), rang), arene.global_position + (_annonces[id] as Rect2).get_center() + Vector2(0, 20), false, "%s|annonce" % id)
			return


# --- Fiches -------------------------------------------------------------------------

func _fiche_noeud(id: String, voie: int, rang: int) -> Dictionary:
	return Texte.fiche(e, id, voie, rang, "a1")


## Une fiche flottante, vide ; rend sa colonne, ou null si ce toucher est celui qui vient de la fermer.
func _nouveau_popup(tenu: bool, cle: String, bord: Color = OR) -> VBoxContainer:
	_fermer_popup()
	if not tenu and cle != "" and _fermee["cle"] == cle and _t - float(_fermee["t"]) < 0.6:
		return null
	popup_tenu = tenu
	_popup_cle = cle
	popup = PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = SURFACE_HAUTE
	style.border_color = bord
	style.set_border_width_all(2)
	style.set_corner_radius_all(12)
	style.set_content_margin_all(10)
	popup.add_theme_stylebox_override("panel", style)
	popup.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(minf(size.x - 24.0, 440.0), 0)
	box.add_theme_constant_override("separation", 3)
	popup.add_child(box)
	return box


## La fiche flottante, au-dessus de l'ancre (en dessous s'il n'y a pas la place), dans l'écran.
func _montrer_popup(box: VBoxContainer, ancre: Vector2) -> void:
	for child in box.get_children():
		if child is Control:
			(child as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	var p := popup
	add_child(p)
	await get_tree().process_frame
	if popup == null or popup != p:
		return
	var pos := Vector2(ancre.x - popup.size.x / 2.0, ancre.y - popup.size.y - 16.0) - global_position
	if pos.y < 8.0:
		pos.y = ancre.y - global_position.y + 30.0
	pos.x = clampf(pos.x, 8.0, size.x - popup.size.x - 8.0)
	pos.y = clampf(pos.y, 8.0, maxf(8.0, size.y - popup.size.y - 8.0))
	popup.position = pos


## La fiche d'un état posé sur un perso : ce qu'il fait, sa valeur, combien de tours encore, qui l'a posé.
func _ouvrir_fiche_etat(id: String, nom_etat: String, ancre: Vector2, tenu: bool, cle: String) -> void:
	var f := Texte.fiche_etat(e, id, nom_etat, noms)
	var box := _nouveau_popup(tenu, cle, Color(f["couleur"]))
	if box == null:
		return
	var titre := HBoxContainer.new()
	titre.add_theme_constant_override("separation", 8)
	titre.add_child(Picto.make(str(f["pictogramme"]), Color(f["couleur"]), 24.0))
	titre.add_child(UiKit.label(str(f["nom"]) + ("  " + str(f["valeur"]) if str(f["valeur"]) != "" else ""), 21, Color(f["couleur"]), false))
	box.add_child(titre)
	box.add_child(UiKit.label(str(f["sous_titre"]), 14, ATTENUE, false))
	box.add_child(UiKit.label(str(f["texte"]), 17, TEXTE, false))
	if str(f["source"]) != "":
		box.add_child(UiKit.label(str(f["source"]), 14, ATTENUE, false))
	_montrer_popup(box, ancre)


## Tout ce que porte un perso : ses menaces (un allié seulement : l'adversaire est caché) et ses états, une ligne
## chacun.
func _ouvrir_liste(id: String, ancre: Vector2, tenu: bool, cle: String) -> void:
	var box := _nouveau_popup(tenu, cle)
	if box == null:
		return
	box.add_child(UiKit.label(_nom(id), 21, OR, false))
	for m in Regles.menaces(e, id) if e.camp(id) == "a" else []:
		var f := _fiche_noeud(id, int(m["voie"]), int(m["rang"]))
		box.add_child(UiKit.label("%s : %s · %s" % [f["nom"], f["ligne"], f["echeance"]], 15, TEXTE, false))
	for nom_etat in e.perso(id)["etats"]:
		if e.tours_restants(id, str(nom_etat)) > 0:
			var f := Texte.fiche_etat(e, id, str(nom_etat), noms)
			box.add_child(UiKit.label("%s%s : %s" % [f["nom"], " " + str(f["valeur"]) if str(f["valeur"]) != "" else "", f["texte"]], 15, VIOLET, false))
	_montrer_popup(box, ancre)


func _ouvrir_fiche(fiche: Dictionary, ancre: Vector2, tenu: bool = true, cle: String = "") -> void:
	var box := _nouveau_popup(tenu, cle)
	if box == null:
		return
	UiKit.fiche_noeud(box, fiche)
	if str(fiche.get("echeance", "")) != "":
		box.add_child(UiKit.label(str(fiche["echeance"]), 15, OR, false))
	if fiche.has("pour_l_empecher"):
		box.add_child(UiKit.label(str(app.data.textes["fiche"]["pour_l_empecher"]), 15, TEAL, false))
		if fiche["pour_l_empecher"].is_empty():
			box.add_child(UiKit.label(str(app.data.textes["fiche"]["aucune_reponse"]), 14, ATTENUE, false))
		else:
			var ligne := HBoxContainer.new()
			ligne.add_theme_constant_override("separation", 10)
			for r in fiche["pour_l_empecher"]:
				var g := HBoxContainer.new()
				g.add_child(Picto.make(str(r["pictogramme"]), Color(str(r["couleur"])), 20.0))
				var l := Label.new()
				l.text = str(r["nom"])
				l.add_theme_font_size_override("font_size", 14)
				g.add_child(l)
				ligne.add_child(g)
			box.add_child(ligne)
	_montrer_popup(box, ancre)


func _fermer_popup() -> void:
	if popup != null:
		popup.queue_free()
		popup = null


## La fiche d'un personnage (maquette « Enemy Sheet Screen ») : nom, classe, PV, états, et ses voies ; pour un ennemi,
## caché, seulement sa Clé prête et ce qu'on l'a vu jouer.
func _ouvrir_feuille(id: String) -> void:
	_fermer_feuille()
	feuille = ColorRect.new()
	(feuille as ColorRect).color = Color(0, 0, 0, 0.55)
	feuille.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(feuille)
	var panneau := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = SURFACE
	style.set_corner_radius_all(18)
	style.set_content_margin_all(16)
	panneau.add_theme_stylebox_override("panel", style)
	panneau.anchor_left = 0.0
	panneau.anchor_right = 1.0
	panneau.anchor_top = 1.0
	panneau.anchor_bottom = 1.0
	panneau.grow_vertical = Control.GROW_DIRECTION_BEGIN
	feuille.add_child(panneau)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 6)
	panneau.add_child(col)
	var fiche := e.fiche(id)
	var classe := app.data.classe(str(fiche["classe"]))
	col.add_child(UiKit.label(str(noms.get(id, fiche["nom"])), 26, OR if e.camp(id) == "a" else ROUGE, false))
	col.add_child(UiKit.label("%s · niv. %d · %d %% PV" % [classe["nom"], e.niveau, roundi(100.0 * e.pv_pourcent(id))], 15, ATTENUE, false))
	var etats: Array[String] = []
	for nom in e.perso(id)["etats"]:
		var r := e.tours_restants(id, str(nom))
		if r > 0:
			etats.append("%s (%d tour%s)" % [e.defs_etats[nom]["nom"], r, "s" if r > 1 else ""])
	col.add_child(UiKit.label("États : " + (", ".join(etats) if not etats.is_empty() else "aucun"), 15, VIOLET, false))
	if e.camp(id) == "b":
		if e.vivant(id) and phase == "choix" and _cle_prete(id):
			col.add_child(UiKit.label("Sa Clé est prête : il peut lancer son gros coup ce tour-ci.", 15, VIOLET, false))
		var deja: Array = vus.get(id, [])
		col.add_child(UiKit.label("Vu jouer : " + (", ".join(deja) if not deja.is_empty() else "rien encore"), 15, TEXTE, false))
		col.add_child(UiKit.label("Ses voies sont cachées : tu les découvres en le regardant jouer.", 14, ATTENUE, false))
	else:
		_feuille_voies(col, id)
	var boutons := HBoxContainer.new()
	boutons.add_theme_constant_override("separation", 10)
	col.add_child(boutons)
	if e.camp(id) == "b" and e.vivant(id) and phase == "choix":
		boutons.add_child(UiKit.main_button("Le prendre pour cible", func():
			_on_perso_touche(id)
			_fermer_feuille(), 56))
	boutons.add_child(UiKit.button("Fermer", _fermer_feuille, 56))


## Les voies d'un allié dans sa fiche : son moyeu, puis la bande de chaque voie et son prochain nœud.
func _feuille_voies(col: VBoxContainer, id: String) -> void:
	var moyeu := _fiche_noeud(id, -1, 0)
	col.add_child(UiKit.label("Moyeu, toujours jouable : %s · %s" % [moyeu["nom"], moyeu["ligne"]], 14, TEXTE, false))
	col.add_child(UiKit.label("Ses voies, et le prochain nœud de chacune (touche un point : sa fiche)", 14, ATTENUE, false))
	for v in range(e.nb_voies(id)):
		var b := BandeVoie.new()
		_maj_bande(b, id, v)
		b.noeud_touche.connect(func(voie, rang, ancre, tenu): _ouvrir_fiche(_fiche_noeud(id, voie, rang), ancre, tenu, "%s|%d|%d" % [id, voie, rang]))
		col.add_child(b)
		col.add_child(_ligne_prochain(id, v))


## Sous la bande d'une voie : son prochain nœud, ce qu'il fait et quand il sera jouable.
func _ligne_prochain(id: String, v: int) -> Label:
	var rang := int(e.perso(id)["jalons"][v]) + 1
	if rang > 4 or not bool(e.noeud(id, v, rang)["allume"]):
		return UiKit.label("    Prochain : rien (la voie s'arrête là)", 13, ATTENUE, false)
	var f := _fiche_noeud(id, v, rang)
	var jouable := false
	for a in Regles.actions_legales(e, id):
		jouable = jouable or (a["source"] == "voie" and int(a["voie"]) == v and int(a["rang"]) == rang)
	var quand := "jouable ce tour-ci" if jouable else str(f["echeance"]).to_lower()
	return UiKit.label("    Prochain : %s%s · %s · %s" % [f["nom"], " (Clé)" if rang == 4 else "", f["ligne"], quand], 13,
		OR if jouable else ATTENUE, false)


func _fermer_feuille() -> void:
	if feuille != null:
		feuille.queue_free()
		feuille = null


# --- L'annonce de l'acolyte ----------------------------------------------------------

## Les annonces des Échos du joueur (celles d'en face sont cachées, comme tout l'adversaire).
func _dessiner_traits() -> void:
	_annonces = {}
	if phase != "choix":
		return
	var police := ThemeDB.fallback_font
	for id in declarations:
		if not e.fiche(id)["place"] in ["acolyte", "echo"] or e.camp(id) != "a":
			continue
		var a: Dictionary = declarations[id]
		var n := Regles.noeud_de(e, a)
		var ef: Dictionary = n["effets"][0]
		var cible := ""
		match str(ef["cible"]):
			"un_ennemi":
				cible = str(a["cible_ennemie"])
			"un_allie":
				cible = str(a["cible_alliee"])
			"soi":
				cible = id
		var depart: Vector2 = (vues[id] as UnitView).centre()
		var couleur := TEAL if e.camp(id) == "a" else ROUGE
		if cible != "" and cible != id and vues.has(cible):
			traits.draw_line(depart, (vues[cible] as UnitView).centre(), Color(couleur, 0.7), 2.0)
		# La pastille : effet · cible · son nom.
		var p := Texte.picto(ef)
		var nom := str(noms.get(id, e.fiche(id)["nom"]))
		var largeur := 64.0 + police.get_string_size(nom, HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x
		var r := Rect2(depart + Vector2(-largeur / 2.0, -(vues[id] as UnitView).rect_sprite().size.y * 0.5 - 34.0), Vector2(largeur, 28))
		_annonces[id] = r
		var style := StyleBoxFlat.new()
		style.bg_color = SURFACE
		style.border_color = couleur
		style.set_border_width_all(2)
		style.set_corner_radius_all(14)
		traits.draw_style_box(style, r)
		Picto.dessiner(traits, str(p["pictogramme"]), r.position + Vector2(16, 14), 18.0, Color(str(p["couleur"])))
		Picto.dessiner(traits, str(app.data.textes["pictos"]["cibles"][str(ef["cible"])]), r.position + Vector2(38, 14), 14.0, ATTENUE)
		traits.draw_string(police, r.position + Vector2(52, 19), nom, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, TEXTE)


# --- Résolution et fin ----------------------------------------------------------------

func _resoudre() -> void:
	if phase != "choix":
		return
	phase = "resolution"
	_fermer_popup()
	_fermer_feuille()
	bandeau.maj("", "", "")
	var avant := e
	e = Regles.resoudre_tour(e, declarations)
	if donjon != null:
		message_boss = str(donjon.apres_tour(e)["message"])
	for id in trace:
		var a: Dictionary = e.actions_jouees.get(id, {})
		if not a.is_empty() and (tour == null or id == "a1"):
			trace[id].append({"nom": Texte.nom(Regles.noeud_de(e, a)), "cle": int(a["rang"]) == 4 and a["source"] == "voie"})
	for ev in e.journal:
		var x := str(ev["acteur"])
		if x == "" or not e.statique.has(x) or e.camp(x) != "a":
			continue
		if not parts.has(x):
			parts[x] = {"degats": 0, "soins": 0, "protections": 0}
		var t := str(ev["cible"])
		match str(ev["type"]):
			"degats", "tick":
				if ev["detail"] != "gardien" and t != "" and e.camp(t) == "b":
					parts[x]["degats"] += int(ev["valeur"])
				elif ev["detail"] == "gardien":
					parts[x]["soins"] += int(ev["valeur"])
			"soin":
				parts[x]["soins"] += int(ev["valeur"])
	# Ce que les barrières de chacun ont absorbé (la barrière d'un allié : à qui l'a posée en dernier).
	for ev in e.journal:
		var t := str(ev["cible"])
		if str(ev["type"]) in ["degats", "tick"] and int(ev["absorbe"]) > 0 and t != "" and e.camp(t) == "a" and _poseurs.has(t):
			var x := str(_poseurs[t])
			if parts.has(x):
				parts[x]["protections"] += int(ev["absorbe"])
	for ev in e.journal:
		if str(ev["type"]) == "barriere" and int(ev["valeur"]) > 0 and e.camp(str(ev["cible"])) == "a":
			_poseurs[str(ev["cible"])] = str(ev["acteur"])
	for id in e.actions_jouees:
		if e.camp(id) == "b":
			var nom := Texte.nom(Regles.noeud_de(e, e.actions_jouees[id]))
			if not vus.has(id):
				vus[id] = []
			if not nom in vus[id]:
				vus[id].append(nom)
	for ev in e.journal:
		if ev["type"] == "synergie" and e.camp(str(ev["acteur"])) == "a":
			synergies.append(str(ev["detail"]))
	var vue := ResolutionVue.new()
	vue.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(vue)
	vue.jouer(app, avant, e, noms, vues)
	await vue.termine
	vue.queue_free()
	_maj()
	if e.fini:
		_fin()
	else:
		_debut_tour()


func _on_quitter() -> void:
	if phase == "fin":
		return
	if _quitter_arme <= 0.0:
		_quitter_arme = 3.0
		btn_quitter.text = "Sûr ?"
		return
	phase = "fin"
	if tour != null:
		app.fin_tour(tour)
		app.show_screen("tower")
	elif donjon != null:
		app.abandonner_donjon()
		app.show_screen("donjon")
	else:
		app.fin_duel(false, classe)
		app.show_screen("ville")


func _fin() -> void:
	phase = "fin"
	lbl_chrono.text = ""
	var options := {"etat": e, "noms": noms, "trace": trace, "synergies": synergies, "parts": parts, "classe": classe}
	if tour != null:
		options["tour"] = tour
	if donjon != null:
		options["donjon"] = donjon
	app.show_screen("fin", options)
