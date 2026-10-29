## Avant un duel : la recherche d'un adversaire, puis le face-à-face des deux duos (GDD : « File d'attente »).
## En attendant les vrais joueurs (étape 5 de la feuille de route), l'adversaire est un duo piloté par l'IA, de ton
## niveau, et c'est écrit.
extends Control

const ENEMY_NAMES := ["Ombre", "Brume", "Cendre", "Givre", "Ronce", "Écume", "Nox", "Bise"]

var app: ArenaApp
var options := {}


func setup(p_app: ArenaApp, _options: Dictionary) -> void:
	app = p_app
	options = app.duel_contre_ia()
	var premier := app.rng.randi_range(0, ENEMY_NAMES.size() - 1)
	options["noms"]["b1"] = ENEMY_NAMES[premier]
	options["noms"]["b2"] = ENEMY_NAMES[(premier + app.rng.randi_range(1, ENEMY_NAMES.size() - 1)) % ENEMY_NAMES.size()]
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
	for camp in [["b1", "b2", true], ["a1", "a2", false]]:
		var rangee := HBoxContainer.new()
		rangee.alignment = BoxContainer.ALIGNMENT_CENTER
		rangee.add_theme_constant_override("separation", 16)
		column.add_child(rangee)
		for id in [camp[0], camp[1]]:
			var classe := str(e.fiche(id)["classe"])
			var p := PortraitView.make(classe, str(noms[id]), app.class_label(classe), 8.0, camp[2])
			p.title_color = UiKit.RED if camp[2] else (UiKit.GOLD if id == "a1" else UiKit.ACOLYTE_BLUE)
			p.appear()
			rangee.add_child(p)
		if camp[2]:
			column.add_child(UiKit.label("Duo IA · niveau %d" % e.niveau, 15, UiKit.SOFT))
			column.add_child(UiKit.label("contre", 20, Color.WHITE))
	column.add_child(UiKit.main_button("Combattre", func(): app.show_screen("combat", options)))
	column.add_child(UiKit.button("Retour", func(): app.show_screen("home"), 52))
