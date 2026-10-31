## La Guilde (docs/GDD_V2.md, § 9.1 ; docs/PLAN.md, phase 6) : sans guilde, en fonder une (un nom, une bannière composée
## avec les modèles du jeu) ou en rejoindre une ; avec une guilde, sa bannière, son niveau, ses places, son Influence, ses
## effets (à monter par le chef et les officiers), ses membres (rôles, exclusion, transmission), et la quitter. Affichage
## seulement : les règles sont dans engine/guilde.gd, la guilde sur le serveur (ArenaApp).
extends Control

const ATTENUE := Color("aaa49b")

var app: ArenaApp
var _motif := ""
var _fond := ""
var _couleur := ""
var _confirmation := ""


func setup(p_app: ArenaApp, _options: Dictionary) -> void:
	app = p_app
	var column := UiKit.scroll_column(self, 12)
	column.add_child(UiKit.label("La Guilde", 34, UiKit.GOLD))
	var g: Dictionary = await app.ma_guilde()
	if not is_inside_tree():
		return
	if not app.serveur.est_connecte():
		column.add_child(UiKit.label("Pas de serveur pour l'instant : la Guilde attend la connexion.", 15, UiKit.SOFT))
		column.add_child(UiKit.button("Retour à la ville", func(): app.show_screen("ville"), 52))
		return
	if g.is_empty():
		_sans_guilde(column)
	else:
		_ma_guilde(column, g)
	column.add_child(UiKit.button("Retour à la ville", func(): app.show_screen("ville"), 52))


# --- Sans guilde : fonder ou rejoindre ------------------------------------------------------------

func _sans_guilde(column: VBoxContainer) -> void:
	column.add_child(UiKit.label("Une guilde, c'est des joueurs ensemble : leur activité (duels, étages, Gardiens) rapporte de l'Influence, qui monte des effets pour tous les membres. Jamais de puissance en PvP.", 14, UiKit.SOFT))
	# Fonder.
	var fonder := UiKit.card(column, 6)
	fonder.add_child(UiKit.label("Fonder une guilde", 20, UiKit.GOLD, false))
	var d := app.data
	if _motif == "":
		var b := Guilde.banniere_defaut(app.graine, d)
		_motif = str(b["motif"])
		_fond = str(b["fond"])
		_couleur = str(b["couleur"])
	var ligne := HBoxContainer.new()
	ligne.add_theme_constant_override("separation", 10)
	fonder.add_child(ligne)
	var banniere := Banniere.new()
	banniere.app = app
	banniere.banniere = {"motif": _motif, "fond": _fond, "couleur": _couleur}
	ligne.add_child(banniere)
	var choix := VBoxContainer.new()
	choix.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ligne.add_child(choix)
	choix.add_child(UiKit.button("Motif : %s" % d.guildes["banniere"]["motifs"][_motif], func():
		app.sfx.play("clic")
		_motif = _suivant(d.guildes["banniere"]["motifs"].keys(), _motif)
		app.show_screen("guilde"), 40, 14))
	choix.add_child(UiKit.button("Fond : %s" % _fond, func():
		app.sfx.play("clic")
		_fond = _suivant(d.guildes["banniere"]["couleurs"].keys(), _fond, _couleur)
		app.show_screen("guilde"), 40, 14))
	choix.add_child(UiKit.button("Motif en : %s" % _couleur, func():
		app.sfx.play("clic")
		_couleur = _suivant(d.guildes["banniere"]["couleurs"].keys(), _couleur, _fond)
		app.show_screen("guilde"), 40, 14))
	var champ := LineEdit.new()
	champ.placeholder_text = "Le nom de ta guilde (%d à %d caractères)" % [int(d.guildes["nom"]["min"]), int(d.guildes["nom"]["max"])]
	champ.max_length = int(d.guildes["nom"]["max"])
	champ.custom_minimum_size = Vector2(0, 48)
	fonder.add_child(champ)
	var retour := UiKit.label("", 14, ATTENUE, false)
	fonder.add_child(UiKit.main_button("Fonder", func():
		app.sfx.play("clic")
		if not Guilde.nom_valide(champ.text, d):
			retour.text = "Un nom de %d à %d caractères." % [int(d.guildes["nom"]["min"]), int(d.guildes["nom"]["max"])]
			return
		if await app.creer_guilde(champ.text, {"motif": _motif, "fond": _fond, "couleur": _couleur}):
			app.sfx.play("victoire")
			app.show_screen("guilde")
		else:
			retour.text = "Impossible : %s." % (app.serveur.erreur if app.serveur.erreur != "" else "le serveur refuse"), 60))
	fonder.add_child(retour)
	# Rejoindre.
	var rejoindre := UiKit.card(column, 6)
	rejoindre.add_child(UiKit.label("Rejoindre une guilde", 20, UiKit.GOLD, false))
	var liste: Array = await app.serveur.guildes(20)
	if not is_inside_tree():
		return
	if liste.is_empty():
		rejoindre.add_child(UiKit.label("Aucune guilde pour l'instant.", 15, ATTENUE, false))
	for r in liste:
		var l := HBoxContainer.new()
		l.add_theme_constant_override("separation", 10)
		rejoindre.add_child(l)
		var petite := Banniere.new()
		petite.app = app
		petite.banniere = r["banniere"]
		petite.custom_minimum_size = Vector2(44, 56)
		l.add_child(petite)
		var texte := VBoxContainer.new()
		texte.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		l.add_child(texte)
		texte.add_child(UiKit.label("%s · niveau %d" % [r["nom"], int(r["niveau"])], 17, Color.WHITE, false))
		texte.add_child(UiKit.label("%d membre%s sur %d places · %d Influence" % [int(r["membres"]), "s" if int(r["membres"]) > 1 else "", int(r["places"]), int(r["influence_totale"])], 13, ATTENUE, false))
		var pleine: bool = int(r["membres"]) >= int(r["places"])
		var b := UiKit.button("Pleine" if pleine else "Rejoindre", func():
			app.sfx.play("clic")
			if await app.rejoindre_guilde(str(r["id"])):
				app.sfx.play("victoire")
			app.show_screen("guilde"), 40, 14)
		b.disabled = pleine
		l.add_child(b)


func _suivant(liste: Array, actuel: String, interdit: String = "") -> String:
	var i := liste.find(actuel)
	for _k in range(liste.size()):
		i = (i + 1) % liste.size()
		if str(liste[i]) != interdit:
			return str(liste[i])
	return actuel


# --- Ma guilde ------------------------------------------------------------------------------------

func _ma_guilde(column: VBoxContainer, g: Dictionary) -> void:
	var d := app.data
	var moi := app.serveur.compte_id
	var role := Guilde.role_de(g, moi)
	var nv := Guilde.niveau(int(g["influence_totale"]), d)
	var tete := UiKit.card(column, 4)
	var ligne := HBoxContainer.new()
	ligne.add_theme_constant_override("separation", 12)
	tete.add_child(ligne)
	var banniere := Banniere.new()
	banniere.app = app
	banniere.banniere = g["banniere"]
	ligne.add_child(banniere)
	var texte := VBoxContainer.new()
	texte.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ligne.add_child(texte)
	texte.add_child(UiKit.label(str(g["nom"]), 24, UiKit.GOLD, false))
	texte.add_child(UiKit.label("Niveau %d · %d membre%s sur %d places · tu es %s" % [nv, g["membres"].size(), "s" if g["membres"].size() > 1 else "", Guilde.taille_max(nv, d), str(d.guildes["roles"][role]).to_lower()], 15, Color.WHITE, false))
	var manque := Guilde.manque_niveau(int(g["influence_totale"]), d)
	texte.add_child(UiKit.label("%d Influence en réserve · %d gagnée en tout%s" % [int(g["influence"]), int(g["influence_totale"]), (" · encore %d pour le niveau %d" % [manque, nv + 1]) if manque > 0 else ""], 14, ATTENUE, false))
	tete.add_child(UiKit.label("L'Influence vient de l'activité des membres : %s." % ", ".join(_gains(d)), 13, ATTENUE, false))
	# Les effets.
	var effets := UiKit.card(column, 6)
	effets.add_child(UiKit.label("Les effets de la guilde", 20, UiKit.GOLD, false))
	for e in d.guildes["effets"]:
		var niveau_e := int(g["effets"].get(e, 0))
		var maxi_e := int(d.guildes["effets"][e]["max"])
		effets.add_child(UiKit.label(Guilde.texte_effet(str(e), niveau_e, d) + ("" if niveau_e > 0 else " (pas encore)"), 15, Color.WHITE if niveau_e > 0 else ATTENUE, false))
		var cout := Guilde.cout_effet(str(e), niveau_e, d)
		if Guilde.peut(role, "acheter") and cout > 0:
			var b := UiKit.button("Monter (%d Influence%s)" % [cout, "" if int(g["influence"]) >= cout else ", il en manque"], func():
				app.sfx.play("clic")
				if await app.acheter_effet_guilde(str(e)):
					app.sfx.play("victoire")
				app.show_screen("guilde"), 40, 14)
			b.disabled = int(g["influence"]) < cout
			effets.add_child(b)
		elif cout == 0:
			effets.add_child(UiKit.label("Au maximum (%d sur %d)." % [niveau_e, maxi_e], 13, ATTENUE, false))
	# Les membres.
	var membres := UiKit.card(column, 6)
	membres.add_child(UiKit.label("Les membres", 20, UiKit.GOLD, false))
	var tri: Array = g["membres"].duplicate()
	tri.sort_custom(func(a, b): return Guilde.ROLES.find(str(a["role"])) < Guilde.ROLES.find(str(b["role"])))
	for m in tri:
		var est_moi: bool = str(m["id"]) == moi
		membres.add_child(UiKit.label("%s%s · %s · niveau %d · %s" % [m["pseudo"], " (toi)" if est_moi else "", app.class_label(str(m["classe"])), int(m["niveau"]), d.guildes["roles"][m["role"]]], 15, UiKit.GOLD if str(m["role"]) == "chef" else Color.WHITE, false))
		if est_moi:
			continue
		var actions := HBoxContainer.new()
		actions.add_theme_constant_override("separation", 6)
		if Guilde.peut(role, "promouvoir") and str(m["role"]) == "membre":
			actions.add_child(UiKit.button("Nommer officier", _changer_role.bind(str(m["id"]), "officier"), 36, 13))
		if Guilde.peut(role, "retrograder") and str(m["role"]) == "officier":
			actions.add_child(UiKit.button("Remettre membre", _changer_role.bind(str(m["id"]), "membre"), 36, 13))
		if Guilde.peut(role, "transmettre") and str(m["role"]) != "chef":
			actions.add_child(UiKit.button("Transmettre la guilde", _changer_role.bind(str(m["id"]), "chef"), 36, 13))
		if Guilde.peut(role, "exclure") and str(m["role"]) != "chef" and (role == "chef" or str(m["role"]) == "membre"):
			actions.add_child(UiKit.button("Exclure", _exclure.bind(str(m["id"])), 36, 13))
		if actions.get_child_count() > 0:
			membres.add_child(actions)
	# Quitter.
	var quitter := UiKit.card(column, 4)
	var mot := "Quitter la guilde" if g["membres"].size() > 1 else "Dissoudre la guilde (tu es seul)"
	if role == "chef" and g["membres"].size() > 1:
		quitter.add_child(UiKit.label("Si tu pars, la guilde passe au plus ancien officier, sinon au plus ancien membre.", 13, ATTENUE, false))
	var bq := UiKit.button(mot, func():
		app.sfx.play("clic")
		if _confirmation != "quitter":
			_confirmation = "quitter"
			app.show_screen("guilde")
			return
		if await app.quitter_guilde():
			app.show_screen("ville")
		else:
			app.show_screen("guilde"), 44, 15)
	if _confirmation == "quitter":
		bq.text = "Sûr ? Touche encore pour partir"
		bq.modulate = Color(1, 0.85, 0.5)
	quitter.add_child(bq)


func _gains(d: Donnees) -> Array[String]:
	var noms := {"duel": "un duel", "duel_gagne": "un duel gagné", "etage": "un étage", "gardien": "un Gardien", "boss": "un boss", "selection": "une sélection comme Écho"}
	var out: Array[String] = []
	for a in d.guildes["influence"]:
		out.append("%s %d" % [noms.get(a, a), int(d.guildes["influence"][a])])
	return out


func _changer_role(id: String, role: String) -> void:
	app.sfx.play("clic")
	await app.role_guilde(id, role)
	app.show_screen("guilde")


func _exclure(id: String) -> void:
	app.sfx.play("clic")
	if _confirmation != "exclure-" + id:
		_confirmation = "exclure-" + id
		app.show_screen("guilde")
		return
	await app.exclure_guilde(id)
	app.show_screen("guilde")


## La bannière d'une guilde : un fond et un motif, dessinés d'après les modèles du jeu (engine/guilde.gd).
class Banniere:
	extends Control
	var app: ArenaApp
	var banniere: Dictionary = {}

	func _init() -> void:
		custom_minimum_size = Vector2(64, 80)
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var fond := Guilde.couleur(str(banniere.get("fond", "")), app.data)
		var motif := Guilde.couleur(str(banniere.get("couleur", "")), app.data)
		var w := size.x
		var h := size.y
		var corps := PackedVector2Array([Vector2(0, 0), Vector2(w, 0), Vector2(w, h * 0.8), Vector2(w / 2, h), Vector2(0, h * 0.8)])
		draw_colored_polygon(corps, fond)
		draw_polyline(PackedVector2Array([Vector2(0, 0), Vector2(w, 0), Vector2(w, h * 0.8), Vector2(w / 2, h), Vector2(0, h * 0.8), Vector2(0, 0)]), Color(0, 0, 0, 0.5), 2.0)
		var c := Vector2(w / 2, h * 0.42)
		var r := minf(w, h) * 0.26
		match str(banniere.get("motif", "")):
			"croix":
				draw_rect(Rect2(c.x - r * 0.25, c.y - r, r * 0.5, r * 2), motif)
				draw_rect(Rect2(c.x - r, c.y - r * 0.25, r * 2, r * 0.5), motif)
			"etoile":
				var pts := PackedVector2Array()
				for i in range(10):
					var a := -PI / 2 + i * PI / 5
					pts.append(c + Vector2(cos(a), sin(a)) * (r if i % 2 == 0 else r * 0.45))
				draw_colored_polygon(pts, motif)
			"lune":
				draw_circle(c, r, motif)
				draw_circle(c + Vector2(r * 0.45, -r * 0.2), r * 0.85, fond)
			"tour":
				draw_rect(Rect2(c.x - r * 0.5, c.y - r * 0.6, r, r * 1.6), motif)
				for i in range(3):
					draw_rect(Rect2(c.x - r * 0.6 + i * r * 0.45, c.y - r, r * 0.3, r * 0.4), motif)
			"flamme":
				draw_colored_polygon(PackedVector2Array([c + Vector2(0, -r * 1.1), c + Vector2(r * 0.7, 0), c + Vector2(r * 0.35, r * 0.9), c + Vector2(-r * 0.35, r * 0.9), c + Vector2(-r * 0.7, 0)]), motif)
			"vague":
				for k in range(2):
					var pts := PackedVector2Array()
					for i in range(13):
						var x := c.x - r + i * (2 * r / 12.0)
						pts.append(Vector2(x, c.y - r * 0.4 + k * r * 0.7 + sin(i * PI / 3) * r * 0.25))
					draw_polyline(pts, motif, maxf(2.0, r * 0.22))
			_:
				draw_circle(c, r, motif)
