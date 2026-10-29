## Combat V2 : le simulateur d'équilibrage (docs/SPEC-COMBAT-V2.md, section 14, tests 49 et 50).
extends "res://tests/test_case.gd"

const Lib := preload("res://tools/equilibrage_lib.gd")


# 49. Le rapport est produit et contient les six critères.
func test_49_rapport_et_six_criteres() -> void:
	var parts: Array = [Lib.simuler(donnees, "matrice", 0, 10, 1, 1), Lib.simuler(donnees, "routes", 0, 20, 1, 1),
		Lib.simuler(donnees, "tour", 0, 10, 1, 1)]
	# Comme les travailleurs : en JSON et retour.
	for i in range(parts.size()):
		parts[i] = JSON.parse_string(JSON.stringify(parts[i]))
	var mesure := Lib.fusionner(parts, donnees.ordre_classes.size())
	var r := Lib.resumer(donnees, mesure)
	assert_eq(r["combats"], 10, "10 duels de la matrice")
	var criteres := Lib.criteres(r)
	assert_eq(criteres.size(), 6, "six critères")
	var texte := Lib.rapport(donnees, r, "Essai", ["k_classe du Mage : 1,00 → 1,05 (46 % de victoires)"])
	for c in criteres:
		assert_true(texte.contains(str(c["titre"])), "le rapport contient « %s »" % c["titre"])
	for morceau in ["La matrice des classes", "Les trois routes", "Boutons touchés", "Ruée", "Éventail", "Réactive", "Tour"]:
		assert_true(texte.contains(morceau), "le rapport contient « %s »" % morceau)


# 50. Un combat IA contre IA finit toujours (au-delà de 60 tours, le test échoue).
func test_50_un_combat_ia_contre_ia_finit_toujours() -> void:
	var memoire := {}
	var classes := donnees.ordre_classes
	var plus_long := 0
	for i in range(classes.size()):
		for j in range(classes.size()):
			var r := Lib.duel(donnees, classes[i], classes[j], 1 + i, (i + j) % 2 == 0, "reactive", memoire)
			assert_true(r["fini"] and int(r["tours"]) <= 60, "%s contre %s : fini en %d tours" % [classes[i], classes[j], r["tours"]])
			plus_long = maxi(plus_long, int(r["tours"]))
	assert_true(plus_long > 0, "des combats ont été joués")
	for route in ["ruee", "eventail"]:
		var r := Lib.duel(donnees, "guerrier", "mage", 3, true, route, memoire)
		assert_true(r["fini"], "route %s : le combat finit" % route)
