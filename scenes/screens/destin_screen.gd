## La roue du Destin (docs/SPEC-COMBAT-V2.md, sections 3 et 12) : le moyeu au centre, les 5 voies en rayons (N1 près
## du centre, la Clé au bout, en losange), les éclats accrochés à leur nœud. Toucher un nœud le choisit et dit s'il
## peut être allumé ; un appui long ouvre sa fiche au-dessus de lui, qui se ferme au toucher suivant.
## Affichage seulement : la règle d'allumage est dans engine/generateur.gd.
extends Control

## La roue tient dans un carré de 560 (noms des voies compris), mis à l'échelle de la place disponible.
const COTE := 560.0
const R_MOYEU := 30.0
const R_NOEUD := 21.0
const R_ECLAT := 8.0
## Distance au centre de N1, N2, N3 et de la Clé (sur une roue de 560 de côté).
const RAYONS := [72.0, 122.0, 172.0, 224.0]
const APPUI_LONG := 0.25
const OR := Color("e3b85f")
const TEXTE := Color("efe9d9")
const ATTENUE := Color("aaa49b")
const SURFACE := Color("262337")
const BORD := Color("3a3650")

var app: ArenaApp
var canvas: Control
var header: Label
var info: VBoxContainer
var evolution_box: VBoxContainer
## Les boutons « Évoluer », par évolution ; celle dont le bouton est armé (attend le second appui).
var evolution_buttons: Dictionary = {}
var _evolution_armee := ""
var light_button: Button
var popup: PanelContainer
## Où est chaque nœud sur la roue : « moyeu », « v1.n2 », « v3.e1 »… -> position.
var positions: Dictionary = {}
var selected: String = ""
var _echelle := 1.0
var _time := 0.0
var _appui_cle := ""
var _appui_depuis := -1.0
var _appui_long_fait := false


func setup(p_app: ArenaApp, _options: Dictionary) -> void:
	app = p_app
	var column := VBoxContainer.new()
	column.set_anchors_preset(Control.PRESET_FULL_RECT)
	column.add_theme_constant_override("separation", 4)
	add_child(column)
	var margin := MarginContainer.new()
	for side in ["left", "right", "top"]:
		margin.add_theme_constant_override("margin_" + side, 12)
	column.add_child(margin)
	var head := VBoxContainer.new()
	margin.add_child(head)
	head.add_child(UiKit.label("Ton Destin", 28, UiKit.GOLD))
	header = UiKit.label("", 15, UiKit.SOFT)
	head.add_child(header)
	canvas = Control.new()
	canvas.custom_minimum_size = Vector2(0, 500)
	canvas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	canvas.mouse_filter = Control.MOUSE_FILTER_STOP
	canvas.draw.connect(_dessiner)
	canvas.gui_input.connect(_on_input)
	canvas.resized.connect(_placer)
	column.add_child(canvas)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)
	var pad := MarginContainer.new()
	pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for side in ["left", "right", "bottom"]:
		pad.add_theme_constant_override("margin_" + side, 12)
	scroll.add_child(pad)
	var panel := PanelContainer.new()
	pad.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	panel.add_child(box)
	evolution_box = VBoxContainer.new()
	evolution_box.add_theme_constant_override("separation", 4)
	box.add_child(evolution_box)
	_remplir_evolution()
	info = VBoxContainer.new()
	info.add_theme_constant_override("separation", 3)
	box.add_child(info)
	light_button = UiKit.button("Allumer ce nœud", _allumer, 52)
	box.add_child(light_button)
	_choisir("moyeu")


## Les positions de la roue, à l'échelle de la largeur disponible.
func _placer() -> void:
	_echelle = minf(canvas.size.x, canvas.size.y) / COTE
	var centre := canvas.size / 2.0
	positions = {"moyeu": centre}
	var destin := app.destin
	for v in range(destin.voies.size()):
		var angle := -PI / 2.0 + float(v) * TAU / float(destin.voies.size())
		var dir := Vector2(cos(angle), sin(angle))
		var perp := Vector2(-dir.y, dir.x)
		for r in range(4):
			positions["v%d.n%d" % [v + 1, r + 1]] = centre + dir * RAYONS[r] * _echelle
		var ecarts := [[1, 1.0], [1, -1.0], [2, 1.0], [3, 1.0], [4, 1.0]]
		for e in range(5):
			var noeud: Vector2 = positions["v%d.n%d" % [v + 1, ecarts[e][0]]]
			positions["v%d.e%d" % [v + 1, e + 1]] = noeud + perp * float(ecarts[e][1]) * 27.0 * _echelle


func _process(delta: float) -> void:
	_time += delta
	if _appui_cle != "" and not _appui_long_fait and _time - _appui_depuis >= APPUI_LONG:
		_appui_long_fait = true
		_ouvrir_fiche(_appui_cle)
	if canvas != null:
		canvas.queue_redraw()


# --- Dessin ---------------------------------------------------------------------

func _dessiner() -> void:
	if positions.is_empty():
		_placer()
	var destin := app.destin
	var police := ThemeDB.fallback_font
	var centre: Vector2 = positions["moyeu"]
	var pouls := 0.5 + 0.5 * sin(_time * 5.0)
	var points := app.destin_points_left()
	for v in range(destin.voies.size()):
		var voie: Dictionary = destin.voies[v]
		var precedent := centre
		for r in range(4):
			var cle := "v%d.n%d" % [v + 1, r + 1]
			var allume := bool(voie["noeuds"][r]["allume"])
			canvas.draw_line(precedent, positions[cle], OR if allume else BORD, (4.0 if allume else 2.0) * _echelle)
			precedent = positions[cle]
		for e in range(5):
			var cle := "v%d.e%d" % [v + 1, e + 1]
			var accroche := "v%d.n%d" % [v + 1, Destin.ECLAT_NOEUD[e]]
			canvas.draw_line(positions[accroche], positions[cle], OR if voie["eclats"][e] else BORD, 1.5 * _echelle)
		# Le nom de la voie, au bout du rayon.
		var bout: Vector2 = centre + (positions["v%d.n4" % (v + 1)] - centre) * 1.2
		var nom := _nom_court(str(voie["nom"]))
		var largeur := police.get_string_size(nom, HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x
		canvas.draw_string(police, bout + Vector2(-largeur / 2.0, 5.0), nom, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, ATTENUE)
	# Les éclats, puis les nœuds par-dessus.
	for v in range(destin.voies.size()):
		var voie: Dictionary = destin.voies[v]
		for e in range(5):
			var cle := "v%d.e%d" % [v + 1, e + 1]
			var pos: Vector2 = positions[cle]
			var r := R_ECLAT * _echelle
			if voie["eclats"][e]:
				canvas.draw_circle(pos, r, OR)
			else:
				if points > 0 and Generateur.peut_allumer(destin, cle):
					canvas.draw_circle(pos, r + 3.0 * pouls, Color(OR, 0.25))
				canvas.draw_circle(pos, r, SURFACE)
				canvas.draw_arc(pos, r, 0.0, TAU, 16, BORD, 1.5)
			if cle == selected:
				canvas.draw_arc(pos, r + 5.0, 0.0, TAU, 16, Color.WHITE, 2.0)
		for r in range(4):
			_dessiner_noeud("v%d.n%d" % [v + 1, r + 1], voie["noeuds"][r], r == 3, points, pouls)
	_dessiner_noeud("moyeu", destin.moyeu, false, points, pouls, R_MOYEU)


func _dessiner_noeud(cle: String, noeud: Dictionary, est_cle: bool, points: int, pouls: float, rayon: float = R_NOEUD) -> void:
	var pos: Vector2 = positions[cle]
	var r := rayon * _echelle
	var allume := bool(noeud.get("allume", true))
	var forme := PackedVector2Array([pos + Vector2(0, -r * 1.2), pos + Vector2(r * 1.2, 0), pos + Vector2(0, r * 1.2), pos + Vector2(-r * 1.2, 0)])
	if not allume and points > 0 and Generateur.peut_allumer(app.destin, cle):
		var halo := r + 5.0 * pouls
		canvas.draw_circle(pos, halo, Color(OR, 0.2))
	if est_cle:
		canvas.draw_colored_polygon(forme, SURFACE)
		canvas.draw_polyline(forme + PackedVector2Array([forme[0]]), OR if allume else BORD, (3.0 if allume else 1.5) * _echelle)
	else:
		canvas.draw_circle(pos, r, SURFACE)
		canvas.draw_arc(pos, r, 0.0, TAU, 28, OR if allume else BORD, (3.0 if allume else 1.5) * _echelle)
	var p := Texte.picto(noeud["effets"][0])
	var col := Color(str(p["couleur"]))
	Picto.dessiner(canvas, str(p["pictogramme"]), pos, r * 1.1, col if allume else Color(col, 0.35))
	if cle == selected:
		canvas.draw_arc(pos, r * (1.35 if est_cle else 1.0) + 5.0, 0.0, TAU, 28, Color.WHITE, 2.5)


func _nom_court(nom: String) -> String:
	for prefixe in ["Voie du ", "Voie de la ", "Voie de l'", "Voie des "]:
		if nom.begins_with(prefixe):
			return nom.substr(prefixe.length())
	return nom


# --- Toucher -------------------------------------------------------------------

func _on_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton or event.button_index != MOUSE_BUTTON_LEFT:
		return
	if event.pressed:
		_fermer_fiche()
		_appui_cle = _cle_proche(event.position)
		_appui_depuis = _time
		_appui_long_fait = false
	else:
		if _appui_cle != "" and not _appui_long_fait:
			app.sfx.play("clic")
			_choisir(_appui_cle)
		_appui_cle = ""


func _cle_proche(pos: Vector2) -> String:
	var meilleure := ""
	var distance := R_NOEUD * 1.6 * _echelle
	for cle in positions:
		var d: float = positions[cle].distance_to(pos)
		if d < distance:
			meilleure = cle
			distance = d
	return meilleure


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_fermer_fiche()


## Le nœud choisi : sa fiche sous la roue, et le bouton pour l'allumer.
func _choisir(cle: String) -> void:
	selected = cle
	for child in info.get_children():
		child.queue_free()
	_remplir_fiche(info, cle)
	var left := app.destin_points_left()
	var etat := ("%d point%s à placer" % [left, "s" if left > 1 else ""]) if left > 0 else "aucun point à placer (un par niveau)"
	if app.peut_evoluer():
		etat = "ton évolution t'attend (ci-dessous)"
	header.text = "%s · niveau %d · %s" % [app.destin.nom, app.profile.level, etat]
	var peut := cle != "moyeu" and Generateur.peut_allumer(app.destin, cle)
	light_button.disabled = not peut or left <= 0
	if cle == "moyeu" or _deja_allume(cle):
		light_button.text = "Déjà allumé"
	elif not peut:
		light_button.text = "Allume d'abord le nœud d'avant"
	elif left <= 0:
		light_button.text = "Gagne un niveau pour l'allumer"
	else:
		light_button.text = "Allumer (1 point)"


func _deja_allume(cle: String) -> bool:
	var v := int(cle.substr(1, 1)) - 1
	var n := int(cle.substr(4))
	if cle.substr(3, 1) == "n":
		return bool(app.destin.voies[v]["noeuds"][n - 1]["allume"])
	return bool(app.destin.voies[v]["eclats"][n - 1])


func _remplir_fiche(box: VBoxContainer, cle: String) -> void:
	if cle == "moyeu":
		UiKit.fiche_noeud(box, Texte.fiche_destin(app.destin, -1, 0, app.profile.level))
		return
	var v := int(cle.substr(1, 1)) - 1
	var n := int(cle.substr(4))
	if cle.substr(3, 1) == "n":
		UiKit.fiche_noeud(box, Texte.fiche_destin(app.destin, v, n, app.profile.level))
		return
	var textes: Dictionary = app.data.textes["fiche"]
	var voie: Dictionary = app.destin.voies[v]
	box.add_child(UiKit.label(str(textes["eclat_titre"]).format({"n": n, "voie": voie["nom"]}), 20, UiKit.GOLD, false))
	box.add_child(UiKit.label(str(textes["eclats"][n - 1]), 17, Color.WHITE, false))
	box.add_child(UiKit.label(str(textes["eclat_accroche"]).format({"noeud": Texte.nom(voie["noeuds"][Destin.ECLAT_NOEUD[n - 1] - 1])}), 14, UiKit.SOFT, false))


## Les cartes des évolutions (GDD V2, § 3 : le choix parmi trois) : avant le niveau 30, ce que la classe pourra
## devenir ; au niveau 30, une carte par évolution (rôle, description, voies) avec son bouton « Évoluer » (deux appuis :
## le second confirme) ; après, rien.
func _remplir_evolution() -> void:
	for child in evolution_box.get_children():
		child.queue_free()
	evolution_buttons.clear()
	var possibles := app.evolutions_possibles()
	if possibles.is_empty():
		return
	var plafond := app.niveau_max()
	if not app.peut_evoluer():
		var noms: Array = []
		for id in possibles:
			var ev := app.data.classe(id)
			noms.append("%s (%s)" % [ev["nom"], UiKit.ROLE_LABELS[ev["role"]]])
		var liste := ", ".join(noms.slice(0, noms.size() - 1)) + (" ou " if noms.size() > 1 else "") + str(noms[noms.size() - 1])
		evolution_box.add_child(UiKit.label("Au niveau %d, %s pourra devenir %s." % [plafond, app.destin.nom, liste], 14, UiKit.SOFT, false))
		return
	evolution_box.add_child(UiKit.label("Ton évolution : choisis-en une", 22, UiKit.GOLD, false))
	evolution_box.add_child(UiKit.label("Nouvelle roue, même graine : tes points repartent à zéro, puis un par niveau jusqu'au niveau %d. Sans retour." % Evolution.niveau_max(1, app.data), 14, UiKit.SOFT, false))
	for id in possibles:
		var ev := app.data.classe(id)
		var role := str(UiKit.ROLE_LABELS[ev["role"]])
		var carte := UiKit.card(evolution_box, 3)
		carte.add_child(UiKit.label("%s · %s" % [ev["nom"], role], 19, UiKit.GOLD, false))
		carte.add_child(UiKit.label(str(ev["description"]), 14, Color.WHITE, false))
		var voies: Array = []
		for v in ev["voies"]:
			voies.append(str(v["nom"]).trim_prefix("Voie ").trim_prefix("de la ").trim_prefix("de l'").trim_prefix("du ").trim_prefix("des ").trim_prefix("de "))
		carte.add_child(UiKit.label("Voies : %s." % ", ".join(voies), 13, UiKit.SOFT, false))
		var bouton := UiKit.button("Évoluer en %s" % ev["nom"], _evoluer.bind(str(ev["id"])), 50, 18)
		carte.add_child(bouton)
		evolution_buttons[str(ev["id"])] = bouton
	evolution_box.add_child(UiKit.spacer(6))


## Évoluer demande une confirmation : un second appui sur le même bouton (toucher un autre bouton change de choix).
func _evoluer(evolution_id: String) -> void:
	if _evolution_armee != evolution_id:
		if _evolution_armee != "" and evolution_buttons.has(_evolution_armee):
			var ancien: Button = evolution_buttons[_evolution_armee]
			ancien.text = "Évoluer en %s" % app.data.classe(_evolution_armee)["nom"]
			ancien.modulate = Color.WHITE
		_evolution_armee = evolution_id
		var bouton: Button = evolution_buttons[evolution_id]
		bouton.text = "Sûr ? Touche encore pour évoluer"
		bouton.modulate = Color(1.0, 0.85, 0.3)
		return
	if not app.evoluer(evolution_id):
		return
	app.sfx.play("releve")
	app.show_screen("destin")


func _allumer() -> void:
	if selected == "" or not app.allumer(selected):
		return
	app.sfx.play("releve")
	_choisir(selected)


## La fiche flottante d'un appui long, au-dessus du nœud.
func _ouvrir_fiche(cle: String) -> void:
	_fermer_fiche()
	popup = PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = SURFACE
	style.border_color = OR
	style.set_border_width_all(2)
	style.set_corner_radius_all(12)
	style.set_content_margin_all(10)
	popup.add_theme_stylebox_override("panel", style)
	popup.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(minf(size.x - 24.0, 420.0), 0)
	popup.add_child(box)
	_remplir_fiche(box, cle)
	add_child(popup)
	await get_tree().process_frame
	if popup == null:
		return
	var ancre: Vector2 = canvas.position + positions[cle]
	var pos := Vector2(ancre.x - popup.size.x / 2.0, ancre.y - popup.size.y - R_NOEUD * 1.5)
	if pos.y < 4.0:
		pos.y = ancre.y + R_NOEUD * 1.5
	pos.x = clampf(pos.x, 8.0, size.x - popup.size.x - 8.0)
	popup.position = pos


func _fermer_fiche() -> void:
	if popup != null:
		popup.queue_free()
		popup = null
