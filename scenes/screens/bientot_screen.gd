## Ce qui est en reconstruction pendant le passage au combat V2 (docs/SPEC-COMBAT-V2.md, section 15) : le duel
## arrive avec l'écran de combat (étape 6), la Tour avec ses monstres sur le nouveau système (étape 4).
extends Control

var app: ArenaApp


func setup(p_app: ArenaApp, _options: Dictionary) -> void:
	app = p_app
	var column := UiKit.scroll_column(self, 14)
	column.add_child(UiKit.spacer(40))
	var tour := app.current_name == "tower"
	column.add_child(UiKit.label("La Tour" if tour else "Combattre", 32, UiKit.GOLD))
	column.add_child(UiKit.label("En reconstruction", 24, Color.WHITE))
	column.add_child(UiKit.label("Le combat passe au nouveau système : la roue du Destin, les voies et leurs Clés, les menaces qu'on voit venir.", 17, UiKit.SOFT))
	column.add_child(UiKit.label("En attendant, ton Destin est prêt : va voir ta roue.", 17, UiKit.SOFT))
	column.add_child(UiKit.main_button("Voir mon Destin", func(): app.show_screen("destin")))
	column.add_child(UiKit.button("Retour à l'accueil", func(): app.show_screen("home"), 56))
