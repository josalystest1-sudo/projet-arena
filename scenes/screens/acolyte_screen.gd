## La fiche de l'acolyte (GDD, écran « Acolyte ») : lui en pied, ses compétences, et comment il joue.
## Il joue seul, comme un second joueur : on ne lui donne aucun ordre (décision du 27 octobre : plus de postures).
extends Control

var app: ArenaApp


func setup(p_app: ArenaApp, _options: Dictionary) -> void:
	app = p_app
	var column := UiKit.scroll_column(self, 12)
	var portrait := PortraitView.make(app.acolyte["class_id"], app.acolyte_name, app.class_label(app.acolyte["class_id"]), 10.0)
	portrait.title_color = UiKit.ACOLYTE_BLUE
	column.add_child(portrait)
	column.add_child(UiKit.label("Ton acolyte, piloté par l'IA. Même niveau que toi, toujours.", 16, UiKit.SOFT))
	var kit := UiKit.card(column, 6)
	kit.add_child(UiKit.label("Ses compétences", 20, UiKit.GOLD, false))
	for skill_id in app.acolyte_skills():
		UiKit.skill_block(kit, app.data, skill_id, UiKit.ACOLYTE_BLUE)
	UiKit.passive_block(kit, app.data, app.acolyte_passive())
	UiKit.destin_balance(kit, app.data, app.acolyte_skills(), app.acolyte_passive(), app.acolyte["class_id"], app.player_class, true)
	var mini := UiKit.card(column, 4)
	mini.add_child(UiKit.label("Son mini-Destin", 20, UiKit.GOLD, false))
	mini.add_child(UiKit.label("%d nœuds, comme le tien en plus petit. Ses points se placent seuls, un tous les deux niveaux : %d pris sur %d." % [
		app.acolyte_destin.get("nodes", []).size(), app.acolyte_taken.size(), app.acolyte_destin.get("nodes", []).size()], 15, UiKit.SOFT, false))
	for node_id in app.acolyte_taken:
		mini.add_child(UiKit.label("• " + str(Destin.node_of(app.acolyte_destin, int(node_id)).get("name", "")), 15, Color.WHITE, false))
	var next := Destin.auto_take(app.acolyte_destin, app.acolyte_taken)
	if next >= 0:
		mini.add_child(UiKit.label("Prochain nœud (au niveau %d) : %s" % [(app.acolyte_taken.size() + 1) * 2, str(Destin.node_of(app.acolyte_destin, next).get("name", ""))], 14, Color(0.6, 0.65, 0.8), false))
	UiKit.acolyte_rules_card(column, app.data, app.acolyte["class_id"], app.acolyte_name)
