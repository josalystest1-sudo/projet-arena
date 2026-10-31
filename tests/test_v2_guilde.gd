## Les guildes (docs/GDD_V2.md, § 9.1 ; engine/guilde.gd) : nom et bannière, niveau et places, Influence, rôles et pouvoirs,
## effets ; le serveur simulé (fonder, rejoindre, quitter, monter un effet, rôles, exclusion) ; les bonus dans l'application
## (butin de guilde à la Tour).
extends "res://tests/test_case.gd"


func _profil() -> PlayerProfile:
	PlayerProfile.chemin = "user://test_profil_guilde.cfg"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PlayerProfile.chemin))
	return PlayerProfile.new()


func _simule(profile: PlayerProfile) -> Serveur:
	var s: Serveur = Serveur.creer(donnees, profile)
	s._ready()
	return s


func _fiche(id: String, niveau: int = 10) -> Dictionary:
	return {"id": id, "pseudo": "Joueur " + id, "classe": "mage", "niveau": niveau}


# Les données : un nom de 3 à 20 caractères, une bannière faite des modèles, le niveau par paliers, les places, l'Influence
# par activité, les coûts et les textes des effets.
func test_regles() -> void:
	for erreur in donnees.erreurs:
		failures.append(erreur)
	assert_true(Guilde.nom_valide("Les Veilleurs", donnees) and not Guilde.nom_valide("Ab", donnees) and not Guilde.nom_valide("Un nom beaucoup trop long pour une guilde", donnees), "le nom")
	var b := Guilde.banniere_defaut(7, donnees)
	assert_true(Guilde.banniere_valide(b, donnees), "une bannière tirée est valide")
	assert_eq(Guilde.banniere_defaut(7, donnees), b, "même graine, même bannière")
	assert_false(Guilde.banniere_valide({"motif": "croix", "fond": "rouge", "couleur": "rouge"}, donnees), "deux couleurs différentes")
	assert_false(Guilde.banniere_valide({"motif": "dragon", "fond": "rouge", "couleur": "bleu"}, donnees), "un motif des modèles")
	assert_eq(Guilde.couleur("rouge", donnees), Color("c0392b"), "la couleur d'un modèle")
	assert_eq(Guilde.niveau(0, donnees), 1, "niveau 1 au départ")
	assert_eq(Guilde.niveau(299, donnees), 1, "juste sous le palier")
	assert_eq(Guilde.niveau(300, donnees), 2, "le palier 2")
	assert_eq(Guilde.niveau(100000, donnees), donnees.guildes["niveaux"].size(), "le dernier niveau")
	assert_eq(Guilde.manque_niveau(100, donnees), 200, "encore 200 pour le niveau 2")
	assert_eq(Guilde.manque_niveau(100000, donnees), 0, "rien au dernier niveau")
	assert_eq(Guilde.taille_max(1, donnees), 20, "20 places au niveau 1")
	assert_eq(Guilde.taille_max(3, donnees), 40, "40 au niveau 3")
	assert_eq(Guilde.taille_max(50, donnees), 100, "100 au plus")
	assert_eq(Guilde.influence_de("gardien", 2, donnees), 20, "deux Gardiens : 20")
	assert_eq(Guilde.influence_de("inconnue", 2, donnees), 0, "une activité inconnue ne vaut rien")
	assert_eq(Guilde.cout_effet("xp", 0, donnees), 400, "le premier niveau de Savoir")
	assert_eq(Guilde.cout_effet("xp", 1, donnees), 800, "le deuxième coûte le double")
	assert_eq(Guilde.cout_effet("xp", 3, donnees), 0, "au maximum : rien à acheter")
	assert_eq(Guilde.texte_effet("xp", 2, donnees), "Savoir de guilde II : +10 % d'XP pour chaque membre", "le texte d'un effet")
	assert_almost(Guilde.bonus({"effets": {"xp": 2}}, "xp", donnees), 0.1, "le bonus d'un effet au niveau 2")
	assert_almost(Guilde.bonus({}, "xp", donnees), 0.0, "rien sans guilde")


# Une guilde : fondée par un chef ; des membres jusqu'aux places ; les rôles et leurs pouvoirs ; quitter (le chef passe
# la main) ; dissoute quand elle se vide ; l'Influence et les effets.
func test_vie_d_une_guilde() -> void:
	var g := Guilde.nouvelle("g1", "  Les Veilleurs ", Guilde.banniere_defaut(1, donnees), _fiche("chef"), "2026-11-01", donnees)
	assert_true(Guilde.guilde_valide(g, donnees), "une guilde neuve est valide")
	assert_eq(str(g["nom"]), "Les Veilleurs", "le nom sans ses espaces")
	assert_eq(Guilde.role_de(g, "chef"), "chef", "le fondateur est chef")
	assert_eq(Guilde.role_de(g, "x"), "", "un inconnu n'a pas de rôle")
	for i in range(19):
		g = Guilde.ajouter(g, _fiche("m%d" % i), "2026-11-%02d" % (2 + i), donnees)
	assert_eq(g["membres"].size(), 20, "vingt membres : la guilde de niveau 1 est pleine")
	assert_false(Guilde.peut_rejoindre(g, donnees), "plus de place")
	assert_eq(Guilde.ajouter(g, _fiche("trop"), "2026-11-30", donnees)["membres"].size(), 20, "un de plus est refusé")
	assert_eq(Guilde.ajouter(g, _fiche("m3"), "2026-11-30", donnees)["membres"].size(), 20, "déjà membre : refusé")
	# Les pouvoirs.
	assert_true(Guilde.peut("chef", "transmettre") and Guilde.peut("officier", "acheter") and not Guilde.peut("officier", "promouvoir") and not Guilde.peut("membre", "exclure"), "les pouvoirs des rôles")
	assert_eq(Guilde.role_de(Guilde.changer_role(g, "m0", "m1", "officier", donnees), "m1"), "membre", "un membre ne nomme personne")
	g = Guilde.changer_role(g, "chef", "m1", "officier", donnees)
	assert_eq(Guilde.role_de(g, "m1"), "officier", "le chef nomme un officier")
	for i in range(2, 9):
		g = Guilde.changer_role(g, "chef", "m%d" % i, "officier", donnees)
	var officiers := 0
	for m in g["membres"]:
		if str(m["role"]) == "officier":
			officiers += 1
	assert_eq(officiers, int(donnees.guildes["officiers_max"]), "pas plus d'officiers que le maximum")
	assert_eq(Guilde.role_de(Guilde.exclure(g, "m1", "m2"), "m2"), "officier", "un officier n'exclut pas un officier")
	assert_eq(Guilde.role_de(Guilde.exclure(g, "m1", "m10"), "m10"), "", "un officier exclut un membre")
	assert_eq(Guilde.role_de(Guilde.exclure(g, "m10", "m11"), "m11"), "membre", "un membre n'exclut personne")
	assert_eq(Guilde.role_de(Guilde.exclure(g, "m1", "chef"), "chef"), "chef", "personne n'exclut le chef")
	assert_eq(Guilde.exclure(g, "chef", "chef"), g, "le chef ne s'exclut pas lui-même")
	g = Guilde.changer_role(g, "chef", "m1", "membre", donnees)
	assert_eq(Guilde.role_de(g, "m1"), "membre", "le chef remet un officier membre")
	# Le chef part : le plus ancien officier prend la guilde.
	var sans_chef := Guilde.retirer(g, "chef")
	assert_eq(Guilde.role_de(sans_chef, "m2"), "chef", "le plus ancien officier devient chef")
	assert_eq(Guilde.chef(sans_chef)["id"], "m2", "la fonction chef")
	assert_true(Guilde.guilde_valide(sans_chef, donnees), "toujours valide")
	# Transmettre.
	var transmise := Guilde.changer_role(g, "chef", "m5", "chef", donnees)
	assert_eq(Guilde.role_de(transmise, "m5"), "chef", "la guilde transmise")
	assert_eq(Guilde.role_de(transmise, "chef"), "officier", "l'ancien chef devient officier")
	# Une guilde qui se vide est dissoute.
	var seul := Guilde.nouvelle("g2", "Solitaire", Guilde.banniere_defaut(2, donnees), _fiche("a"), "2026-11-01", donnees)
	assert_true(Guilde.retirer(seul, "a").is_empty(), "le dernier membre part : dissoute")
	var deux := Guilde.ajouter(seul, _fiche("b"), "2026-11-02", donnees)
	assert_eq(Guilde.role_de(Guilde.retirer(deux, "a"), "b"), "chef", "sans officier, le plus ancien membre devient chef")
	# L'Influence et les effets.
	g = Guilde.gagner(g, 1000)
	assert_eq(int(g["influence"]), 1000, "la réserve")
	assert_eq(int(g["influence_totale"]), 1000, "le total")
	assert_eq(Guilde.niveau(int(g["influence_totale"]), donnees), 3, "niveau 3 à 1000")
	assert_true(Guilde.peut_rejoindre(g, donnees), "des places au niveau 3")
	assert_eq(Guilde.acheter(g, "m10", "xp", donnees), g, "un membre n'achète pas")
	var achete := Guilde.acheter(g, "m2", "xp", donnees)
	assert_eq(int(achete["effets"]["xp"]), 1, "un officier monte le Savoir")
	assert_eq(int(achete["influence"]), 600, "400 Influence de moins")
	assert_eq(int(achete["influence_totale"]), 1000, "le total ne bouge pas")
	assert_eq(Guilde.acheter(achete, "chef", "reforge", donnees)["influence"], 300, "la Forge coûte 300")
	assert_eq(Guilde.acheter(Guilde.acheter(achete, "chef", "reforge", donnees), "chef", "xp", donnees)["influence"], 300, "pas assez pour 800 : rien")
	assert_eq(Guilde.acheter(g, "chef", "inconnu", donnees), g, "un effet inconnu")


# Le monde simulé : des guildes faites des joueurs simulés, un chef et un officier chacune, de l'Influence par jour.
func test_monde_simule() -> void:
	var joueurs: Array = []
	for i in range(24):
		joueurs.append(_fiche("sim-%d" % (i + 1), 5 + i))
	var liste := Guilde.guildes_simulees(joueurs, "2026-11-02", donnees)
	assert_eq(liste.size(), donnees.guildes["simule"]["noms"].size(), "une guilde par nom simulé")
	for g in liste:
		assert_true(Guilde.guilde_valide(g, donnees), g["nom"] + " : valide")
		assert_eq(g["membres"].size(), 6, g["nom"] + " : six membres")
		assert_eq(str(g["membres"][1]["role"]), "officier", g["nom"] + " : un officier")
	assert_eq(Guilde.guildes_simulees(joueurs, "2026-11-02", donnees), liste, "mêmes joueurs, mêmes guildes")
	var inf := Guilde.influence_simulee(liste[0], "2026-11-02", 2, donnees)
	assert_between(float(inf), 6.0 * 2 * 5, 6.0 * 2 * 15, "six membres simulés pendant deux jours")
	assert_eq(Guilde.influence_simulee(liste[0], "2026-11-02", 0, donnees), 0, "rien pour zéro jour")


# Le serveur simulé : fonder, le nom pris, rejoindre une guilde du monde, apporter de l'Influence, monter un effet, les
# rôles, exclure, quitter ; tout dans le profil.
func test_serveur_simule() -> void:
	var profile := _profil()
	var s := _simule(profile)
	await s.connecter()
	var moi := _fiche(s.compte_id, 12)
	assert_true((await s.ma_guilde()).is_empty(), "sans guilde au départ")
	var liste: Array = await s.guildes(10)
	assert_eq(liste.size(), donnees.guildes["simule"]["noms"].size(), "les guildes du monde")
	assert_true((await s.creer_guilde("La Lame grise", Guilde.banniere_defaut(1, donnees), moi)).is_empty(), "un nom du monde est pris")
	assert_true((await s.creer_guilde("Ab", Guilde.banniere_defaut(1, donnees), moi)).is_empty(), "un nom trop court")
	var g: Dictionary = await s.creer_guilde("Les Nôtres", Guilde.banniere_defaut(1, donnees), moi)
	assert_eq(Guilde.role_de(g, s.compte_id), "chef", "fondée : je suis chef")
	assert_true((await s.creer_guilde("Encore", Guilde.banniere_defaut(1, donnees), moi)).is_empty(), "déjà dans une guilde")
	assert_eq(int((await s.guildes(10))[0]["membres"]), 1, "ma guilde en tête de la liste")
	assert_true(await s.influence_guilde(450), "de l'Influence apportée")
	g = await s.ma_guilde()
	assert_eq(int(g["influence"]), 450, "la réserve")
	assert_true((await s.acheter_effet("butin"))["effets"]["butin"] == 1, "la Chasse montée")
	assert_true((await s.acheter_effet("butin")).is_empty(), "plus assez pour la suivante")
	assert_true((await s.role_guilde("personne", "officier")).is_empty(), "un inconnu")
	assert_true(await s.quitter_guilde(), "je dissous ma guilde en partant seul")
	assert_true((await s.ma_guilde()).is_empty(), "plus de guilde")
	# Rejoindre une guilde du monde.
	var cible: Dictionary = (await s.guildes(10))[0]
	g = await s.rejoindre_guilde(str(cible["id"]), moi)
	assert_eq(Guilde.role_de(g, s.compte_id), "membre", "rejointe comme membre")
	assert_eq(g["membres"].size(), int(cible["membres"]) + 1, "un membre de plus")
	assert_true((await s.acheter_effet("xp")).is_empty(), "un membre n'achète pas")
	assert_true((await s.exclure_guilde(str(g["membres"][2]["id"]))).is_empty(), "un membre n'exclut pas")
	# Les membres simulés apportent leur Influence chaque jour : la guilde datée d'hier en reçoit à la lecture.
	profile.serveur["guilde"]["dernier_jour"] = "2026-01-01"
	var avant := int(g["influence_totale"])
	g = await s.ma_guilde()
	assert_true(int(g["influence_totale"]) > avant, "l'Influence du monde simulé est arrivée")
	assert_true(await s.quitter_guilde(), "je quitte")
	assert_true((await s.ma_guilde()).is_empty(), "sans guilde")
	assert_eq(int((await s.guildes(10))[0]["membres"]), int(cible["membres"]), "la guilde du monde a retrouvé ses membres")
	s.free()


# La Chasse de guilde : un étage rejoué lâche un objet plus souvent.
func test_butin_de_guilde() -> void:
	var sans := 0
	var avec := 0
	for graine in range(1, 201):
		if not Equipement.butin("etage", 10, false, graine, donnees).is_empty():
			sans += 1
		if not Equipement.butin("etage", 10, false, graine, donnees, 0.3).is_empty():
			avec += 1
	assert_true(avec > sans, "plus d'objets avec la Chasse (%d contre %d)" % [avec, sans])
	assert_between(float(avec), 130.0, 190.0, "environ huit fois sur dix")
	var t := Tour.commencer(Generateur.generer("guerrier", 3, 10), Generateur.acolyte("guerrier", 3, 10), 10, 3, donnees)
	var tombes := 0
	for n in range(1, 101):
		if n % 5 != 0 and not t.butin(n, false, 0.5).is_empty():
			tombes += 1
	assert_true(tombes >= 70, "la Tour passe le bonus (%d sur 80)" % tombes)
