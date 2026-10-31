## La Guilde (docs/GDD_V2.md, § 9.1 ; docs/PLAN.md, phase 6) : sans guilde, en fonder une (un nom, une bannière composée
## avec les modèles du jeu) ou en rejoindre une (ouverte, ou sur invitation) ; avec une guilde, sa bannière, son niveau,
## ses places, son Influence, son annonce, ses effets (à monter par qui en a le pouvoir), ses membres et leurs rôles, le
## recrutement, et, pour le chef, les rôles qu'il définit (jusqu'à cinq, avec leurs pouvoirs ; décision de Gautier du
## 1er novembre). Affichage seulement : les règles sont dans engine/guilde.gd, la guilde sur le serveur (ArenaApp).
extends Control

const ATTENUE := Color("aaa49b")

var app: ArenaApp
var _motif := ""
var _fond := ""
var _couleur := ""
var _confirmation := ""
var _roles_ouverts := false
var _recrutement_ouvert := false


func setup(p_app: ArenaApp, options: Dictionary) -> void:
	app = p_app
	_roles_ouverts = bool(options.get("roles", false))
	_recrutement_ouvert = bool(options.get("recruter", false))
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
		await _sans_guilde(column)
	else:
		await _ma_guilde(column, g)
	if not is_inside_tree():
		return
	column.add_child(UiKit.button("Retour à la ville", func(): app.show_screen("ville"), 52))


func _rafraichir(options: Dictionary = {}) -> void:
	app.show_screen("guilde", options)


# --- La bannière à composer ---------------------------------------------------------------------

func _choix_banniere(parent: VBoxContainer, actuelle: Dictionary, options: Dictionary) -> void:
	var d := app.data
	if _motif == "":
		_motif = str(actuelle["motif"])
		_fond = str(actuelle["fond"])
		_couleur = str(actuelle["couleur"])
	var ligne := HBoxContainer.new()
	ligne.add_theme_constant_override("separation", 10)
	parent.add_child(ligne)
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
		_rafraichir(options), 40, 14))
	choix.add_child(UiKit.button("Fond : %s" % _fond, func():
		app.sfx.play("clic")
		_fond = _suivant(d.guildes["banniere"]["couleurs"].keys(), _fond, _couleur)
		_rafraichir(options), 40, 14))
	choix.add_child(UiKit.button("Motif en : %s" % _couleur, func():
		app.sfx.play("clic")
		_couleur = _suivant(d.guildes["banniere"]["couleurs"].keys(), _couleur, _fond)
		_rafraichir(options), 40, 14))


func _banniere_choisie() -> Dictionary:
	return {"motif": _motif, "fond": _fond, "couleur": _couleur}


func _suivant(liste: Array, actuel: String, interdit: String = "") -> String:
	var i := liste.find(actuel)
	for _k in range(liste.size()):
		i = (i + 1) % liste.size()
		if str(liste[i]) != interdit:
			return str(liste[i])
	return actuel


# --- Sans guilde : fonder ou rejoindre ------------------------------------------------------------

func _sans_guilde(column: VBoxContainer) -> void:
	var d := app.data
	column.add_child(UiKit.label("Une guilde, c'est des joueurs ensemble : leur activité (duels, étages, Gardiens) rapporte de l'Influence, qui monte des effets pour tous les membres. Jamais de puissance en PvP.", 14, UiKit.SOFT))
	var fonder := UiKit.card(column, 6)
	fonder.add_child(UiKit.label("Fonder une guilde", 20, UiKit.GOLD, false))
	_choix_banniere(fonder, Guilde.banniere_defaut(app.graine, d), {})
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
		if await app.creer_guilde(champ.text, _banniere_choisie()):
			app.sfx.play("victoire")
			_rafraichir()
		else:
			retour.text = "Impossible : %s." % (app.serveur.erreur if app.serveur.erreur != "" else "le serveur refuse"), 60))
	fonder.add_child(retour)
	var rejoindre := UiKit.card(column, 6)
	rejoindre.add_child(UiKit.label("Rejoindre une guilde", 20, UiKit.GOLD, false))
	rejoindre.add_child(UiKit.label("Une guilde ouverte se rejoint librement s'il reste une place ; une guilde sur invitation attend qu'un de ses recruteurs t'invite.", 13, ATTENUE, false))
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
		texte.add_child(UiKit.label("%d membre%s sur %d places · %d Influence%s" % [int(r["membres"]), "s" if int(r["membres"]) > 1 else "", int(r["places"]), int(r["influence_totale"]), "" if bool(r.get("ouvert", true)) else " · sur invitation"], 13, ATTENUE, false))
		if str(r.get("annonce", "")) != "":
			texte.add_child(UiKit.label("« %s »" % r["annonce"], 13, UiKit.SOFT, false))
		var pleine: bool = int(r["membres"]) >= int(r["places"])
		var fermee: bool = not bool(r.get("ouvert", true))
		var b := UiKit.button("Pleine" if pleine else ("Sur invitation" if fermee else "Rejoindre"), func():
			app.sfx.play("clic")
			if await app.rejoindre_guilde(str(r["id"])):
				app.sfx.play("victoire")
			_rafraichir(), 40, 14)
		b.disabled = pleine or fermee
		l.add_child(b)


# --- Ma guilde ------------------------------------------------------------------------------------

func _ma_guilde(column: VBoxContainer, g: Dictionary) -> void:
	var d := app.data
	var moi := app.serveur.compte_id
	var mon_role := Guilde.role_de(g, moi)
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
	texte.add_child(UiKit.label("Niveau %d · %d membre%s sur %d places · tu es %s · %s" % [nv, g["membres"].size(), "s" if g["membres"].size() > 1 else "", Guilde.taille_max(nv, d), Guilde.nom_role(g, mon_role).to_lower(), "ouverte" if bool(g["ouvert"]) else "sur invitation"], 15, Color.WHITE, false))
	var manque := Guilde.manque_niveau(int(g["influence_totale"]), d)
	texte.add_child(UiKit.label("%d Influence en réserve · %d gagnée en tout%s" % [int(g["influence"]), int(g["influence_totale"]), (" · encore %d pour le niveau %d" % [manque, nv + 1]) if manque > 0 else ""], 14, ATTENUE, false))
	tete.add_child(UiKit.label("L'Influence vient de l'activité des membres : %s." % ", ".join(_gains(d)), 13, ATTENUE, false))
	# L'annonce.
	var annonce := UiKit.card(column, 4)
	annonce.add_child(UiKit.label("L'annonce", 20, UiKit.GOLD, false))
	annonce.add_child(UiKit.label(("« %s »" % g["annonce"]) if str(g["annonce"]) != "" else "Aucune annonce pour l'instant.", 15, Color.WHITE if str(g["annonce"]) != "" else ATTENUE, false))
	if app.peut_guilde("annonce"):
		var champ := LineEdit.new()
		champ.text = str(g["annonce"])
		champ.placeholder_text = "Ce que ta guilde dit aux autres"
		champ.max_length = int(d.guildes["annonce_max"])
		champ.custom_minimum_size = Vector2(0, 46)
		annonce.add_child(champ)
		annonce.add_child(UiKit.button("Changer l'annonce", func():
			app.sfx.play("clic")
			await app.annonce_guilde(champ.text)
			_rafraichir(), 40, 14))
	# Les effets.
	var effets := UiKit.card(column, 6)
	effets.add_child(UiKit.label("Les effets de la guilde", 20, UiKit.GOLD, false))
	for e in d.guildes["effets"]:
		var niveau_e := int(g["effets"].get(e, 0))
		var maxi_e := int(d.guildes["effets"][e]["max"])
		effets.add_child(UiKit.label(Guilde.texte_effet(str(e), niveau_e, d) + ("" if niveau_e > 0 else " (pas encore)"), 15, Color.WHITE if niveau_e > 0 else ATTENUE, false))
		var cout := Guilde.cout_effet(str(e), niveau_e, d)
		if app.peut_guilde("acheter") and cout > 0:
			var b := UiKit.button("Monter (%d Influence%s)" % [cout, "" if int(g["influence"]) >= cout else ", il en manque"], func():
				app.sfx.play("clic")
				if await app.acheter_effet_guilde(str(e)):
					app.sfx.play("victoire")
				_rafraichir(), 40, 14)
			b.disabled = int(g["influence"]) < cout
			effets.add_child(b)
		elif cout == 0:
			effets.add_child(UiKit.label("Au maximum (%d sur %d)." % [niveau_e, maxi_e], 13, ATTENUE, false))
	# Les membres.
	var membres := UiKit.card(column, 6)
	membres.add_child(UiKit.label("Les membres", 20, UiKit.GOLD, false))
	var ordre: Array = [Guilde.CHEF]
	for r in g["roles"]:
		ordre.append(str(r["id"]))
	var tri: Array = g["membres"].duplicate()
	tri.sort_custom(func(a, b): return ordre.find(str(a["role"])) < ordre.find(str(b["role"])))
	for m in tri:
		var est_moi: bool = str(m["id"]) == moi
		var est_chef: bool = str(m["role"]) == Guilde.CHEF
		membres.add_child(UiKit.label("%s%s · %s · niveau %d · %s" % [m["pseudo"], " (toi)" if est_moi else "", app.class_label(str(m["classe"])), int(m["niveau"]), Guilde.nom_role(g, str(m["role"]))], 15, UiKit.GOLD if est_chef else Color.WHITE, false))
		if est_moi or est_chef:
			continue
		var actions := HBoxContainer.new()
		actions.add_theme_constant_override("separation", 6)
		if app.peut_guilde("roles") and g["roles"].size() > 1:
			var suivant := _suivant(ordre.slice(1), str(m["role"]))
			actions.add_child(UiKit.button("Rôle → %s" % Guilde.nom_role(g, suivant), _changer_role.bind(str(m["id"]), suivant), 36, 13))
		if mon_role == Guilde.CHEF:
			actions.add_child(UiKit.button("Transmettre la guilde", _changer_role.bind(str(m["id"]), Guilde.CHEF), 36, 13))
		if app.peut_guilde("exclure"):
			var bx := UiKit.button("Exclure", _exclure.bind(str(m["id"])), 36, 13)
			if _confirmation == "exclure-" + str(m["id"]):
				bx.text = "Sûr ? Exclure"
				bx.modulate = Color(1, 0.85, 0.5)
			actions.add_child(bx)
		if actions.get_child_count() > 0:
			membres.add_child(actions)
	# Le recrutement.
	if app.peut_guilde("recruter"):
		var recrut := UiKit.card(column, 4)
		recrut.add_child(UiKit.label("Le recrutement", 20, UiKit.GOLD, false))
		recrut.add_child(UiKit.button("La guilde est %s · passer %s" % ["ouverte" if bool(g["ouvert"]) else "sur invitation", "sur invitation" if bool(g["ouvert"]) else "ouverte"], func():
			app.sfx.play("clic")
			await app.recrutement_guilde(not bool(g["ouvert"]))
			_rafraichir({"recruter": true}), 40, 14))
		if not _recrutement_ouvert:
			recrut.add_child(UiKit.button("Inviter des joueurs", func():
				app.sfx.play("clic")
				_rafraichir({"recruter": true}), 40, 14))
		else:
			await _invitations(recrut, g)
			if not is_inside_tree():
				return
	# La bannière.
	if app.peut_guilde("banniere"):
		var ban := UiKit.card(column, 4)
		ban.add_child(UiKit.label("La bannière", 20, UiKit.GOLD, false))
		_choix_banniere(ban, g["banniere"], {})
		ban.add_child(UiKit.button("Changer la bannière", func():
			app.sfx.play("clic")
			await app.banniere_guilde(_banniere_choisie())
			_rafraichir(), 40, 14))
	# Les rôles (le chef).
	if mon_role == Guilde.CHEF:
		var roles := UiKit.card(column, 4)
		roles.add_child(UiKit.label("Les rôles", 20, UiKit.GOLD, false))
		roles.add_child(UiKit.label("Tu définis jusqu'à %d rôles et ce que chacun peut faire. Le dernier de la liste est celui des nouveaux venus." % int(d.guildes["roles_max"]), 13, ATTENUE, false))
		if not _roles_ouverts:
			roles.add_child(UiKit.button("Régler les rôles", func():
				app.sfx.play("clic")
				_rafraichir({"roles": true}), 40, 14))
		else:
			_reglage_roles(roles, g)
	# Quitter.
	var quitter := UiKit.card(column, 4)
	var mot := "Quitter la guilde" if g["membres"].size() > 1 else "Dissoudre la guilde (tu es seul)"
	if mon_role == Guilde.CHEF and g["membres"].size() > 1:
		quitter.add_child(UiKit.label("Si tu pars, la guilde passe au membre du rôle le plus haut, le plus ancien.", 13, ATTENUE, false))
	var bq := UiKit.button(mot, func():
		app.sfx.play("clic")
		if _confirmation != "quitter":
			_confirmation = "quitter"
			_rafraichir()
			return
		if await app.quitter_guilde():
			app.show_screen("ville")
		else:
			_rafraichir(), 44, 15)
	if _confirmation == "quitter":
		bq.text = "Sûr ? Touche encore pour partir"
		bq.modulate = Color(1, 0.85, 0.5)
	quitter.add_child(bq)


## Les joueurs autour de ton niveau, à inviter.
func _invitations(parent: VBoxContainer, g: Dictionary) -> void:
	parent.add_child(UiKit.label("Autour de ton niveau, sur le serveur :", 14, Color.WHITE, false))
	var candidats: Array = []
	for role in Trio.ROLES:
		for f in await app.serveur.personnages(role, app.profile.level, 3):
			if Guilde.membre(g, str(f["id"])).is_empty():
				candidats.append(f)
	if not is_inside_tree():
		return
	if candidats.is_empty():
		parent.add_child(UiKit.label("Personne à inviter pour l'instant.", 14, ATTENUE, false))
	for f in candidats:
		var l := HBoxContainer.new()
		l.add_theme_constant_override("separation", 8)
		parent.add_child(l)
		var t := UiKit.label("%s · %s · niveau %d" % [f["pseudo"], app.class_label(str(f["classe"])), int(f["niveau"])], 14, Color.WHITE, false)
		t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		l.add_child(t)
		var place := Guilde.a_une_place(g, app.data)
		var b := UiKit.button("Inviter" if place else "Plus de place", func():
			app.sfx.play("clic")
			if await app.inviter_guilde(f):
				app.sfx.play("victoire")
			_rafraichir({"recruter": true}), 36, 13)
		b.disabled = not place
		l.add_child(b)


## Le chef règle ses rôles : le nom, les pouvoirs (un bouton par pouvoir), supprimer, un rôle de plus.
func _reglage_roles(parent: VBoxContainer, g: Dictionary) -> void:
	var d := app.data
	for r in g["roles"]:
		var bloc := VBoxContainer.new()
		bloc.add_theme_constant_override("separation", 4)
		parent.add_child(bloc)
		var ligne := HBoxContainer.new()
		ligne.add_theme_constant_override("separation", 8)
		bloc.add_child(ligne)
		var champ := LineEdit.new()
		champ.text = str(r["nom"])
		champ.max_length = Guilde.NOM_ROLE_MAX
		champ.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		champ.custom_minimum_size = Vector2(0, 42)
		ligne.add_child(champ)
		ligne.add_child(UiKit.button("Renommer", func():
			app.sfx.play("clic")
			await app.definir_role_guilde({"id": r["id"], "nom": champ.text, "pouvoirs": r["pouvoirs"]})
			_rafraichir({"roles": true}), 42, 13))
		if g["roles"].size() > 1:
			ligne.add_child(UiKit.button("Supprimer", func():
				app.sfx.play("clic")
				await app.supprimer_role_guilde(str(r["id"]))
				_rafraichir({"roles": true}), 42, 13))
		var grille := HFlowContainer.new()
		grille.add_theme_constant_override("h_separation", 6)
		grille.add_theme_constant_override("v_separation", 6)
		bloc.add_child(grille)
		for p in Guilde.pouvoirs(d):
			var a: bool = p in r["pouvoirs"]
			var b := UiKit.button("%s %s" % ["✓" if a else "✗", Guilde.texte_pouvoir(p, d)], func():
				app.sfx.play("clic")
				var pouvoirs: Array = Array(r["pouvoirs"])
				if a:
					pouvoirs.erase(p)
				else:
					pouvoirs.append(p)
				await app.definir_role_guilde({"id": r["id"], "nom": r["nom"], "pouvoirs": pouvoirs})
				_rafraichir({"roles": true}), 34, 12)
			b.modulate = Color.WHITE if a else Color(0.7, 0.7, 0.75)
			grille.add_child(b)
	if g["roles"].size() < int(d.guildes["roles_max"]):
		parent.add_child(UiKit.button("Un rôle de plus", func():
			app.sfx.play("clic")
			var n: int = g["roles"].size() + 1
			await app.definir_role_guilde({"id": "role_%d" % n, "nom": "Rôle %d" % n, "pouvoirs": []})
			_rafraichir({"roles": true}), 40, 14))


func _gains(d: Donnees) -> Array[String]:
	var noms := {"duel": "un duel", "duel_gagne": "un duel gagné", "etage": "un étage", "gardien": "un Gardien", "boss": "un boss", "selection": "une sélection comme Écho"}
	var out: Array[String] = []
	for a in d.guildes["influence"]:
		out.append("%s %d" % [noms.get(a, a), int(d.guildes["influence"][a])])
	return out


func _changer_role(id: String, p_role: String) -> void:
	app.sfx.play("clic")
	await app.role_guilde(id, p_role)
	_rafraichir()


func _exclure(id: String) -> void:
	app.sfx.play("clic")
	if _confirmation != "exclure-" + id:
		_confirmation = "exclure-" + id
		_rafraichir()
		return
	await app.exclure_guilde(id)
	_rafraichir()


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
