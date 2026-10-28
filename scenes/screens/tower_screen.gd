## La Tour (GDD, écran « La Tour ») : comment elle marche, ton record, les records de chaque classe, le bestiaire,
## et on monte.
extends Control

var app: ArenaApp


func setup(p_app: ArenaApp, _options: Dictionary) -> void:
	app = p_app
	var column := UiKit.scroll_column(self, 12)
	var floors := int(app.data.tower.get("floors", []).size())
	column.add_child(UiKit.label("La Tour", 36, UiKit.GOLD))
	var record := int(app.profile.tower_records.get(app.player_class, 0))
	var cls_name := app.data.class_name_of(app.player_class)
	column.add_child(UiKit.label("Ton record de %s : %s" % [cls_name, "étage %d sur %d" % [record, floors] if record > 0 else "aucun pour l'instant"], 22))
	column.add_child(UiKit.main_button("Commencer la montée", _climb))
	column.add_child(UiKit.button("Bestiaire : les monstres de la Tour", func(): app.show_screen("bestiaire"), 56))
	var rules := UiKit.card(column, 6)
	rules.add_child(UiKit.label("Comment ça marche", 20, UiKit.GOLD, false))
	for line in [
		"%d étages de monstres, de plus en plus forts : de 1 à 4 par étage, d'une même famille. Aux étages 5 et 10, un Gardien." % floors,
		"Entre deux étages, tu gardes tes PV et tes recharges : seuls %d %% de tes PV te sont rendus (un acolyte tombé revient avec autant)." % int(round(float(app.data.tower.get("heal_between_floors", 0.2)) * 100.0)),
		"Pas de mort subite. Au tour %d, les ennemis s'épuisent : ils ne soignent plus. Au tour %d, ils abandonnent." % [int(app.data.tower.get("exhaustion_turn", 12)), int(app.data.tower.get("turn_limit", 24))],
		"La montée s'arrête quand ton duo tombe. Ton record est gardé pour ta classe.",
	]:
		rules.add_child(UiKit.label("• " + line, 16, UiKit.SOFT, false))
	var records := UiKit.card(column, 4)
	records.add_child(UiKit.label("Tes records par classe", 20, UiKit.GOLD, false))
	for class_id in app.data.class_ids:
		var value := int(app.profile.tower_records.get(class_id, 0))
		records.add_child(UiKit.label("%s : %s" % [app.data.class_name_of(class_id), "étage %d" % value if value > 0 else "—"], 17, Color.WHITE, false))


func _climb() -> void:
	app.sfx.play("clic")
	app.show_screen("combat", {"mode": "tour"})
