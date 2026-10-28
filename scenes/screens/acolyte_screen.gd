## La fiche de l'acolyte (GDD, écran « Acolyte ») : lui en pied, ses trois voies, et comment il joue.
## Il joue seul, comme un second joueur : on ne lui donne aucun ordre ; ses voies s'allument seules avec le niveau.
extends Control

var app: ArenaApp


func setup(p_app: ArenaApp, _options: Dictionary) -> void:
	app = p_app
	var column := UiKit.scroll_column(self, 12)
	var portrait := PortraitView.make(app.acolyte_class(), app.acolyte_name, app.class_label(app.acolyte_class()), 10.0)
	portrait.title_color = UiKit.ACOLYTE_BLUE
	column.add_child(portrait)
	column.add_child(UiKit.label("Ton acolyte, piloté par l'IA. Même niveau que toi, toujours.", 16, UiKit.SOFT))
	var kit := UiKit.card(column, 6)
	kit.add_child(UiKit.label("Ses trois voies", 20, UiKit.GOLD, false))
	kit.add_child(UiKit.label("Elles s'allument seules : un nœud par niveau, toutes à partir du niveau 10 (○ : pas encore allumé).", 15, UiKit.SOFT, false))
	kit.add_child(UiKit.label("Au centre : %s" % Texte.nom(app.acolyte_destin.moyeu), 16, Color.WHITE, false))
	for v in range(app.acolyte_destin.voies.size()):
		UiKit.voie_resume(kit, app.acolyte_destin, v, UiKit.ACOLYTE_BLUE)
	UiKit.acolyte_rules_card(column, app.acolyte_name)
