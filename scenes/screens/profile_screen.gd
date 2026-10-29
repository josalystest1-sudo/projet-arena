## Ton profil (GDD, écran « Profil ») : le trio en pied, ta classe, tes résultats et tes records.
extends Control

var app: ArenaApp


func setup(p_app: ArenaApp, _options: Dictionary) -> void:
	app = p_app
	var column := UiKit.scroll_column(self, 12)
	column.add_child(UiKit.label("Ton profil", 30, UiKit.GOLD))
	column.add_child(UiKit.rangee_trio(app, 6.0))
	var profile := app.profile
	var games := profile.wins + profile.losses
	var duel := UiKit.card(column, 4)
	duel.add_child(UiKit.label("Duels", 20, UiKit.GOLD, false))
	duel.add_child(UiKit.label("%d combat%s : %d victoire%s, %d défaite%s" % [games, "s" if games > 1 else "", profile.wins, "s" if profile.wins > 1 else "", profile.losses, "s" if profile.losses > 1 else ""], 17, Color.WHITE, false))
	if games > 0:
		duel.add_child(UiKit.label("Taux de victoire : %d %%" % int(round(100.0 * profile.wins / games)), 17, Color.WHITE, false))
	duel.add_child(UiKit.label("Série en cours : %d · meilleure série : %d" % [profile.streak, profile.best_streak], 17, Color.WHITE, false))
	var tower := UiKit.card(column, 4)
	tower.add_child(UiKit.label("La Tour", 20, UiKit.GOLD, false))
	for class_id in app.data.ordre_classes:
		var value := int(profile.tower_records.get(class_id, 0))
		tower.add_child(UiKit.label("%s : %s" % [app.data.classe(class_id)["nom"], "étage %d" % value if value > 0 else "—"], 17, Color.WHITE, false))
	column.add_child(UiKit.label("Classements, saisons et profils des autres joueurs arriveront avec le serveur (étape 5).", 14, Color(0.6, 0.62, 0.7)))
