## La ville (docs/GDD_V2.md, § 11 ; docs/PLAN.md, PR 4.1) : la carte vient des données, chaque bâtiment disponible ouvre
## un écran qui existe, tout est à deux touchers.
extends "res://tests/test_case.gd"

const App := preload("res://scenes/app/app.gd")


func test_ville_dans_les_donnees() -> void:
	for erreur in donnees.erreurs:
		failures.append(erreur)
	var batiments: Array = donnees.ville["batiments"]
	assert_eq(batiments.size(), 9, "neuf bâtiments")
	var ids: Dictionary = {}
	for b in batiments:
		ids[b["id"]] = true
		if bool(b["dispo"]):
			assert_true(App.SCREENS.has(str(b["ecran"])), "%s : son écran « %s » existe" % [b["id"], b["ecran"]])
		assert_between(float(b["x"]), 0.0, 1.0, "%s : x sur la carte" % b["id"])
		assert_between(float(b["y"]), 0.0, 1.0, "%s : y sur la carte" % b["id"])
	for id in ["tour", "arene", "donjon", "guilde", "comptoir", "forge", "maison", "boutique", "tableau"]:
		assert_true(ids.has(id), id + " : un bâtiment du GDD")
	# Tout est à deux touchers : la Tour, l'Arène, la Forge, la Maison et le Tableau sont disponibles.
	for b in batiments:
		if str(b["id"]) in ["tour", "arene", "forge", "maison", "tableau"]:
			assert_true(bool(b["dispo"]), b["id"] + " : disponible")
	# La barre du bas : Ville, Chat (grisé jusqu'au serveur), Profil.
	assert_eq(App.NAV.size(), 3, "trois onglets")
	assert_eq(App.NAV[0][0], "ville", "la ville d'abord")
	# Une donnée fausse est signalée : un bâtiment disponible sans écran, une position hors de la carte.
	var d2 := Donnees.charger()
	d2.ville["batiments"][0]["ecran"] = ""
	d2.ville["batiments"][1]["x"] = 1.5
	d2.erreurs.clear()
	d2._valider_ville()
	assert_eq(d2.erreurs.size(), 2, "deux erreurs signalées (%s)" % str(d2.erreurs))
