## La fatigue et la potion d'énergie (docs/VISION.md § 7, décision de Gautier du 1er novembre ; engine/fatigue.gd) :
## la jauge, la récupération, le malus, l'écroulement et le réveil, le farm, la potion, le combat, le profil.
extends "res://tests/test_case.gd"

const T0 := 1_800_000_000


# Les données et un personnage reposé.
func test_donnees_et_etat_neuf() -> void:
	for erreur in donnees.erreurs:
		failures.append(erreur)
	assert_eq(int(donnees.fatigue["energie_max"]), 100, "cent points d'énergie")
	assert_eq(int(donnees.fatigue["cout_combat"]), 10, "dix par combat de farm : fatigué après dix combats")
	var f := Fatigue.neuf(T0, donnees)
	assert_true(Fatigue.etat_valide(f), "un état neuf est valide")
	assert_eq(Fatigue.energie(f, T0, donnees), 100, "reposé : toute l'énergie")
	assert_false(Fatigue.est_ecroule(f, T0, donnees), "reposé : debout")
	assert_eq(Fatigue.malus_actuel(f, T0, donnees), 0.0, "reposé : aucun malus")
	assert_true(Fatigue.peut_combattre(f, T0, donnees), "reposé : peut farmer")
	assert_eq(Fatigue.energie({}, T0, donnees), 100, "un état vide (profil d'avant) : un personnage reposé")
	assert_eq(Fatigue.energie({"energie": 3}, T0, donnees), 100, "un état abîmé : un personnage reposé")


# Le farm coûte de l'énergie ; à zéro, le personnage s'écroule ; l'énergie revient avec le temps, jamais au-delà du max.
func test_farm_ecroulement_et_repos() -> void:
	var f := Fatigue.neuf(T0, donnees)
	for i in range(9):
		f = Fatigue.apres_combat(f, T0, donnees)
		assert_true(Fatigue.peut_combattre(f, T0, donnees), "après %d combats : encore debout" % (i + 1))
	assert_eq(Fatigue.energie(f, T0, donnees), 10, "neuf combats : 10 points")
	f = Fatigue.apres_combat(f, T0, donnees)
	assert_eq(Fatigue.energie(f, T0, donnees), 0, "dix combats : à zéro")
	assert_true(Fatigue.est_ecroule(f, T0, donnees), "à zéro : écroulé")
	assert_false(Fatigue.peut_combattre(f, T0, donnees), "écroulé : plus de farm")
	assert_eq(Fatigue.secondes_reveil(f, T0, donnees), 2700, "réveil à 30 points : trois quarts d'heure (40 par heure)")
	# La récupération : 40 points par heure.
	assert_eq(Fatigue.energie(f, T0 + 1800, donnees), 20, "une demi-heure : 20 points")
	assert_true(Fatigue.est_ecroule(f, T0 + 1800, donnees), "à 20 : encore écroulé")
	assert_false(Fatigue.est_ecroule(f, T0 + 2700, donnees), "à 30 : réveillé")
	assert_true(Fatigue.peut_combattre(f, T0 + 2700, donnees), "réveillé : le farm reprend")
	assert_eq(Fatigue.energie(f, T0 + 9000, donnees), 100, "deux heures et demie : plein")
	assert_eq(Fatigue.energie(f, T0 + 36000, donnees), 100, "jamais au-delà du maximum")
	assert_eq(Fatigue.secondes_reveil(f, T0 + 2700, donnees), 0, "réveillé : rien à attendre")
	# Un état mis à jour garde l'instant ; le temps à l'envers ne retire rien.
	var g := Fatigue.a_jour(f, T0 + 1800, donnees)
	assert_eq(int(g["depuis"]), T0 + 1800, "l'instant de la mise à jour")
	assert_eq(Fatigue.energie(g, T0, donnees), 20, "une horloge qui recule ne change rien")
	# Presque à bout mais debout : le combat se joue, puis il s'écroule.
	var h := Fatigue.neuf(T0, donnees)
	h["energie"] = 5.0
	assert_true(Fatigue.peut_combattre(h, T0, donnees), "à 5 : encore un combat possible")
	assert_true(Fatigue.est_ecroule(Fatigue.apres_combat(h, T0, donnees), T0, donnees), "et après, écroulé")


# Le malus : rien au-dessus du seuil, puis jusqu'à 30 % à zéro.
func test_malus() -> void:
	assert_eq(Fatigue.malus(100.0, donnees), 0.0, "à 100 : rien")
	assert_eq(Fatigue.malus(50.0, donnees), 0.0, "au seuil : rien")
	assert_true(absf(Fatigue.malus(25.0, donnees) - 0.15) < 0.0001, "à 25 : −15 %")
	assert_true(absf(Fatigue.malus(0.0, donnees) - 0.3) < 0.0001, "à 0 : −30 %")
	var f := Fatigue.neuf(T0, donnees)
	f["energie"] = 40.0
	assert_true(absf(Fatigue.malus_actuel(f, T0, donnees) - 0.06) < 0.0001, "à 40 : −6 %")
	assert_eq(Fatigue.malus_actuel(f, T0 + 3600, donnees), 0.0, "une heure plus tard : en forme")


# Ce qui est du farm à la Tour : un étage au plus égal au record ; le record, jamais.
func test_farm_tour() -> void:
	assert_true(Fatigue.est_farm_tour(5, 12), "l'étage 5 avec un record de 12 : déjà franchi")
	assert_true(Fatigue.est_farm_tour(12, 12), "l'étage du record lui-même : déjà franchi")
	assert_false(Fatigue.est_farm_tour(13, 12), "l'étage 13 : le record, pas du farm")
	assert_false(Fatigue.est_farm_tour(1, 0), "sans record : rien n'est du farm")


# La potion : +50, trois par jour, relève un écroulé ; les textes.
func test_potion_et_textes() -> void:
	var f := Fatigue.neuf(T0, donnees)
	for i in range(10):
		f = Fatigue.apres_combat(f, T0, donnees)
	assert_eq(Fatigue.potions_restantes(f, "2026-11-02", donnees), 3, "trois potions par jour")
	assert_eq(Fatigue.prix_potion(donnees), {"eclats": 40, "or": 5}, "le prix : 40 Éclats ou 5 Or")
	f = Fatigue.boire(f, T0, "2026-11-02", donnees)
	assert_eq(Fatigue.energie(f, T0, donnees), 50, "une potion : +50")
	assert_false(Fatigue.est_ecroule(f, T0, donnees), "la potion relève un écroulé")
	assert_eq(Fatigue.potions_restantes(f, "2026-11-02", donnees), 2, "il en reste deux")
	f = Fatigue.boire(f, T0, "2026-11-02", donnees)
	assert_eq(Fatigue.energie(f, T0, donnees), 100, "deux potions : plein")
	f = Fatigue.boire(f, T0, "2026-11-02", donnees)
	assert_eq(Fatigue.energie(Fatigue.boire(f, T0, "2026-11-02", donnees), T0, donnees), 100, "jamais au-delà du maximum")
	assert_eq(Fatigue.potions_restantes(f, "2026-11-02", donnees), 0, "trois bues : plus rien")
	assert_false(Fatigue.peut_boire(f, "2026-11-02", donnees), "la quatrième est refusée")
	assert_eq(Fatigue.boire(f, T0, "2026-11-02", donnees), Fatigue.a_jour(f, T0, donnees), "refusée : l'état tel quel")
	assert_eq(Fatigue.potions_restantes(f, "2026-11-03", donnees), 3, "le lendemain : trois à nouveau")
	assert_eq(Fatigue.texte_duree(30), "moins d'une minute", "trente secondes")
	assert_eq(Fatigue.texte_duree(2700), "45 min", "trois quarts d'heure")
	assert_eq(Fatigue.texte_duree(7500), "2 h 05", "deux heures cinq")
	var r := Fatigue.neuf(T0, donnees)
	assert_eq(Fatigue.texte_energie(r, T0, donnees), "Énergie 100 / 100 · en forme", "reposé")
	r["energie"] = 25.0
	assert_eq(Fatigue.texte_energie(r, T0, donnees), "Énergie 25 / 100 · fatigué (−15 % sur tes PV et tes valeurs)", "fatigué")
	r["energie"] = 0.0
	r["ecroule"] = true
	assert_eq(Fatigue.texte_energie(r, T0, donnees), "Énergie 0 / 100 · écroulé de fatigue, réveil dans 45 min", "écroulé")


# Le malus entre dans un combat par le Destin : les PV max et le multiplicateur baissent ; en forme, rien ne change.
func test_fatigue_en_combat() -> void:
	var a := Generateur.generer("guerrier", 3, 10, Generateur.PAR_DEFAUT, donnees)
	var b := Generateur.generer("mage", 4, 10, Generateur.PAR_DEFAUT, donnees)
	var e0 := Regles.nouveau_combat([a], [b], 10, "pvp", donnees)
	var pv0 := int(e0.fiche("a1")["pv_max"])
	var k0 := float(e0.fiche("a1")["k"])
	a.fatigue = 0.2
	var e1 := Regles.nouveau_combat([a], [b], 10, "pvp", donnees)
	assert_eq(int(e1.fiche("a1")["pv_max"]), Regles.plancher(float(pv0) * 0.8), "−20 % : les PV max × 0,8")
	assert_true(absf(float(e1.fiche("a1")["k"]) - k0 * 0.8) < 0.0001, "−20 % : le multiplicateur × 0,8")
	assert_eq(float(e1.fiche("a1")["fatigue"]), 0.2, "la fiche du combat garde le malus")
	assert_eq(int(e1.fiche("b1")["pv_max"]), int(e0.fiche("b1")["pv_max"]), "l'adversaire n'a rien")
	a.fatigue = 0.0
	var e2 := Regles.nouveau_combat([a], [b], 10, "pvp", donnees)
	assert_eq(int(e2.fiche("a1")["pv_max"]), pv0, "en forme : les mêmes PV")
	# Le Destin se sérialise avec son malus.
	a.fatigue = 0.12
	assert_eq(Destin.depuis_dict(a.vers_dict()).fatigue, 0.12, "vers_dict / depuis_dict gardent la fatigue")
	assert_eq(Destin.depuis_dict({"classe_id": "mage", "nom": "x", "role": "degats", "graine": 1, "acolyte": false, "pv_base": 100, "pv_mult": 1.0, "k": 1.0, "moyeu": {}, "voies": []}).fatigue, 0.0, "un Destin d'avant : en forme")


# Le profil garde la fatigue et l'instant du jeu suit « Passer au lendemain » ; l'Or d'une potion est détruit.
func test_profil_et_economie() -> void:
	var chemin_avant := PlayerProfile.chemin
	PlayerProfile.chemin = "user://test_fatigue_profil.cfg"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PlayerProfile.chemin))
	var p := PlayerProfile.new()
	assert_true(p.fatigue.is_empty(), "un profil neuf : pas d'état (un personnage reposé)")
	var avant := p.maintenant()
	p.jours_avance = 2
	assert_true(p.maintenant() - avant >= 2 * 86400 and p.maintenant() - avant < 2 * 86400 + 5, "le lendemain décale l'instant du jeu")
	p.fatigue = Fatigue.apres_combat(Fatigue.neuf(T0, donnees), T0, donnees)
	p.save()
	var relu := PlayerProfile.load_profile()
	assert_eq(Fatigue.energie(relu.fatigue, T0, donnees), 90, "la fatigue relue")
	assert_eq(int(relu.fatigue["depuis"]), T0, "et son instant")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PlayerProfile.chemin))
	PlayerProfile.chemin = chemin_avant
	var m := Economie.mouvement("potion", 5, "2026-11-02")
	assert_true(Economie.mouvement_valide(m), "la potion en Or est un mouvement connu")
	assert_eq(int(Economie.bilan([m], Arene.semaine("2026-11-02"))["detruit"]), 5, "son Or est détruit")
