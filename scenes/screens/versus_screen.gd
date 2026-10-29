## Avant un duel : la recherche d'un adversaire, puis le face-à-face des deux trios (GDD : « File d'attente »).
## En attendant les vrais joueurs (étape 5 de la feuille de route), l'adversaire est un trio piloté par l'IA, de ton
## niveau, et c'est écrit.
extends Control

const ENEMY_NAMES := ["Ombre", "Brume", "Cendre", "Givre", "Ronce", "Écume", "Nox", "Bise"]

var app: ArenaApp
var options := {}
## Un combat classé (l'Arène) ou un amical.
var classe := false


func setup(p_app: ArenaApp, p_options: Dictionary) -> void:
	app = p_app
	classe = bool(p_options.get("classe", false))
	options = app.duel_classe() if classe else app.duel_contre_ia()
	if options.is_empty():
		# Plus de combat classé aujourd'hui : retour à l'Arène.
		app.show_screen("arene")
		return
	var libres := ENEMY_NAMES.filter(func(n): return n != str(options["noms"].get("b1", "")))
	for id in ["b1", "b2", "b3"]:
		if not options["noms"].has(id):
			options["noms"][id] = libres.pop_at(app.rng.randi_range(0, libres.size() - 1))
	var column := UiKit.scroll_column(self, 10)
	var cherche := UiKit.label("Recherche d'un adversaire...", 24, UiKit.SOFT)
	column.add_child(UiKit.spacer(40))
	column.add_child(cherche)
	var tween := create_tween()
	tween.tween_interval(0.9)
	tween.tween_callback(func(): _face_a_face(column, cherche))


func _face_a_face(column: VBoxContainer, cherche: Label) -> void:
	cherche.text = "Adversaire trouvé"
	cherche.add_theme_color_override("font_color", UiKit.GOLD)
	app.sfx.play("forte", 1.1, -6.0)
	var e: EtatCombat = options["etat"]
	var noms: Dictionary = options["noms"]
	for camp in [[["b2", "b1", "b3"], true], [["a2", "a1", "a3"], false]]:
		var rangee := HBoxContainer.new()
		rangee.alignment = BoxContainer.ALIGNMENT_CENTER
		rangee.add_theme_constant_override("separation", 8)
		column.add_child(rangee)
		for id in camp[0]:
			var classe := str(e.fiche(id)["classe"])
			var p := PortraitView.make(classe, str(noms[id]), app.class_label(classe), 6.0, camp[1])
			p.title_color = UiKit.RED if camp[1] else (UiKit.GOLD if id == "a1" else UiKit.ACOLYTE_BLUE)
			p.appear()
			rangee.add_child(p)
		if camp[1]:
			var adv: Dictionary = options.get("adversaire", {})
			if classe:
				column.add_child(UiKit.label("Combat classé · %s, niveau %d%s · trio généré en attendant le serveur" % [adv.get("nom", "?"), int(adv.get("niveau", e.niveau)), " · équipé" if str(adv.get("equipement", "")) != "" else ""], 14, UiKit.SOFT))
			else:
				column.add_child(UiKit.label("Amical · trio IA · niveau %d" % e.niveau, 15, UiKit.SOFT))
			column.add_child(UiKit.label("contre", 20, Color.WHITE))
	column.add_child(UiKit.main_button("Combattre", func(): app.show_screen("combat", options)))
	column.add_child(UiKit.button("Retour", func(): app.show_screen("trio", {"mode": "classe" if classe else "duel"}), 52))
