## La Forge (docs/GDD_V2.md, § 10.1 ; docs/PLAN.md, PR 3.2) : ce que tu portes (cinq emplacements), tes bonus, ton sac,
## et la fiche d'un objet : ses lignes avec leurs fourchettes entre crochets, sa qualité, lié ou échangeable, la
## comparaison avec ce que tu portes (les bonus avant et après, et ce que ça change sur ta roue : « Boule de feu :
## 48 → 54 »), équiper, retirer, recycler (des Éclats), reforger une ligne (des Éclats, de plus en plus cher).
## Affichage et navigation seulement : les objets et leurs règles viennent d'engine/equipement.gd ; l'inventaire vit
## dans le profil (ArenaApp.equiper, retirer, recycler, reforger).
extends Control

const ATTENUE := Color("aaa49b")

var app: ArenaApp
var recycler_bouton: Button
var _recycler_arme := false


func setup(p_app: ArenaApp, options: Dictionary) -> void:
	app = p_app
	if options.has("ou"):
		_fiche(str(options["ou"]), options["cle"])
	else:
		_forge()


# --- La Forge : porté, bonus, sac -------------------------------------------------------------

func _forge() -> void:
	var column := UiKit.scroll_column(self, 12)
	column.add_child(UiKit.label("La Forge", 34, UiKit.GOLD))
	column.add_child(UiKit.label("%d Éclat%s" % [app.profile.eclats, "s" if app.profile.eclats > 1 else ""], 18, Color.WHITE))
	column.add_child(UiKit.label("Un objet n'a de valeur que pour ta roue : ses lignes s'ajoutent à tes nœuds. Équipe, compare, reforge.", 15, UiKit.SOFT))
	# Ce que tu portes.
	var porte := UiKit.card(column, 6)
	porte.add_child(UiKit.label("Ce que tu portes", 20, UiKit.GOLD, false))
	for e in app.data.objets["emplacements"]:
		var nom_e := str(app.data.objets["emplacements"][e]["nom"])
		if app.profile.portes.has(e):
			var f := Equipement.fiche(app.profile.portes[e], app.data)
			var b := UiKit.button("%s : %s · qualité %d %%" % [nom_e, f["nom"], f["qualite"]], _ouvrir.bind("porte", str(e)), 52, 16)
			b.alignment = HORIZONTAL_ALIGNMENT_LEFT
			b.add_theme_color_override("font_color", UiKit.rarete_couleur(int(f["rang"])))
			porte.add_child(b)
		else:
			porte.add_child(UiKit.label("%s : rien" % nom_e, 16, ATTENUE, false))
	# Tes bonus.
	var bonus := UiKit.card(column, 4)
	bonus.add_child(UiKit.label("Tes bonus", 20, UiKit.GOLD, false))
	var lignes := _lignes_bonus(app.bonus_portes())
	if lignes.is_empty():
		bonus.add_child(UiKit.label("Aucun : équipe un objet.", 16, ATTENUE, false))
	for l in lignes:
		bonus.add_child(UiKit.label(l, 16, Color.WHITE, false))
	for t in Equipement.traits(app.objets_portes(), app.data):
		bonus.add_child(UiKit.label(Equipement.texte_trait(t, app.data), 16, UiKit.rarete_couleur(4), false))
	# Le sac.
	var sac := UiKit.card(column, 6)
	sac.add_child(UiKit.label("Ton sac (%d)" % app.profile.sac.size(), 20, UiKit.GOLD, false))
	if app.profile.sac.is_empty():
		sac.add_child(UiKit.label("Vide. Chaque étage de la Tour franchi lâche un objet (épique aux Gardiens) ; un étage rejoué, une fois sur deux.", 16, ATTENUE, false))
	for i in range(app.profile.sac.size()):
		var f := Equipement.fiche(app.profile.sac[i], app.data)
		var b := UiKit.button("%s · %s · niveau %d · qualité %d %%" % [f["nom"], f["emplacement"], f["niveau"], f["qualite"]], _ouvrir.bind("sac", i), 52, 16)
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.add_theme_color_override("font_color", UiKit.rarete_couleur(int(f["rang"])))
		sac.add_child(b)
	column.add_child(UiKit.label("Les Éclats viennent des duels, des étages de la Tour et du revenu de chaque jour. Ils paient la reforge.", 14, ATTENUE))


func _ouvrir(ou: String, cle: Variant) -> void:
	app.sfx.play("clic")
	app.show_screen("forge", {"ou": ou, "cle": cle})


## « +12,3 % de PV max » pour chaque ligne non nulle d'un jeu de bonus.
func _lignes_bonus(mods: Dictionary) -> Array[String]:
	var out: Array[String] = []
	for s in Equipement.STATS:
		if float(mods.get(s, 0.0)) > 0.0:
			out.append(Equipement.texte_ligne({"stat": s, "valeur": float(mods[s]) * 100.0}, app.data))
	return out


# --- La fiche d'un objet ----------------------------------------------------------------------

func _fiche(ou: String, cle: Variant) -> void:
	var objet := app.objet_a(ou, cle)
	if objet.is_empty():
		_forge()
		return
	var f := Equipement.fiche(objet, app.data)
	var column := UiKit.scroll_column(self, 12)
	column.add_child(UiKit.label(str(f["nom"]), 30, UiKit.rarete_couleur(int(f["rang"]))))
	column.add_child(UiKit.label("%s · niveau %d · qualité %d %% · %s" % [f["emplacement"], f["niveau"], f["qualite"], "lié à toi" if f["lie"] else "échangeable"], 15, UiKit.SOFT))
	if str(f.get("description", "")) != "":
		column.add_child(UiKit.label(str(f["description"]), 14, ATTENUE, false))
	if str(f.get("texte_trait", "")) != "":
		column.add_child(UiKit.label("Trait légendaire · " + str(f["texte_trait"]), 16, UiKit.rarete_couleur(4), false))
	if ou == "porte":
		column.add_child(UiKit.label("Tu le portes.", 15, ATTENUE))
	# Les lignes, chacune avec sa fourchette et sa reforge.
	var lignes := UiKit.card(column, 6)
	lignes.add_child(UiKit.label("Ses lignes", 20, UiKit.GOLD, false))
	lignes.add_child(UiKit.label("Entre crochets : ce que cette ligne peut valoir sur un objet de ce niveau et de cette rareté.", 14, ATTENUE, false))
	var cout := int(f["reforge"])
	for i in range(f["lignes"].size()):
		var l: Dictionary = f["lignes"][i]
		lignes.add_child(UiKit.label("%s  %s" % [l["texte"], l["fourchette"]], 17, Color.WHITE, false))
		var assez := app.profile.eclats >= cout
		var b := UiKit.button("Reforger « %s » (%d Éclats%s)" % [l["nom"], cout, "" if assez else ", il t'en manque"], _reforger.bind(ou, cle, i), 44, 15)
		b.disabled = not assez
		lignes.add_child(b)
	lignes.add_child(UiKit.label("Reforger retire une ligne au sort (une autre statistique possible, un autre chiffre). Chaque reforge coûte plus cher que la précédente.", 14, ATTENUE, false))
	# La comparaison : les bonus avant et après, et ce que ça change sur ta roue.
	var e := Equipement.emplacement(objet, app.data)
	var avant := app.bonus_portes()
	var autres: Array = app.objets_portes().filter(func(o): return Equipement.emplacement(o, app.data) != e)
	var apres := Equipement.mods(autres + ([objet] if ou == "sac" else []), app.data)
	var comp := UiKit.card(column, 4)
	comp.add_child(UiKit.label("Si tu l'équipes" if ou == "sac" else "Si tu le retires", 20, UiKit.GOLD, false))
	if ou == "sac" and app.profile.portes.has(e):
		comp.add_child(UiKit.label("À la place de : %s" % Equipement.nom(app.profile.portes[e], app.data), 15, ATTENUE, false))
	var change := false
	for s in Equipement.STATS:
		var a := float(avant.get(s, 0.0))
		var b := float(apres.get(s, 0.0))
		if absf(a - b) < 0.0005:
			continue
		change = true
		comp.add_child(UiKit.label("%s : %s %% → %s %%" % [app.data.objets["lignes"][s]["nom"], Equipement.chiffre(a * 100.0), Equipement.chiffre(b * 100.0)], 16, UiKit.GREEN if b > a else UiKit.RED, false))
	if not change:
		comp.add_child(UiKit.label("Tes bonus ne changent pas.", 16, ATTENUE, false))
	var exemples := Equipement.apercu(app.destin, avant, apres, app.profile.level, app.data)
	if not exemples.is_empty():
		comp.add_child(UiKit.label("Sur ta roue :", 15, ATTENUE, false))
		for x in exemples:
			comp.add_child(UiKit.label(x, 16, Color.WHITE, false))
	elif change:
		comp.add_child(UiKit.label("Aucun chiffre de ta roue ne change (les PV max ne s'y voient pas).", 14, ATTENUE, false))
	# Les actions.
	column.add_child(UiKit.spacer(4))
	if ou == "sac":
		column.add_child(UiKit.main_button("Équiper" + ("" if f["lie"] else " (il devient lié)"), _equiper.bind(int(cle)), 72))
		recycler_bouton = UiKit.button("Recycler (+%d Éclats)" % Equipement.recyclage(objet, app.data), _recycler.bind(int(cle)), 52)
		column.add_child(recycler_bouton)
		if Comptoir.vendable(objet):
			column.add_child(UiKit.label("Échangeable : le Comptoir l'achète %d Or (prix plancher)." % Comptoir.prix_plancher(objet, app.data), 14, ATTENUE))
			column.add_child(UiKit.button("Vendre au Comptoir", func(): app.show_screen("comptoir"), 48, 16))
	else:
		column.add_child(UiKit.main_button("Retirer (il va dans ton sac)", _retirer.bind(str(cle)), 72))
	column.add_child(UiKit.button("Retour à la Forge", func(): app.show_screen("forge"), 56))


func _equiper(index: int) -> void:
	app.sfx.play("clic")
	app.equiper(index)
	app.show_screen("forge")


func _retirer(emplacement: String) -> void:
	app.sfx.play("clic")
	app.retirer(emplacement)
	app.show_screen("forge")


## Recycler demande une confirmation : un second appui.
func _recycler(index: int) -> void:
	if not _recycler_arme:
		_recycler_arme = true
		recycler_bouton.text = "Sûr ? Touche encore pour le recycler"
		recycler_bouton.modulate = Color(1, 0.6, 0.6)
		return
	app.sfx.play("clic")
	app.recycler(index)
	app.show_screen("forge")


func _reforger(ou: String, cle: Variant, ligne: int) -> void:
	if app.reforger(ou, cle, ligne):
		app.sfx.play("clic")
	# La fiche se redessine, avec la ligne retirée (le sac et l'emplacement n'ont pas bougé).
	app.show_screen("forge", {"ou": ou, "cle": cle})
