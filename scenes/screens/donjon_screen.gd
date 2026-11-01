## Le Donjon (docs/GDD_V2.md, § 8 ; docs/PLAN.md, PR 6.3, joué en solo en attendant le serveur) : la liste des donjons
## par tranche de niveau, ta carte de chacun (routes explorées, portes révélées, boss vaincus), l'entrée (des Éclats) ;
## puis, pendant une descente, les trois portes dans ton ordre, et l'abandon. Affichage seulement : les règles sont dans
## engine/donjon.gd, la descente en cours dans ArenaApp.
extends Control

const ATTENUE := Color("aaa49b")

var app: ArenaApp


func setup(p_app: ArenaApp, _options: Dictionary) -> void:
	app = p_app
	if app.donjon_en_cours != null and app.donjon_en_cours.phase == "portes":
		_portes()
	else:
		_liste()


# --- La liste des donjons --------------------------------------------------------------

func _liste() -> void:
	var column := UiKit.scroll_column(self, 12)
	column.add_child(UiKit.label("Les donjons", 34, UiKit.GOLD))
	column.add_child(UiKit.label("Un donjon est un arbre de routes : trois portes à chaque embranchement, une vague derrière chacune. Au bout, un élite ; sur une seule route, le boss. Tu descends avec tes deux Échos ; le vote des portes est ton choix.", 15, UiKit.SOFT))
	column.add_child(UiKit.label("Les portes n'ont pas de nom : leur ordre est le tien, personne ne peut te dicter une route. Ta carte retient où tu es passé ; un élite lâche un fragment qui révèle une porte du boss.", 14, ATTENUE))
	column.add_child(UiKit.label("%d Éclat%s" % [app.profile.eclats, "s" if app.profile.eclats > 1 else ""], 17, Color.WHITE))
	# La fatigue : chaque combat de donjon coûte de l'énergie ; écroulé, on attend (ou une potion).
	column.add_child(UiKit.label("%s · chaque combat de donjon coûte %d points d'énergie." % [app.texte_energie(), int(app.data.fatigue["cout_combat"])], 14, UiKit.SOFT))
	if not app.peut_farmer():
		column.add_child(UiKit.label(app.texte_ecroule(), 15, UiKit.SOFT))
	for dj in app.data.donjons["donjons"]:
		var carte := app.carte_donjon(str(dj["id"]))
		var c := UiKit.card(column, 4)
		c.add_child(UiKit.label("%s · niveaux %d à %d" % [dj["nom"], int(dj["niveau_min"]), int(dj["niveau_max"])], 20, UiKit.GOLD, false))
		c.add_child(UiKit.label(str(dj["description"]), 14, UiKit.SOFT, false))
		var routes := int(carte.get("explorees", []).size())
		var boss := int(carte.get("boss", 0))
		c.add_child(UiKit.label("Ta carte : %d chemin%s explor%s · %d porte%s révélée%s · boss vaincu %d fois (chasse %d)" % [routes, "s" if routes > 1 else "", "és" if routes > 1 else "é", carte.get("revelees", []).size(), "s" if carte.get("revelees", []).size() > 1 else "", "s" if carte.get("revelees", []).size() > 1 else "", boss, int(carte.get("chasse", 0)) + 1], 14, Color.WHITE, false))
		var secrets: Array = carte.get("secrets", [])
		var nb_paliers: int = app.data.boss["boss"].get(str(dj["boss"]), {}).get("paliers", []).size()
		if nb_paliers > 0:
			c.add_child(UiKit.label("Secrets du boss : %d sur %d trouvé%s" % [secrets.size(), nb_paliers, "s" if secrets.size() > 1 else ""], 14, Color.WHITE, false))
			for s in secrets:
				c.add_child(UiKit.label("· " + str(app.data.boss["solutions"].get(str(s), s)), 13, ATTENUE, false))
		var entree := int(dj["entree"])
		var assez := app.profile.eclats >= entree
		var hors := app.profile.level < int(dj["niveau_min"])
		var b := UiKit.button("Entrer (%d Éclats)%s" % [entree, "" if assez else ", il t'en manque"] if not hors else "Entrer (%d Éclats) · tu es sous le niveau %d" % [entree, int(dj["niveau_min"])], _entrer.bind(str(dj["id"])), 56, 17)
		b.disabled = not assez or not app.peut_farmer()
		c.add_child(b)
	column.add_child(UiKit.button("Retour à la ville", func(): app.show_screen("ville"), 52))


func _entrer(id: String) -> void:
	if app.commencer_donjon(id):
		app.sfx.play("clic")
		app.show_screen("donjon")


# --- Les portes -------------------------------------------------------------------------------

func _portes() -> void:
	var dj: Donjon = app.donjon_en_cours
	var carte := app.carte_donjon(dj.id)
	var column := UiKit.scroll_column(self, 12)
	column.add_child(UiKit.label(str(dj.def["nom"]), 30, UiKit.GOLD))
	column.add_child(UiKit.label("Embranchement %d sur %d · chasse %d" % [dj.profondeur() + 1, int(app.data.donjons["profondeur"]), dj.chasse + 1], 15, UiKit.SOFT))
	column.add_child(UiKit.label("Trois portes, dans ton ordre. Derrière chacune, la même vague ; mais une seule route mène au boss.", 14, ATTENUE))
	var noms := ["Porte de gauche", "Porte du milieu", "Porte de droite"]
	for p in dj.portes(carte):
		var etat := str(p["etat"])
		var texte: String = noms[int(p["position"])] if int(p["position"]) < noms.size() else "Porte %d" % (int(p["position"]) + 1)
		var detail := "inconnue"
		var couleur := Color.WHITE
		if etat == "exploree":
			detail = "déjà explorée"
			couleur = UiKit.SOFT
		elif etat == "revelee":
			detail = "révélée par un fragment : vers le boss"
			couleur = UiKit.GOLD
		var b := UiKit.button("%s · %s" % [texte, detail], _choisir.bind(int(p["position"])), 64, 17)
		b.disabled = not app.peut_farmer()
		b.add_theme_color_override("font_color", couleur)
		column.add_child(b)
	# Les PV du trio.
	var pv := UiKit.card(column, 2)
	pv.add_child(UiKit.label("Ton trio", 17, ATTENUE, false))
	var noms_trio := app.noms_trio()
	for i in range(dj.membres.size()):
		var pid := "a%d" % (i + 1)
		var etat := "KO" if bool(dj.ko.get(pid, false)) else ("%d PV" % int(dj.pv[pid]) if dj.pv.has(pid) else "tous ses PV")
		pv.add_child(UiKit.label("%s : %s" % [noms_trio.get(pid, pid), etat], 15, Color.WHITE, false))
	column.add_child(UiKit.button("Abandonner (la carte est gardée)", func():
		app.abandonner_donjon()
		app.show_screen("donjon"), 52))


func _choisir(position: int) -> void:
	var dj: Donjon = app.donjon_en_cours
	if not app.peut_farmer():
		return
	if dj.choisir(position):
		app.sfx.play("clic")
		app.show_screen("combat", app.combat_donjon(dj))
