## Les objectifs du jour (GDD V2, § 10.3 ; plan, PR 4.1 « Tableau ») : tirés avec la date, un avancement par compteur,
## une récompense réclamée une fois.
extends "res://tests/test_case.gd"


func test_objectifs_du_jour() -> void:
	for erreur in donnees.erreurs:
		failures.append(erreur)
	var jour := Objectifs.du_jour("2026-10-30", donnees)
	assert_eq(jour.size(), 3, "trois objectifs par jour")
	assert_eq(jour, Objectifs.du_jour("2026-10-30", donnees), "le même jour, les mêmes")
	var vus: Dictionary = {}
	for id in jour:
		assert_false(vus.has(id), "trois objectifs différents")
		vus[id] = true
		assert_false(Objectifs.definition(id, donnees).is_empty(), id + " : un objectif de la réserve")
	var ensembles: Dictionary = {}
	for j in range(1, 29):
		ensembles[str(Objectifs.du_jour("2026-11-%02d" % j, donnees))] = true
	assert_true(ensembles.size() >= 10, "les jours diffèrent (%d ensembles sur 28 jours)" % ensembles.size())
	# L'avancement et la récompense.
	var compteurs := {"duels": 2, "duels_gagnes": 1, "cles": 7}
	assert_eq(Objectifs.avancement("trois_duels", compteurs, donnees), 2, "deux duels sur trois")
	assert_false(Objectifs.fini("trois_duels", compteurs, donnees), "pas fini")
	assert_true(Objectifs.fini("duel_gagne", compteurs, donnees), "un duel gagné : fini")
	assert_eq(Objectifs.avancement("cinq_cles", compteurs, donnees), 5, "borné à la cible")
	assert_eq(Objectifs.avancement("gardien", compteurs, donnees), 0, "compteur absent : zéro")
	assert_eq(Objectifs.recompense("gardien", donnees), {"xp": 120, "eclats": 40}, "la récompense d'un Gardien")
	assert_eq(Objectifs.recompense("inconnu", donnees), {"xp": 0, "eclats": 0}, "un objectif inconnu ne rapporte rien")
	var etat := Objectifs.etat_du_jour("2026-10-30", compteurs, ["duel_gagne"], donnees)
	assert_eq(etat.size(), 3, "l'état du jour : trois lignes")
	for o in etat:
		assert_true(o.has("texte") and o.has("avancement") and o.has("cible") and o.has("fini") and o.has("reclame"), "chaque ligne est complète")
		if o["id"] == "duel_gagne":
			assert_true(bool(o["reclame"]), "un objectif réclamé le reste")
	# Chaque compteur de la réserve est un compteur que l'application fait monter.
	for o in donnees.objectifs["reserve"]:
		assert_true(str(o["compteur"]) in Objectifs.COMPTEURS, "%s : compteur connu" % o["id"])
	# Une donnée fausse est signalée.
	var d2 := Donnees.charger()
	d2.objectifs["reserve"][0]["compteur"] = "danse"
	d2.objectifs["reserve"][1]["id"] = d2.objectifs["reserve"][2]["id"]
	d2.erreurs.clear()
	d2._valider_objectifs()
	assert_eq(d2.erreurs.size(), 2, "deux erreurs signalées (%s)" % str(d2.erreurs))


# Le profil garde les objectifs du jour (jour, compteurs, réclamés).
func test_profil_des_objectifs() -> void:
	var chemin_avant := PlayerProfile.chemin
	PlayerProfile.chemin = "user://test_objectifs_profil.cfg"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PlayerProfile.chemin))
	var p := PlayerProfile.new()
	p.objectifs_jour = "2026-10-30"
	p.compteurs = {"duels": 2}
	p.objectifs_reclames = ["duel_gagne"]
	p.save()
	var relu := PlayerProfile.load_profile()
	assert_eq(relu.objectifs_jour, "2026-10-30", "le jour relu")
	assert_eq(int(relu.compteurs["duels"]), 2, "les compteurs relus")
	assert_eq(relu.objectifs_reclames, ["duel_gagne"], "les réclamés relus")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PlayerProfile.chemin))
	PlayerProfile.chemin = chemin_avant
