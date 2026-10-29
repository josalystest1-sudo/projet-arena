## Ton profil (GDD, écran « Profil ») : le trio en pied, ta classe, tes monnaies, ton équipement, l'Arène, les donjons,
## tes résultats et tes records.
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
	# Les monnaies et l'équipement porté.
	var richesse := UiKit.card(column, 4)
	richesse.add_child(UiKit.label("Monnaies et équipement", 20, UiKit.GOLD, false))
	richesse.add_child(UiKit.label("%d Éclat%s (liés) · %d Or (échangeable)" % [profile.eclats, "s" if profile.eclats > 1 else "", profile.monnaie_or], 17, Color.WHITE, false))
	var portes: Array[String] = []
	for e in app.data.objets["emplacements"]:
		if profile.portes.has(e):
			portes.append(Equipement.nom(profile.portes[e], app.data))
	richesse.add_child(UiKit.label(("Porté : " + ", ".join(portes)) if not portes.is_empty() else "Aucun objet porté : passe à la Forge.", 15, UiKit.SOFT, false))
	var bonus: Array[String] = []
	var mods := app.bonus_portes()
	for s in Equipement.STATS:
		if float(mods.get(s, 0.0)) > 0.0:
			bonus.append(Equipement.texte_ligne({"stat": s, "valeur": float(mods[s]) * 100.0}, app.data))
	if not bonus.is_empty():
		richesse.add_child(UiKit.label(" · ".join(bonus), 14, UiKit.SOFT, false))
	# L'Arène.
	var a := app.etat_arene()
	var arene := UiKit.card(column, 4)
	arene.add_child(UiKit.label("L'Arène", 20, UiKit.GOLD, false))
	arene.add_child(UiKit.label("%d points · ligue des %s · saison %d" % [int(a["points"]), Arene.nom_ligue(str(a["ligue"]), app.data), int(a["saison"]) + 1], 17, Color.WHITE, false))
	arene.add_child(UiKit.label("%d victoire%s classée%s cette semaine · %d combat%s classé%s restant%s aujourd'hui" % [int(a["victoires_semaine"]), "s" if int(a["victoires_semaine"]) > 1 else "", "s" if int(a["victoires_semaine"]) > 1 else "", int(a["restants"]), "s" if int(a["restants"]) > 1 else "", "s" if int(a["restants"]) > 1 else "", "s" if int(a["restants"]) > 1 else ""], 15, UiKit.SOFT, false))
	# Les donjons.
	var donjons := UiKit.card(column, 4)
	donjons.add_child(UiKit.label("Les donjons", 20, UiKit.GOLD, false))
	for dj in app.data.donjons["donjons"]:
		var carte := app.carte_donjon(str(dj["id"]))
		donjons.add_child(UiKit.label("%s : boss vaincu %d fois · %d chemin%s explor%s · %d secret%s" % [dj["nom"], int(carte.get("boss", 0)), carte.get("explorees", []).size(), "s" if carte.get("explorees", []).size() > 1 else "", "és" if carte.get("explorees", []).size() > 1 else "é", carte.get("secrets", []).size(), "s" if carte.get("secrets", []).size() > 1 else ""], 15, Color.WHITE, false))
	column.add_child(UiKit.label("Classements, saisons et profils des autres joueurs arriveront avec le serveur (étape 5).", 14, Color(0.6, 0.62, 0.7)))
