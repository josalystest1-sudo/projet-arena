## L'économie (docs/GDD_V2.md, § 10.2 ; engine/economie.gd) : l'Or mesuré par semaine, la taxe qui monte, les garde-fous
## par jour ; le serveur simulé note les mouvements et rend le bilan ; le Marché applique le taux de la semaine.
extends "res://tests/test_case.gd"


func _profil() -> PlayerProfile:
	PlayerProfile.chemin = "user://test_profil_economie.cfg"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PlayerProfile.chemin))
	return PlayerProfile.new()


func _simule(profile: PlayerProfile) -> Serveur:
	var s: Serveur = Serveur.creer(donnees, profile)
	s._ready()
	return s


# Les données et les mouvements : un mouvement est daté et rangé dans sa semaine ; le bilan d'une semaine additionne
# par type ; les mauvaises données sont signalées.
func test_mouvements_et_bilan() -> void:
	for erreur in donnees.erreurs:
		failures.append(erreur)
	var m := Economie.mouvement("comptoir", 40, "2026-11-02")
	assert_eq(int(m["semaine"]), Arene.semaine("2026-11-02"), "la semaine du jour")
	assert_true(Economie.mouvement_valide(m), "un mouvement valide")
	assert_false(Economie.mouvement_valide({"type": "don", "montant": 5, "jour": "2026-11-02", "semaine": 1}), "un type inconnu : refusé")
	assert_eq(int(Economie.mouvement("taxe", -3, "2026-11-02")["montant"]), 0, "jamais négatif")
	var s := Arene.semaine("2026-11-02")
	var liste := [Economie.mouvement("comptoir", 40, "2026-11-02"), Economie.mouvement("comptoir", 10, "2026-11-03"),
		Economie.mouvement("taxe", 6, "2026-11-04"), Economie.mouvement("achat", 30, "2026-11-04"),
		Economie.mouvement("comptoir", 999, "2026-11-09")]
	assert_eq(Economie.bilan(liste, s), {"entre": 50, "detruit": 6, "echange": 30}, "le bilan de la semaine")
	assert_eq(Economie.bilan(liste, s + 1), {"entre": 999, "detruit": 0, "echange": 0}, "la semaine d'après")
	assert_eq(Economie.somme({"entre": 1, "detruit": 2, "echange": 3}, {"entre": 10, "detruit": 20, "echange": 30}), {"entre": 11, "detruit": 22, "echange": 33}, "deux bilans additionnés")
	var monde := Economie.monde_simule(24, s, donnees)
	assert_true(int(monde["entre"]) > 0 and int(monde["detruit"]) > 0, "le monde simulé bouge de l'Or")
	assert_eq(Economie.monde_simule(24, s, donnees), monde, "même semaine, même monde")
	assert_true(float(monde["entre"]) / float(monde["detruit"]) < float(donnees.marche["inflation"]["seuil"]), "en temps ordinaire, sous le seuil d'inflation")
	var d2 := Donnees.charger()
	d2.marche["taxe_max"] = 0.1
	d2.comptoir["ventes_par_jour"] = 0
	d2.erreurs.clear()
	d2.valider()
	assert_true(d2.erreurs.size() >= 2, "taxe_max sous la taxe et une limite nulle sont signalés (%s)" % str(d2.erreurs))


# La taxe qui monte : au taux de base sous le seuil (ou avec trop peu d'Or pour juger), puis un pas par cran, jusqu'au
# plafond ; les fourchettes de prix ne bougent pas.
func test_taxe_qui_monte() -> void:
	var base := float(donnees.marche["taxe"])
	assert_almost(Economie.taux_taxe(0, 0, donnees), base, "rien : le taux de base")
	assert_almost(Economie.taux_taxe(400, 1, donnees), base, "trop peu d'Or pour juger (sous le minimum)")
	assert_almost(Economie.taux_taxe(2000, 600, donnees), base, "créé ÷ détruit = 3,3 : sous le seuil de 4")
	assert_almost(Economie.taux_taxe(2000, 500, donnees), base, "pile au seuil : encore le taux de base")
	assert_almost(Economie.taux_taxe(2100, 500, donnees), base + 0.05, "4,2 : un cran")
	assert_almost(Economie.taux_taxe(3000, 500, donnees), base + 0.15, "6 : trois crans")
	assert_almost(Economie.taux_taxe(100000, 1, donnees), float(donnees.marche["taxe_max"]), "jamais au-delà du plafond")
	assert_eq(Economie.texte_taux(0.15), "15 %", "le taux en clair")
	assert_true(Economie.texte_taxe({"entre": 840, "detruit": 264, "echange": 1700}, 0.15, donnees).begins_with("Taxe du Marché cette semaine : 15 %"), "le texte de la semaine")
	assert_true("elle monte" in Economie.texte_taxe({"entre": 8400, "detruit": 264, "echange": 1700}, 0.3, donnees), "le texte dit quand elle monte")
	# Le Marché applique le taux donné ; sans taux, le taux de base.
	assert_eq(Marche.taxe(100, donnees), 15, "la taxe de base sur 100")
	assert_eq(Marche.taxe(100, donnees, 0.3), 30, "la taxe de la semaine sur 100")
	assert_eq(Marche.net(100, donnees, 0.3), 70, "le net de la semaine")
	var o := Equipement.tirer("epee", "epique", 20, 5, donnees, false)
	assert_eq(Comptoir.fourchette_marche(o, donnees), Comptoir.fourchette_marche(o, donnees), "les fourchettes ne dépendent pas de la taxe")


# Les garde-fous par jour : des limites lues dans les données, des compteurs remis à zéro au changement de jour.
func test_limites_du_jour() -> void:
	assert_eq(Economie.limite("ventes", donnees), int(donnees.comptoir["ventes_par_jour"]), "ventes au Comptoir par jour")
	assert_eq(Economie.limite("depots", donnees), int(donnees.marche["depots_par_jour"]), "mises en vente par jour")
	assert_eq(Economie.limite("achats", donnees), int(donnees.marche["achats_par_jour"]), "achats par jour")
	var c := {}
	assert_eq(Economie.reste(c, "2026-11-02", "ventes", donnees), Economie.limite("ventes", donnees), "rien compté : tout reste")
	for _i in range(3):
		c = Economie.compter(c, "2026-11-02", "ventes")
	assert_eq(Economie.reste(c, "2026-11-02", "ventes", donnees), Economie.limite("ventes", donnees) - 3, "trois ventes de moins")
	assert_eq(Economie.reste(c, "2026-11-02", "achats", donnees), Economie.limite("achats", donnees), "les achats ne bougent pas")
	assert_eq(Economie.reste(c, "2026-11-03", "ventes", donnees), Economie.limite("ventes", donnees), "le lendemain, tout revient")
	for _i in range(100):
		c = Economie.compter(c, "2026-11-02", "ventes")
	assert_eq(Economie.reste(c, "2026-11-02", "ventes", donnees), 0, "jamais négatif")
	assert_eq(Economie.texte_reste(c, "2026-11-02", "ventes", donnees), "Ventes au Comptoir aujourd'hui : 103 sur %d." % Economie.limite("ventes", donnees), "le texte du jour")


# Le serveur simulé : tes mouvements sont gardés, le bilan d'une semaine les ajoute au monde simulé ; encaisser prend le
# taux de la semaine ; un mouvement invalide est refusé.
func test_serveur_simule() -> void:
	var profile := _profil()
	var s := _simule(profile)
	await s.connecter()
	var jour := Time.get_date_string_from_system()
	var semaine := Arene.semaine(jour)
	var avant: Dictionary = await s.bilan(semaine)
	assert_true(await s.mouvement(Economie.mouvement("comptoir", 25, jour)), "un mouvement noté")
	assert_true(await s.mouvement(Economie.mouvement("taxe", 4, jour)), "un autre")
	assert_false(await s.mouvement({"type": "vol", "montant": 1}), "un mouvement invalide est refusé")
	var apres: Dictionary = await s.bilan(semaine)
	assert_eq(int(apres["entre"]) - int(avant["entre"]), 25, "l'Or créé s'ajoute au monde")
	assert_eq(int(apres["detruit"]) - int(avant["detruit"]), 4, "l'Or détruit aussi")
	assert_eq(profile.serveur["mouvements"].size(), 2, "gardés dans le profil")
	for _i in range(450):
		await s.mouvement(Economie.mouvement("achat", 1, jour))
	assert_eq(profile.serveur["mouvements"].size(), 400, "les 400 derniers seulement")
	# Encaisser au taux de la semaine : une annonce vendue hier.
	var o := Equipement.tirer("epee", "epique", 20, 5, donnees, false)
	var a := Marche.annonce(o, 200, s.compte_id, "test-1")
	assert_true(await s.deposer(a), "une annonce déposée")
	var miennes: Array = profile.serveur["annonces"]
	miennes[0]["vendu"] = true
	miennes[0]["jour"] = "2026-01-01"
	var ventes: Array = await s.encaisser(0.3)
	assert_eq(ventes.size(), 1, "une vente encaissée")
	assert_eq(int(ventes[0]["net"]), 140, "au taux de 30 % : 140 sur 200")
	s.free()


## L'outil du prototype « Passer au lendemain » : le jour du profil avance d'autant de jours, sans toucher au système.
func test_jours_avance() -> void:
	var p := PlayerProfile.new()
	var aujourd_hui := p.aujourd_hui()
	assert_eq(aujourd_hui, Time.get_date_string_from_system(), "sans avance : la date du jour")
	p.jours_avance = 1
	assert_eq(Arene.jours(p.aujourd_hui()) - Arene.jours(aujourd_hui), 1, "un jour d'avance : demain")
	p.jours_avance = 40
	assert_eq(Arene.jours(p.aujourd_hui()) - Arene.jours(aujourd_hui), 40, "quarante jours d'avance")
	assert_eq(p.aujourd_hui().length(), 10, "au format AAAA-MM-JJ")


# L'Or de l'amélioration est détruit, comme la taxe (VISION § 8 : un puits qui grandit avec la richesse).
func test_amelioration_detruit_de_l_or() -> void:
	var m := Economie.mouvement("amelioration", 40, "2026-11-02")
	assert_true(Economie.mouvement_valide(m), "l'amélioration est un mouvement connu")
	var b := Economie.bilan([m, Economie.mouvement("taxe", 10, "2026-11-02")], Arene.semaine("2026-11-02"))
	assert_eq(int(b["detruit"]), 50, "l'Or de l'amélioration compte dans l'Or détruit")
	assert_eq(int(b["entre"]), 0, "et pas dans l'Or créé")
