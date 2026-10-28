## Combat V2 : le générateur de Destin, les formes, l'allumage et les textes (docs/SPEC-COMBAT-V2.md, section 14,
## tests 5 à 10 et 45).
extends "res://tests/test_case.gd"


func _signature(d: Destin) -> String:
	var formes: Array[String] = []
	for voie in d.voies:
		for n in voie["noeuds"]:
			formes.append(str(n["forme"]))
	return ",".join(formes)


# 5. Même graine : même Destin.
func test_05_meme_graine_meme_destin() -> void:
	for id in donnees.ordre_classes:
		var a := Generateur.generer(id, 123456789, 17)
		var b := Generateur.generer(id, 123456789, 17)
		assert_eq(JSON.stringify(a.vers_dict()), JSON.stringify(b.vers_dict()), id + " : même graine, même Destin")
		var c := Generateur.acolyte(id, 123456789, 17)
		var c2 := Generateur.acolyte(id, 123456789, 17)
		assert_eq(JSON.stringify(c.vers_dict()), JSON.stringify(c2.vers_dict()), id + " : même acolyte")


# 6. Des graines différentes donnent des formes différentes (sur 100 graines).
func test_06_graines_differentes_formes_differentes() -> void:
	for id in donnees.ordre_classes:
		var vues := {}
		var formes := {}
		for g in range(1, 101):
			var d := Generateur.generer(id, g, 1)
			vues[_signature(d)] = true
			for voie in d.voies:
				for n in voie["noeuds"]:
					formes[n["forme"]] = true
		assert_eq(vues.size(), 100, id + " : 100 graines, 100 Destins différents")
		assert_true(formes.size() >= 4, id + " : au moins 4 formes tirées (%s)" % str(formes.keys()))


# 7. Chaque forme générée reste dans ±6 % du budget de son rang.
func test_07_chaque_forme_dans_son_budget() -> void:
	var compte := 0
	for id in donnees.ordre_classes:
		for voie in donnees.classe(id)["voies"]:
			for n in voie["noeuds"]:
				for forme in Generateur.formes_possibles(donnees.regles, n, id, voie["id"]):
					var f := Generateur.appliquer_forme(donnees.regles, n, forme, id, voie["id"])
					compte += 1
					var faute := Budget.faute(donnees.regles, f)
					if faute != "":
						failures.append("%s %s %s (%s) : %s" % [id, voie["id"], n["nom"], forme, faute])
		for g in range(1, 21):
			for d in [Generateur.generer(id, g * 7919, 30), Generateur.acolyte(id, g * 7919, 30)]:
				for voie in d.voies:
					for n in voie["noeuds"]:
						var faute := Budget.faute(donnees.regles, n)
						if faute != "":
							failures.append("%s graine %d %s (%s) : %s" % [id, g, n["nom"], n["forme"], faute])
	assert_true(compte > 400, "toutes les formes de tous les nœuds vérifiées (%d)" % compte)


# 8. Chaque forme ne s'applique qu'aux nœuds qu'elle concerne.
func test_08_formes_applicables() -> void:
	for id in donnees.ordre_classes:
		for voie in donnees.classe(id)["voies"]:
			for n in voie["noeuds"]:
				var types := {}
				var mono := false
				var multi := false
				for ef in n["effets"]:
					types[ef["type"]] = true
					mono = mono or ef["cible"] in ["un_ennemi", "un_allie", "soi"]
					multi = multi or ef["cible"] in ["tous_les_ennemis", "duo"]
				var possibles := Generateur.formes_possibles(donnees.regles, n, id, voie["id"])
				var ou := "%s %s" % [id, n["nom"]]
				assert_true("base" in possibles, ou + " : Base toujours")
				if "diffuse" in possibles:
					assert_true(mono, ou + " : Diffuse sans effet mono-cible")
				if "concentree" in possibles:
					assert_true(multi, ou + " : Concentrée sans effet multi-cible")
				if "persistante" in possibles:
					assert_true(types.has("degats") or types.has("soin"), ou + " : Persistante sans dégâts ni soin directs")
				if "vive" in possibles:
					assert_true(types.has("dot") or types.has("gardien"), ou + " : Vive sans DoT ni Gardien")
	# Exemples de la section 4.
	var boule := Generateur.appliquer_forme(donnees.regles, donnees.noeud("mage", 0, 2), "diffuse", "mage", "brasier")
	assert_eq(boule["effets"][0]["cible"], "tous_les_ennemis", "Boule de feu diffuse : sur tous les ennemis")
	assert_almost(float(boule["effets"][0]["valeur"]), 100.0 / 1.3, "Boule de feu diffuse : 100 ÷ 1,3")
	var priere := Generateur.appliquer_forme(donnees.regles, donnees.noeud("pretre", 0, 1), "persistante", "pretre", "lumiere")
	assert_eq(priere["effets"][0]["type"], "gardien", "Prière persistante : un Gardien")
	assert_eq(int(priere["effets"][0]["tours"]), 3, "sur 3 tours")
	var acide := Generateur.appliquer_forme(donnees.regles, donnees.noeud("alchimiste", 0, 2), "vive", "alchimiste", "acide")
	assert_eq(acide["effets"].size(), 1, "Acide vif : le Poison devient des dégâts, regroupés avec ceux déjà là")
	assert_eq(acide["effets"][0]["type"], "degats", "Acide vif : des dégâts directs")
	assert_almost(float(acide["effets"][0]["valeur"]), 100.0, "Acide vif : 30 + 100 × 0,7")
	var tir := Generateur.appliquer_forme(donnees.regles, donnees.noeud("archer", 0, 1), "persistante", "archer", "precision")
	assert_eq(tir["effets"][0]["sous_type"], "saignement", "Archer, voie de la Précision : Saignement")
	var feu := Generateur.appliquer_forme(donnees.regles, donnees.noeud("archer", 3, 1), "persistante", "archer", "feu_gregeois")
	assert_eq(feu["effets"][0]["sous_type"], "brulure", "Archer, ailleurs : Brûlure")
	assert_eq(Generateur.formes_possibles(donnees.regles, donnees.noeud("voleur", 2, 1), "voleur", "ruse"), ["base"] as Array[String], "Jet de sable : Aveuglé à tous coûterait plus que son budget")


# 9. Allumage par défaut au niveau 30 : 15 nœuds actifs, et É1, É3, É2 de chaque voie.
func test_09_allumage_par_defaut_niveau_30() -> void:
	var d := Generateur.generer("guerrier", 42, 30)
	for voie in d.voies:
		for n in voie["noeuds"]:
			assert_true(bool(n["allume"]), "%s %s allumé" % [voie["id"], n["nom"]])
		assert_eq(voie["eclats"], [true, true, true, false, false], voie["id"] + " : É1, É2, É3")
	var d1 := Generateur.generer("guerrier", 42, 1)
	assert_true(bool(d1.voies[0]["noeuds"][1]["allume"]), "niveau 1 : N2 de la première voie")
	assert_false(bool(d1.voies[1]["noeuds"][1]["allume"]), "niveau 1 : rien d'autre")
	for v in range(5):
		assert_true(bool(d1.voies[v]["noeuds"][0]["allume"]), "les N1 sont allumés d'office")
	var d6 := Generateur.generer("guerrier", 42, 6)
	assert_true(bool(d6.voies[0]["noeuds"][2]["allume"]), "niveau 6 : N3 de la première voie après les cinq N2")
	var aco := Generateur.acolyte("guerrier", 42, 10)
	assert_eq(aco.classe_id, "pretre", "l'acolyte d'un Guerrier est un Prêtre")
	assert_eq(aco.voies.size(), 3, "3 voies")
	for voie in aco.voies:
		for n in voie["noeuds"]:
			assert_true(bool(n["allume"]), "acolyte niveau 10 : %s allumé" % n["nom"])
	assert_eq(aco.voies[0]["eclats"], [true, false, true, false, false], "acolyte : É1 et É3 de sa première voie")
	assert_eq(aco.graine, 42 ^ 0x5A5A5A5A, "graine de l'acolyte")
	var aco4 := Generateur.acolyte("guerrier", 42, 4)
	var allumes := 0
	for voie in aco4.voies:
		for n in voie["noeuds"]:
			allumes += 1 if bool(n["allume"]) else 0
	assert_eq(allumes, 7, "acolyte niveau 4 : les 3 N1 et 4 points")


# 10. Règle d'allumage : un rang k exige le rang k−1 ; un éclat exige son nœud.
func test_10_regle_d_allumage() -> void:
	var d := Generateur.generer("mage", 7, 1, [] as Array[String])
	assert_false(Generateur.peut_allumer(d, "v1.n3"), "N3 sans N2")
	assert_true(Generateur.peut_allumer(d, "v1.n2"), "N2 après N1")
	assert_true(Generateur.peut_allumer(d, "v1.e1"), "É1 sur N1")
	assert_true(Generateur.peut_allumer(d, "v1.e2"), "É2 sur N1")
	assert_false(Generateur.peut_allumer(d, "v1.e3"), "É3 sans N2")
	assert_false(Generateur.peut_allumer(d, "v1.e5"), "É5 sans Clé")
	var e := Generateur.generer("mage", 7, 3, ["v1.n3", "v1.n2", "v1.n3", "v1.e3"] as Array[String])
	assert_false(bool(e.voies[0]["noeuds"][3]["allume"]), "pas de Clé")
	assert_true(bool(e.voies[0]["noeuds"][2]["allume"]), "N3 allumé une fois N2 allumé")
	assert_true(e.voies[0]["eclats"][2], "É3 allumé après N2")
	var trop := Generateur.generer("mage", 7, 2, ["v1.n2", "v2.n2", "v3.n2"] as Array[String])
	assert_false(bool(trop.voies[2]["noeuds"][1]["allume"]), "niveau 2 : deux points seulement")


# 45. Textes : nom accordé, ligne chiffrée, phrase de 10 mots au plus sans chiffre, pour tous les nœuds et formes.
func test_45_textes() -> void:
	var chiffres := RegEx.create_from_string("[0-9]")
	var compte := 0
	for id in donnees.ordre_classes:
		var cls := donnees.classe(id)
		var noeuds: Array = [[cls["moyeu"], "", "base"]]
		for voie in cls["voies"]:
			for n in voie["noeuds"]:
				for forme in Generateur.formes_possibles(donnees.regles, n, id, voie["id"]):
					noeuds.append([Generateur.appliquer_forme(donnees.regles, n, forme, id, voie["id"]), voie["id"], forme])
		for entree in noeuds:
			var n: Dictionary = entree[0]
			compte += 1
			var nom := Texte.nom(n)
			var ligne := Texte.ligne(n)
			var phrase := Texte.phrase(n)
			var ou := "%s %s (%s)" % [id, n["nom"], entree[2]]
			if entree[2] == "base":
				assert_eq(nom, n["nom"], ou + " : nom de base")
			else:
				assert_eq(nom, "%s %s" % [n["nom"], donnees.textes["formes"][entree[2]][n["genre"]]], ou + " : suffixe accordé")
			assert_true(ligne.length() > 0 and not ligne.contains("{"), ou + " : ligne « %s »" % ligne)
			assert_true(phrase.split(" ").size() <= 10, ou + " : phrase de plus de 10 mots « %s »" % phrase)
			assert_true(chiffres.search(phrase) == null, ou + " : chiffre dans la phrase « %s »" % phrase)
			assert_true(phrase.ends_with(".") and phrase.substr(0, 1) == phrase.substr(0, 1).to_upper(), ou + " : phrase « %s »" % phrase)
	assert_true(compte >= 400, "tous les nœuds sous toutes leurs formes (%d)" % compte)
	assert_eq(Texte.nom({"nom": "Boule de feu", "genre": "f", "forme": "diffuse"}), "Boule de feu diffuse", "exemple de la section 4")
	assert_eq(Texte.nom({"nom": "Acide", "genre": "m", "forme": "vive"}), "Acide vif", "exemple de la section 4")
	assert_eq(Texte.nom({"nom": "Lianes", "genre": "fp", "forme": "diffuse"}), "Lianes diffuses", "pluriel")
	assert_eq(Texte.ligne(donnees.noeud("guerrier", 0, 1)), "45 à un ennemi + 12×3 Saignement", "ligne d'Entaille")
	assert_eq(Texte.ligne(donnees.noeud("guerrier", 3, 3)), "73 à tous + Enraciné 1", "ligne de Tremblement (section 12.4)")
	assert_eq(Texte.ligne(donnees.noeud("guerrier", 4, 1)), "+25 % Renfort 2 t + 20 à un ennemi", "ligne de Cri de guerre")
	assert_eq(Texte.ligne(donnees.noeud("pretre", 0, 3)), "soin 120 au duo", "ligne de Bénédiction")
	var cri := Generateur.appliquer_forme(donnees.regles, donnees.noeud("guerrier", 4, 1), "persistante", "guerrier", "cri")
	assert_eq(Texte.ligne(cri), "+25 % Renfort 2 t + 9×3 Saignement", "Cri de guerre persistant : le Renfort ne bouge pas")
	assert_eq(Texte.phrase(donnees.noeud("guerrier", 0, 4)), "Frappe, lacère et désarme un ennemi.", "phrase d'Exsangue")
	assert_eq(Texte.phrase(donnees.noeud("guerrier", 1, 4)), "Se protège, provoque tous les ennemis et frappe un ennemi.", "phrase de Rempart vivant")
	assert_eq(Texte.ligne(donnees.noeud("guerrier", 0, 1), 2.0), "90 à un ennemi + 24×3 Saignement", "ligne au double (niveau, k, éclats)")
