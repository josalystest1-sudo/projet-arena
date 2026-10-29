## Les donjons à routes en solo (GDD V2, § 8 ; plan, PR 6.3 adaptée) : l'arbre, les portes sans nom, la même vague par
## profondeur, une descente jouée par l'IA, la carte, les fragments, les récompenses, le profil.
extends "res://tests/test_case.gd"


func _descente(graine_joueur: int = 5, chasse: int = 0, donjon_id: String = "terrier", niveau: int = 8) -> Donjon:
	return Donjon.commencer(donjon_id, Trio.camp(Generateur.generer("guerrier", 3, niveau, Generateur.PAR_DEFAUT, donnees), niveau, donnees), niveau, graine_joueur, chasse, donnees)


func test_donnees_des_donjons() -> void:
	for erreur in donnees.erreurs:
		failures.append(erreur)
	assert_eq(donnees.donjons["donjons"].size(), 3, "trois donjons, un par tranche de niveau")
	for dj in donnees.donjons["donjons"]:
		assert_true(donnees.bestiaire["familles"].has(str(dj["famille"])), "%s : famille connue" % dj["id"])
		assert_eq(str(donnees.bestiaire["monstres"][dj["boss"]]["rang"]), "gardien", "%s : son boss est un Gardien du bestiaire" % dj["id"])
	var d2 := Donnees.charger()
	d2.donjons["donjons"][0]["famille"] = "dragons"
	d2.donjons["donjons"][1]["boss"] = "rat"
	d2.erreurs.clear()
	d2._valider_donjons()
	assert_eq(d2.erreurs.size(), 2, "deux erreurs signalées (%s)" % str(d2.erreurs))


# Les portes sans nom : trois portes, un ordre propre au joueur et à l'embranchement, toujours le même pour lui.
func test_portes_sans_nom() -> void:
	var a := Donjon.ordre_portes(5, "terrier", [], donnees)
	var b := Donjon.ordre_portes(5, "terrier", [], donnees)
	assert_eq(a, b, "le même joueur voit le même ordre")
	assert_eq(a.size(), 3, "trois portes")
	var vues := a.duplicate()
	vues.sort()
	assert_eq(vues, [0, 1, 2] as Array[int], "une permutation des trois portes vraies")
	var differents := 0
	for g in range(1, 41):
		if Donjon.ordre_portes(g, "terrier", [], donnees) != a:
			differents += 1
	assert_true(differents >= 20, "d'autres joueurs voient d'autres ordres (%d sur 40)" % differents)
	assert_true(Donjon.ordre_portes(5, "terrier", [1], donnees) != a or Donjon.ordre_portes(5, "terrier", [2], donnees) != a, "l'ordre change d'un embranchement à l'autre")
	# La route du boss : une porte par profondeur, la même pour une chasse, une autre pour la suivante (sur dix chasses).
	var r0 := Donjon.route_boss("terrier", 0, donnees)
	assert_eq(r0.size(), 3, "une porte par profondeur")
	assert_eq(r0, Donjon.route_boss("terrier", 0, donnees), "la même route pour la même chasse")
	var autres := 0
	for c in range(1, 11):
		if Donjon.route_boss("terrier", c, donnees) != r0:
			autres += 1
	assert_true(autres >= 5, "les chasses changent la route (%d sur 10)" % autres)


# Les vagues : la même quel que soit la porte, plus de monstres en profondeur, de la famille du donjon.
func test_vagues_par_profondeur() -> void:
	var dj := _descente()
	for k in [1, 2, 3]:
		var v := dj.monstres_vague(k)
		assert_eq(v.size(), k + 1, "profondeur %d : %d monstres" % [k, k + 1])
		for m in v:
			assert_eq(str(donnees.bestiaire["monstres"][m]["famille"]), "betes", "profondeur %d : des bêtes" % k)
	var a := _descente()
	a.choisir(0)
	var b := _descente()
	b.choisir(2)
	assert_eq(a.monstres_vague(1), b.monstres_vague(1), "deux portes différentes : la même vague")
	var ea := a.combat()
	var eb := b.combat()
	assert_eq(int(ea.fiche("b1")["pv_max"]), int(eb.fiche("b1")["pv_max"]), "les mêmes monstres au combat")
	assert_eq(str(ea.fiche("b1")["place"]), "ennemi", "des ennemis de la Tour (mode tour)")
	assert_eq(ea.mode, "tour", "sans mort subite")


# Une descente entière jouée par l'IA : les portes, les vagues, l'élite ou le boss, les PV gardés, les récompenses.
func test_descente_jouee_par_l_ia() -> void:
	var resultats: Dictionary = {}
	for graine in range(1, 7):
		var dj := _descente(graine, 0, "terrier", 12)
		var combats := 0
		while dj.phase != "fini" and combats < 10:
			if dj.phase == "portes":
				var portes := dj.portes({"explorees": [], "revelees": []})
				assert_eq(portes.size(), 3, "trois portes à choisir")
				assert_true(dj.choisir(graine % 3), "choisir une porte")
			var e := dj.combat()
			var tours := 0
			while not e.fini and tours < 300:
				e = tour(e, IA.declarer(e))
				tours += 1
			assert_true(e.fini, "graine %d : le combat se termine" % graine)
			combats += 1
			dj.terminer(e)
		assert_eq(dj.phase, "fini", "graine %d : la descente se termine" % graine)
		resultats[dj.resultat] = true
		if dj.resultat != "tombe":
			assert_eq(combats, 4, "graine %d : trois vagues puis la fin" % graine)
			assert_true(dj.finale, "le dernier combat était la finale")
			assert_eq(dj.chemins_explores().size(), 3, "trois chemins explorés")
			var r := dj.recompense()
			assert_eq(str(r["rarete"]), "legendaire" if dj.resultat == "boss" else "epique", "graine %d : la rareté de la récompense" % graine)
			assert_eq(bool(r["lie"]), dj.resultat != "boss", "le boss donne un objet échangeable, l'élite un objet lié")
			var o := dj.butin(graine)
			assert_true(Equipement.valide(o, donnees), "l'objet est conforme")
			assert_eq(int(o["niveau"]), 6, "du niveau du donjon")
		else:
			assert_true(dj.recompense().is_empty(), "tombé : pas de récompense")
	assert_true(resultats.has("elite") or resultats.has("boss"), "au niveau 12, le Terrier se finit (%s)" % str(resultats.keys()))
	# Suivre la route du boss mène au boss.
	var route := Donjon.route_boss("terrier", 0, donnees)
	var dj := _descente(5, 0, "terrier", 12)
	for k in range(3):
		var ordre := Donjon.ordre_portes(5, "terrier", dj.chemin, donnees)
		dj.choisir(ordre.find(route[k]))
		dj.phase = "portes"
	assert_true(dj.sur_la_route_du_boss(), "le chemin suit la route du boss")
	assert_eq(dj.monstre_final(), "dragonnet", "au bout : le boss")
	dj.phase = "combat"
	dj.finale = true
	var eb := dj.combat()
	assert_eq(int(eb.fiche("b1")["pv_max"]), Regles.plancher(float(Generateur.monstre("dragonnet", dj.graine_vague(3), 6, donnees).pv_base) * 1.5 * ((1.0 + 0.05 * 5.0) / (1.0 + 0.05 * 11.0)) * 1.3 * Regles.multiplicateur_niveau(eb) * (1.0 + Generateur.monstre("dragonnet", dj.graine_vague(3), 6, donnees).bonus_pv())), "le boss a 30 % de plus")


# La carte et les fragments : les portes explorées se voient, un fragment révèle la porte du boss.
func test_carte_et_fragments() -> void:
	var carte := {"explorees": ["1", "1.2"], "revelees": []}
	var dj := _descente()
	var portes := dj.portes(carte)
	var explorees := 0
	for p in portes:
		if p["etat"] == "exploree":
			explorees += 1
			assert_eq(int(p["vraie"]), 1, "la porte explorée est la vraie 1")
	assert_eq(explorees, 1, "une porte explorée à l'entrée")
	var route := Donjon.route_boss("terrier", 0, donnees)
	var f1 := Donjon.reveler("terrier", 0, carte, donnees)
	assert_eq(f1, str(route[0]), "le premier fragment révèle la première porte du boss")
	carte["revelees"].append(f1)
	var f2 := Donjon.reveler("terrier", 0, carte, donnees)
	assert_eq(f2, "%d.%d" % [route[0], route[1]], "le second, la suivante")
	carte["revelees"].append(f2)
	carte["revelees"].append(Donjon.reveler("terrier", 0, carte, donnees))
	assert_eq(Donjon.reveler("terrier", 0, carte, donnees), "", "tout révélé : rien")
	var revelees := 0
	for p in dj.portes(carte):
		if p["etat"] == "revelee":
			revelees += 1
			assert_eq(int(p["vraie"]), route[0], "la porte révélée est celle du boss")
	assert_eq(revelees, 1, "une porte révélée à l'entrée")


func test_profil_des_donjons() -> void:
	var chemin_avant := PlayerProfile.chemin
	PlayerProfile.chemin = "user://test_donjons_profil.cfg"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PlayerProfile.chemin))
	var p := PlayerProfile.new()
	p.donjons = {"terrier": {"chasse": 1, "explorees": ["0", "0.1"], "revelees": ["2"], "boss": 1}}
	p.save()
	var relu := PlayerProfile.load_profile()
	assert_eq(int(relu.donjons["terrier"]["chasse"]), 1, "la chasse relue")
	assert_eq(relu.donjons["terrier"]["explorees"], ["0", "0.1"], "la carte relue")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PlayerProfile.chemin))
	PlayerProfile.chemin = chemin_avant
