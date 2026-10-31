## La carte du monde (docs/GDD_V2.md, § 9.2 ; docs/PLAN.md, phase 7) : trois régions de territoires reliés, qui tient
## quoi (la bannière de la guilde), le type de chaque territoire et ce qu'il rapporte, et le donjon de chaque région, qui
## apparaît chaque semaine sur l'un de ses territoires : c'est ici qu'on entre dans un donjon. Toucher un territoire
## ouvre sa fiche. Affichage seulement : les règles sont dans engine/carte.gd, qui tient quoi sur le serveur (ArenaApp).
extends Control

const ATTENUE := Color("aaa49b")

var app: ArenaApp
var selection := ""


func setup(p_app: ArenaApp, options: Dictionary) -> void:
	app = p_app
	selection = str(options.get("territoire", ""))
	var column := UiKit.scroll_column(self, 12)
	column.add_child(UiKit.label("La carte du monde", 34, UiKit.GOLD))
	var etat: Dictionary = await app.carte_territoires()
	if not is_inside_tree():
		return
	var donjons := app.donjons_de_la_semaine()
	var batailles: Array = await app.batailles_du_jour()
	if not is_inside_tree():
		return
	column.add_child(UiKit.label("Trois régions, des territoires reliés. Une guilde qui tient un territoire en touche le revenu ; le donjon d'une région apparaît chaque semaine sur l'un de ses territoires, et c'est là qu'on y entre. Touche un territoire.", 14, UiKit.SOFT))
	var dessin := Dessin.new()
	dessin.app = app
	dessin.etat = etat
	dessin.donjons = donjons
	dessin.nb_guildes = app.nb_guildes
	dessin.selection = selection
	dessin.choix = _choisir
	column.add_child(dessin)
	if selection != "":
		_fiche(column, selection, etat, donjons, batailles)
	else:
		var aide := UiKit.card(column, 4)
		aide.add_child(UiKit.label("Les donjons de la semaine", 20, UiKit.GOLD, false))
		for t in donjons:
			var dj := Donjon.definition(str(donjons[t]), app.data)
			var ter := Carte.territoire(str(t), app.data)
			aide.add_child(UiKit.button("%s · %s (niveaux %d à %d)" % [dj["nom"], ter["nom"], int(dj["niveau_min"]), int(dj["niveau_max"])], _choisir.bind(str(t)), 44, 15))
		aide.add_child(UiKit.label("Légende : Mi mine · S sanctuaire · Ma marché · R relais · B bastion · un anneau d'or marque un donjon · la couleur est celle de la guilde qui tient le territoire, gris pour un territoire neutre.", 13, ATTENUE, false))
	_guerres(column, batailles, etat)
	column.add_child(UiKit.button("Retour à la ville", func(): app.show_screen("ville"), 52))


func _choisir(id: String) -> void:
	app.sfx.play("clic")
	app.show_screen("carte", {"territoire": id})


func _fiche(column: VBoxContainer, id: String, etat: Dictionary, donjons: Dictionary, batailles: Array) -> void:
	var d := app.data
	var t := Carte.territoire(id, d)
	if t.is_empty():
		return
	var r := Carte.region(str(t["region"]), d)
	var carte := UiKit.card(column, 4)
	carte.add_child(UiKit.label(str(t["nom"]), 24, UiKit.GOLD, false))
	carte.add_child(UiKit.label("%s · niveaux %d à %d" % [r["nom"], int(r["niveau_min"]), int(r["niveau_max"])], 14, ATTENUE, false))
	if not Carte.ouvert(t, app.nb_guildes):
		carte.add_child(UiKit.label("Ce territoire n'existe pas encore : il apparaîtra quand le serveur comptera %d guildes (il en compte %d)." % [int(t["des"]), app.nb_guildes], 14, UiKit.SOFT, false))
		return
	carte.add_child(UiKit.label(Carte.texte_type(str(t["type"]), d), 15, Color.WHITE, false))
	var tenu: Dictionary = etat.get(id, {})
	if tenu.is_empty():
		carte.add_child(UiKit.label("Neutre : aucune guilde ne le tient.", 15, UiKit.SOFT, false))
	else:
		var ligne := HBoxContainer.new()
		ligne.add_theme_constant_override("separation", 8)
		carte.add_child(ligne)
		var b := preload("res://scenes/screens/guilde_screen.gd").Banniere.new()
		b.app = app
		b.banniere = tenu.get("banniere", {})
		b.custom_minimum_size = Vector2(36, 46)
		ligne.add_child(b)
		var mienne: bool = not app.guilde.is_empty() and str(tenu.get("guilde", "")) == str(app.guilde["id"])
		ligne.add_child(UiKit.label("Tenu par %s%s (%s)" % [tenu.get("nom", "?"), " : ta guilde" if mienne else "", tenu.get("depuis", "")], 15, UiKit.GOLD if mienne else Color.WHITE, false))
	var noms: Array[String] = []
	for v in Carte.voisins(id, d):
		noms.append(str(Carte.territoire(v, d).get("nom", v)))
	carte.add_child(UiKit.label("Voisins : %s." % ", ".join(noms), 13, ATTENUE, false))
	if not app.guilde.is_empty():
		var pourquoi := app.empeche_guerre(id, batailles)
		if pourquoi == "":
			carte.add_child(UiKit.button("Déclarer une attaque ce soir", func():
				app.sfx.play("clic")
				if (await app.declarer_guerre(id)).is_empty():
					app.sfx.play("defaite")
				app.show_screen("carte", {"territoire": id}), 44, 15))
		else:
			carte.add_child(UiKit.label("Pas d'attaque possible : %s." % pourquoi, 13, ATTENUE, false))
	if donjons.has(id):
		var dj := Donjon.definition(str(donjons[id]), d)
		var carte_dj := UiKit.card(column, 4)
		carte_dj.add_child(UiKit.label("%s est ici cette semaine" % dj["nom"], 20, UiKit.GOLD, false))
		carte_dj.add_child(UiKit.label(str(dj["description"]), 14, UiKit.SOFT, false))
		carte_dj.add_child(UiKit.label("%d %% de l'entrée vont à la guilde qui tient ce territoire." % roundi(100.0 * float(d.carte["donjon"]["part_entree"])), 13, ATTENUE, false))
		var entree := int(dj["entree"])
		var assez := app.profile.eclats >= entree
		var hors := app.profile.level < int(dj["niveau_min"])
		var bouton := UiKit.main_button("Entrer (%d Éclats)%s" % [entree, "" if assez else ", il t'en manque"] if not hors else "Entrer (%d Éclats) · tu es sous le niveau %d" % [entree, int(dj["niveau_min"])], func():
			if app.commencer_donjon(str(donjons[id])):
				app.sfx.play("clic")
				app.show_screen("donjon"), 60)
		bouton.disabled = not assez
		carte_dj.add_child(bouton)
		carte_dj.add_child(UiKit.button("Ta carte de ce donjon", func(): app.show_screen("donjon"), 40, 14))


## Les guerres du soir : chaque bataille (le territoire, l'attaquant, le défenseur, les scores), tes combats à jouer si ta
## guilde attaque ; les soirs passés sont résolus au passage (le résultat se lit sur la carte).
func _guerres(column: VBoxContainer, batailles: Array, _etat: Dictionary) -> void:
	var d := app.data
	var carte := UiKit.card(column, 4)
	carte.add_child(UiKit.label("Les guerres du soir", 20, UiKit.GOLD, false))
	carte.add_child(UiKit.label("Chaque soir, une guilde déclare des attaques sur des territoires voisins des siens (1 + sa taille ÷ %d). Chaque membre a %d combats de guerre contre les trios des défenseurs ; la défense est automatique. Le score pèse chaque victoire par le niveau de l'adversaire battu. Un territoire neutre va au meilleur score ; un territoire tenu tombe si l'attaque dépasse la défense × %s (× %s avec un Bastion voisin). Le résultat tombe le lendemain ; un territoire pris est protégé %d jours ; sans combat pendant %d jours, il redevient neutre." % [int(d.guerre["membres_par_attaque"]), int(d.guerre["combats_par_membre"]), str(d.guerre["defense"]).replace(".", ","), str(d.guerre["defense_bastion"]).replace(".", ","), int(d.guerre["protection_jours"]), int(d.carte["neutre_apres_jours"])], 13, ATTENUE, false))
	if batailles.is_empty():
		carte.add_child(UiKit.label("Aucune bataille ce soir pour l'instant. Touche un territoire voisin des tiens pour déclarer une attaque.", 14, UiKit.SOFT, false))
	for b in batailles:
		var ter := Carte.territoire(str(b["territoire"]), d)
		var att: Dictionary = b["attaquant"]
		var def: Dictionary = b["defenseur"]
		var mienne: bool = not app.guilde.is_empty() and str(att.get("id", "")) == str(app.guilde["id"])
		var defendue: bool = not app.guilde.is_empty() and str(def.get("id", "")) == str(app.guilde["id"])
		carte.add_child(UiKit.label("%s : %s%s attaque %s" % [ter.get("nom", "?"), att.get("nom", "?"), " (ta guilde)" if mienne else "", (str(def.get("nom", "?")) + (" (ta guilde)" if defendue else "")) if not def.is_empty() else "un territoire neutre"], 15, UiKit.GOLD if mienne or defendue else Color.WHITE, false))
		carte.add_child(UiKit.label("Score : attaquants %s · défenseurs %s · %d combat%s joué%s%s" % [("%.1f" % Guerre.score(b, "attaquant")).replace(".", ","), ("%.1f" % Guerre.score(b, "defenseur")).replace(".", ","), b["combats"].size(), "s" if b["combats"].size() > 1 else "", "s" if b["combats"].size() > 1 else "", (" · " + str(b["resultat"])) if bool(b["resolue"]) else ""], 13, ATTENUE, false))
		if mienne and not bool(b["resolue"]):
			var reste := Guerre.reste(b, app.serveur.compte_id, "attaquant", d)
			var bouton := UiKit.button("Combattre (%d combat%s restant%s ce soir)" % [reste, "s" if reste > 1 else "", "s" if reste > 1 else ""] if reste > 0 else "Tes combats du soir sont faits", func():
				app.sfx.play("clic")
				app.show_screen("versus", {"guerre": str(b["id"])}), 44, 15)
			bouton.disabled = reste <= 0
			carte.add_child(bouton)


## Le dessin de la carte : trois bandes (les régions), les liens, un rond par territoire (la couleur de la guilde qui le
## tient, gris s'il est neutre, à peine visible s'il n'existe pas encore), la lettre de son type, un anneau d'or s'il
## porte un donjon, un cercle blanc pour la sélection. Toucher un rond appelle `choix` avec l'identifiant.
class Dessin:
	extends Control
	const RAYON := 17.0
	var app: ArenaApp
	var etat: Dictionary = {}
	var donjons: Dictionary = {}
	var nb_guildes := 0
	var selection := ""
	var choix: Callable

	func _init() -> void:
		custom_minimum_size = Vector2(0, 560)
		size_flags_horizontal = Control.SIZE_EXPAND_FILL
		mouse_filter = Control.MOUSE_FILTER_STOP

	func _position(t: Dictionary) -> Vector2:
		return Vector2(16.0 + float(t["x"]) * (size.x - 32.0), 14.0 + float(t["y"]) * (size.y - 28.0))

	func _draw() -> void:
		var d := app.data
		var police := ThemeDB.fallback_font
		var regions: Array = Carte.regions(d)
		for i in range(regions.size()):
			var r: Dictionary = regions[i]
			var ys: Array = r["territoires"].map(func(t): return float(t["y"]))
			var haut: float = 14.0 + float(ys.min()) * (size.y - 28.0) - 30.0
			var bas: float = 14.0 + float(ys.max()) * (size.y - 28.0) + 30.0
			draw_rect(Rect2(0, haut, size.x, bas - haut), Color(1, 1, 1, 0.03 + 0.02 * (i % 2)))
			draw_string(police, Vector2(8, haut + 14), "%s · niveaux %d à %d" % [r["nom"], int(r["niveau_min"]), int(r["niveau_max"])], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.8, 0.85, 1, 0.8))
		var lettres := {"mine": "Mi", "sanctuaire": "S", "marche": "Ma", "relais": "R", "bastion": "B"}
		for r in regions:
			for lien in r["liens"]:
				var a := Carte.territoire(str(lien[0]), d)
				var b := Carte.territoire(str(lien[1]), d)
				if a.is_empty() or b.is_empty():
					continue
				var visible := Carte.ouvert(a, nb_guildes) and Carte.ouvert(b, nb_guildes)
				draw_line(_position(a), _position(b), Color(1, 1, 1, 0.25 if visible else 0.07), 2.0)
		for t in Carte.territoires(d):
			var p := _position(t)
			var ouvert := Carte.ouvert(t, nb_guildes)
			var tenu: Dictionary = etat.get(str(t["id"]), {})
			var fond := Color(0.35, 0.37, 0.45) if tenu.is_empty() else Guilde.couleur(str(tenu.get("banniere", {}).get("fond", "")), d)
			if not ouvert:
				fond = Color(0.2, 0.2, 0.25, 0.5)
			draw_circle(p, RAYON, fond)
			draw_arc(p, RAYON, 0, TAU, 40, Color(0, 0, 0, 0.5), 2.0)
			if donjons.has(str(t["id"])):
				draw_arc(p, RAYON + 5, 0, TAU, 40, UiKit.GOLD, 3.0)
			if str(t["id"]) == selection:
				draw_arc(p, RAYON + 9, 0, TAU, 40, Color.WHITE, 2.0)
			var lettre: String = lettres.get(str(t["type"]), "?") if ouvert else "?"
			draw_string(police, p + Vector2(-RAYON, 5), lettre, HORIZONTAL_ALIGNMENT_CENTER, RAYON * 2, 13, Color.WHITE if ouvert else Color(1, 1, 1, 0.4))
			draw_string(police, p + Vector2(-60, RAYON + 14), str(t["nom"]), HORIZONTAL_ALIGNMENT_CENTER, 120, 11, Color(1, 1, 1, 0.85 if ouvert else 0.35))

	func _gui_input(event: InputEvent) -> void:
		if not event is InputEventMouseButton or not event.pressed or event.button_index != MOUSE_BUTTON_LEFT:
			return
		var plus_proche := ""
		var distance := RAYON + 8.0
		for t in Carte.territoires(app.data):
			var dist := _position(t).distance_to(event.position)
			if dist < distance:
				distance = dist
				plus_proche = str(t["id"])
		if plus_proche != "" and choix.is_valid():
			accept_event()
			choix.call(plus_proche)
