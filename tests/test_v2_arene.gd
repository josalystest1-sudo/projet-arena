## L'Arène classée hors ligne (GDD V2, § 7 ; plan, PR 5.3 adaptée) : les jours, les saisons et les semaines, les points,
## la ligue, le coffre de la semaine, les adversaires générés.
extends "res://tests/test_case.gd"


func test_temps_de_l_arene() -> void:
	for erreur in donnees.erreurs:
		failures.append(erreur)
	assert_eq(Arene.jours("1970-01-02"), 1, "le 2 janvier 1970 : un jour")
	assert_eq(Arene.jours("2026-10-30") - Arene.jours("2026-10-01"), 29, "29 jours entre le 1er et le 30 octobre")
	assert_eq(Arene.saison("2026-10-01", donnees), 0, "le premier jour : saison 0")
	assert_eq(Arene.saison("2026-12-29", donnees), 0, "89 jours plus tard : toujours la saison 0")
	assert_eq(Arene.saison("2026-12-30", donnees), 1, "90 jours plus tard : la saison 1")
	assert_eq(Arene.saison("2025-01-01", donnees), 0, "avant le début : la saison 0")
	assert_eq(Arene.fin_de_saison("2026-10-30", donnees), "2026-12-30", "la saison 0 finit le 30 décembre")
	assert_eq(Arene.semaine("2026-10-26"), Arene.semaine("2026-11-01"), "lundi et dimanche : la même semaine")
	assert_eq(Arene.semaine("2026-11-02"), Arene.semaine("2026-10-26") + 1, "le lundi suivant : la semaine d'après")
	assert_eq(Arene.jours("n'importe quoi"), 0, "une date mal formée : zéro")


func test_points_ligue_et_coffre() -> void:
	assert_eq(Arene.points_apres(100, true, donnees), 120, "gagné : +20")
	assert_eq(Arene.points_apres(100, false, donnees), 90, "perdu : −10")
	assert_eq(Arene.points_apres(5, false, donnees), 0, "jamais sous zéro")
	assert_eq(Arene.ligue(0), "aspirants", "une classe de base : Aspirants")
	assert_eq(Arene.ligue(1), "elus", "rang 1 : Élus")
	assert_eq(Arene.ligue(7), "ascendants", "au-delà : Ascendants")
	assert_eq(Arene.nom_ligue("aspirants", donnees), "Aspirants", "le nom d'une ligue")
	assert_eq(Arene.rarete_coffre(2, donnees), "", "deux victoires : pas de coffre")
	assert_eq(Arene.rarete_coffre(3, donnees), "commun", "trois : commun")
	assert_eq(Arene.rarete_coffre(5, donnees), "rare", "cinq : rare")
	assert_eq(Arene.rarete_coffre(12, donnees), "epique", "sept et plus : épique")
	assert_true(Arene.coffre(2, 12, 1, donnees).is_empty(), "pas de coffre : rien")
	var c := Arene.coffre(7, 12, 1, donnees)
	assert_eq(str(c["rarete"]), "epique", "le coffre épique")
	assert_eq(int(c["niveau"]), 12, "du niveau du joueur")
	assert_true(bool(c["lie"]), "lié")
	assert_true(Equipement.valide(c, donnees), "conforme")
	assert_eq(Arene.coffre(7, 12, 1, donnees), c, "même graine, même coffre")


func test_adversaires_generes() -> void:
	var classes: Dictionary = {}
	var equipes: Dictionary = {}
	for graine in range(1, 61):
		var adv := Arene.adversaire(12, graine, donnees)
		assert_true(donnees.classes.has(str(adv["classe"])), "graine %d : une classe connue" % graine)
		assert_between(int(adv["niveau"]), 10, 14, "graine %d : à deux niveaux près" % graine)
		assert_true(str(adv["nom"]) != "", "graine %d : un nom" % graine)
		classes[adv["classe"]] = true
		equipes[adv["equipement"]] = true
		assert_eq(Arene.adversaire(12, graine, donnees), adv, "graine %d : le même adversaire" % graine)
	assert_true(classes.size() >= 5, "des classes variées (%d)" % classes.size())
	assert_true(equipes.size() >= 3, "des équipements variés (%s)" % str(equipes.keys()))
	assert_between(int(Arene.adversaire(1, 3, donnees)["niveau"]), 1, 3, "au niveau 1, jamais en dessous de 1")
	assert_between(int(Arene.adversaire(30, 3, donnees)["niveau"]), 28, 30, "au niveau 30, jamais au-dessus")
	var adv := {"classe": "mage", "graine": 9, "niveau": 20, "nom": "Nox", "equipement": "epique"}
	var trio := Arene.trio_adverse(adv, donnees)
	assert_eq(trio.size(), 3, "un trio")
	assert_eq(trio[0].classe_id, "mage", "le joueur adverse")
	assert_false(Equipement.sans_bonus(trio[0].mods), "équipé")
	assert_true(trio[1].mods.is_empty(), "ses Échos ne le sont pas")
	var nu := Arene.trio_adverse({"classe": "mage", "graine": 9, "niveau": 20, "nom": "Nox", "equipement": ""}, donnees)
	assert_true(nu[0].mods.is_empty(), "sans équipement")
	# Un combat classé contre lui se joue jusqu'au bout.
	var joueur := Trio.camp(Generateur.generer("guerrier", 4, 20, Generateur.PAR_DEFAUT, donnees), 20, donnees)
	var e := Regles.nouveau_combat(joueur, trio, 20, "pvp", donnees)
	while not e.fini and e.tour <= 100:
		e = tour(e, IA.declarer(e))
	assert_true(e.fini, "le combat se termine")


# Le profil garde l'Arène.
func test_profil_de_l_arene() -> void:
	var chemin_avant := PlayerProfile.chemin
	PlayerProfile.chemin = "user://test_arene_profil.cfg"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PlayerProfile.chemin))
	var p := PlayerProfile.new()
	p.arene = {"points": 140, "saison": 0, "jour": "2026-10-30", "combats_jour": 2, "semaine": 2965, "victoires_semaine": 4, "coffre_reclame": false}
	p.save()
	var relu := PlayerProfile.load_profile()
	assert_eq(int(relu.arene["points"]), 140, "les points relus")
	assert_eq(int(relu.arene["victoires_semaine"]), 4, "les victoires relues")
	assert_true(PlayerProfile.new().arene.is_empty(), "un profil neuf : pas d'Arène encore")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PlayerProfile.chemin))
	PlayerProfile.chemin = chemin_avant
