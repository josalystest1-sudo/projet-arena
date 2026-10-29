## Le Comptoir (docs/GDD_V2.md, § 10.2 ; docs/PLAN.md, PR 5.5, hors ligne) : ton Or, l'étal du jour (des objets liés
## contre des Éclats), et la vente de tes objets échangeables au prix plancher (le seul robinet d'Or). Affichage
## seulement : les prix viennent d'engine/comptoir.gd, l'inventaire du profil (ArenaApp).
extends Control

const ATTENUE := Color("aaa49b")

var app: ArenaApp
var vendre_boutons: Dictionary = {}
var _vente_armee := -1


func setup(p_app: ArenaApp, _options: Dictionary) -> void:
	app = p_app
	var column := UiKit.scroll_column(self, 12)
	column.add_child(UiKit.label("Le Comptoir", 34, UiKit.GOLD))
	column.add_child(UiKit.label("%d Or · %d Éclat%s" % [app.profile.monnaie_or, app.profile.eclats, "s" if app.profile.eclats > 1 else ""], 18, Color.WHITE))
	column.add_child(UiKit.label("L'Or ne tombe jamais du jeu : il naît ici, quand tu vends un objet échangeable (premier passage de la Tour, boss de donjon). Il sert au Marché, entre joueurs, et servira à la Boutique.", 14, UiKit.SOFT))
	column.add_child(UiKit.main_button("Le Marché (entre joueurs)%s" % ("" if app.marche_ouvert() else " · fermé pour toi"), func():
		app.sfx.play("clic")
		app.show_screen("marche"), 70))
	# L'étal du jour.
	var etal := UiKit.card(column, 6)
	etal.add_child(UiKit.label("L'étal du jour", 20, UiKit.GOLD, false))
	etal.add_child(UiKit.label("Des objets liés, à ton niveau, contre des Éclats. L'étal change chaque jour.", 14, ATTENUE, false))
	var objets := app.etal_du_jour()
	for i in range(objets.size()):
		var o: Dictionary = objets[i]
		var f := Equipement.fiche(o, app.data)
		var lignes: Array[String] = []
		for l in f["lignes"]:
			lignes.append(str(l["texte"]))
		etal.add_child(UiKit.label("%s · %s · qualité %d %%" % [f["nom"], f["emplacement"], f["qualite"]], 17, UiKit.rarete_couleur(int(f["rang"])), false))
		etal.add_child(UiKit.label(" + ".join(lignes), 14, Color.WHITE, false))
		var prix := Comptoir.prix_etal(o, app.data)
		if bool(o.get("achete", false)):
			etal.add_child(UiKit.label("Acheté aujourd'hui.", 14, ATTENUE, false))
		else:
			var b := UiKit.button("Acheter (%d Éclats%s)" % [prix, "" if app.profile.eclats >= prix else ", il t'en manque"], _acheter.bind(i), 48, 16)
			b.disabled = app.profile.eclats < prix
			etal.add_child(b)
	# Vendre.
	var vente := UiKit.card(column, 6)
	vente.add_child(UiKit.label("Vendre au prix plancher", 20, UiKit.GOLD, false))
	vente.add_child(UiKit.label("Seuls tes objets échangeables. Le prix dépend de la rareté, du niveau et de la qualité ; au Marché, tu pourras demander plus.", 14, ATTENUE, false))
	var un := false
	for i in range(app.profile.sac.size()):
		var o: Dictionary = app.profile.sac[i]
		if not Comptoir.vendable(o):
			continue
		un = true
		var f := Equipement.fiche(o, app.data)
		var fm := Comptoir.fourchette_marche(o, app.data)
		vente.add_child(UiKit.label("%s · %s · niveau %d · qualité %d %% · au Marché : de %d à %d Or" % [f["nom"], f["emplacement"], f["niveau"], f["qualite"], int(fm[0]), int(fm[1])], 15, UiKit.rarete_couleur(int(f["rang"])), false))
		var b := UiKit.button("Vendre (+%d Or)" % Comptoir.prix_plancher(o, app.data), _vendre.bind(i), 46, 16)
		vendre_boutons[i] = b
		vente.add_child(b)
	if not un:
		vente.add_child(UiKit.label("Rien d'échangeable dans ton sac.", 15, ATTENUE, false))
	column.add_child(UiKit.button("Retour à la ville", func(): app.show_screen("ville"), 52))


func _acheter(index: int) -> void:
	if app.acheter_etal(index):
		app.sfx.play("clic")
	app.show_screen("comptoir")


## Vendre demande une confirmation : un second appui sur le même bouton.
func _vendre(index: int) -> void:
	if _vente_armee != index:
		_vente_armee = index
		var b: Button = vendre_boutons[index]
		b.text = "Sûr ? Touche encore pour vendre"
		b.modulate = Color(1, 0.85, 0.5)
		return
	if app.vendre(index) > 0:
		app.sfx.play("victoire")
	app.show_screen("comptoir")
