## Le trio : le joueur et ses deux Échos (docs/GDD_V2.md, § 4.3 et § 5 ; docs/PLAN.md, PR 1.1).
extends "res://tests/test_case.gd"

const Lib := preload("res://tools/equilibrage_lib.gd")


## Un trio d'essai : trois Destins d'essai, les deux derniers marqués Échos.
func trio_essai(a1: Destin = null, a2: Destin = null, a3: Destin = null) -> Array:
	var out := [a1 if a1 else essai(), a2 if a2 else essai(), a3 if a3 else essai()]
	out[1].echo = true
	out[2].echo = true
	return out


# Toujours un Front, un Dégâts et un Soutien ; les Échos sont des personnages entiers au niveau du joueur, tirés avec
# sa graine (même graine, mêmes Échos).
func test_composition_du_trio() -> void:
	for classe in donnees.ordre_classes:
		for graine in [1, 2, 77, 123456789]:
			var echos := Trio.echos(classe, graine, 12, donnees)
			assert_eq(echos.size(), 2, "%s : deux Échos" % classe)
			var roles := [str(donnees.classe(classe)["role"])]
			for x in echos:
				roles.append(x.role)
				assert_true(x.echo and not x.acolyte, "%s : un Écho est marqué Écho, pas acolyte" % x.classe_id)
				assert_eq(x.voies.size(), 5, "%s : une roue entière" % x.classe_id)
				# Au niveau du joueur, allumage par défaut : la même roue que celle d'un joueur de sa classe et de sa graine.
				var meme := Generateur.generer(x.classe_id, x.graine, 12, Generateur.PAR_DEFAUT, donnees)
				assert_eq(JSON.stringify(meme.voies), JSON.stringify(x.voies), "%s : allumé au niveau du joueur" % x.classe_id)
			roles.sort()
			assert_eq(roles, ["degats", "front", "soutien"], "%s (graine %d) : les trois rôles" % [classe, graine])
			assert_eq(echos[0].role, Trio.ROLES[Trio.ROLES.find(echos[0].role)], "rôles dans l'ordre")
			assert_true(Trio.ROLES.find(echos[0].role) < Trio.ROLES.find(echos[1].role), "%s : Front, Dégâts, Soutien dans l'ordre" % classe)
			var encore := Trio.echos(classe, graine, 12, donnees)
			for i in range(2):
				assert_eq(JSON.stringify(encore[i].vers_dict()), JSON.stringify(echos[i].vers_dict()), "%s : même graine, mêmes Échos" % classe)
	# Le rôle vient des données de la classe (le combat V2 : l'Invocateur est Dégâts).
	assert_eq(Trio.classes_du_role("front", donnees), ["guerrier", "pugiliste"] as Array[String], "les Fronts")
	assert_eq(Trio.classes_du_role("degats", donnees).size(), 4, "quatre Dégâts")
	assert_eq(Trio.classes_du_role("soutien", donnees).size(), 4, "quatre Soutiens")


# Selon la graine, chaque classe d'un rôle peut être tirée.
func test_echos_varies() -> void:
	var vus := {}
	for graine in range(1, 61):
		for x in Trio.echos("guerrier", graine, 1, donnees):
			vus[x.classe_id] = true
	for role in ["degats", "soutien"]:
		for classe in Trio.classes_du_role(role, donnees):
			assert_true(vus.has(classe), "%s tiré au moins une fois en 60 graines" % classe)
	assert_false(vus.has("guerrier") or vus.has("pugiliste"), "un joueur Front n'a pas d'Écho Front")


# Le camp : le joueur, puis ses Échos ; un Destin sauvegardé garde sa marque d'Écho.
func test_places_du_trio() -> void:
	var e := combat(Trio.camp(Generateur.generer("mage", 5, 10), 10, donnees), Trio.camp(Generateur.generer("pretre", 6, 10), 10, donnees), 10)
	assert_eq(e.ordre, ["a1", "a2", "a3", "b1", "b2", "b3"] as Array[String], "trois contre trois")
	for id in e.ordre:
		assert_eq(e.fiche(id)["place"], "joueur" if id.ends_with("1") else "echo", id)
	assert_eq([e.fiche("a2")["role"], e.fiche("a3")["role"]], ["front", "soutien"], "le Mage : un Front, un Soutien")
	assert_eq([e.fiche("b2")["role"], e.fiche("b3")["role"]], ["front", "degats"], "le Prêtre : un Front, un Dégâts")
	var x := Trio.echos("mage", 5, 10, donnees)[0]
	assert_true(Destin.depuis_dict(x.vers_dict()).echo, "la marque d'Écho survit à la sauvegarde")
	assert_false(Destin.depuis_dict(Generateur.acolyte("mage", 5, 10).vers_dict()).echo, "un acolyte n'est pas un Écho")
	# La cible « duo » des données vise tout le camp.
	var soigneur := essai([[[soin(50, "duo")]]])
	var t := combat(trio_essai(soigneur), trio_essai())
	assert_eq(Regles.cibles(t, jouer(t, "a1", 0), "duo"), ["a1", "a2", "a3"] as Array[String], "« duo » : les trois")


# Les annonces en chaîne : l'Écho 1 ne sait rien, l'Écho 2 connaît l'Écho 1, le joueur IA connaît les deux. Les
# Échos annoncent la même chose que le joueur soit humain ou non : le joueur ne les commande jamais.
func test_annonces_en_chaine() -> void:
	var e := combat(Trio.camp(Generateur.generer("barde", 31, 20), 20, donnees), Trio.camp(Generateur.generer("voleur", 32, 20), 20, donnees), 20)
	for t in range(8):
		if e.fini:
			break
		var decl := IA.declarer(e, ["a1"])
		assert_false(decl.has("a1"), "tour %d : le joueur humain n'est pas joué par l'IA" % e.tour)
		for id in ["a2", "a3", "b1", "b2", "b3"]:
			if e.vivant(id) and not e.a_etat(id, "etourdi"):
				assert_true(decl.has(id), "tour %d : %s annonce" % [e.tour, id])
		for c: String in ["a", "b"]:
			var e1 := c + "2"
			var e2 := c + "3"
			if decl.has(e1):
				assert_eq(decl[e1], IA.choisir(e, e1, {}), "tour %d : %s (Écho 1) ne sait rien" % [e.tour, e1])
			if decl.has(e1) and decl.has(e2):
				assert_eq(decl[e2], IA.choisir(e, e2, {e1: decl[e1]}), "tour %d : %s (Écho 2) connaît l'Écho 1" % [e.tour, e2])
		if decl.has("b1"):
			var connues := {}
			for id in ["b2", "b3"]:
				if decl.has(id):
					connues[id] = decl[id]
			assert_eq(decl["b1"], IA.choisir(e, "b1", connues), "tour %d : le joueur IA connaît ses deux Échos" % e.tour)
		var tous := IA.declarer(e)
		for id in ["a2", "a3"]:
			assert_eq(tous.get(id, {}), decl.get(id, {}), "tour %d : %s annonce pareil, joueur humain ou non" % [e.tour, id])
		e = tour(e, tous)


# Les Synergies valent entre chaque paire du camp : le joueur avec chacun de ses Échos, et les deux Échos entre eux.
func test_synergies_entre_chaque_paire() -> void:
	# a1 étourdit b1, a2 et a3 le frappent : deux Brisures (a1 avec chacun), les deux coups ×1,25.
	var e := combat(trio_essai(essai([[[etat("etourdi", 1)]]]), essai([[[deg(100)]]]), essai([[[deg(100)]]])), trio_essai())
	var actions := {"a1": jouer(e, "a1", 0, "b1"), "a2": jouer(e, "a2", 0, "b1"), "a3": jouer(e, "a3", 0, "b1")}
	var s := Regles.synergies(e, actions)
	var paires: Array = []
	for x in s["liste"]:
		assert_eq(x["nom"], "Brisure", "Brisure")
		paires.append(x["acteurs"])
	assert_eq(paires, [["a1", "a2"], ["a1", "a3"]], "une Brisure par paire")
	assert_eq(s["mods"]["degats"], {"a2|0|b1": Regles.BRISURE_DEGATS, "a3|0|b1": Regles.BRISURE_DEGATS}, "les deux coups renforcés")
	var apres := tour(e, actions)
	assert_eq(evenements(apres, "synergie").size(), 2, "deux Synergies au journal")
	# Les deux Échos entre eux : deux DoT sur la même cible, Embrasement.
	var f := combat(trio_essai(null, essai([[[dot("brulure", 20, 2)]]]), essai([[[dot("poison", 20, 2)]]])), trio_essai())
	var s2 := Regles.synergies(f, {"a1": moyeu("a1", "b2"), "a2": jouer(f, "a2", 0, "b1"), "a3": jouer(f, "a3", 0, "b1")})
	assert_eq(s2["liste"].size(), 1, "une Synergie")
	assert_eq([s2["liste"][0]["nom"], s2["liste"][0]["acteurs"]], ["Embrasement", ["a2", "a3"]], "entre les deux Échos")
	# Un même coup renforcé par deux paires ne l'est qu'une fois.
	var g := combat(trio_essai(essai([[[etat("etourdi", 1)]]]), essai([[[etat("gele", 1)]]]), essai([[[deg(100)]]])), trio_essai())
	var s3 := Regles.synergies(g, {"a1": jouer(g, "a1", 0, "b1"), "a2": jouer(g, "a2", 0, "b1"), "a3": jouer(g, "a3", 0, "b1")})
	assert_eq(s3["liste"].size(), 2, "deux Brisures (a1 et a2 avec a3)")
	assert_eq(s3["mods"]["degats"], {"a3|0|b1": Regles.BRISURE_DEGATS}, "le coup de a3 : ×1,25 une seule fois")
	# Les ennemis de la Tour n'en font pas.
	var monstres := [essai([[[etat("etourdi", 1)]]]), essai([[[deg(100)]]])]
	var h := combat(trio_essai(), monstres, 1, "tour")
	assert_true(Regles.synergies(h, {"b1": jouer(h, "b1", 0, "a1"), "b2": jouer(h, "b2", 0, "a1")})["liste"].is_empty(), "pas de Synergie chez les monstres")


# Le bonus de Synergie de l'IA (+40) compte avec chaque allié qui a déjà annoncé, pas avec une Synergie entre deux autres.
func test_bonus_de_synergie_avec_chaque_allie() -> void:
	var e := combat(trio_essai(essai([[[deg(100)]]]), essai([[[deg(30)]]]), essai([[[etat("etourdi", 1)]]])), trio_essai())
	var a2 := jouer(e, "a2", 0, "b1")
	var a3 := jouer(e, "a3", 0, "b1")
	var frappe_b1 := jouer(e, "a1", 0, "b1")
	var seul: Array[Dictionary] = [a2]
	var les_deux: Array[Dictionary] = [a2, a3]
	assert_almost(IA.score(e, frappe_b1, les_deux) - IA.score(e, frappe_b1, seul), IA.SYNERGIE_BONUS, "avec l'étourdissement du second Écho : +40")
	var frappe_b2 := jouer(e, "a1", 0, "b2")
	var aucun: Array[Dictionary] = []
	assert_almost(IA.score(e, frappe_b2, les_deux), IA.score(e, frappe_b2, aucun), "a2 et a3 font Brisure entre eux : rien pour a1")


# Provoquer protège le plus bas de ses alliés (dans un trio, pas forcément le premier).
func test_provocation_et_le_plus_bas_des_allies() -> void:
	var e := combat(trio_essai(essai([[[etat("provoque", 1)]]])), trio_essai())
	var provoque := jouer(e, "a1", 0, "b1")
	var sans := IA.score(e, provoque)
	e.perso("a3")["pv"] = 400
	assert_almost(IA.score(e, provoque) - sans, IA.PROVOQUE_VALEUR, "le second Écho est à 40 % : provoquer le protège")


# La Tour en trio : le camp garde ses PV ; un Écho KO revient avec 20 %, le joueur KO reste KO.
func test_tour_en_trio() -> void:
	var t := Tour.commencer_camp(Trio.camp(Generateur.generer("pretre", 99, 10), 10, donnees), 10, 99, donnees)
	var e := t.combat()
	assert_eq(e.vivants("a").size(), 3, "trois persos montent")
	assert_eq([e.fiche("a2")["place"], e.fiche("a3")["place"], e.fiche("b1")["place"]], ["echo", "echo", "ennemi"], "les places")
	var max_a3 := int(e.fiche("a3")["pv_max"])
	e.perso("a3")["pv"] = 0
	e.perso("a3")["ko"] = true
	e.fini = true
	e.vainqueur = "a"
	t.terminer(e)
	var e2 := t.combat()
	assert_eq(int(e2.perso("a3")["pv"]), Regles.plancher(0.2 * max_a3), "l'Écho KO revient avec 20 %")
	e2.perso("a1")["pv"] = 0
	e2.perso("a1")["ko"] = true
	e2.fini = true
	e2.vainqueur = "a"
	t.terminer(e2)
	var e3 := t.combat()
	assert_false(e3.vivant("a1"), "le joueur KO reste KO")
	assert_eq(e3.vivants("a").size(), 2, "ses deux Échos continuent")
	e3.fini = true
	e3.vainqueur = "b"
	t.terminer(e3)
	assert_true(t.fini, "le camp tombe : la montée s'arrête")
	assert_eq(t.atteint, 3, "étage atteint")


# Le simulateur fait jouer des trios contre des trios, jusqu'au bout, et monter des trios à la Tour.
func test_simulateur_en_trio() -> void:
	var memoire := {}
	var classes := donnees.ordre_classes
	for i in range(classes.size()):
		var j := (i + 3) % classes.size()
		var r := Lib.duel(donnees, classes[i], classes[j], 7 + i, i % 2 == 0, "reactive", memoire, "trio")
		assert_true(r["fini"] and int(r["tours"]) <= Lib.TOURS_MAX, "%s contre %s en trio : fini en %d tours" % [classes[i], classes[j], r["tours"]])
		var encore := Lib.duel(donnees, classes[i], classes[j], 7 + i, i % 2 == 0, "reactive", {}, "trio")
		assert_eq(encore, r, "%s contre %s : même graine, même combat" % [classes[i], classes[j]])
	assert_true(Lib.montee(donnees, "barde", 3, memoire, "trio") >= 1, "une montée en trio")
	var part := Lib.simuler(donnees, "matrice", 0, 50, 1, 1, "trio")
	assert_eq(int(part["non_finis"]), 0, "aucun combat non fini")
