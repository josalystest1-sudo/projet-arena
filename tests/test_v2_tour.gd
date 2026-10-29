## Combat V2 : la Tour et son bestiaire (docs/SPEC-COMBAT-V2.md, section 14, tests 46 à 48).
extends "res://tests/test_case.gd"


func _tour(classe: String = "guerrier", niveau: int = 10, graine: int = 99) -> Tour:
	return Tour.commencer(Generateur.generer(classe, graine, niveau), Generateur.acolyte(classe, graine, niveau), niveau, graine, donnees)


# 46. Entre deux étages : +20 % des PV max ; un acolyte KO revient avec 20 %.
func test_46_pv_entre_les_etages() -> void:
	var t := _tour()
	var e := t.combat()
	var max_a1 := int(e.fiche("a1")["pv_max"])
	var max_a2 := int(e.fiche("a2")["pv_max"])
	e.perso("a1")["pv"] = 100
	e.perso("a2")["pv"] = 0
	e.perso("a2")["ko"] = true
	e.fini = true
	e.vainqueur = "a"
	t.terminer(e)
	assert_eq(t.etage, 2, "étage suivant")
	var e2 := t.combat()
	assert_eq(int(e2.perso("a1")["pv"]), 100 + Regles.plancher(0.2 * max_a1), "le joueur récupère 20 % de ses PV max")
	assert_eq(int(e2.perso("a2")["pv"]), Regles.plancher(0.2 * max_a2), "l'acolyte KO revient avec 20 %")
	assert_false(bool(e2.perso("a2")["ko"]), "l'acolyte n'est plus KO")
	for id in ["a1", "a2"]:
		assert_eq(e2.perso(id)["jalons"], [0, 0, 0, 0, 0].slice(0, e2.nb_voies(id)), id + " : jalons remis à 0")
		assert_true(e2.perso(id)["etats"].is_empty(), id + " : états retirés")
	e2.perso("a1")["pv"] = 3000
	e2.fini = true
	e2.vainqueur = "a"
	t.terminer(e2)
	assert_eq(int(t.pv["a1"]), max_a1, "jamais au-dessus des PV max")
	var e3 := t.combat()
	e3.fini = true
	e3.vainqueur = "b"
	t.terminer(e3)
	assert_true(t.fini, "le duo tombe : la montée s'arrête")
	assert_eq(t.atteint, 3, "étage atteint : celui où il est tombé")


# 47. Les règles d'étage transposées : un Gardien tous les 5 étages, une famille par étage, abandon au tour limite
# (data/tour.json), pas de mort subite.
func test_47_regles_d_etage() -> void:
	var t := _tour()
	var monstres: Dictionary = donnees.bestiaire["monstres"]
	for n in range(1, 16):
		var ids := t.tirer_etage(n)
		var gardiens := 0
		var familles := {}
		for id in ids:
			familles[monstres[id]["famille"]] = true
			if monstres[id]["rang"] == "gardien":
				gardiens += 1
		var gardien_tient := t.fourchette(n).y >= 1.5
		assert_eq(gardiens, 1 if n % 5 == 0 and gardien_tient else 0, "étage %d : Gardien tous les 5 étages (s'il tient dans la force de l'étage)" % n)
		assert_eq(familles.size(), 1, "étage %d : une seule famille (%s)" % [n, str(ids)])
	var e := t.combat()
	assert_eq(e.mode, "tour", "combat de Tour")
	e.tour = 200
	assert_eq(Regles.mort_subite(e), 1.0, "pas de mort subite à la Tour, ni de limite de tours")
	e.fini = true
	e.vainqueur = "a"
	t.terminer(e)
	assert_eq(t.etage, 2, "l'étage est franchi")
	assert_false(t.fini, "la montée continue")


# 48. Un étage tire 1 à 6 monstres, dont la somme des multiplicateurs de PV tombe dans la fourchette de l'étage (la
# spécification disait 1,6 à 2,4 ; décision de Gautier du 28 octobre : elle monte avec les étages).
func test_48_tirage_d_un_etage() -> void:
	for graine in range(1, 41):
		var t := _tour("mage", 5, graine * 31)
		for n in range(1, 21):
			var ids := t.tirer_etage(n)
			var somme := 0.0
			for id in ids:
				somme += float(donnees.bestiaire["monstres"][id]["pv_mult"])
			var f := t.fourchette(n)
			assert_between(ids.size(), 1, 6, "graine %d, étage %d : nombre de monstres" % [graine, n])
			assert_between(somme, f.x - 0.0001, f.y + 0.0001, "graine %d, étage %d : somme des multiplicateurs (%s)" % [graine, n, str(ids)])
			assert_eq(ids, t.tirer_etage(n), "même graine, même étage")
	var t10 := _tour()
	assert_true(t10.fourchette(10).x > t10.fourchette(1).x, "les monstres sont plus forts à l'étage 10 qu'à l'étage 1")
	var t := _tour()
	var m := t.monstres(1)
	var e := t.combat()
	for i in range(m.size()):
		var id := "b%d" % (i + 1)
		assert_eq(e.fiche(id)["place"], "ennemi", id + " : un ennemi de la Tour")
		assert_eq(int(e.fiche(id)["pv_max"]), Regles.plancher(float(m[i].pv_base) * m[i].pv_mult * Regles.multiplicateur_niveau(e) * (1.0 + m[i].bonus_pv())), id + " : PV de sa classe × pv_mult (ramené au niveau de l'étage) × niveau")
		assert_eq(e.nb_voies(id), donnees.bestiaire["monstres"][m[i].sprite]["voies"].size(), id + " : seulement ses voies")


# Le bestiaire : les 14 monstres d'avant, chacun une classe, des voies et un multiplicateur de PV.
func test_bestiaire_transpose() -> void:
	var monstres: Dictionary = donnees.bestiaire["monstres"]
	assert_eq(monstres.size(), 14, "14 monstres")
	for id in ["rat", "loup", "ours", "squelette", "goule", "necromancien", "feu_follet", "gelee", "golem", "gobelin", "chaman", "chef_gobelin", "dragonnet", "liche"]:
		assert_true(monstres.has(id), id + " transposé")
		assert_true(PixelSprites.SPRITES.has(id), id + " : son sprite")
	for erreur in donnees.erreurs:
		failures.append(erreur)


# Un étage joué par l'IA des deux côtés va jusqu'au bout.
func test_un_etage_joue_par_l_ia() -> void:
	for graine in range(1, 9):
		var t := _tour(donnees.ordre_classes[graine], 12, graine)
		var e := t.combat()
		while not e.fini and e.tour <= 300:
			e = tour(e, IA.declarer(e))
		assert_true(e.fini, "graine %d : l'étage se termine (sans limite de tours)" % graine)


# La Tour infinie (docs/GDD_V2.md, § 6) : un étage a la même force quel que soit le niveau du trio ; les étages lointains
# se génèrent ; les paliers.
func test_tour_infinie() -> void:
	var bas := Tour.commencer_camp(Trio.camp(Generateur.generer("mage", 5, 3), 3, donnees), 3, 77, donnees)
	var haut := Tour.commencer_camp(Trio.camp(Generateur.generer("mage", 5, 30), 30, donnees), 30, 77, donnees)
	for n in [1, 7, 15]:
		var eb := Regles.nouveau_combat(bas.membres, bas.monstres(n), 3, "tour", donnees)
		var eh := Regles.nouveau_combat(haut.membres, haut.monstres(n), 30, "tour", donnees)
		assert_eq(bas.tirer_etage(n), haut.tirer_etage(n), "étage %d : les mêmes monstres" % n)
		assert_true(absf(float(eb.fiche("b1")["pv_max"]) - float(eh.fiche("b1")["pv_max"])) <= 1.0, "étage %d : les mêmes PV au niveau 3 et au niveau 30" % n)
	assert_true(bas.niveau_etage(10) > bas.niveau_etage(1), "les monstres de l'étage 10 ont un plus haut niveau")
	for n in [50, 200, 1000]:
		var ids := bas.tirer_etage(n)
		assert_between(ids.size(), 1, 6, "étage %d : il se génère" % n)
		assert_true(not bas.monstres(n).is_empty(), "étage %d : ses monstres" % n)
	assert_eq(Tour.palier_apres(0, 5), 1, "rien franchi : on part de l'étage 1")
	assert_eq(Tour.palier_apres(4, 5), 1, "étage 4 franchi : toujours 1")
	assert_eq(Tour.palier_apres(5, 5), 6, "le Gardien de l'étage 5 franchi : palier 6")
	assert_eq(Tour.palier_apres(23, 5), 21, "étage 23 franchi : palier 21")
	assert_eq(Tour.paliers(12, 5), [1, 6, 11] as Array[int], "les paliers d'où repartir")
	var reprise := Tour.commencer_camp(Trio.camp(Generateur.generer("mage", 5, 12), 12, donnees), 12, 9, donnees, 11)
	var e := reprise.combat()
	assert_eq(reprise.etage, 11, "la montée reprend à l'étage 11")
	for id in ["a1", "a2", "a3"]:
		assert_eq(int(e.perso(id)["pv"]), int(e.fiche(id)["pv_max"]), id + " : tous ses PV au palier")
	reprise.arreter()
	assert_true(reprise.fini and reprise.atteint == 11, "arrêter entre deux étages : l'étage atteint est celui qui allait se jouer")


# À la Tour, les soins d'un monstre s'affaiblissent à chaque usage (× 0,75) ; pas ceux du trio, ni en duel.
func test_soins_des_monstres_qui_s_affaiblissent() -> void:
	var soigneur := essai([[[soin(400)]]])
	var e := combat([essai(), essai()], [soigneur, essai()], 1, "tour")
	var usure := float(donnees.regles["tour_soins_usure"])
	var vus: Array = []
	for i in range(3):
		e.perso("b2")["pv"] = 100
		e = tour(e, {"b1": jouer(e, "b1", 0, "", "b2"), "a1": moyeu("a1"), "a2": moyeu("a2"), "b2": moyeu("b2")})
		vus.append(int(e.perso("b2")["pv"]) - 100)
		e.perso("b1")["spent_until"][0] = [0, 0, 0, 0]
		e.perso("b1")["jalons"][0] = 0
	assert_eq(vus, [400, Regles.plancher(400.0 * usure), Regles.plancher(400.0 * usure * usure)], "400, puis ×0,75 à chaque soin")
	var d := duel_essai(null, null, essai([[[soin(400)]]]))
	d.perso("b2")["pv"] = 100
	d = tour(d, {"b1": jouer(d, "b1", 0, "", "b2")})
	assert_eq(int(d.perso("b2")["pv"]), 500, "en duel, pas d'usure")
