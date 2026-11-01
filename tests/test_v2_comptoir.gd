## Le Comptoir et l'Or (GDD V2, § 10.2 ; plan, PR 5.5 adaptée) : le prix plancher, la fourchette du Marché, l'étal du
## jour, le profil.
extends "res://tests/test_case.gd"


func _objet(rarete: String, niveau: int, qualite: int, lie: bool = false) -> Dictionary:
	return {"base": "epee", "rarete": rarete, "niveau": niveau, "lignes": [], "qualite": qualite, "lie": lie, "reforges": 0}


func test_prix_plancher() -> void:
	for erreur in donnees.erreurs:
		failures.append(erreur)
	assert_eq(Comptoir.prix_plancher(_objet("commun", 30, 100), donnees), 4, "un commun parfait au niveau 30 : 2 × 2 × 1")
	assert_eq(Comptoir.prix_plancher(_objet("commun", 30, 0), donnees), 2, "qualité 0 : la moitié")
	assert_eq(Comptoir.prix_plancher(_objet("legendaire", 30, 100), donnees), 160, "un légendaire parfait : 160 Or")
	assert_true(Comptoir.prix_plancher(_objet("rare", 10, 50), donnees) < Comptoir.prix_plancher(_objet("rare", 20, 50), donnees), "plus cher avec le niveau")
	assert_true(Comptoir.prix_plancher(_objet("rare", 10, 20), donnees) < Comptoir.prix_plancher(_objet("rare", 10, 90), donnees), "plus cher avec la qualité")
	assert_true(Comptoir.prix_plancher(_objet("rare", 10, 50), donnees) < Comptoir.prix_plancher(_objet("epique", 10, 50), donnees), "plus cher avec la rareté")
	assert_eq(Comptoir.prix_plancher(_objet("commun", 1, 0), donnees), 1, "jamais moins de 1")
	assert_eq(Comptoir.prix_plancher({"rarete": "inconnue"}, donnees), 0, "une rareté inconnue ne vaut rien")
	assert_true(Comptoir.vendable(_objet("commun", 1, 0, false)), "un objet échangeable se vend")
	assert_false(Comptoir.vendable(_objet("commun", 1, 0, true)), "un objet lié ne se vend pas")
	assert_false(Comptoir.vendable({}), "rien ne se vend")
	var f := Comptoir.fourchette_marche(_objet("legendaire", 30, 100), donnees)
	assert_eq(f, [160, 80000], "au Marché, un légendaire de 1 à 500 fois le plancher")
	assert_eq(Comptoir.fourchette_marche(_objet("commun", 30, 100), donnees), [4, 8], "un commun de 1 à 2 fois")


func test_etal_du_jour() -> void:
	var etal := Comptoir.etal_du_jour("2026-10-30", 12, donnees)
	assert_eq(etal.size(), 3, "trois objets à l'étal")
	assert_eq(str(etal[0]["rarete"]), "commun", "un commun")
	assert_eq(str(etal[1]["rarete"]), "peu_commun", "un peu commun")
	assert_eq(str(etal[2]["rarete"]), "rare", "un rare")
	for o in etal:
		assert_true(bool(o["lie"]), "les objets de l'étal sont liés")
		assert_eq(int(o["niveau"]), 12, "du niveau du joueur")
		assert_true(Equipement.valide(o, donnees), "conformes")
	assert_eq(Comptoir.etal_du_jour("2026-10-30", 12, donnees), etal, "le même étal le même jour")
	assert_true(Comptoir.etal_du_jour("2026-10-31", 12, donnees) != etal, "un autre étal le lendemain")
	assert_eq(Comptoir.prix_etal(etal[0], donnees), 40, "un commun de l'étal : 40 Éclats")
	assert_eq(Comptoir.prix_etal(etal[1], donnees), 80, "un peu commun : 80 Éclats")
	assert_eq(Comptoir.prix_etal(etal[2], donnees), 120, "un rare : 120 Éclats")


func test_profil_du_comptoir() -> void:
	var chemin_avant := PlayerProfile.chemin
	PlayerProfile.chemin = "user://test_comptoir_profil.cfg"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PlayerProfile.chemin))
	var p := PlayerProfile.new()
	p.monnaie_or = 37
	p.etal_jour = "2026-10-30"
	p.etal_achetes = [1]
	p.save()
	var relu := PlayerProfile.load_profile()
	assert_eq(relu.monnaie_or, 37, "l'Or relu")
	assert_eq(relu.etal_jour, "2026-10-30", "le jour de l'étal relu")
	assert_eq(relu.etal_achetes, [1], "les achats relus")
	assert_eq(PlayerProfile.new().monnaie_or, 0, "un profil neuf : pas d'Or")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PlayerProfile.chemin))
	PlayerProfile.chemin = chemin_avant
