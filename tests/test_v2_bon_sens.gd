## L'IA de bon sens et le tableau des erreurs (docs/GDD_V2.md, § 4.5 ; docs/PLAN.md, PR 1.2).
extends "res://tests/test_case.gd"

const Lib := preload("res://tools/equilibrage_lib.gd")


func setup() -> void:
	super.setup()
	IA.bon_sens = true


## Le choix de l'IA, avec ou sans les règles de bon sens.
func choix(e: EtatCombat, id: String, connues: Dictionary, bon_sens: bool) -> Dictionary:
	IA.bon_sens = bon_sens
	var a := IA.choisir(e, id, connues)
	IA.bon_sens = true
	return a


# Les dégâts qu'une action infligera : avec Renfort ; rien sur un ennemi unique quand on est Aveuglé.
func test_degats_prevus() -> void:
	var e := duel_essai(essai([[[deg(100)]], [[deg(40, "tous_les_ennemis")]]]))
	assert_eq(IA.degats_prevus(e, jouer(e, "a1", 0, "b1")), {"b1": 100}, "un coup de 100")
	assert_eq(IA.degats_prevus(e, jouer(e, "a1", 1)), {"b1": 40, "b2": 40}, "une zone de 40")
	poser(e, "a1", "renfort", 1, 0.2)
	assert_eq(IA.degats_prevus(e, jouer(e, "a1", 0, "b1")), {"b1": 120}, "Renfort +20 %")
	poser(e, "a1", "aveugle")
	assert_eq(IA.degats_prevus(e, jouer(e, "a1", 0, "b1")), {}, "Aveuglé : rien sur un ennemi unique")
	assert_eq(IA.degats_prevus(e, jouer(e, "a1", 1)), {"b1": 48, "b2": 48}, "Aveuglé : la zone touche quand même")


# Achever : l'ennemi que mon coup abat avec celui annoncé par mon allié, plutôt que le plus blessé.
func test_achever() -> void:
	var e := duel_essai(essai([[[deg(100)]]]), essai([[[deg(350)]]]))
	e.perso("b1")["pv"] = 400
	e.perso("b2")["pv"] = 300
	var annonce := {"a2": jouer(e, "a2", 0, "b1")}
	assert_eq(choix(e, "a1", annonce, false)["cible_ennemie"], "b2", "sans bon sens : le plus blessé (70 % manquants)")
	var a := choix(e, "a1", annonce, true)
	assert_eq([a["cible_ennemie"], a["voie"]], ["b1", 0], "avec : b1, que 350 + 100 abattent")
	assert_eq(IA.ennemis_a_portee(e, "a1", [annonce["a2"]] as Array[Dictionary], Regles.actions_legales(e, "a1")), ["b1"] as Array[String], "b1 à portée")


# Ne pas frapper un ennemi que les coups annoncés abattent déjà.
func test_pas_de_coup_perdu() -> void:
	var e := duel_essai(essai([[[deg(100)]]]), essai([[[deg(500)]]]))
	e.perso("b2")["pv"] = 300
	var annonce := {"a2": jouer(e, "a2", 0, "b2")}
	assert_eq(choix(e, "a1", annonce, false)["cible_ennemie"], "b2", "sans bon sens : b2, déjà abattu par l'allié")
	assert_eq(choix(e, "a1", annonce, true)["cible_ennemie"], "b1", "avec : l'autre ennemi")


# Les dégâts sur la durée de la fin du tour comptent : un ennemi qui saigne de 60 et n'a plus que 100 PV tombe sous un
# coup de 50.
func test_dot_compte() -> void:
	var e := duel_essai(essai([[[deg(50)]]]))
	e.perso("b2")["pv"] = 100
	assert_eq(IA.ennemis_a_portee(e, "a1", [], Regles.actions_legales(e, "a1")).size(), 0, "sans DoT : personne à portée")
	poser(e, "b2", "saignement", 2, 60.0)
	assert_eq(IA.ticks_a_venir(e, "b2"), 60, "60 à la fin du tour")
	assert_eq(IA.ennemis_a_portee(e, "a1", [], Regles.actions_legales(e, "a1")), ["b2"] as Array[String], "avec : b2 à portée")
	assert_eq(choix(e, "a1", {}, true)["cible_ennemie"], "b2", "l'IA l'achève")


# Une barrière seulement sur un allié que les ennemis viseront (leur cible prévue par la section 10.2).
func test_barriere_sur_l_allie_vise() -> void:
	var e := duel_essai(essai([[[barriere(200)]]]))
	e.perso("a2")["pv"] = 500
	assert_eq(IA.cible_ennemie(e, "b1"), "a2", "les ennemis visent le plus blessé")
	assert_almost(IA.degats_sur(e, "a2"), 2.0 * IA.DEGATS_PAR_ENNEMI, "a2 : deux ennemis le viseront")
	assert_almost(IA.degats_sur(e, "a1"), 0.0, "a1 : personne")
	assert_eq(choix(e, "a1", {}, false)["source"], "voie", "sans bon sens : la barrière sur soi")
	assert_eq(choix(e, "a1", {}, true)["source"], "moyeu", "avec : pas de barrière sur soi, personne ne le visera")
	var f := duel_essai(essai([[[barriere(200, "un_allie")]]]))
	f.perso("a2")["pv"] = 500
	var a := choix(f, "a1", {}, true)
	assert_eq([a["source"], a["cible_alliee"]], ["voie", "a2"], "une barrière sur a2, que les ennemis viseront")


# Une Clé n'est pas gaspillée : pour achever, le coup le moins cher qui suffit ; pas de Clé absorbée par une barrière.
func test_cle_epargnee() -> void:
	var tueur := essai([[[deg(10)], [deg(10)], [deg(10)], [deg(300)]], [[deg(60)]]])
	var e := duel_essai(tueur)
	e.perso("a1")["jalons"][0] = 3
	e.perso("b1")["pv"] = 50
	assert_eq(int(choix(e, "a1", {}, false)["rang"]), 4, "sans bon sens : la Clé (bonus de progression)")
	var a := choix(e, "a1", {}, true)
	assert_eq([a["voie"], int(a["rang"]), a["cible_ennemie"]], [1, 1, "b1"], "avec : le N1 de 60 suffit à achever b1")
	var f := duel_essai(essai([[[deg(10)], [deg(10)], [deg(10)], [deg(300)]], [[deg(60)]]]))
	f.perso("a1")["jalons"][0] = 3
	for id in ["b1", "b2"]:
		f.perso(id)["barriere"] = 500
	assert_eq(int(choix(f, "a1", {}, false)["rang"]), 4, "sans bon sens : la Clé, même toute absorbée")
	assert_eq(int(choix(f, "a1", {}, true)["rang"]), 1, "avec : la Clé attend, la barrière l'absorberait toute")


# Ce que chacun connaît en annonçant : l'ordre de la phase 1.
func test_annonces_connues() -> void:
	var t := combat(Trio.camp(Generateur.generer("mage", 5, 10), 10, donnees), Trio.camp(Generateur.generer("pretre", 6, 10), 10, donnees), 10)
	var decl := {}
	for id in t.ordre:
		decl[id] = Regles.actions_legales(t, id)[0]
	assert_eq(IA.annonces_connues(t, "a2", decl).size(), 0, "l'Écho 1 ne sait rien")
	assert_eq(IA.annonces_connues(t, "a3", decl), [decl["a2"]] as Array[Dictionary], "l'Écho 2 connaît l'Écho 1")
	assert_eq(IA.annonces_connues(t, "a1", decl), [decl["a2"], decl["a3"]] as Array[Dictionary], "le joueur connaît les deux")
	var d := duel_essai()
	var decl_d := {"a1": moyeu("a1"), "a2": moyeu("a2"), "b1": moyeu("b1"), "b2": moyeu("b2")}
	assert_eq(IA.annonces_connues(d, "a2", decl_d).size(), 0, "l'acolyte ne sait rien")
	assert_eq(IA.annonces_connues(d, "a1", decl_d), [decl_d["a2"]] as Array[Dictionary], "le joueur connaît son acolyte")


# Le tableau des erreurs : coup perdu, soin perdu, barrière inutile, Clé gaspillée, achèvement raté.
func test_tableau_des_erreurs() -> void:
	# a2 abat b1 (50 PV) avec 100 : les 30 de a1 étaient perdus, pas les 100 de a2.
	var e := duel_essai(essai([[[deg(30)]]]), essai([[[deg(100)]]]))
	e.perso("b1")["pv"] = 50
	var decl := {"a1": jouer(e, "a1", 0, "b1"), "a2": jouer(e, "a2", 0, "b1")}
	var out := {}
	Lib.compter_erreurs(e, Regles.resoudre_tour(e, decl), decl, [], {}, out)
	assert_eq(out["degats"], [2, 1, 0, 0, 0, 0], "deux actions, un coup perdu (celui de a1)")
	# Un soin sur un allié à PV pleins, alors qu'un coup achevait b1 : soin perdu et achèvement raté.
	var s := duel_essai(essai([[[soin(200)]], [[deg(100)]]]))
	s.perso("b1")["pv"] = 50
	var decl_s := {"a1": jouer(s, "a1", 0, "", "a2")}
	out = {}
	Lib.compter_erreurs(s, Regles.resoudre_tour(s, decl_s), decl_s, [], {}, out)
	assert_eq(out["degats"], [1, 0, 1, 0, 0, 1], "soin perdu et achèvement raté")
	# Une barrière qui expire sans rien avoir absorbé (posée par une Clé : Clé gaspillée aussi).
	var b := duel_essai(essai([[[deg(10)], [deg(10)], [deg(10)], [barriere(200)]]]))
	b.perso("a1")["jalons"][0] = 3
	var suivi := {}
	out = {}
	var decl_b := {"a1": jouer(b, "a1", 0)}
	var b2 := Regles.resoudre_tour(b, decl_b)
	Lib.compter_erreurs(b, b2, decl_b, [], suivi, out)
	assert_true(suivi.has("a1"), "la barrière est suivie")
	for i in range(3):
		var avant := b2
		b2 = Regles.resoudre_tour(b2, {})
		Lib.compter_erreurs(avant, b2, {}, [], suivi, out)
	assert_false(suivi.has("a1"), "la barrière a expiré")
	assert_eq(out["degats"], [1, 0, 0, 1, 1, 0], "barrière inutile, posée par une Clé")


# La mesure « bon_sens » : l'IA de bon sens contre l'IA de la section 10, et le rapport.
func test_mesure_bon_sens() -> void:
	var part := Lib.simuler(donnees, "bon_sens", 0, 50, 1, 1, "trio")
	assert_eq(int(part["ab"][1]), 2, "deux duels sur cette part")
	var m := Lib.simuler(donnees, "matrice", 0, 50, 1, 1, "trio")
	var r := Lib.resumer(donnees, Lib.fusionner([JSON.parse_string(JSON.stringify(m)), JSON.parse_string(JSON.stringify(part))], donnees.ordre_classes.size()))
	assert_true(not r["erreurs"].is_empty(), "les erreurs sont comptées")
	var texte := Lib.rapport(donnees, r, "Essai", [])
	for morceau in ["Les erreurs de l'IA", "Coup perdu", "Achèvement raté", "L'IA de bon sens contre l'IA de la section 10"]:
		assert_true(texte.contains(morceau), "le rapport contient « %s »" % morceau)
	assert_true(IA.bon_sens, "le bon sens est remis après la mesure")
