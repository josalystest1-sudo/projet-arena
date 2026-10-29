## La fin d'un combat (maquette « Victory Result Screen ») : le trio, le résultat, ce qu'il rapporte (XP, série,
## Synergies), la part de chacun des trois, le tracé des deux joueurs sur leur roue (celui de l'adversaire : ce qu'on
## découvre de lui une fois le combat fini), et la suite (rejouer, retour). À la Tour : l'étage franchi et les monstres
## du suivant, ou l'étage où le trio est tombé. Affichage seulement : le résultat vient du moteur.
extends Control

const OR := Color("e3b85f")
const TEAL := Color("5cc8b8")
const ROUGE := Color("d35b5b")
const ATTENUE := Color("aaa49b")
const SURFACE := Color("1c1a28")

var app: ArenaApp


func setup(p_app: ArenaApp, options: Dictionary) -> void:
	app = p_app
	var e: EtatCombat = options["etat"]
	var noms: Dictionary = options.get("noms", {})
	var tour: Tour = options.get("tour", null)
	var column := UiKit.scroll_column(self, 12)
	var gagne := e.vainqueur == "a"
	# Le trio, en grand.
	var trio := HBoxContainer.new()
	trio.alignment = BoxContainer.ALIGNMENT_CENTER
	trio.add_theme_constant_override("separation", 8)
	column.add_child(trio)
	for id in ["a2", "a1", "a3"]:
		if not e.statique.has(id):
			continue
		var p := PortraitView.make(str(e.fiche(id)["sprite"]), str(noms.get(id, e.fiche(id)["nom"])), "", 7.0)
		p.title_color = OR if id == "a1" else UiKit.ACOLYTE_BLUE
		trio.add_child(p)
	var cartes := HBoxContainer.new()
	cartes.add_theme_constant_override("separation", 8)
	if tour == null:
		var resultat := app.fin_duel(gagne)
		column.add_child(UiKit.label("Victoire !" if gagne else "Défaite", 40, OR if gagne else ROUGE))
		app.sfx.play("victoire" if gagne else "defaite")
		column.add_child(cartes)
		_carte(cartes, "XP", "+%d" % int(resultat["xp"]), "niveau %d%s" % [app.profile.level, (" (+%d)" % int(resultat["niveaux"])) if int(resultat["niveaux"]) > 0 else ""])
		_carte(cartes, "Série", str(app.profile.streak), "record %d" % app.profile.best_streak)
		var syn: Array = options.get("synergies", [])
		_carte(cartes, "Synergies", str(syn.size()), ", ".join(_uniques(syn)) if not syn.is_empty() else "aucune")
	else:
		tour.terminer(e)
		if tour.fini:
			var resultat := app.fin_tour(tour)
			column.add_child(UiKit.label("Tombé à l'étage %d" % tour.atteint, 34, ROUGE))
			app.sfx.play("defaite")
			column.add_child(cartes)
			_carte(cartes, "Étage atteint", str(tour.atteint), "record %s : %d" % [app.data.classe(app.player_class)["nom"], int(app.profile.tower_records.get(app.player_class, 0))])
			_carte(cartes, "Reprise", "étage %d" % app.palier(), "tous tes PV")
		else:
			var xp := app.xp_etage(tour.etage - 1)
			app.gain_xp(xp)
			column.add_child(UiKit.label("Étage %d franchi !" % (tour.etage - 1), 34, OR))
			app.sfx.play("victoire")
			column.add_child(cartes)
			_carte(cartes, "PV rendus", "+20 %", "à chacun")
			_carte(cartes, "XP", "+%d" % xp, "niveau %d" % app.profile.level)
			if (tour.etage - 1) % int(app.data.tour["gardien_tous_les"]) == 0:
				_carte(cartes, "Palier", "étage %d" % tour.etage, "tu reprendras d'ici")
			var noms_m: Array[String] = []
			for id in tour.tirer_etage(tour.etage):
				noms_m.append(str(app.data.bestiaire["monstres"][id]["nom"]))
			var suite := UiKit.card(column, 4)
			suite.add_child(UiKit.label("Étage %d" % tour.etage, 20, OR, false))
			suite.add_child(UiKit.label(", ".join(noms_m), 17, Color.WHITE, false))
	# La part de chacun des trois : ce qu'il a infligé, soigné, protégé.
	var parts: Dictionary = options.get("parts", {})
	if not parts.is_empty():
		var carte := UiKit.card(column, 2)
		carte.add_child(UiKit.label("La part de chacun", 17, ATTENUE, false))
		for id in ["a1", "a2", "a3"]:
			if not parts.has(id):
				continue
			var x: Dictionary = parts[id]
			carte.add_child(UiKit.label("%s : %d dégâts · %d soins · %d protégés" % [noms.get(id, e.fiche(id)["nom"]), x["degats"], x["soins"], x["protections"]], 16, OR if id == "a1" else UiKit.ACOLYTE_BLUE, false))
	# Le tracé des deux joueurs sur leur roue.
	var traces: Dictionary = options.get("trace", {})
	for id in ["a1", "b1"]:
		if not traces.has(id) or traces[id].is_empty():
			continue
		var carte := UiKit.card(column, 6)
		carte.add_child(UiKit.label("Ton tracé sur la roue" if id == "a1" else "Le tracé de %s" % noms.get(id, e.fiche(id)["nom"]), 17, ATTENUE, false))
		var flux := HFlowContainer.new()
		flux.add_theme_constant_override("h_separation", 6)
		flux.add_theme_constant_override("v_separation", 6)
		carte.add_child(flux)
		for pas in traces[id]:
			flux.add_child(_puce(str(pas["nom"]), bool(pas["cle"])))
	column.add_child(UiKit.spacer(8))
	if tour == null:
		column.add_child(UiKit.main_button("Rejouer", func(): app.show_screen("versus")))
		column.add_child(UiKit.button("Retour à la Vitrine", func(): app.show_screen("home"), 56))
	elif tour.fini:
		column.add_child(UiKit.main_button("Remonter", func(): app.show_screen("tower")))
		column.add_child(UiKit.button("Retour à la Vitrine", func(): app.show_screen("home"), 56))
	else:
		column.add_child(UiKit.main_button("Étage suivant", func(): app.show_screen("combat", {"etat": tour.combat(), "tour": tour, "noms": noms})))
		column.add_child(UiKit.button("Arrêter la montée", func():
			tour.arreter()
			app.fin_tour(tour)
			app.show_screen("tower"), 56))


func _carte(parent: HBoxContainer, titre: String, valeur: String, detail: String) -> void:
	var carte := UiKit.card(parent, 2)
	carte.get_parent().size_flags_horizontal = Control.SIZE_EXPAND_FILL
	carte.add_child(UiKit.label(titre, 14, ATTENUE, false))
	carte.add_child(UiKit.label(valeur, 28, Color.WHITE, false))
	carte.add_child(UiKit.label(detail, 13, ATTENUE, false))


func _puce(texte: String, cle: bool) -> PanelContainer:
	var p := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = SURFACE
	style.border_color = ROUGE if cle else Color("3a3650")
	style.set_border_width_all(2)
	style.set_corner_radius_all(14)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	p.add_theme_stylebox_override("panel", style)
	var l := Label.new()
	l.text = texte
	l.add_theme_font_size_override("font_size", 15)
	p.add_child(l)
	return p


func _uniques(liste: Array) -> Array:
	var vus := {}
	for x in liste:
		vus[x] = true
	return vus.keys()
