## Le Marché (docs/GDD_V2.md, § 10.2 ; docs/PLAN.md, PR 5.5) : tes ventes encaissées, tes annonces, mettre un objet
## échangeable en vente à un prix dans sa fourchette, et les annonces anonymes des autres joueurs, au premier acheteur.
## Fermé avant le niveau 15 et 7 jours de compte. Affichage seulement : les règles sont dans engine/marche.gd, les
## annonces sur le serveur (ArenaApp).
extends Control

const ATTENUE := Color("aaa49b")

var app: ArenaApp
var achat_boutons: Dictionary = {}
var _achat_arme := ""


func setup(p_app: ArenaApp, _options: Dictionary) -> void:
	app = p_app
	var column := UiKit.scroll_column(self, 12)
	column.add_child(UiKit.label("Le Marché", 34, UiKit.GOLD))
	var encaisse: Array = await app.encaisser_ventes()
	if not is_inside_tree():
		return
	column.add_child(UiKit.label("%d Or · %d Éclat%s" % [app.profile.monnaie_or, app.profile.eclats, "s" if app.profile.eclats > 1 else ""], 18, Color.WHITE))
	for v in encaisse:
		var f := Equipement.fiche(v["annonce"]["objet"], app.data)
		column.add_child(UiKit.label("Vendu : %s pour %d Or · taxe %d · tu touches %d Or." % [f["nom"], int(v["annonce"]["prix"]), int(v["annonce"]["prix"]) - int(v["net"]), int(v["net"])], 15, UiKit.GOLD))
	column.add_child(UiKit.label("Entre joueurs : tu fixes ton prix dans une fourchette, les annonces sont anonymes et partent au premier acheteur, et chaque vente perd %d %% de taxe." % roundi(100.0 * float(app.data.marche["taxe"])), 14, UiKit.SOFT))
	if not app.marche_ouvert():
		var ferme := UiKit.card(column, 4)
		ferme.add_child(UiKit.label("Le Marché est fermé pour toi", 20, UiKit.GOLD, false))
		ferme.add_child(UiKit.label("Il s'ouvre au niveau %d et après %d jours de compte. Il te manque %s." % [int(app.data.marche["niveau_min"]), int(app.data.marche["jours_min"]), app.marche_manque()], 15, Color.WHITE, false))
		ferme.add_child(UiKit.label("En attendant, le Comptoir achète tes objets échangeables au prix plancher.", 14, ATTENUE, false))
		column.add_child(UiKit.button("Retour au Comptoir", func(): app.show_screen("comptoir"), 52))
		return
	var annonces: Array = await app.serveur.annonces(30)
	if not is_inside_tree():
		return
	# Mes annonces.
	var miennes := UiKit.card(column, 6)
	miennes.add_child(UiKit.label("Mes annonces", 20, UiKit.GOLD, false))
	var nb_miennes := 0
	for a in annonces:
		if not bool(a.get("mienne", false)):
			continue
		nb_miennes += 1
		var f := Equipement.fiche(a["objet"], app.data)
		miennes.add_child(UiKit.label("%s · %s · niveau %d · qualité %d %% · %d Or (tu toucheras %d)" % [f["nom"], f["emplacement"], f["niveau"], f["qualite"], int(a["prix"]), Marche.net(int(a["prix"]), app.data)], 15, UiKit.rarete_couleur(int(f["rang"])), false))
		miennes.add_child(UiKit.button("Retirer de la vente", func():
			app.sfx.play("clic")
			await app.retirer_annonce(str(a["id"]))
			app.show_screen("marche"), 44, 15))
	if nb_miennes == 0:
		miennes.add_child(UiKit.label("Aucune annonce en cours (%d au plus)." % int(app.data.marche["annonces_max"]), 14, ATTENUE, false))
	# Mettre en vente.
	var vente := UiKit.card(column, 6)
	vente.add_child(UiKit.label("Mettre en vente", 20, UiKit.GOLD, false))
	vente.add_child(UiKit.label("Tes objets échangeables. Choisis un prix dans la fourchette ; la taxe de %d %% est retenue à la vente." % roundi(100.0 * float(app.data.marche["taxe"])), 14, ATTENUE, false))
	var un := false
	for i in range(app.profile.sac.size()):
		var o: Dictionary = app.profile.sac[i]
		if not Comptoir.vendable(o):
			continue
		un = true
		var f := Equipement.fiche(o, app.data)
		var fm := Comptoir.fourchette_marche(o, app.data)
		vente.add_child(UiKit.label("%s · %s · niveau %d · qualité %d %% · de %d à %d Or" % [f["nom"], f["emplacement"], f["niveau"], f["qualite"], int(fm[0]), int(fm[1])], 15, UiKit.rarete_couleur(int(f["rang"])), false))
		var ligne := HBoxContainer.new()
		ligne.add_theme_constant_override("separation", 8)
		vente.add_child(ligne)
		var champ := LineEdit.new()
		champ.text = str(int(fm[0]))
		champ.placeholder_text = "Prix en Or"
		champ.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		champ.custom_minimum_size = Vector2(0, 46)
		ligne.add_child(champ)
		var retour := UiKit.label("", 13, ATTENUE, false)
		ligne.add_child(UiKit.button("Mettre en vente", func():
			app.sfx.play("clic")
			var prix := int(champ.text) if champ.text.is_valid_int() else -1
			if not Marche.prix_valide(o, prix, app.data):
				retour.text = "Un prix entre %d et %d Or." % [int(fm[0]), int(fm[1])]
				return
			if await app.deposer_annonce(i, prix):
				app.show_screen("marche")
			else:
				retour.text = "Impossible : %d annonces au plus, ou le serveur refuse." % int(app.data.marche["annonces_max"]), 46, 15))
		vente.add_child(retour)
	if not un:
		vente.add_child(UiKit.label("Rien d'échangeable dans ton sac.", 15, ATTENUE, false))
	# Les annonces des autres.
	var autres := UiKit.card(column, 6)
	autres.add_child(UiKit.label("Les annonces", 20, UiKit.GOLD, false))
	autres.add_child(UiKit.label("Anonymes, au premier acheteur. L'objet acheté reste échangeable tant que tu ne le portes pas.", 14, ATTENUE, false))
	var nb := 0
	for a in annonces:
		if bool(a.get("mienne", false)):
			continue
		nb += 1
		var f := Equipement.fiche(a["objet"], app.data)
		var lignes: Array[String] = []
		for l in f["lignes"]:
			lignes.append(str(l["texte"]))
		autres.add_child(UiKit.label("%s · %s · niveau %d · qualité %d %%" % [f["nom"], f["emplacement"], f["niveau"], f["qualite"]], 16, UiKit.rarete_couleur(int(f["rang"])), false))
		autres.add_child(UiKit.label(" + ".join(lignes), 13, Color.WHITE, false))
		var prix := int(a["prix"])
		var b := UiKit.button("Acheter (%d Or%s)" % [prix, "" if app.profile.monnaie_or >= prix else ", il t'en manque"], _acheter.bind(str(a["id"]), prix), 46, 16)
		b.disabled = app.profile.monnaie_or < prix
		achat_boutons[str(a["id"])] = b
		autres.add_child(b)
	if nb == 0:
		autres.add_child(UiKit.label("Aucune annonce pour l'instant.", 15, ATTENUE, false))
	column.add_child(UiKit.button("Retour au Comptoir", func(): app.show_screen("comptoir"), 52))


## Acheter demande une confirmation : un second appui sur le même bouton.
func _acheter(id: String, prix: int) -> void:
	if _achat_arme != id:
		_achat_arme = id
		var b: Button = achat_boutons[id]
		b.text = "Sûr ? Touche encore pour acheter (%d Or)" % prix
		b.modulate = Color(1, 0.85, 0.5)
		return
	if await app.acheter_annonce(id, prix):
		app.sfx.play("victoire")
	else:
		app.sfx.play("clic")
	app.show_screen("marche")
