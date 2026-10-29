## Combat V2 : l'IA (docs/SPEC-COMBAT-V2.md, section 14, tests 37 à 40).
extends "res://tests/test_case.gd"


# 37. Déterminisme : même état, même choix.
func test_37_determinisme() -> void:
	var e := combat([Generateur.generer("guerrier", 11, 15), Generateur.acolyte("guerrier", 11, 15)], [Generateur.generer("mage", 12, 15), Generateur.acolyte("mage", 12, 15)], 15)
	for t in range(5):
		var decl := IA.declarer(e)
		var reference := JSON.stringify(decl)
		for i in range(50):
			if JSON.stringify(IA.declarer(e.copie())) != reference:
				failures.append("tour %d : choix différent à l'essai %d" % [e.tour, i])
				break
		e = tour(e, decl)
	assert_eq(e.tour, 6, "cinq tours joués")


# 38. L'IA ne soigne jamais un allié à PV pleins.
func test_38_ne_soigne_jamais_a_pv_pleins() -> void:
	var soigneur := essai([[[soin(200)]], [[deg(10)]]], 1000, [soin(60)])
	var e := duel_essai(soigneur)
	var a := IA.choisir(e, "a1")
	assert_eq([a["source"], a["voie"]], ["voie", 1], "à PV pleins : ni le soin ni le moyeu qui soigne")
	e.perso("a2")["pv"] = 500
	a = IA.choisir(e, "a1")
	assert_eq([a["source"], a["voie"], a["cible_alliee"]], ["voie", 0, "a2"], "un allié blessé : le soin, sur lui")
	# Avec les vraies classes : un Prêtre au tour 1, tout le monde à PV pleins.
	var p := combat([Generateur.generer("pretre", 3, 30), Generateur.acolyte("pretre", 3, 30)], [Generateur.generer("guerrier", 4, 30), Generateur.acolyte("guerrier", 4, 30)], 30)
	var choix := IA.choisir(p, "a1")
	for ef in Regles.noeud_de(p, choix)["effets"]:
		assert_ne(ef["type"], "soin", "le Prêtre ne joue pas un soin à PV pleins (%s)" % Regles.noeud_de(p, choix)["nom"])


# 39. Une menace d'échéance 1 : un contrôle plutôt que des dégâts égaux.
func test_39_controle_sur_une_menace() -> void:
	# Gelé 1 vaut 80 dans la grille, autant que 80 dégâts ; à égalité, la dernière voie (les dégâts) l'emporte.
	var ia := essai([[[etat("gele", 1)]], [[deg(80)]]])
	var menace := essai([[[deg(10)], [deg(10)], [deg(140)], [deg(230)]]])
	var e := duel_essai(ia, null, menace)
	assert_eq(IA.choisir(e, "a1")["voie"], 1, "sans menace : les dégâts")
	e.perso("b1")["jalons"][0] = 2
	assert_true(IA.a_menace_imminente(e, "b1"), "le joueur adverse a un N3 d'échéance 1")
	var a := IA.choisir(e, "a1")
	assert_eq([a["voie"], a["cible_ennemie"]], [0, "b1"], "avec une menace : Gelé sur celui qui menace")


# 40. Le moyeu seulement si rien d'autre n'est légal, ou meilleur.
func test_40_moyeu_en_dernier_recours() -> void:
	var e := duel_essai(essai([[[deg(30)]]], 1000, [deg(55)]))
	assert_eq(IA.choisir(e, "a1")["source"], "voie", "N1 (30 + 15) plutôt que le moyeu (55 − 40)")
	poser(e, "a1", "gele")
	assert_eq(IA.choisir(e, "a1")["source"], "moyeu", "Gelé : seul le moyeu")
	var fort := duel_essai(essai([[[deg(30)]]], 1000, [deg(200)]))
	assert_eq(IA.choisir(fort, "a1")["source"], "moyeu", "un moyeu bien meilleur (200 − 40) reste joué")
	var vide := duel_essai(essai([[[soin(100)]]], 1000, [soin(60)]))
	assert_eq(IA.choisir(vide, "a1")["source"], "moyeu", "tout est retiré (soins à PV pleins) : le moyeu")


# Un combat IA contre IA avec les vraies classes va jusqu'au bout.
func test_ia_contre_ia_finit() -> void:
	for g in range(1, 21):
		var classes: Array = donnees.ordre_classes
		var ca: String = classes[g % 10]
		var cb: String = classes[(g * 3 + 1) % 10]
		var e := combat([Generateur.generer(ca, g, 30), Generateur.acolyte(ca, g, 30)], [Generateur.generer(cb, g + 100, 30), Generateur.acolyte(cb, g + 100, 30)], 30)
		while not e.fini and e.tour <= 60:
			e = tour(e, IA.declarer(e))
		assert_true(e.fini, "%s contre %s (graine %d) : fini avant le tour 60" % [ca, cb, g])
