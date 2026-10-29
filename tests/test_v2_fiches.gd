## Combat V2 : menaces et fiches (docs/SPEC-COMBAT-V2.md, section 14, tests 41 à 44).
extends "res://tests/test_case.gd"


func _quatre(effets_n3: Array = [deg(140)], effets_cle: Array = [deg(230)]) -> Array:
	return [[deg(70)], [deg(100)], effets_n3, effets_cle]


# 41. Échéance = max(rang − jalon, extinction restante).
func test_41_echeance() -> void:
	var e := duel_essai(essai([_quatre(), _quatre()]))
	assert_eq(Regles.echeance(e, "a1", 0, 3), 3, "jalon 0 : N3 à 3")
	assert_eq(Regles.echeance(e, "a1", 0, 4), 4, "jalon 0 : la Clé à 4")
	e.perso("a1")["jalons"][0] = 2
	assert_eq(Regles.echeance(e, "a1", 0, 3), 1, "jalon 2 : N3 à 1")
	assert_eq(Regles.echeance(e, "a1", 0, 4), 2, "jalon 2 : la Clé à 2")
	e.perso("a1")["spent_until"][0][2] = e.tour + 3
	assert_eq(Regles.echeance(e, "a1", 0, 3), 3, "N3 éteint encore 3 tours : 3")
	e.perso("a1")["spent_until"][0][3] = e.tour + 1
	assert_eq(Regles.echeance(e, "a1", 0, 4), 2, "Clé éteinte 1 tour mais à 2 rangs : 2")


# 42. Seulement les rangs 3 et 4, d'échéance ≤ 2, 3 au plus, triées par échéance puis budget.
func test_42_menaces_filtrees_et_triees() -> void:
	var voies: Array = []
	for i in range(5):
		voies.append(_quatre())
	var e := duel_essai(null, null, essai(voies))
	assert_true(Regles.menaces(e, "b1").is_empty(), "jalons à 0 : aucune menace")
	e.perso("b1")["jalons"] = [2, 2, 1, 0, 3]
	var m := Regles.menaces(e, "b1")
	assert_eq(m.size(), 3, "3 au plus")
	for x in m:
		assert_true(int(x["rang"]) >= 3, "rang 3 ou 4")
		assert_true(int(x["echeance"]) <= 2, "échéance ≤ 2")
	assert_eq([m[0]["echeance"], m[0]["rang"]], [1, 4], "d'abord l'échéance 1, la Clé au plus gros budget (voie 5)")
	assert_eq([m[1]["echeance"], m[1]["rang"]], [1, 3], "puis les N3 à 1")
	assert_eq([m[2]["echeance"], m[2]["rang"]], [1, 3], "puis les N3 à 1")
	e.perso("b1")["jalons"] = [1, 0, 0, 0, 0]
	m = Regles.menaces(e, "b1")
	assert_eq(m.size(), 1, "jalon 1 : seul le N3 de la voie 1 (échéance 2)")
	assert_eq([m[0]["voie"], m[0]["rang"], m[0]["echeance"]], [0, 3, 2], "N3 de la voie 1")


# 43. Une menace est barrée quand un état déjà posé l'empêche.
func test_43_menace_barree() -> void:
	var e := duel_essai(null, null, essai([_quatre()]))
	e.perso("b1")["jalons"][0] = 3
	assert_false(bool(Regles.menaces(e, "b1")[0]["barre"]), "Clé à 1, rien ne l'empêche")
	poser(e, "b1", "silencie", 1)
	assert_true(bool(Regles.menaces(e, "b1")[0]["barre"]), "Silencié ce tour-ci : la Clé est barrée")
	var e2 := duel_essai(null, null, essai([_quatre()]))
	e2.perso("b1")["jalons"][0] = 2
	e2.perso("b1")["etats"]["silencie"] = {"debut": e2.tour, "fin": e2.tour, "valeur": 0.0, "source": "a1"}
	var m := Regles.menaces(e2, "b1")
	assert_eq(m.size(), 2, "N3 à 1 et Clé à 2")
	assert_false(bool(m[1]["barre"]), "Silencié ne dure que ce tour : la Clé à 2 n'est pas barrée")
	e2.perso("b1")["etats"]["silencie"]["fin"] = e2.tour + 1
	assert_true(bool(Regles.menaces(e2, "b1")[1]["barre"]), "Silencié jusqu'au tour où la Clé devient jouable : barrée")
	poser(e2, "b1", "gele", 1)
	assert_true(bool(Regles.menaces(e2, "b1")[0]["barre"]), "Gelé ce tour-ci : le N3 à 1 est barré")


# 44. « Pour l'empêcher » ne liste que des nœuds légaux ce tour-ci, du joueur ou de son acolyte.
func test_44_pour_l_empecher() -> void:
	var a1 := essai([[[etat("etourdi", 1)]], [[deg(10)], [etat("silencie", 1)]], [[etat("gele", 1)]]], 1000, [deg(10)])
	var a2 := essai([[[barriere(100, "un_allie")]]])
	a1.voies[0]["noeuds"][0]["nom"] = "Assommer"
	a1.voies[1]["noeuds"][1]["nom"] = "Bâillon"
	a1.voies[2]["noeuds"][0]["nom"] = "Gel"
	a2.voies[0]["noeuds"][0]["nom"] = "Bouclier"
	var e := duel_essai(a1, a2, essai([_quatre()]))
	e.perso("b1")["jalons"][0] = 3
	e.perso("a1")["spent_until"][2][0] = e.tour + 2
	var reponses := Texte.pour_l_empecher(e, "b1", 0, 4, "a1")
	var noms: Array = []
	for r in reponses:
		noms.append(r["nom"])
		assert_true(r.has("pictogramme"), "chaque réponse a son pictogramme")
	assert_eq(noms, ["Assommer", "Bouclier"], "l'Étourdi du joueur et la barrière de l'acolyte (légaux)")
	assert_false("Bâillon" in noms, "le Silencié de la voie 2 n'est pas légal ce tour (jalon 0) : absent")
	assert_false("Gel" in noms, "le Gelé de la voie 3 est éteint : absent")
	var fiche := Texte.fiche(e, "b1", 0, 4, "a1")
	assert_true(fiche.has("pour_l_empecher"), "la fiche d'un nœud ennemi a « Pour l'empêcher »")
	assert_eq(fiche["echeance"], donnees.textes["fiche"]["jouable_ce_tour"], "un nœud ennemi légal ce tour-ci : il peut le jouer ce tour-ci")
	var a_soi := Texte.fiche(e, "a1", 0, 1, "a1")
	assert_false(a_soi.has("pour_l_empecher"), "pas de « Pour l'empêcher » pour un nœud à soi")
	assert_eq(a_soi["echeance"], donnees.textes["fiche"]["jouable_maintenant"], "à soi et légal : jouable maintenant")
	assert_true(str(a_soi["apres"]).contains("N2"), "« Après » : le nœud suivant (%s)" % a_soi["apres"])
	var cle := Texte.fiche(e, "b1", 0, 3, "a1")
	assert_eq(cle["echeance"], donnees.textes["fiche"]["depasse"], "un nœud que le jalon a dépassé")
	var vide := duel_essai(essai([[[deg(10)]]]), essai([[[deg(10)]]]), essai([_quatre()]))
	vide.perso("b1")["jalons"][0] = 3
	assert_true(Texte.pour_l_empecher(vide, "b1", 0, 4, "a1").is_empty(), "aucune réponse en main")


# Les Synergies possibles (l'écran les montre en doré) : celles que synergies() déclencherait, avec la bonne cible.
func test_synergies_possibles() -> void:
	# Le joueur frappe (voie 1) ou gèle (voie 2) ; l'acolyte a annoncé un gel sur b2.
	var e := duel_essai(essai([[[deg(100)]], [[etat("gele", 1)]]]), essai([[[etat("gele", 1)]]]))
	var annonce := jouer(e, "a2", 0, "b2")
	var possibles := Regles.synergies_possibles(e, "a1", annonce)
	var vues: Array = []
	for o in possibles:
		vues.append([o["action"]["source"], int(o["action"]["voie"]), str(o["action"]["cible_ennemie"]), o["noms"]])
		var e1 := tour(e, {"a1": o["action"], "a2": annonce})
		assert_eq(evenements(e1, "synergie").size(), 1, "chaque Synergie possible se déclenche vraiment")
	assert_true(["voie", 0, "b2", ["Brisure"]] in vues, "frapper b2, gelé par l'acolyte : Brisure (%s)" % str(vues))
	for v in vues:
		assert_eq(v[2], "b2", "seulement sur la cible de l'acolyte")
		assert_ne(v[1], 1, "deux gels ne font pas de Synergie")
	assert_true(Regles.synergies_possibles(e, "a1", {}).is_empty(), "sans annonce : rien")


# La fiche d'un état posé et l'explication d'une Synergie, en clair.
func test_fiche_etat_et_synergie() -> void:
	var e := duel_essai()
	poser(e, "b1", "saignement", 3, 12.0, "a2")
	var f := Texte.fiche_etat(e, "b1", "saignement", {"a2": "Cèdre"})
	assert_eq(f["nom"], donnees.etats["saignement"]["nom"], "son nom")
	assert_eq(f["valeur"], "12 par tour", "sa valeur par tour")
	assert_true(str(f["sous_titre"]).contains("3 tours"), "les tours restants (%s)" % f["sous_titre"])
	assert_true(str(f["source"]).contains("Cèdre"), "qui l'a posé (%s)" % f["source"])
	poser(e, "a1", "renfort", 2, 0.25, "a2")
	assert_eq(Texte.fiche_etat(e, "a1", "renfort")["valeur"], "+25 %", "un Renfort en pourcentage")
	var s := Texte.synergie("Brisure")
	assert_true(str(s["effet"]).contains("1,25"), "Brisure : le chiffre des règles (%s)" % s["effet"])
	assert_ne(str(s["regle"]), "", "et sa règle")
