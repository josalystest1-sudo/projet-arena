## La résolution d'un tour (docs/SPEC-COMBAT-V2.md, section 12.5) : plein écran, un cut-in par action, dans l'ordre
## joueur A, acolyte A, joueur B, acolyte B (ou les ennemis), puis les ticks regroupés, puis les KO. Chaque cut-in : le
## perso en grand, le nom du nœud, ses pictogrammes, les nombres sur les cibles (or : dégâts ; teal : soin ; teal clair :
## barrière ; violet : état posé ; rouge : tick). Une Synergie : un bandeau à son nom (doré pour ton duo, rouge pour
## l'adversaire), avec qui l'a faite, sur qui, la règle et son effet ; ce cut-in dure plus longtemps. 4 secondes au plus
## (plus le temps de lire les Synergies) ; un toucher accélère, un second saute à la fin. Tout vient du journal
## d'événements du moteur : rien n'est recalculé.
## Affichage seulement.
extends Control

signal termine

const OR := Color("e3b85f")
const TEAL := Color("5cc8b8")
const TEAL_CLAIR := Color("9bd3ca")
const ROUGE := Color("d35b5b")
const VIOLET := Color("c9a0ff")
const TEXTE := Color("efe9d9")
const ATTENUE := Color("aaa49b")
const NUIT := Color("0f0e17")
const DUREE_MAX := 4.0

var app: ArenaApp
var e: EtatCombat
var noms := {}
## Les cut-ins : {acteur, titre, sous_titre, pictos, nombres: [[cible, texte, couleur]], synergie, synergie_qui (qui,
## sur qui), synergie_ligne (la règle et l'effet), synergie_adverse, tick, ko}.
var sequence: Array = []
var courant := -1
var _temps := 0.0
var _duree := 0.9
var _vitesse := 1.0
var _touches := 0
var _fini := false


func jouer(p_app: ArenaApp, _avant: EtatCombat, apres: EtatCombat, p_noms: Dictionary, _vues: Dictionary) -> void:
	app = p_app
	e = apres
	noms = p_noms
	mouse_filter = Control.MOUSE_FILTER_STOP
	_construire_sequence()
	if sequence.is_empty():
		_finir.call_deferred()
		return
	_duree = minf(0.95, DUREE_MAX / float(sequence.size()))
	_suivant()


## Un cut-in de Synergie dure le temps de lire son explication.
func _duree_cut() -> float:
	if courant >= 0 and courant < sequence.size() and str(sequence[courant]["synergie"]) != "":
		return maxf(_duree, 2.2)
	return _duree


func _nom(id: String) -> String:
	if id == "":
		return ""
	return str(noms.get(id, e.fiche(id)["nom"]))


func _construire_sequence() -> void:
	var journal: Array = e.journal
	var synergies := {}
	for ev in journal:
		if ev["type"] == "synergie":
			synergies[ev["acteur"]] = ev
	var ordre_actions: Array = []
	for id in e.ordre:
		if e.actions_jouees.has(id):
			ordre_actions.append(id)
	for id in ordre_actions:
		var a: Dictionary = e.actions_jouees[id]
		var n := Regles.noeud_de(e, a)
		var cut := {"acteur": id, "titre": Texte.nom(n), "pictos": Texte.pictos(n), "nombres": [], "synergie": "", "synergie_ligne": "",
			"synergie_adverse": false, "tick": false}
		var rang := int(a["rang"]) if a["source"] == "voie" else 0
		var cible := ""
		for ef in n["effets"]:
			if ef["cible"] == "un_ennemi":
				cible = str(a["cible_ennemie"])
			elif ef["cible"] == "un_allie" and cible == "":
				cible = str(a["cible_alliee"])
		cut["sous_titre"] = ("Clé" if rang == 4 else ("Moyeu" if rang == 0 else "Rang %d" % rang)) + (" · sur %s" % _nom(cible) if cible != "" else "")
		for ev in journal:
			if ev["acteur"] != id or ev["phase"] in ["2f", "2g", "2h", "2i"] or ev["type"] == "synergie":
				continue
			var nombre := _nombre(ev)
			if not nombre.is_empty():
				cut["nombres"].append(nombre)
		# La Synergie s'annonce au cut-in du second de ses deux acteurs.
		for acteur in synergies:
			if acteur != id and e.camp(acteur) == e.camp(id) and ordre_actions.find(id) > ordre_actions.find(acteur):
				var ev: Dictionary = synergies[acteur]
				var s := Texte.synergie(str(ev["detail"]))
				cut["synergie"] = str(ev["detail"])
				cut["synergie_adverse"] = e.camp(id) == "b"
				var qui := "%s et %s" % [_nom(acteur), _nom(id)]
				var sur := " sur %s" % _nom(str(ev["cible"])) if str(ev["cible"]) != "" else ""
				cut["synergie_qui"] = "%s%s" % [qui, sur]
				cut["synergie_ligne"] = "%s : %s" % [s["regle"].substr(0, 1).to_upper() + s["regle"].substr(1), s["effet"]]
		sequence.append(cut)
	var ticks := {"acteur": "", "titre": "Les effets qui durent", "sous_titre": "", "pictos": [], "nombres": [], "synergie": "", "tick": true}
	var kos := {"acteur": "", "titre": "", "sous_titre": "", "pictos": [], "nombres": [], "synergie": "", "tick": true}
	var tombes: Array[String] = []
	for ev in journal:
		if ev["phase"] == "2f":
			var nombre := _nombre(ev)
			if not nombre.is_empty():
				ticks["nombres"].append(nombre)
		if ev["type"] == "ko":
			tombes.append(_nom(str(ev["cible"])))
	if not ticks["nombres"].is_empty():
		sequence.append(ticks)
	if not tombes.is_empty():
		kos["titre"] = "KO !"
		kos["sous_titre"] = ", ".join(tombes)
		sequence.append(kos)


## Un nombre à afficher pour un événement : [cible, texte, couleur], ou vide.
func _nombre(ev: Dictionary) -> Array:
	var cible := str(ev["cible"])
	match str(ev["type"]):
		"degats":
			if str(ev["detail"]) == "aveugle":
				return [cible, "raté", ATTENUE]
			var abs_ := int(ev["absorbe"])
			return [cible, "-%d" % int(ev["valeur"]) + (" (%d bloqués)" % abs_ if abs_ > 0 else ""), OR]
		"soin":
			return [cible, "+%d" % int(ev["valeur"]), TEAL]
		"barriere":
			return [cible, ("barrière %d" % int(ev["valeur"])) if int(ev["valeur"]) > 0 else "barrière déjà plus grosse", TEAL_CLAIR]
		"etat":
			var detail := str(ev["detail"]).split(":")[0]
			if e.defs_etats.has(detail):
				return [cible, str(e.defs_etats[detail]["nom"]), VIOLET]
		"egare":
			return [cible, "Égaré", VIOLET]
		"purge":
			return [cible, "purifié", TEAL]
		"dissipe":
			return [cible, "dépouillé", VIOLET]
		"tick":
			if str(ev["detail"]) == "gardien":
				return [cible, "+%d" % int(ev["valeur"]), TEAL]
			return [cible, "-%d %s" % [int(ev["valeur"]), e.defs_etats[str(ev["detail"])]["nom"].to_lower()], ROUGE]
	return []


func _suivant() -> void:
	courant += 1
	_temps = 0.0
	if courant >= sequence.size():
		_finir()
		return
	var cut: Dictionary = sequence[courant]
	if cut["synergie"] != "":
		app.sfx.play("synergie")
	elif not cut["nombres"].is_empty():
		var gros := false
		for n in cut["nombres"]:
			gros = gros or n[2] == OR
		app.sfx.play("gros_coup" if gros and str(cut["sous_titre"]).begins_with("Clé") else ("coup" if gros else "soin"), 1.0, -4.0)
	if cut["titre"] == "KO !":
		app.sfx.play("ko")


func _finir() -> void:
	if _fini:
		return
	_fini = true
	termine.emit()


func _process(delta: float) -> void:
	if _fini or courant < 0:
		return
	_temps += delta * _vitesse
	if _temps >= _duree_cut():
		_suivant()
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_touches += 1
		if _touches == 1:
			_vitesse = 3.0
		else:
			_finir()
		accept_event()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(NUIT, 0.94))
	if courant < 0 or courant >= sequence.size():
		return
	var police := ThemeDB.fallback_font
	var cut: Dictionary = sequence[courant]
	var t := clampf(_temps / _duree_cut(), 0.0, 1.0)
	var arrivee := minf(1.0, t * 4.0)
	# Le perso en grand, avec son halo.
	if cut["acteur"] != "":
		var id: String = cut["acteur"]
		var allie := e.camp(id) == "a"
		var couleur := TEAL if allie else ROUGE
		var cote := size.x * 0.5
		var centre := Vector2(size.x / 2.0 + (1.0 - arrivee) * (-120.0 if allie else 120.0), size.y * 0.36)
		draw_circle(centre, cote * 0.7, Color(couleur, 0.10))
		draw_circle(centre, cote * 0.45, Color(couleur, 0.12))
		PixelSprites.draw(self, str(e.fiche(id)["sprite"]), centre - Vector2(cote, cote) / 2.0, cote / float(PixelSprites.GRID), couleur, not allie, false)
	# Le nom du nœud et la ligne du dessous.
	draw_string(police, Vector2(0, 92), str(cut["titre"]), HORIZONTAL_ALIGNMENT_CENTER, size.x, 40, OR)
	var sous := str(cut["sous_titre"])
	if cut["acteur"] != "":
		sous = "%s · %s" % [_nom(cut["acteur"]), sous]
	draw_string(police, Vector2(0, 126), sous, HORIZONTAL_ALIGNMENT_CENTER, size.x, 18, ATTENUE)
	var x := size.x / 2.0 - float(cut["pictos"].size()) * 22.0
	for p in cut["pictos"]:
		Picto.dessiner(self, str(p["pictogramme"]), Vector2(x + 22.0, 156), 28.0, Color(str(p["couleur"])))
		x += 44.0
	# Les nombres qui tombent sur les cibles.
	var y := size.y * 0.62
	for n in cut["nombres"]:
		var chute := (1.0 - arrivee) * -30.0
		var ligne := "%s  %s" % [_nom(str(n[0])), n[1]]
		draw_string(police, Vector2(0, y + chute), ligne, HORIZONTAL_ALIGNMENT_CENTER, size.x, 30, n[2])
		y += 40.0
	if cut["synergie"] != "":
		var r := Rect2(0, size.y * 0.52 - 40, size.x, 96)
		var adverse: bool = cut.get("synergie_adverse", false)
		draw_rect(r, Color(ROUGE if adverse else OR, 0.9))
		var titre := ("SYNERGIE ADVERSE : %s" if adverse else "SYNERGIE : %s") % str(cut["synergie"]).to_upper()
		draw_string(police, Vector2(0, r.position.y + 34), titre, HORIZONTAL_ALIGNMENT_CENTER, size.x, 28, NUIT)
		var ys := r.position.y + 60.0
		for ligne in [str(cut.get("synergie_qui", "")), str(cut.get("synergie_ligne", ""))]:
			var taille := 17
			while taille > 11 and police.get_string_size(ligne, HORIZONTAL_ALIGNMENT_LEFT, -1, taille).x > size.x - 24:
				taille -= 1
			draw_string(police, Vector2(12, ys), ligne, HORIZONTAL_ALIGNMENT_CENTER, size.x - 24, taille, NUIT)
			ys += 24.0
	# L'ordre du tour.
	var yl := size.y - 230.0
	var i := 0
	for c in sequence:
		if c["acteur"] == "":
			continue
		var etat := "fait" if i < courant else ("en cours" if i == courant else "à venir")
		var couleur_l := TEAL if etat == "fait" else (OR if etat == "en cours" else Color(ATTENUE, 0.6))
		draw_string(police, Vector2(24, yl), "%d. %s · %s" % [i + 1, _nom(c["acteur"]), c["titre"]], HORIZONTAL_ALIGNMENT_LEFT, size.x - 140, 16, TEXTE if i <= courant else Color(ATTENUE, 0.6))
		draw_string(police, Vector2(size.x - 120, yl), etat, HORIZONTAL_ALIGNMENT_RIGHT, 96, 15, couleur_l)
		yl += 30.0
		i += 1
	draw_string(police, Vector2(0, size.y - 30), "touche pour accélérer, encore pour passer", HORIZONTAL_ALIGNMENT_CENTER, size.x, 14, ATTENUE)
