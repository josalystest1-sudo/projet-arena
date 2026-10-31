## Les évolutions de classe (docs/GDD_V2.md, § 3 ; docs/PLAN.md, phase 8, PR 8.1 ; décisions de Gautier du 30 octobre) :
## les données des dix évolutions, les points d'un rang, le saut de puissance, les Échos et adversaires évolués, le
## garde-fou « un évolué à roue vide bat un niveau 29 ».
extends "res://tests/test_case.gd"


# Cent vingt évolutions : trente de rang 1 (trois par classe de base, une de chaque rôle) et quatre-vingt-dix de rang 2
# (trois par évolution de rang 1, une de chaque rôle), chacune une roue entière, dans le budget.
func test_donnees_des_evolutions() -> void:
	assert_eq(donnees.erreurs, [] as Array[String], "aucune erreur de données")
	assert_eq(donnees.ordre_evolutions.size(), 120, "cent vingt évolutions")
	var par_rang := {1: 0, 2: 0}
	var enfants := {}
	var bases := {}
	var roles := {}
	var roles_par_base := {}
	for id in donnees.ordre_evolutions:
		var ev := donnees.classe(id)
		assert_eq(str(ev["id"]), id, id + " : identifiant")
		var rang := int(ev["rang"])
		par_rang[rang] = int(par_rang.get(rang, 0)) + 1
		if rang == 1:
			assert_true(donnees.ordre_classes.has(str(ev["base"])), id + " : une classe de base connue")
			bases[str(ev["base"])] = true
			roles[str(ev["role"])] = true
			roles_par_base[str(ev["base"]) + "|" + str(ev["role"])] = true
		else:
			assert_eq(Evolution.rang(str(ev["base"]), donnees), 1, id + " : son parent est de rang 1")
			assert_true(donnees.ordre_classes.has(Evolution.base(id, donnees)), id + " : une lignée connue")
			enfants[str(ev["base"]) + "|" + str(ev["role"])] = int(enfants.get(str(ev["base"]) + "|" + str(ev["role"]), 0)) + 1
		assert_eq(ev["voies"].size(), 5, id + " : 5 voies")
		for voie in ev["voies"]:
			assert_eq(voie["noeuds"].size(), 4, "%s %s : 4 nœuds" % [id, voie["id"]])
		assert_true(str(ev["description"]) != "", id + " : une description")
		assert_eq(Evolution.rang(id, donnees), rang, id + " : rang lu")
		assert_eq(Evolution.parent(id, donnees), str(ev["base"]), id + " : parent lu")
	assert_eq(bases.size(), 10, "chaque classe de base a ses évolutions")
	assert_eq(roles.size(), 3, "les trois rôles parmi les évolutions")
	assert_eq(roles_par_base.size(), 30, "chaque classe a une évolution de chaque rôle")
	assert_eq(par_rang, {1: 30, 2: 90}, "trente de rang 1, quatre-vingt-dix de rang 2")
	assert_eq(enfants.size(), 90, "chaque évolution de rang 1 a une évolution de rang 2 de chaque rôle")
	for id in donnees.ordre_evolutions:
		if Evolution.rang(id, donnees) == 1:
			assert_eq(Evolution.evolutions_de(id, donnees).size(), 3, id + " : trois évolutions de rang 2")
	assert_eq(Budget.fautes(donnees), [] as Array[Dictionary], "tous les nœuds des évolutions dans leur budget")
	for classe in donnees.ordre_classes:
		assert_eq(Evolution.evolutions_de(classe, donnees).size(), 3, classe + " : trois évolutions")
		assert_eq(Evolution.rang(classe, donnees), 0, classe + " : rang 0")
		assert_eq(Evolution.base(classe, donnees), classe, classe + " : sa propre lignée")
	# Les classes de base ne changent pas : leurs identifiants ne sont pas ceux des évolutions.
	assert_eq(donnees.ordre_classes.size(), 10, "toujours dix classes de base")


# Les niveaux d'un rang : 30 points pour la classe de base (niveaux 1 à 30), zéro au niveau 30 pour une évolution
# puis un par niveau jusqu'à 60.
func test_points_et_niveaux() -> void:
	assert_eq(Evolution.niveaux_par_rang(donnees), 30, "30 niveaux par rang")
	assert_eq(Evolution.points(1, 0, donnees), 1, "niveau 1 : 1 point")
	assert_eq(Evolution.points(30, 0, donnees), 30, "niveau 30 : 30 points")
	assert_eq(Evolution.points(30, 1, donnees), 0, "évolué au niveau 30 : 0 point")
	assert_eq(Evolution.points(31, 1, donnees), 1, "évolué au niveau 31 : 1 point")
	assert_eq(Evolution.points(60, 1, donnees), 30, "évolué au niveau 60 : 30 points")
	assert_eq(Evolution.niveau_max(0, donnees), 30, "plafond de la classe de base")
	assert_eq(Evolution.niveau_max(1, donnees), 60, "plafond du rang 1")
	assert_eq(Evolution.rang_max(donnees), 1, "en version 1, le rang 1 seulement (rules.json : rang_max)")
	var d2 := _avec_rang_2()
	assert_eq(Evolution.rang_max(d2), 2, "deux rangs existent dans les données")
	assert_eq(Evolution.niveau_max(2, donnees), 90, "plafond du rang 2")
	assert_eq(Evolution.points(61, 2, donnees), 1, "rang 2 au niveau 61 : 1 point")
	assert_eq(Evolution.rang_du_niveau(30, donnees), 0, "niveau 30 : classe de base")
	assert_eq(Evolution.rang_du_niveau(31, donnees), 1, "niveau 31 : évolué")
	assert_eq(Evolution.rang_du_niveau(60, donnees), 1, "niveau 60 : évolué")
	assert_eq(Evolution.rang_du_niveau(61, d2), 2, "niveau 61 : rang 2")
	assert_eq(Evolution.rang_du_niveau(90, d2), 2, "niveau 90 : rang 2")
	assert_eq(Evolution.rang_du_niveau(90, donnees), 1, "en version 1 : jamais au-delà du rang 1")
	assert_eq(Evolution.rang_du_niveau(120, d2), 2, "niveau 120 : borné par ce qui existe")
	assert_eq(Evolution.rang_du_niveau(120, donnees), 1, "niveau 120 en version 1 : borné par rang_max")
	assert_false(Evolution.peut_evoluer("guerrier", 29, donnees), "pas avant le niveau 30")
	assert_true(Evolution.peut_evoluer("guerrier", 30, donnees), "au niveau 30")
	assert_false(Evolution.peut_evoluer("champion", 59, donnees), "pas avant le niveau 60")
	assert_true(Evolution.peut_evoluer("champion", 60, d2), "au niveau 60, le rang 2")
	assert_false(Evolution.peut_evoluer("champion", 60, donnees), "en version 1, le Champion n'évolue plus au niveau 60")
	assert_true(Evolution.evolutions_jouables("champion", donnees).is_empty(), "en version 1, rien à proposer au Champion")
	assert_eq(Evolution.evolutions_jouables("guerrier", donnees).size(), 3, "le Guerrier a toujours ses trois évolutions")
	assert_false(Evolution.peut_evoluer("parangon", 90, donnees), "le rang 3 n'existe pas")
	assert_true(Evolution.evolutions_de("champion", donnees).has("parangon"), "le Parangon est une évolution du Champion")
	assert_eq(Evolution.base("parangon", donnees), "guerrier", "la lignée du Parangon")
	assert_eq(Evolution.parent("parangon", donnees), "champion", "son parent")
	assert_eq(Evolution.classe_au_niveau("guerrier", 30, 5, donnees), "guerrier", "jusqu'à 30 : la classe de base")
	assert_true(Evolution.classe_au_niveau("guerrier", 31, 5, donnees) in Evolution.evolutions_de("guerrier", donnees), "au-delà : une de ses évolutions")
	var deux := Evolution.classe_au_niveau("guerrier", 65, 5, d2)
	assert_eq(Evolution.rang(deux, d2), 2, "au niveau 65 : un rang 2")
	assert_eq(Evolution.base(deux, d2), "guerrier", "de la lignée du Guerrier")
	assert_true(Evolution.classe_au_niveau("champion", 65, 5, d2) in Evolution.evolutions_de("champion", d2), "un Champion au niveau 65 : une de ses évolutions")
	assert_eq(Evolution.rang(Evolution.classe_au_niveau("guerrier", 65, 5, donnees), donnees), 1, "en version 1, au niveau 65 : un rang 1")
	assert_eq(Evolution.tirer("champion", 5, donnees), "champion", "en version 1, un Champion ne tire pas de rang 2")
	var tirees := {}
	for graine in range(1, 31):
		tirees[Evolution.tirer("guerrier", graine, donnees)] = true
	assert_eq(tirees.size(), 3, "les trois évolutions sont tirées selon la graine")
	assert_eq(Evolution.classe_au_niveau("champion", 12, 5, donnees), "champion", "une évolution reste une évolution")
	assert_eq(Evolution.tirer("parangon", 5, donnees), "parangon", "sans évolution : elle-même")


# Un Destin évolué : rang 1, le sprite de sa lignée, PV et k multipliés par le saut de puissance ; à roue vide au
# niveau 30, puis un nœud ou éclat par niveau. Une classe de base ne change pas d'un bit.
func test_destin_evolue() -> void:
	var p_pv := float(donnees.regles["evolution"]["puissance_pv"])
	var p_val := float(donnees.regles["evolution"]["puissance_valeurs"])
	var base := Generateur.generer("guerrier", 7, 30, Generateur.PAR_DEFAUT, donnees)
	assert_eq(base.rang, 0, "classe de base : rang 0")
	assert_eq(base.pv_base, 1120, "classe de base : ses PV")
	assert_almost(base.k, 0.8328, "classe de base : son k")
	assert_eq(base.sprite, "guerrier", "classe de base : son sprite")
	assert_eq(_allumes(base), 30, "niveau 30 : 30 points placés")
	var evo := Generateur.generer("champion", 7, 30, Generateur.PAR_DEFAUT, donnees)
	assert_eq(evo.rang, 1, "évolution : rang 1")
	assert_eq(evo.nom, "Champion", "son nom")
	assert_eq(evo.role, "front", "son rôle")
	assert_eq(evo.sprite, "guerrier", "le sprite de sa lignée")
	assert_eq(evo.pv_base, roundi(1120.0 * p_pv), "PV × puissance")
	assert_almost(evo.k, 0.8328 * p_val, "k × puissance")
	assert_eq(evo.voies.size(), 5, "cinq voies")
	assert_eq(_allumes(evo), 0, "niveau 30 : roue vide (le moyeu et les N1 seulement)")
	assert_eq(_allumes(Generateur.generer("champion", 7, 35, Generateur.PAR_DEFAUT, donnees)), 5, "niveau 35 : 5 points")
	assert_eq(_allumes(Generateur.generer("champion", 7, 60, Generateur.PAR_DEFAUT, donnees)), 30, "niveau 60 : 30 points")
	# L'allumage du joueur : au plus ses points.
	var liste: Array[String] = ["v1.n2", "v1.n3", "v2.n2"]
	assert_eq(_allumes(Generateur.generer("champion", 7, 32, liste, donnees)), 2, "niveau 32 : deux des trois nœuds demandés")
	# Un rôle changé : le Paladin est Front, le Berserker Dégâts.
	assert_eq(Generateur.generer("paladin", 1, 30, Generateur.PAR_DEFAUT, donnees).role, "front", "le Paladin est Front")
	assert_eq(Generateur.generer("berserker", 1, 30, Generateur.PAR_DEFAUT, donnees).role, "degats", "le Berserker est Dégâts")
	# Le rang 2 : deux sauts de puissance, le sprite de la lignée.
	var deux := Generateur.generer("parangon", 7, 60, Generateur.PAR_DEFAUT, donnees)
	assert_eq(deux.rang, 2, "rang 2")
	assert_eq(deux.sprite, "guerrier", "le sprite de la lignée")
	assert_eq(deux.pv_base, roundi(1120.0 * p_pv * p_pv), "PV × puissance²")
	assert_eq(_allumes(deux), 0, "niveau 60 : roue vide")
	assert_eq(_allumes(Generateur.generer("parangon", 7, 90, Generateur.PAR_DEFAUT, donnees)), 30, "niveau 90 : 30 points")
	# Sérialisation : le rang survit.
	var copie := Destin.depuis_dict(evo.vers_dict())
	assert_eq(copie.rang, 1, "le rang est sauvegardé")
	assert_eq(JSON.stringify(copie.vers_dict()), JSON.stringify(evo.vers_dict()), "aller-retour identique")
	# Les formes sont tirées avec la graine : même graine, même roue.
	assert_eq(JSON.stringify(Generateur.generer("champion", 7, 30, Generateur.PAR_DEFAUT, donnees).voies), JSON.stringify(evo.voies), "même graine, même roue")


func _allumes(d: Destin) -> int:
	var n := 0
	for voie in d.voies:
		for r in range(1, 4):
			if bool(voie["noeuds"][r]["allume"]):
				n += 1
		for e in voie["eclats"]:
			if bool(e):
				n += 1
	return n


# Au-delà du niveau 30, les Échos sont des évolutions de leur rôle, et le trio garde ses trois rôles ; un joueur
# évolué dont le rôle a changé reçoit les Échos des deux autres rôles.
func test_echos_et_adversaires_evolues() -> void:
	for graine in [1, 2, 77]:
		var echos := Trio.echos("champion", graine, 35, donnees)
		var roles := ["front"]
		for x in echos:
			assert_eq(x.rang, 1, "%s : un Écho évolué" % x.classe_id)
			assert_eq(_allumes(x), 5, "%s : au niveau du joueur" % x.classe_id)
			roles.append(x.role)
		roles.sort()
		assert_eq(roles, ["degats", "front", "soutien"], "graine %d : les trois rôles" % graine)
		for x in Trio.echos("guerrier", graine, 30, donnees):
			assert_eq(x.rang, 0, "%s : jusqu'au niveau 30, des classes de base" % x.classe_id)
	# Le Paladin (Front, venu du Prêtre) reçoit un Dégâts et un Soutien.
	var roles_paladin := Trio.roles_des_echos("paladin", donnees)
	assert_eq(roles_paladin, ["degats", "soutien"] as Array[String], "le Paladin est servi comme un Front")
	assert_eq(Trio.classes_du_role("front", donnees, 1).size(), 10, "dix évolutions Front (une par classe)")
	assert_eq(Trio.classes_du_role("front", donnees, 2).size(), 30, "trente évolutions Front de rang 2 (une par évolution de rang 1)")
	var d2 := _avec_rang_2()
	for x in Trio.echos("parangon", 3, 65, d2):
		assert_eq(x.rang, 2, "%s : au niveau 65, des Échos de rang 2" % x.classe_id)
	var haut := Arene.adversaire(75, 9, d2)
	assert_eq(Evolution.rang(str(haut["classe"]), d2), 2, "un adversaire de rang 2 au niveau 75")
	assert_true(int(Arene.adversaire(90, 9, d2)["niveau"]) <= 90, "jamais au-delà du niveau 90")
	assert_true(int(Arene.adversaire(90, 9, donnees)["niveau"]) <= 60, "en version 1, jamais au-delà du niveau 60")
	assert_eq(Evolution.rang(str(Arene.adversaire(75, 9, donnees)["classe"]), donnees), 1, "en version 1, un adversaire de rang 1 au plus")
	assert_eq(Trio.classes_du_role("front", donnees), ["guerrier", "pugiliste"] as Array[String], "les Fronts de base ne changent pas")
	# L'Arène : un adversaire au-delà du niveau 30 est une évolution ; en dessous, une classe de base.
	var evolues := 0
	for graine in range(1, 41):
		var adv := Arene.adversaire(45, graine, donnees)
		assert_between(float(adv["niveau"]), 43.0, 47.0, "graine %d : niveau à ±2" % graine)
		assert_eq(Evolution.rang(str(adv["classe"]), donnees), 1, "graine %d : un adversaire évolué" % graine)
		var trio := Arene.trio_adverse(adv, donnees)
		assert_eq(trio.size(), 3, "son trio")
		for x in trio:
			if x.rang == 1:
				evolues += 1
		var bas := Arene.adversaire(10, graine, donnees)
		assert_eq(Evolution.rang(str(bas["classe"]), donnees), 0, "graine %d : en dessous, une classe de base" % graine)
	assert_eq(evolues, 120, "tout le trio adverse est évolué")
	# À la frontière : un joueur de niveau 30 peut tomber sur un adversaire de 31 ou 32, évolué.
	var frontiere := {}
	for graine in range(1, 61):
		var adv := Arene.adversaire(30, graine, donnees)
		frontiere[Evolution.rang(str(adv["classe"]), donnees)] = true
		assert_true(int(adv["niveau"]) <= 32, "jamais au-delà de ±2")
	assert_true(frontiere.has(0) and frontiere.has(1), "au niveau 30, des deux côtés de la frontière")


# Le garde-fou de Gautier : un évolué à roue vide (au niveau de son évolution, 30 ou 60, zéro point) bat son parent un
# niveau en dessous (29 ou 59 points), pour chacune des soixante évolutions, sur deux graines et dans les deux sens :
# presque toujours en 1 contre 1, le plus souvent en trio (les Échos des deux camps sont du rang du parent) ; deux graines
# pour le rang 1, une pour le rang 2 (quatre-vingt-dix roues). Le réglage fin est pour la phase 9.
func test_evolue_vide_bat_niveau_29() -> void:
	var solo := [0, 0]
	var trio := [0, 0]
	for evo in donnees.ordre_evolutions:
		var classe := Evolution.parent(evo, donnees)
		var nv := Evolution.niveau_max(Evolution.rang(evo, donnees) - 1, donnees)
		for graine in ([11, 12] if Evolution.rang(evo, donnees) == 1 else [11]):
			for evo_en_premier in [true, false]:
				var a := Generateur.generer(evo, graine, nv, Generateur.PAR_DEFAUT, donnees)
				var b := Generateur.generer(classe, graine + 1000, nv - 1, Generateur.PAR_DEFAUT, donnees)
				solo[0] += 1 if _gagne([a], [b], evo_en_premier, nv) else 0
				solo[1] += 1
				trio[0] += 1 if _gagne(Trio.camp(a, nv, donnees), Trio.camp(b, nv - 1, donnees), evo_en_premier, nv) else 0
				trio[1] += 1
	assert_true(float(solo[0]) / float(solo[1]) >= 0.9, "en 1 contre 1, l'évolué à roue vide gagne au moins 9 fois sur 10 (%d sur %d)" % [solo[0], solo[1]])
	assert_true(float(trio[0]) / float(trio[1]) >= 0.6, "en trio, l'évolué à roue vide gagne au moins 6 fois sur 10 (%d sur %d)" % [trio[0], trio[1]])


## Les données avec le rang 2 ouvert (data/rules.json le ferme en version 1 : rang_max 1).
func _avec_rang_2() -> Donnees:
	var d := Donnees.charger()
	d.regles["evolution"]["rang_max"] = 2
	return d


func _gagne(camp_evo: Array, camp_base: Array, evo_en_premier: bool, niveau: int) -> bool:
	var e := Regles.nouveau_combat(camp_evo if evo_en_premier else camp_base, camp_base if evo_en_premier else camp_evo, niveau, "pvp", donnees)
	while not e.fini and e.tour <= 100:
		e = Regles.resoudre_tour(e, IA.declarer(e, []))
	return e.fini and e.vainqueur == ("a" if evo_en_premier else "b")
