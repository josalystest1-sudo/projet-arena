## La Tour (GDD) : les règles en clair, ton record et ceux de chaque classe, le bestiaire, et le bouton pour monter.
## Les étages se suivent tant que le trio tient ; les monstres sont plus forts à chaque étage.
extends Control

var app: ArenaApp


func setup(p_app: ArenaApp, _options: Dictionary) -> void:
	app = p_app
	var column := UiKit.scroll_column(self, 12)
	column.add_child(UiKit.label("La Tour", 34, UiKit.GOLD))
	var cls_nom := str(app.data.classe(app.player_class)["nom"])
	var record := int(app.profile.tower_records.get(app.player_class, 0))
	column.add_child(UiKit.label("Ton record (%s) : %s" % [cls_nom, "étage %d" % record if record > 0 else "pas encore de montée"], 20, Color.WHITE))
	var regles := UiKit.card(column, 4)
	regles.add_child(UiKit.label("Les règles", 20, UiKit.GOLD, false))
	for ligne in ["Ton trio grimpe les étages, contre 1 à 4 monstres à chaque étage. Plus tu montes, plus ils sont forts.",
			"Entre deux étages, chacun récupère 20 % de ses PV. Un Écho tombé revient avec 20 %.",
			"Pas de mort subite : la montée s'arrête quand tout ton trio tombe. L'étage atteint est ton record, classé par classe."]:
		regles.add_child(UiKit.label(ligne, 16, UiKit.SOFT, false))
	column.add_child(UiKit.main_button("Monter", _monter, 84))
	column.add_child(UiKit.button("Le bestiaire", func(): app.show_screen("bestiaire"), 52))
	var records := UiKit.card(column, 2)
	records.add_child(UiKit.label("Records par classe", 18, UiKit.GOLD, false))
	for class_id in app.data.ordre_classes:
		var value := int(app.profile.tower_records.get(class_id, 0))
		records.add_child(UiKit.label("%s : %s" % [app.data.classe(class_id)["nom"], "étage %d" % value if value > 0 else "—"], 16, Color.WHITE, false))


func _monter() -> void:
	app.sfx.play("clic")
	app.show_screen("trio", {"mode": "tour"})
