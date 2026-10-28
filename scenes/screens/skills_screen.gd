## Tes compétences (GDD, écran « Compétences ») : tes 3 actives et ton passif, leurs recharges, tes Synergies avec l'acolyte.
extends Control

var app: ArenaApp


func setup(p_app: ArenaApp, _options: Dictionary) -> void:
	app = p_app
	var column := UiKit.scroll_column(self, 12)
	var cls: Dictionary = app.data.classes[app.player_class]
	column.add_child(UiKit.label("Ton Destin de %s" % cls["name"], 28, UiKit.GOLD))
	column.add_child(UiKit.label(str(cls["identity"]), 16, UiKit.SOFT))
	var tree := UiKit.card(column, 6)
	var left := app.destin_points_left()
	tree.add_child(UiKit.label("Ton arbre de Destin · niveau %d" % app.profile.level, 20, UiKit.GOLD, false))
	tree.add_child(UiKit.label("%d nœuds, tirés une seule fois, uniques au monde. Tu y places un point par niveau : %d pris sur 30 possibles.%s" % [
		app.destin.get("nodes", []).size(), app.destin_taken.size(), (" %d point%s à placer !" % [left, "s" if left > 1 else ""]) if left > 0 else ""], 15, UiKit.SOFT, false))
	tree.add_child(UiKit.main_button("Voir l'arbre du Destin" if left == 0 else "Placer tes points (%d)" % left, func(): app.show_screen("destin"), 60))
	var cooldowns: Dictionary = app.data.rules.get("cooldowns", {})
	var kit := UiKit.card(column, 6)
	for skill_id in app.player_skills():
		UiKit.skill_block(kit, app.data, skill_id, UiKit.GOLD)
		var tier := str(app.data.skill(skill_id).get("tier", ""))
		var timing := "Tous les tours."
		if tier == "moyenne":
			timing = "Recharge : %d tours après usage." % int(cooldowns.get("moyenne", 2))
		elif tier == "forte":
			timing = "Dès le tour %d, puis recharge : %d tours." % [int(app.data.rules.get("strong_available_from_turn", 3)), int(cooldowns.get("forte", 4))]
		kit.add_child(UiKit.label(timing, 14, Color(0.6, 0.65, 0.8), false))
	UiKit.passive_block(kit, app.data, app.player_passive())
	UiKit.destin_balance(kit, app.data, app.player_skills(), app.player_passive(), app.player_class, app.acolyte["class_id"])

	var synergies := UiKit.card(column, 6)
	synergies.add_child(UiKit.label("Tes Synergies avec %s" % app.acolyte_name, 20, UiKit.GOLD, false))
	synergies.add_child(UiKit.label("Jouées le même tour, deux compétences déclenchent un effet bonus. Pendant le combat, un arc doré te les signale.", 15, UiKit.SOFT, false))
	for synergy in app.duo_synergies():
		synergies.add_child(UiKit.label("%s : %s + %s" % [synergy["name"], app.data.skill_name(synergy["skills"][0]), app.data.skill_name(synergy["skills"][1])], 17, Color.WHITE, false))
		synergies.add_child(UiKit.label(app.data.synergy_description(synergy), 15, UiKit.SOFT, false))
	# Les nœuds pris, en clair.
	if not app.destin_taken.is_empty():
		var taken := UiKit.card(column, 4)
		taken.add_child(UiKit.label("Tes nœuds pris", 20, UiKit.GOLD, false))
		for node_id in app.destin_taken:
			var node := Destin.node_of(app.destin, int(node_id))
			taken.add_child(UiKit.label("• " + str(node.get("name", "")), 15, Color.WHITE, false))
