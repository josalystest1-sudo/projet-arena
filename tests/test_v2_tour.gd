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


# Les Faveurs de la Tour (GDD V2, § 6 ; décision de Gautier du 29 octobre : des petits bonus cumulables, dans la Tour
# seulement) : chacune change ce qu'elle doit, et rien d'autre.
func test_faveurs_de_la_tour() -> void:
	var membres := Trio.camp(Generateur.generer("guerrier", 5, 12), 12, donnees)
	var sans := Tour.commencer_camp(membres, 12, 77, donnees)
	var avec := Tour.commencer_camp(membres, 12, 77, donnees, 1, {"vigueur": 2, "puissance": 1, "repit": 1, "egide": 1, "effroi": 3, "savoir": 2, "inconnue": 1, "nulle": 0})
	assert_eq(avec.faveurs, {"vigueur": 2, "puissance": 1, "repit": 1, "egide": 1, "effroi": 3, "savoir": 2, "inconnue": 1}, "les Faveurs de la montée (les cumuls à zéro ignorés)")
	var e0 := sans.combat()
	var e := avec.combat()
	for id in ["a1", "a2", "a3"]:
		var base := int(e0.fiche(id)["pv_max"])
		assert_eq(int(e.fiche(id)["pv_max"]), Regles.plancher(float(base) * 1.08), id + " : Vigueur ×2, +8 % de PV max")
		assert_eq(int(e.perso(id)["pv"]), int(e.fiche(id)["pv_max"]), id + " : tous ses PV au départ")
		assert_almost(float(e.fiche(id)["k"]), float(e0.fiche(id)["k"]) * 1.04, id + " : Puissance, multiplicateur de classe × 1,04")
		assert_eq(int(e.perso(id)["barriere"]), Regles.plancher(float(e.fiche(id)["pv_max"]) * 0.08), id + " : Égide, une barrière de 8 % des PV max")
		assert_eq(int(e.perso(id)["barrier_until"]), 3, id + " : la barrière de l'Égide tient 3 tours")
		assert_eq(int(e0.perso(id)["barriere"]), 0, id + " : sans Faveur, pas de barrière")
	assert_almost(Regles.valeur(e, "a1", 0, 1, 100.0), Regles.valeur(e0, "a1", 0, 1, 100.0) * 1.04, "Puissance : un coup vaut 4 % de plus")
	for id in e.vivants("b"):
		assert_almost(e.valeur_etat(id, "affaiblissement"), 0.3, id + " : Effroi ×3, les monstres affaiblis de 30 %")
		assert_eq(e.tours_restants(id, "affaiblissement"), 2, id + " : pendant 2 tours")
		assert_eq(int(e.fiche(id)["pv_max"]), int(e0.fiche(id)["pv_max"]), id + " : les monstres gardent leurs PV")
		assert_almost(float(e.fiche(id)["k"]), float(e0.fiche(id)["k"]), id + " : et leur force")
		assert_eq(int(e.perso(id)["barriere"]), 0, id + " : et n'ont pas de barrière")
		assert_true(e0.perso(id)["etats"].is_empty(), id + " : sans Faveur, pas d'état")
	# Le Répit : 25 % des PV max rendus au lieu de 20.
	var max_a1 := int(e.fiche("a1")["pv_max"])
	e.perso("a1")["pv"] = 100
	e.fini = true
	e.vainqueur = "a"
	avec.terminer(e)
	assert_eq(int(avec.pv["a1"]), 100 + Regles.plancher(0.25 * float(max_a1)), "Répit : 25 % des PV max rendus entre deux étages")
	var e2 := avec.combat()
	assert_eq(int(e2.perso("a1")["pv"]), 100 + Regles.plancher(0.25 * float(max_a1)), "l'étage suivant repart avec ces PV")
	assert_eq(int(e2.perso("a1")["barriere"]), Regles.plancher(float(max_a1) * 0.08), "et une nouvelle Égide")
	# L'Effroi s'éteint après 2 tours, et l'étage se joue jusqu'au bout.
	var tours := 0
	while not e2.fini and tours < 300:
		e2 = tour(e2, IA.declarer(e2))
		tours += 1
		if e2.tour == 3 and not e2.fini:
			for id in e2.vivants("b"):
				assert_false(e2.a_etat(id, "affaiblissement"), id + " : l'Effroi est passé au tour 3")
	assert_true(e2.fini, "un étage avec Faveurs se termine")
	# Hors de la Tour, rien : un duel des mêmes membres a les valeurs de base.
	var pvp := Regles.nouveau_combat(membres, Trio.camp(Generateur.generer("mage", 9, 12), 12, donnees), 12, "pvp", donnees)
	assert_eq(int(pvp.fiche("a1")["pv_max"]), int(e0.fiche("a1")["pv_max"]), "en duel, les PV de base")
	assert_eq(int(pvp.perso("a1")["barriere"]), 0, "en duel, pas de barrière")
	assert_true(pvp.perso("b1")["etats"].is_empty(), "en duel, pas d'Effroi")
	# Les valeurs cumulées et leur plafond.
	assert_almost(Tour.valeur_faveur("effroi", 7, donnees), 0.5, "l'Effroi plafonne à 50 %")
	assert_almost(Tour.valeur_faveur("vigueur", 10, donnees), 0.4, "la Vigueur ne plafonne pas")
	assert_almost(Tour.valeur_faveur("savoir", 0, donnees), 0.0, "aucun cumul : rien")
	assert_almost(Tour.valeur_faveur("inconnue", 3, donnees), 0.0, "une Faveur inconnue ne vaut rien")
	assert_eq(Tour.texte_faveur("vigueur", 2, donnees), "Vigueur ×2 : +8 % de PV max pour tout le trio", "le texte d'une Faveur cumulée")
	assert_eq(Tour.texte_faveur("savoir", 1, donnees), "Savoir : +10 % d'XP dans la Tour", "le texte d'une Faveur simple")
	assert_true("50 %" in Tour.texte_faveur("effroi", 9, donnees), "le texte tient compte du plafond")


# Les six Faveurs des données, les trois proposées à un Gardien, et « la première fois ».
func test_faveurs_proposees_au_gardien() -> void:
	assert_eq(donnees.faveurs.size(), 6, "six Faveurs")
	for id in Donnees.FAVEURS:
		assert_true(donnees.faveurs.has(id), id + " : dans les données")
	for erreur in donnees.erreurs:
		failures.append(erreur)
	var t := Tour.commencer_camp(Trio.camp(Generateur.generer("mage", 5, 12), 12, donnees), 12, 77, donnees)
	var vues := {}
	for n in [5, 10, 15, 20, 25, 30, 35, 40]:
		var prop := t.proposer_faveurs(n)
		assert_eq(prop.size(), 3, "étage %d : trois Faveurs proposées" % n)
		assert_eq(prop, t.proposer_faveurs(n), "étage %d : les mêmes à chaque fois" % n)
		var distinctes := {}
		for id in prop:
			assert_true(donnees.faveurs.has(id), "étage %d : une Faveur connue (%s)" % [n, id])
			distinctes[id] = true
		assert_eq(distinctes.size(), 3, "étage %d : trois différentes" % n)
		vues[",".join(prop)] = true
	assert_true(vues.size() >= 2, "les propositions changent d'un Gardien à l'autre")
	var autre := Tour.commencer_camp(t.membres, 12, 78, donnees)
	var differentes := false
	for n in [5, 10, 15, 20, 25]:
		if autre.proposer_faveurs(n) != t.proposer_faveurs(n):
			differentes = true
	assert_true(differentes, "une autre montée propose d'autres Faveurs")
	assert_true(Tour.gardien_premiere_fois(5, 1, 5), "le Gardien 5, palier 1 : première fois")
	assert_false(Tour.gardien_premiere_fois(5, 6, 5), "le Gardien 5, palier 6 : déjà battu")
	assert_false(Tour.gardien_premiere_fois(4, 1, 5), "l'étage 4 : pas un Gardien")
	assert_true(Tour.gardien_premiere_fois(10, 6, 5), "le Gardien 10, palier 6 : première fois")
	assert_false(Tour.gardien_premiere_fois(10, 11, 5), "le Gardien 10, palier 11 : déjà battu")
	assert_false(Tour.gardien_premiere_fois(10, 16, 5), "le Gardien 10, palier 16 : déjà battu")


# Les murs (décision de Gautier du 31 octobre) : un grand Gardien tous les 10 étages, un Gardien moindre tous les 5 ;
# hors Gardiens, chaque étage est plus dur que le précédent ; un Gardien est plus fort que les cinq étages qui le suivent
# (le Gardien moindre compris, après un grand), et le Gardien suivant est plus fort que lui.
func test_murs() -> void:
	var t := _tour()
	assert_eq(t.gardien_de(4), "", "l'étage 4 : ordinaire")
	assert_eq(t.gardien_de(5), "gardien", "l'étage 5 : un Gardien")
	assert_eq(t.gardien_de(10), "grand", "l'étage 10 : un grand Gardien")
	assert_eq(t.gardien_de(15), "gardien", "l'étage 15 : un Gardien moindre")
	assert_eq(t.gardien_de(20), "grand", "l'étage 20 : un grand Gardien")
	assert_eq(t.etage_force(7), 7, "un étage ordinaire a sa propre force")
	assert_true(t.etage_force(5) > 10, "le Gardien 5 a la force d'un étage au-delà du 10")
	assert_true(t.etage_force(10) > t.etage_force(15), "le grand Gardien 10 est plus fort que le Gardien moindre 15")
	for n in range(1, 60):
		var sorte := t.gardien_de(n)
		if sorte == "":
			if n > 1 and t.gardien_de(n - 1) == "":
				assert_true(t.niveau_etage(n) >= t.niveau_etage(n - 1) and t.fourchette(n).x >= t.fourchette(n - 1).x, "étage %d : au moins aussi dur que le %d" % [n, n - 1])
			if n > 2 and t.gardien_de(n - 1) == "" and t.gardien_de(n - 2) == "":
				assert_true(t.niveau_etage(n) > t.niveau_etage(n - 2), "étage %d : plus dur que le %d" % [n, n - 2])
		else:
			for k in range(1, 6):
				if sorte == "gardien" and t.gardien_de(n + k) == "grand":
					assert_true(t.niveau_etage(n + k) > t.niveau_etage(n), "le grand Gardien %d est plus fort que le Gardien %d" % [n + k, n])
				else:
					assert_true(t.niveau_etage(n + k) < t.niveau_etage(n), "l'étage %d est moins fort que le Gardien %d" % [n + k, n])
			assert_true(t.niveau_etage(n + 5) < t.niveau_etage(n) or t.gardien_de(n + 5) == "grand", "le Gardien %d tient cinq étages" % n)
	assert_true(t.niveau_etage(9) > t.niveau_etage(7), "l'étage 9 est plus dur que le 7")
	assert_true(t.butin(10, true).has("rarete"), "un grand Gardien lâche un objet")
	assert_eq(str(t.butin(10, true)["rarete"]), "epique", "épique, comme un Gardien")
	assert_eq(Tour.sorte_gardien(30, {"gardien_tous_les": 5, "grand_gardien_tous_les": 10}), "grand", "la sorte se lit dans les règles")
	assert_eq(Tour.sorte_gardien(30, {"gardien_tous_les": 5}), "gardien", "sans grand Gardien : un Gardien")
	assert_eq(Tour.sorte_gardien(30, {}), "", "sans Gardien du tout")


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
