## Le boss à paliers (GDD V2, § 8.5 ; plan, PR 6.4 en solo) : un palier verrouille le boss, la bonne action le libère,
## une mauvaise non, trop long c'est perdu et « ce qui a manqué » est dit.
extends "res://tests/test_case.gd"


## Une descente du Terrier au niveau 12 (un Guerrier, donc un Front en a1), déjà au bout de la route du boss.
func _boss(donjon_id: String = "terrier", classe: String = "guerrier") -> Donjon:
	var dj := Donjon.commencer(donjon_id, Trio.camp(Generateur.generer(classe, 3, 12, Generateur.PAR_DEFAUT, donnees), 12, donnees), 12, 5, 0, donnees)
	var route := Donjon.route_boss(donjon_id, 0, donnees)
	for k in range(3):
		var ordre := Donjon.ordre_portes(5, donjon_id, dj.chemin, donnees)
		dj.choisir(ordre.find(route[k]))
		dj.phase = "portes"
	dj.phase = "combat"
	dj.finale = true
	return dj


func test_donnees_du_boss() -> void:
	for erreur in donnees.erreurs:
		failures.append(erreur)
	for id in donnees.boss["boss"]:
		assert_eq(str(donnees.bestiaire["monstres"][id]["rang"]), "gardien", id + " : un Gardien du bestiaire")
		var precedent := 1.0
		for p in donnees.boss["boss"][id]["paliers"]:
			assert_true(float(p["pv"]) < precedent and float(p["pv"]) > 0.0, id + " : des paliers décroissants")
			precedent = float(p["pv"])
			assert_true(donnees.boss["solutions"].has(str(p["solution"])), id + " : une solution connue")
	var d2 := Donnees.charger()
	d2.boss["boss"]["dragonnet"]["paliers"][0]["solution"] = "danser"
	d2.boss["boss"]["liche"]["paliers"][1]["pv"] = 0.9
	d2.erreurs.clear()
	d2._valider_boss()
	assert_eq(d2.erreurs.size(), 2, "deux erreurs signalées (%s)" % str(d2.erreurs))


func test_palier_verrouille_et_solution() -> void:
	var dj := _boss()
	assert_true(dj.combat_du_boss(), "au bout de la route du boss")
	assert_eq(dj.paliers().size(), 2, "le dragonnet a deux paliers")
	var e := dj.combat()
	var pv_max := int(e.fiche("b1")["pv_max"])
	assert_eq(str(e.fiche("a1")["role"]), "front", "a1 est un Front")
	# Rien tant qu'il est haut.
	assert_eq(dj.apres_tour(e)["verrou"], -1, "au départ, pas de verrou")
	# Sous 66 % : le verrou se pose, les PV reviennent au palier.
	e.perso("b1")["pv"] = Regles.plancher(float(pv_max) * 0.5)
	var r := dj.apres_tour(e)
	assert_eq(int(r["verrou"]), 0, "le premier palier verrouille")
	assert_eq(int(e.perso("b1")["pv"]), Regles.plancher(float(pv_max) * 0.66), "ses PV reviennent au palier")
	assert_true(str(r["message"]).begins_with("Le dragonnet replie"), "le texte du palier")
	# Un tour sans la solution (le Front joue une voie, pas son geste) : toujours verrouillé, même frappé.
	var decl := {"a1": jouer(e, "a1", 0, "b1"), "a2": moyeu("a2", "b1"), "a3": moyeu("a3", "b1"), "b1": moyeu("b1", "a1")}
	e = tour(e, decl)
	r = dj.apres_tour(e)
	assert_eq(int(r["verrou"]), 0, "sans le geste du Front, le verrou tient")
	assert_eq(int(e.perso("b1")["pv"]), Regles.plancher(float(pv_max) * 0.66), "les PV restent au palier")
	# Le geste du Front (son moyeu sur le boss) : le verrou saute.
	decl = {"a1": moyeu("a1", "b1"), "a2": moyeu("a2", "b1"), "a3": moyeu("a3", "b1"), "b1": moyeu("b1", "a1")}
	e = tour(e, decl)
	r = dj.apres_tour(e)
	assert_true(bool(r["deverrouille"]), "le geste du Front libère le boss")
	assert_eq(int(r["verrou"]), -1, "plus de verrou")
	assert_eq(dj.secrets_trouves(), ["geste_front"] as Array[String], "le secret est trouvé")
	# Sous 33 % : le second palier (un contrôle) ; un coup qui l'abat ne l'abat pas.
	e.perso("b1")["pv"] = 1
	r = dj.apres_tour(e)
	assert_eq(int(r["verrou"]), 1, "le second palier verrouille")
	assert_eq(int(e.perso("b1")["pv"]), Regles.plancher(float(pv_max) * 0.33), "revenu à 33 %")
	# Un coup mortel pendant le verrou : il se relève au palier.
	e.perso("b1")["pv"] = 0
	e.perso("b1")["ko"] = true
	e.fini = true
	e.vainqueur = "a"
	r = dj.apres_tour(e)
	assert_false(e.fini, "le combat continue")
	assert_false(bool(e.perso("b1")["ko"]), "le boss se relève")
	assert_eq(int(e.perso("b1")["pv"]), Regles.plancher(float(pv_max) * 0.33), "au palier")
	# Trop long : perdu, et ce qui a manqué est dit.
	e.tour = int(donnees.boss["tours_max"]) + 1
	r = dj.apres_tour(e)
	assert_true(e.fini and e.vainqueur == "b", "au-delà de la limite, le trio tombe")
	assert_true(dj.manque.begins_with("Il fallait le clouer"), "ce qui a manqué, en termes vagues")


func test_combat_de_boss_joue_par_l_ia() -> void:
	# Le combat se termine (gagné, ou perdu par la limite) et ne dépasse jamais la limite.
	for graine in [1, 2, 3]:
		var dj := Donjon.commencer("terrier", Trio.camp(Generateur.generer("pugiliste", graine, 20, Generateur.PAR_DEFAUT, donnees), 20, donnees), 20, graine, 0, donnees)
		var route := Donjon.route_boss("terrier", 0, donnees)
		for k in range(3):
			var ordre := Donjon.ordre_portes(graine, "terrier", dj.chemin, donnees)
			dj.choisir(ordre.find(route[k]))
			dj.phase = "portes"
		dj.phase = "combat"
		dj.finale = true
		var e := dj.combat()
		var tours := 0
		while not e.fini and tours < 100:
			e = tour(e, IA.declarer(e))
			dj.apres_tour(e)
			tours += 1
		assert_true(e.fini, "graine %d : le combat de boss se termine" % graine)
		assert_true(e.tour <= int(donnees.boss["tours_max"]) + 1, "graine %d : jamais au-delà de la limite" % graine)
		dj.terminer(e)
		if e.vainqueur == "a":
			assert_eq(dj.resultat, "boss", "graine %d : le boss est vaincu" % graine)
			assert_eq(dj.paliers_passes.size(), 2, "graine %d : les deux paliers passés" % graine)
	# Un combat d'élite ou de vague n'a pas de palier.
	var dj2 := Donjon.commencer("terrier", Trio.camp(Generateur.generer("mage", 1, 12, Generateur.PAR_DEFAUT, donnees), 12, donnees), 12, 9, 0, donnees)
	dj2.choisir(0)
	var e2 := dj2.combat()
	e2.perso("b1")["pv"] = 1
	assert_eq(int(dj2.apres_tour(e2)["verrou"]), -1, "une vague : pas de palier")
	assert_eq(int(e2.perso("b1")["pv"]), 1, "ses PV ne bougent pas")
