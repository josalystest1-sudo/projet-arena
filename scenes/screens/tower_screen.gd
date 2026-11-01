## La Tour infinie (docs/GDD_V2.md, § 6) : les règles en clair, ton record et ton palier, « Reprendre » (au palier),
## « Rejouer depuis » un palier plus bas, le bestiaire, et les records de chaque classe. Les étages se suivent tant que le
## trio tient ; chaque étage a toujours la même force, et elle monte d'étage en étage, sans fin.
extends Control

var app: ArenaApp


func setup(p_app: ArenaApp, _options: Dictionary) -> void:
	app = p_app
	var column := UiKit.scroll_column(self, 12)
	column.add_child(UiKit.label("La Tour", 34, UiKit.GOLD))
	var cls_nom := str(app.data.classe(app.lignee())["nom"])
	var record := int(app.profile.tower_records.get(app.lignee(), 0))
	column.add_child(UiKit.label("Ton record (%s) : %s" % [cls_nom, "étage %d" % record if record > 0 else "pas encore de montée"], 20, Color.WHITE))
	var palier := app.palier()
	var regles := UiKit.card(column, 4)
	regles.add_child(UiKit.label("Les règles", 20, UiKit.GOLD, false))
	for ligne in ["La Tour n'a pas de fin. Chaque étage a toujours la même force, pour tout le monde, et elle monte d'étage en étage : c'est ton niveau qui te fait monter plus haut.",
			"Chaque étage est plus dur que le précédent. Un Gardien tous les 5 étages, un grand Gardien tous les 10 : des murs, bien plus forts que les étages qui les suivent. Une fois un Gardien franchi, tu reprends toujours après lui, avec tous tes PV : c'est ton palier.",
			"Entre deux étages, chacun récupère 20 % de ses PV ; un Écho tombé revient avec 20 %. Pas de limite de tours : les soins des monstres s'affaiblissent à chaque fois.",
			"La montée s'arrête quand tout ton trio tombe. L'étage atteint est ton record, classé par classe. Un étage déjà franchi rapporte moitié moins d'XP.",
			"Chaque Gardien que tu bats pour la première fois t'offre une Faveur, à choisir parmi trois. Les Faveurs se cumulent et ne valent que dans la Tour."]:
		regles.add_child(UiKit.label(ligne, 16, UiKit.SOFT, false))
	# Ta forme : rejouer un étage déjà franchi fatigue ; écroulé, on attend (ou une potion).
	var forme := UiKit.card(column, 4)
	forme.add_child(UiKit.label("Ta forme", 20, UiKit.GOLD, false))
	forme.add_child(UiKit.label(app.texte_energie(), 16, Color.WHITE, false))
	forme.add_child(UiKit.label("Rejouer un étage déjà franchi (jusqu'à ton record) coûte %d points d'énergie ; ton record, jamais. Sous %d, tu es moins fort ; à zéro, tu t'écroules et tu attends, ou tu bois une potion chez l'Alchimiste du Comptoir. L'énergie revient toute seule : %d points par heure." % [int(app.data.fatigue["cout_combat"]), int(app.data.fatigue["seuil_fatigue"]), int(app.data.fatigue["recuperation_par_heure"])], 14, UiKit.SOFT, false))
	var bloque := app.farm_etage(palier) and not app.peut_farmer()
	var monter := UiKit.main_button("Écroulé de fatigue : repos d'abord" if bloque else ("Reprendre à l'étage %d" % palier if palier > 1 else "Monter"), _monter.bind(palier), 84)
	monter.disabled = bloque
	column.add_child(monter)
	# Les Faveurs acquises par cette classe.
	var faveurs := app.faveurs()
	var carte_faveurs := UiKit.card(column, 4)
	carte_faveurs.add_child(UiKit.label("Tes Faveurs (%s)" % cls_nom, 18, UiKit.GOLD, false))
	if faveurs.is_empty():
		carte_faveurs.add_child(UiKit.label("Aucune encore : bats un Gardien pour la première fois.", 16, UiKit.SOFT, false))
	for id in app.data.faveurs:
		if faveurs.has(id):
			carte_faveurs.add_child(UiKit.label(Tour.texte_faveur(str(id), int(faveurs[id]), app.data), 16, Color.WHITE, false))
	var plus_bas := Tour.paliers(palier - 1, int(app.data.tour["gardien_tous_les"])).filter(func(p): return p < palier)
	if not plus_bas.is_empty():
		var rejouer := UiKit.card(column, 4)
		rejouer.add_child(UiKit.label("Rejouer depuis un palier plus bas", 18, UiKit.GOLD, false))
		var ligne := HFlowContainer.new()
		ligne.add_theme_constant_override("h_separation", 8)
		ligne.add_theme_constant_override("v_separation", 8)
		rejouer.add_child(ligne)
		for p in plus_bas:
			var b := UiKit.button("Étage %d" % p, _monter.bind(p), 48, 16)
			b.disabled = not app.peut_farmer()
			ligne.add_child(b)
		if not app.peut_farmer():
			rejouer.add_child(UiKit.label(app.texte_ecroule(), 14, UiKit.SOFT, false))
	column.add_child(UiKit.button("Le bestiaire", func(): app.show_screen("bestiaire"), 52))
	column.add_child(UiKit.button("Retour à la ville", func(): app.show_screen("ville"), 52))
	var records := UiKit.card(column, 2)
	records.add_child(UiKit.label("Records par classe", 18, UiKit.GOLD, false))
	for class_id in app.data.ordre_classes:
		var value := int(app.profile.tower_records.get(class_id, 0))
		records.add_child(UiKit.label("%s : %s" % [app.data.classe(class_id)["nom"], "étage %d" % value if value > 0 else "—"], 16, Color.WHITE, false))


func _monter(depart: int) -> void:
	app.sfx.play("clic")
	app.show_screen("trio", {"mode": "tour", "depart": depart})
