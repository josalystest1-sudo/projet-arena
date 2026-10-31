## La carte du monde (docs/GDD_V2.md, § 9.2 ; engine/carte.gd) : régions et territoires, liens, population, les donjons de
## la semaine, la part de l'entrée, les revenus d'un territoire, qui peut viser quoi, le monde simulé ; le serveur simulé.
extends "res://tests/test_case.gd"


func _profil() -> PlayerProfile:
	PlayerProfile.chemin = "user://test_profil_carte.cfg"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PlayerProfile.chemin))
	return PlayerProfile.new()


func _simule(profile: PlayerProfile) -> Serveur:
	var s: Serveur = Serveur.creer(donnees, profile)
	s._ready()
	return s


# Les données : trois régions, un donjon du jeu chacune, vingt-quatre territoires aux identifiants uniques et au type
# connu, des liens symétriques vers des territoires existants, des territoires qui apparaissent avec la population.
func test_regions_et_territoires() -> void:
	for erreur in donnees.erreurs:
		failures.append(erreur)
	assert_eq(Carte.regions(donnees).size(), 3, "trois régions")
	assert_eq(Carte.territoires(donnees).size(), 24, "vingt-quatre territoires")
	for r in Carte.regions(donnees):
		assert_false(Donjon.definition(str(r["donjon"]), donnees).is_empty(), r["nom"] + " : un donjon du jeu")
		assert_eq(r["territoires"].size(), 8, r["nom"] + " : huit territoires")
	var t := Carte.territoire("hameau", donnees)
	assert_eq(str(t["region"]), "basses_terres", "le Hameau est dans les Basses Terres")
	assert_eq(Carte.region_de("hameau", donnees)["id"], "basses_terres", "sa région")
	assert_true(Carte.territoire("nulle_part", donnees).is_empty(), "un inconnu")
	var v := Carte.voisins("hameau", donnees)
	assert_true(v.has("clairiere") and v.has("gue") and v.has("tour_de_guet") and v.has("marais") and v.has("verger"), "les voisins du Hameau")
	for id in Carte.territoires(donnees).map(func(x): return str(x["id"])):
		for w in Carte.voisins(id, donnees):
			assert_true(Carte.voisins(w, donnees).has(id), "%s – %s : le lien va dans les deux sens" % [id, w])
	assert_true(Carte.voisins("verger", donnees).has("necropole"), "un lien entre deux régions")
	assert_eq(Carte.territoires_ouverts(0, donnees).size(), 15, "sans guilde : cinq territoires par région")
	assert_eq(Carte.territoires_ouverts(3, donnees).size(), 18, "trois guildes : un de plus par région")
	assert_eq(Carte.territoires_ouverts(8, donnees).size(), 24, "huit guildes : tout est ouvert")
	assert_true(Carte.ouvert(Carte.territoire("dunes", donnees), 8) and not Carte.ouvert(Carte.territoire("dunes", donnees), 7), "les Dunes dès huit guildes")
	assert_eq(Carte.texte_type("mine", donnees), "Mine : 20 Influence par jour pour la guilde qui la tient", "le texte d'un type")
	assert_eq(Carte.nom_type("bastion", donnees), "Bastion", "le nom d'un type")
	var d2 := Donnees.charger()
	d2.carte["regions"][0]["liens"].append(["hameau", "nulle_part"])
	d2.carte["regions"][1]["territoires"][0]["type"] = "volcan"
	d2.erreurs.clear()
	d2._valider_carte()
	assert_true(d2.erreurs.size() >= 2, "un lien vers un inconnu et un type inconnu sont signalés (%s)" % str(d2.erreurs))


# Les donjons de la semaine : un par région, sur un territoire ouvert de sa région, le même pour tout le monde, qui
# change avec la semaine ; la part de l'entrée.
func test_donjons_de_la_semaine() -> void:
	var ou := Carte.donjons_de_la_semaine(2900, 5, donnees)
	assert_eq(ou.size(), 3, "trois donjons placés")
	var vus := {}
	for t in ou:
		var ter := Carte.territoire(str(t), donnees)
		assert_true(Carte.ouvert(ter, 5), "%s : un territoire ouvert" % t)
		assert_eq(Carte.region(str(ter["region"]), donnees)["donjon"], ou[t], "%s : le donjon de sa région" % t)
		vus[str(ou[t])] = true
	assert_eq(vus.size(), 3, "les trois donjons")
	assert_eq(Carte.donjons_de_la_semaine(2900, 5, donnees), ou, "même semaine, même carte")
	var differentes := false
	for s in range(2901, 2912):
		if Carte.donjons_de_la_semaine(s, 5, donnees) != ou:
			differentes = true
	assert_true(differentes, "le donjon bouge d'une semaine à l'autre")
	assert_eq(Carte.territoire_du_donjon("terrier", 2900, 5, donnees), ou.find_key("terrier"), "où est le Terrier")
	assert_eq(Carte.territoire_du_donjon("inconnu", 2900, 5, donnees), "", "un donjon inconnu n'est nulle part")
	assert_eq(Carte.part_entree(40, donnees), 4, "10 % de 40")
	assert_eq(Carte.part_entree(25, donnees), 3, "arrondi au-dessus")


# Qui tient quoi : un état valide, les territoires d'une guilde, ce qu'ils rapportent, qui peut viser quoi, le monde
# simulé tiré avec la saison.
func test_qui_tient_quoi() -> void:
	var guildes := [{"id": "g1", "nom": "Les Uns", "banniere": Guilde.banniere_defaut(1, donnees)}, {"id": "g2", "nom": "Les Autres", "banniere": Guilde.banniere_defaut(2, donnees)},
		{"id": "g3", "nom": "Les Trois", "banniere": Guilde.banniere_defaut(3, donnees)}, {"id": "g4", "nom": "Les Quatre", "banniere": Guilde.banniere_defaut(4, donnees)}]
	var etat := Carte.monde_simule(guildes, 0, 5, donnees)
	assert_true(Carte.etat_valide(etat, donnees), "un état valide")
	assert_true(etat.size() >= 4 and etat.size() <= 12, "de un à trois territoires par guilde (%d)" % etat.size())
	for t in etat:
		assert_true(Carte.ouvert(Carte.territoire(str(t), donnees), 5), "%s : un territoire ouvert" % t)
	assert_eq(Carte.monde_simule(guildes, 0, 5, donnees), etat, "même saison, même monde")
	assert_ne(Carte.monde_simule(guildes, 1, 5, donnees), etat, "une autre saison, une autre carte")
	assert_false(Carte.etat_valide({"nulle_part": {"guilde": "g1", "nom": "x", "banniere": {}, "depuis": ""}}, donnees), "un territoire inconnu")
	var mien := {"hameau": {"guilde": "moi", "nom": "Moi", "banniere": {}, "depuis": "saison 0"}, "col": {"guilde": "g1", "nom": "Eux", "banniere": {}, "depuis": "saison 0"}}
	assert_eq(Carte.tenus_par(mien, "moi"), ["hameau"] as Array[String], "mes territoires")
	assert_true(Carte.tenus_par(mien, "personne").is_empty(), "aucun")
	var rev := Carte.revenus(["carriere", "clairiere", "hameau", "gue", "tour_de_guet", "marais"], {"hameau": "terrier"}, donnees)
	assert_eq(int(rev["influence"]), 40, "deux Mines : 40 Influence par jour")
	assert_eq(int(rev["xp"]), 15, "un Sanctuaire : 15 XP par membre")
	assert_almost(float(rev["remise"]), 0.1, "un Marché : 10 % de remise")
	assert_eq(int(rev["relais"]), 1, "un Relais")
	assert_eq(int(rev["bastions"]), 1, "un Bastion")
	assert_eq(int(rev["donjons"]), 1, "un donjon sur ses terres")
	assert_true(Carte.peut_viser(mien, "moi", "gue", donnees), "un voisin de mon territoire")
	assert_false(Carte.peut_viser(mien, "moi", "cratere", donnees), "pas un territoire loin des miens")
	assert_false(Carte.peut_viser(mien, "moi", "hameau", donnees), "pas le mien")
	assert_true(Carte.peut_viser(mien, "g2", "cratere", donnees), "sans territoire : n'importe quel neutre")
	assert_false(Carte.peut_viser(mien, "g2", "col", donnees), "sans territoire : pas un territoire tenu")
	assert_false(Carte.peut_viser(mien, "moi", "nulle_part", donnees), "un territoire inconnu")


# Le serveur simulé : qui tient quoi vient des guildes du monde (et de la tienne, si le profil lui en donne) ; le nombre
# de guildes compte la tienne.
func test_serveur_simule() -> void:
	var profile := _profil()
	var s := _simule(profile)
	await s.connecter()
	assert_eq(await s.nombre_guildes(), donnees.guildes["simule"]["noms"].size(), "les guildes du monde")
	var etat: Dictionary = await s.territoires(0)
	assert_true(Carte.etat_valide(etat, donnees), "un état valide")
	assert_true(etat.size() >= 4, "chaque guilde du monde tient au moins un territoire")
	var g: Dictionary = await s.creer_guilde("Les Nôtres", Guilde.banniere_defaut(1, donnees), {"id": s.compte_id, "pseudo": "Moi", "classe": "mage", "niveau": 12})
	assert_eq(await s.nombre_guildes(), donnees.guildes["simule"]["noms"].size() + 1, "la mienne compte")
	assert_true(Carte.tenus_par(await s.territoires(0), str(g["id"])).is_empty(), "ma guilde ne tient rien au départ")
	profile.serveur["territoires"] = {"0": ["hameau"]}
	assert_eq(Carte.tenus_par(await s.territoires(0), str(g["id"])), ["hameau"] as Array[String], "ce que le profil lui donne (les guerres, plus tard)")
	assert_eq(str((await s.territoires(0))["hameau"]["nom"]), "Les Nôtres", "avec son nom")
	s.free()
