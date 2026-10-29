## L'écran de combat V2 (docs/SPEC-COMBAT-V2.md, section 12.2) : une seule scène d'arène. Le duo ennemi en haut à
## droite, le duo du joueur en bas à gauche (à la Tour, 1 à 4 monstres en haut, le plus gros au centre). En haut : le
## tour, le chrono, « Quitter ». En bas : la bande de la voie en cours, les six cases fixes (moyeu en bas à gauche, puis
## les voies), une ligne d'aide. Les acolytes annoncent leur choix en premier (pastille et trait vers la cible). Jouer :
## toucher une case, puis la toucher encore. Rien d'autre ne s'ouvre que les fiches (appui long) et le menu Quitter.
## Affichage seulement : toute la règle vient de res://engine (Regles, IA, Texte, Tour).
extends Control

const HAUT := 58.0
const HUD_H := 430.0
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
## Les places du duo et des ennemis dans l'arène (fractions de sa largeur et de sa hauteur) et la taille de leur pixel.
const PLACES := {"a1": [0.47, 0.70, 9.0], "a2": [0.20, 0.52, 6.5], "b1": [0.62, 0.36, 7.5], "b2": [0.84, 0.15, 6.5]}

var app: ArenaApp
var e: EtatCombat
var tour: Tour = null
var noms := {}
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
var cases := {}
var aide: Label
var popup: PanelContainer = null
var feuille: Control = null
## Le tracé des deux joueurs sur leur roue (pour la fin du combat) et les Synergies du duo.
var trace := {"a1": [], "b1": []}
var synergies: Array = []
var _quitter_arme := 0.0
var _dernier_tic := 0
var _t := 0.0


func setup(p_app: ArenaApp, options: Dictionary) -> void:
	app = p_app
	e = options["etat"]
	tour = options.get("tour", null)
	noms = options.get("noms", {})
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
			pixel = 4.5 + 2.0 * _pv_mult(str(fiche["sprite"]))
		var v := UnitView.make(id, str(fiche["sprite"]), str(noms.get(id, fiche["nom"])), pixel, allie)
		v.touche.connect(_on_perso_touche)
		v.appui_long.connect(_on_perso_appui_long)
		v.appui_menace.connect(_on_menace_appui_long)
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
	# Le bas : la bande de la voie, les six cases, l'aide.
	var hud := VBoxContainer.new()
	hud.name = "hud"
	hud.add_theme_constant_override("separation", 6)
	add_child(hud)
	bande = BandeVoie.new()
	bande.appui_long_noeud.connect(func(v, r, ancre): _ouvrir_fiche(_fiche_noeud("a1", v, r), ancre))
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
	hud.add_child(aide)
	resized.connect(_placer)
	_placer()


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
	arene.size = Vector2(size.x, size.y - HUD_H - HAUT)
	traits.size = arene.size
	var monstres: Array = []
	for id in e.ordre:
		if tour != null and id.begins_with("b"):
			monstres.append(id)
	# À la Tour : le plus gros monstre au centre, les autres de part et d'autre.
	monstres.sort_custom(func(x, y): return _pv_mult(str(e.fiche(x)["sprite"])) > _pv_mult(str(e.fiche(y)["sprite"])))
	var places_tour := [[0.55, 0.26], [0.30, 0.18], [0.80, 0.18], [0.75, 0.40]]
	for id in e.ordre:
		var v: UnitView = vues[id]
		var f := Vector2.ZERO
		if tour != null and id.begins_with("b"):
			var k := monstres.find(id)
			f = Vector2(places_tour[k][0], places_tour[k][1])
		else:
			f = Vector2(PLACES[id][0], PLACES[id][1])
		var centre := Vector2(arene.size.x * f.x, arene.size.y * f.y)
		v.position = centre - Vector2(v.size.x / 2.0, v.rect_sprite().size.y / 2.0)


func _draw() -> void:
	# Le ciel et le sol de l'arène.
	draw_rect(Rect2(Vector2.ZERO, size), NUIT)
	var haut_sol := HAUT + (size.y - HUD_H - HAUT) * 0.35
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
	if Regles.actions_legales(e, "a1").is_empty():
		# KO ou Étourdi : l'acolyte joue seul, le tour part tout seul.
		aide.text = "Tu ne peux pas jouer ce tour-ci : %s joue seul." % noms.get("a2", "ton acolyte") if e.vivant("a1") else "Tu es KO : %s continue seul." % noms.get("a2", "ton acolyte")
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
		for m in Regles.menaces(e, id):
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
			v.etats.append({"pictogramme": def["pictogramme"], "couleur": def["couleur"], "tours": restants})
	_maj_cases()
	var nom_cible := str(noms.get(cible_e, e.fiche(cible_e)["nom"])) if cible_e != "" else "—"
	if e.vivant("a1") and not Regles.actions_legales(e, "a1").is_empty():
		aide.text = "cible : %s · touche un nœud deux fois pour jouer" % nom_cible


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
func _ligne_courte(n: Dictionary, voie: int, rang: int) -> String:
	var fiche := e.fiche("a1")
	var bonus := 0.0 if rang == 0 else float(fiche["bonus"][voie][rang - 1])
	var morceaux: Array[String] = []
	for p in Texte.pictos(n, Regles.multiplicateur_niveau(e) * float(fiche["k"]) * (1.0 + bonus), 1.0 + bonus):
		if str(p["texte"]) != "":
			morceaux.append(str(p["texte"]))
	return " + ".join(morceaux)


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


func _on_case_appui_long(i: int) -> void:
	if phase != "choix":
		return
	if verrouillee and i == choisie:
		verrouillee = false
		_maj_cases()
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


func _on_menace_appui_long(id: String, index: int, ancre: Vector2) -> void:
	var v: UnitView = vues[id]
	if index < v.menaces.size():
		_ouvrir_fiche(_fiche_noeud(id, int(v.menaces[index]["voie"]), int(v.menaces[index]["rang"])), ancre)


func _input(event: InputEvent) -> void:
	# Une fiche ouverte par un appui long se ferme au relâchement.
	if popup != null and event is InputEventMouseButton and not event.pressed:
		_fermer_popup()


# --- Fiches -------------------------------------------------------------------------

func _fiche_noeud(id: String, voie: int, rang: int) -> Dictionary:
	return Texte.fiche(e, id, voie, rang, "a1")


func _ouvrir_fiche(fiche: Dictionary, ancre: Vector2) -> void:
	_fermer_popup()
	popup = PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = SURFACE_HAUTE
	style.border_color = OR
	style.set_border_width_all(2)
	style.set_corner_radius_all(12)
	style.set_content_margin_all(10)
	popup.add_theme_stylebox_override("panel", style)
	popup.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(minf(size.x - 24.0, 440.0), 0)
	box.add_theme_constant_override("separation", 3)
	popup.add_child(box)
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
	for child in box.get_children():
		if child is Control:
			(child as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(popup)
	await get_tree().process_frame
	if popup == null:
		return
	var pos := Vector2(ancre.x - popup.size.x / 2.0, ancre.y - popup.size.y - 16.0) - global_position
	if pos.y < 8.0:
		pos.y = ancre.y - global_position.y + 30.0
	pos.x = clampf(pos.x, 8.0, size.x - popup.size.x - 8.0)
	popup.position = pos


func _fermer_popup() -> void:
	if popup != null:
		popup.queue_free()
		popup = null


## La fiche d'un personnage (maquette « Enemy Sheet Screen ») : nom, classe, PV, états, et ses voies.
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
	col.add_child(UiKit.label("Ses voies (appui long sur un nœud : sa fiche)", 14, ATTENUE, false))
	for v in range(e.nb_voies(id)):
		var b := BandeVoie.new()
		_maj_bande(b, id, v)
		b.appui_long_noeud.connect(func(voie, rang, ancre): _ouvrir_fiche(_fiche_noeud(id, voie, rang), ancre))
		col.add_child(b)
	var boutons := HBoxContainer.new()
	boutons.add_theme_constant_override("separation", 10)
	col.add_child(boutons)
	if e.camp(id) == "b" and e.vivant(id) and phase == "choix":
		boutons.add_child(UiKit.main_button("Le prendre pour cible", func():
			_on_perso_touche(id)
			_fermer_feuille(), 56))
	boutons.add_child(UiKit.button("Fermer", _fermer_feuille, 56))


func _fermer_feuille() -> void:
	if feuille != null:
		feuille.queue_free()
		feuille = null


# --- Les annonces des acolytes -------------------------------------------------------

func _dessiner_traits() -> void:
	if phase != "choix":
		return
	var police := ThemeDB.fallback_font
	for id in declarations:
		if e.fiche(id)["place"] != "acolyte":
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
	e = Regles.resoudre_tour(e, declarations)
	for id in trace:
		var a: Dictionary = e.actions_jouees.get(id, {})
		if not a.is_empty() and (tour == null or id == "a1"):
			trace[id].append({"nom": Texte.nom(Regles.noeud_de(e, a)), "cle": int(a["rang"]) == 4 and a["source"] == "voie"})
	for ev in e.journal:
		if ev["type"] == "synergie" and e.camp(str(ev["acteur"])) == "a":
			synergies.append(str(ev["detail"]))
	# La résolution animée (cut-ins) et l'écran de fin viennent à l'étape 7 du plan.
	_maj()
	if e.fini or (tour != null and tour.abandonne(e)):
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
	else:
		app.fin_duel(false)
		app.show_screen("home")


func _fin() -> void:
	phase = "fin"
	lbl_chrono.text = ""
	if tour == null:
		app.fin_duel(e.vainqueur == "a")
		app.show_screen("home")
		return
	tour.terminer(e)
	if tour.fini:
		app.fin_tour(tour)
		app.show_screen("tower")
	else:
		app.gain_xp(40)
		app.show_screen("combat", {"etat": tour.combat(), "tour": tour, "noms": noms})
