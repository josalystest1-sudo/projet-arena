## Les guerres de guilde (docs/GDD_V2.md, § 9.3 et 9.4 ; engine/guerre.gd) : déclarer, les combats et le score, le
## résultat, la carte qui change, la protection, les territoires qui redeviennent neutres, les attaques du monde ; le serveur
## simulé (une bataille de bout en bout, la résolution le lendemain, les revenus).
extends "res://tests/test_case.gd"


func _profil() -> PlayerProfile:
	PlayerProfile.chemin = "user://test_profil_guerre.cfg"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PlayerProfile.chemin))
	return PlayerProfile.new()


func _simule(profile: PlayerProfile) -> Serveur:
	var s: Serveur = Serveur.creer(donnees, profile)
	s._ready()
	return s


func _guilde(id: String, n: int) -> Dictionary:
	var g := Guilde.nouvelle(id, "Guilde " + id, Guilde.banniere_defaut(id.hash(), donnees), {"id": id + "-chef", "pseudo": "Chef", "classe": "mage", "niveau": 10}, "2026-11-01", donnees)
	for i in range(n - 1):
		g["membres"].append({"id": "%s-%d" % [id, i], "pseudo": "M%d" % i, "classe": "mage", "niveau": 10, "role": "membre", "depuis": "2026-11-01"})
	return g


func _fiche(id: String, niveau: int = 10, graine: int = 3) -> Dictionary:
	return {"id": id, "pseudo": "P" + id, "classe": "guerrier", "role": "front", "graine": str(graine), "niveau": niveau, "allumage": [], "equipement": []}


# Déclarer : les attaques par soir, les empêchements (la carte, la protection, la taille, une par territoire, le maximum).
func test_declarer() -> void:
	for erreur in donnees.erreurs:
		failures.append(erreur)
	assert_eq(Guerre.attaques_max(1, donnees), 1, "une guilde d'un membre : une attaque")
	assert_eq(Guerre.attaques_max(45, donnees), 3, "quarante-cinq membres : trois attaques")
	var petite := _guilde("p", 3)
	var grande := _guilde("g", 12)
	var etat := {"hameau": {"guilde": "p", "nom": "Guilde p", "banniere": {}, "depuis": "2026-11-01"}, "gue": {"guilde": "x", "nom": "Eux", "banniere": {}, "depuis": "2026-11-01"}}
	assert_eq(Guerre.empeche(etat, {}, {}, "clairiere", "2026-11-05", [], donnees), "il faut une guilde", "sans guilde")
	assert_eq(Guerre.empeche(etat, {}, petite, "clairiere", "2026-11-05", [], donnees), "", "un voisin neutre : oui")
	assert_true(Guerre.empeche(etat, {}, petite, "cratere", "2026-11-05", [], donnees).begins_with("on ne vise"), "un territoire loin des siens : non")
	assert_true(Guerre.empeche(etat, {}, petite, "gue", "2026-11-05", [], donnees).begins_with("il faut 10 membres"), "trois membres n'attaquent pas un territoire tenu")
	etat["hameau"]["guilde"] = "g"
	assert_eq(Guerre.empeche(etat, {}, grande, "gue", "2026-11-05", [], donnees), "", "douze membres : un territoire tenu voisin, oui")
	assert_true(Guerre.empeche(etat, {"gue": "2026-11-06"}, grande, "gue", "2026-11-05", [], donnees).begins_with("ce territoire est protégé"), "protégé")
	assert_eq(Guerre.empeche(etat, {"gue": "2026-11-04"}, grande, "gue", "2026-11-05", [], donnees), "", "la protection est passée")
	var b := Guerre.nouvelle_bataille("b1", "2026-11-05", "gue", grande, {"id": "x", "nom": "Eux"}, 1)
	assert_true(Guerre.bataille_valide(b), "une bataille valide")
	assert_true(Guerre.empeche(etat, {}, grande, "gue", "2026-11-05", [b], donnees).begins_with("la guilde attaque déjà"), "pas deux fois le même territoire")
	assert_true(Guerre.empeche(etat, {}, grande, "clairiere", "2026-11-05", [b], donnees).begins_with("la guilde a déclaré toutes"), "une attaque pour douze membres : plus d'attaque")
	var sans := _guilde("s", 2)
	assert_eq(Guerre.empeche({"gue": etat["gue"]}, {}, sans, "cratere", "2026-11-05", [], donnees), "", "sans territoire : un neutre quelconque")
	assert_true(Guerre.empeche({"gue": etat["gue"]}, {}, sans, "gue", "2026-11-05", [], donnees) != "", "sans territoire : pas un territoire tenu")


# Les combats et le score : trois par membre, le poids d'une victoire, le défenseur tiré (trois défenses au plus),
# le résultat (neutre, tenu, le Bastion), la carte qui change et la protection, les territoires qui redeviennent neutres.
func test_combats_score_resultat() -> void:
	var att := _guilde("a", 2)
	var b := Guerre.nouvelle_bataille("b1", "2026-11-05", "gue", att, {"id": "x", "nom": "Eux"}, 1)
	assert_eq(Guerre.reste(b, "a-chef", "attaquant", donnees), 3, "trois combats par soir")
	assert_almost(Guerre.poids(30, donnees), 2.0, "un adversaire de niveau 30 pèse 2")
	assert_almost(Guerre.poids(15, donnees), 1.5, "de niveau 15 : 1,5")
	b = Guerre.enregistrer(b, "a-chef", "attaquant", true, 30, "x-1", donnees)
	b = Guerre.enregistrer(b, "a-chef", "attaquant", false, 30, "x-1", donnees)
	b = Guerre.enregistrer(b, "a-chef", "attaquant", true, 15, "x-2", donnees)
	assert_eq(Guerre.reste(b, "a-chef", "attaquant", donnees), 0, "ses trois combats sont faits")
	assert_eq(Guerre.combats_de(b, "a-0", "attaquant"), 0, "l'autre membre n'a rien fait")
	assert_almost(Guerre.score(b, "attaquant"), 3.5, "le score des attaquants : 2 + 1,5")
	assert_almost(Guerre.score(b, "defenseur"), 0.0, "rien en face")
	assert_eq(Guerre.defenses_de(b, "x-1"), 2, "x-1 a défendu deux fois")
	var membres := [_fiche("x-1"), _fiche("x-2")]
	for i in range(3):
		b = Guerre.enregistrer(b, "a-0", "attaquant", false, 10, str(Guerre.defenseur(b, membres, i, donnees)["id"]), donnees)
	assert_eq(Guerre.defenses_de(b, "x-1") + Guerre.defenses_de(b, "x-2"), 6, "six défenses en tout")
	assert_true(Guerre.defenses_de(b, "x-1") <= 3 + 1, "x-1 ne défend pas bien plus de trois fois")
	assert_true(Guerre.defenseur(b, [], 1, donnees).is_empty(), "un territoire neutre : personne ne défend")
	# Le résultat.
	var etat := {"gue": {"guilde": "x", "nom": "Eux", "banniere": {}, "depuis": "2026-11-01"}}
	assert_eq(Guerre.resultat(b, etat, donnees), "attaquant", "3,5 contre 0 × 1,2 : pris")
	var b2 := Guerre.enregistrer(b, "x-1", "defenseur", true, 30, "a-chef", donnees)
	b2 = Guerre.enregistrer(b2, "x-2", "defenseur", true, 30, "a-chef", donnees)
	assert_eq(Guerre.resultat(b2, etat, donnees), "defenseur", "3,5 contre 4 × 1,2 : il tient")
	assert_almost(Guerre.coefficient_defense(etat, "gue", donnees), 1.2, "la défense d'un territoire tenu")
	var etat_bastion := etat.duplicate(true)
	etat_bastion["tour_de_guet"] = {"guilde": "x", "nom": "Eux", "banniere": {}, "depuis": "2026-11-01"}
	assert_almost(Guerre.coefficient_defense(etat_bastion, "gue", donnees), 1.5, "un Bastion voisin tenu par le même : 1,5")
	assert_almost(Guerre.coefficient_defense(etat, "clairiere", donnees), 1.0, "un territoire neutre : 1")
	var neutre := Guerre.nouvelle_bataille("b3", "2026-11-05", "clairiere", att, {}, 1)
	assert_eq(Guerre.resultat(neutre, etat, donnees), "neutre", "aucune victoire : personne ne prend")
	neutre = Guerre.enregistrer(neutre, "a-chef", "attaquant", true, 10, "garde-1", donnees)
	assert_eq(Guerre.resultat(neutre, etat, donnees), "attaquant", "une victoire : le territoire neutre est pris")
	# La carte après la bataille, la protection.
	var apres := Guerre.appliquer(etat, {}, b, "attaquant", "2026-11-06", donnees)
	assert_eq(str(apres["etat"]["gue"]["guilde"]), "a", "le Gué change de main")
	assert_eq(str(apres["etat"]["gue"]["depuis"]), "2026-11-06", "depuis le lendemain")
	assert_eq(str(apres["protections"]["gue"]), "2026-11-08", "protégé deux jours")
	assert_eq(Guerre.appliquer(etat, {}, b2, "defenseur", "2026-11-06", donnees)["etat"], etat, "le défenseur tient : rien ne bouge")
	assert_eq(Guerre.jour_plus("2026-11-30", 2), "2026-12-02", "deux jours plus tard")
	# Les territoires sans combat depuis sept jours.
	var vieux := {"gue": {"guilde": "x", "nom": "Eux", "banniere": {}, "depuis": "2026-11-01"}, "hameau": {"guilde": "x", "nom": "Eux", "banniere": {}, "depuis": "2026-11-01"}}
	var neutralise := Guerre.neutraliser(vieux, {"hameau": "2026-11-07"}, "2026-11-09", donnees)
	assert_false(neutralise.has("gue"), "le Gué, sans combat depuis huit jours, redevient neutre")
	assert_true(neutralise.has("hameau"), "le Hameau s'est battu il y a deux jours : il reste")
	assert_true(Guerre.neutraliser({"gue": {"guilde": "x", "nom": "Eux", "banniere": {}, "depuis": "saison 0"}}, {}, "2026-11-09", donnees).has("gue"), "une prise de début de saison n'a pas de date : elle reste")


# Un combat de guerre joué par l'IA, et les attaques des guildes du monde.
func test_combat_ia_et_attaques_du_monde() -> void:
	var fort := _fiche("fort", 30, 5)
	var faible := _fiche("faible", 5, 6)
	var gagnes := 0
	for g in range(1, 6):
		if Guerre.combat_ia(fort, faible, g, donnees):
			gagnes += 1
	assert_true(gagnes >= 4, "un niveau 30 bat un niveau 5 (%d sur 5)" % gagnes)
	assert_eq(Guerre.combat_ia(fort, faible, 1, donnees), Guerre.combat_ia(fort, faible, 1, donnees), "même graine, même combat")
	var guildes := [{"id": "g1", "nom": "Les Uns", "banniere": {}, "membres": 6}, {"id": "g2", "nom": "Les Autres", "banniere": {}, "membres": 6}]
	var etat := {"hameau": {"guilde": "g1", "nom": "Les Uns", "banniere": {}, "depuis": "2026-11-01"}}
	var att := Guerre.attaques_simulees(guildes, etat, {}, "2026-11-05", donnees)
	assert_eq(att.size(), int(donnees.guerre["simule"]["attaques_par_jour"]), "une attaque du monde par soir")
	assert_eq(Guerre.attaques_simulees(guildes, etat, {}, "2026-11-05", donnees), att, "même jour, même attaque")
	for a in att:
		assert_eq(Guerre.empeche(etat, {}, a["attaquant"], str(a["territoire"]), "2026-11-05", [], donnees), "", "une attaque permise")
	assert_true(Guerre.attaques_simulees([], etat, {}, "2026-11-05", donnees).is_empty(), "sans guilde, rien")


# Le serveur simulé : les batailles du monde se jouent seules ; ta guilde déclare une attaque sur un territoire neutre,
# tu joues tes combats, le lendemain le territoire est pris et protégé ; tes territoires rapportent.
func test_serveur_simule() -> void:
	var profile := _profil()
	var s := _simule(profile)
	await s.connecter()
	await s.publier({"id": s.compte_id, "pseudo": "Moi", "classe": "guerrier", "role": "front", "graine": "7", "niveau": 12, "allumage": [], "equipement": []})
	var g: Dictionary = await s.creer_guilde("Les Nôtres", Guilde.banniere_defaut(1, donnees), {"id": s.compte_id, "pseudo": "Moi", "classe": "guerrier", "niveau": 12})
	assert_false(g.is_empty(), "ma guilde")
	var jour := Time.get_date_string_from_system()
	var liste: Array = await s.batailles(jour)
	assert_eq(liste.size(), int(donnees.guerre["simule"]["attaques_par_jour"]), "les batailles du monde ce soir")
	assert_true(liste[0]["combats"].size() > 0, "jouées par l'IA")
	assert_eq(await s.batailles(jour), liste, "la même liste à la seconde lecture")
	# Une cible neutre pour moi (sans territoire : n'importe quel neutre ouvert).
	var saison := Arene.saison(jour, donnees)
	var etat: Dictionary = await s.territoires(saison)
	var cible := ""
	for t in Carte.territoires_ouverts(await s.nombre_guildes(), donnees):
		if not etat.has(str(t["id"])) and Guerre.empeche(etat, s.protections(), g, str(t["id"]), jour, liste, donnees) == "":
			cible = str(t["id"])
			break
	assert_true(cible != "", "un territoire neutre à viser")
	assert_true((await s.declarer_guerre("nulle_part")).is_empty(), "un territoire inconnu : refusé")
	var b: Dictionary = await s.declarer_guerre(cible)
	assert_false(b.is_empty(), "l'attaque est déclarée (%s)" % s.erreur)
	assert_true((await s.declarer_guerre(cible)).is_empty(), "pas deux fois")
	assert_eq((await s.batailles(jour)).size(), liste.size() + 1, "une bataille de plus ce soir")
	for i in range(3):
		var c: Dictionary = await s.combat_guerre(str(b["id"]))
		assert_false(c.is_empty(), "combat %d : un adversaire" % (i + 1))
		assert_true(str(c["adversaire"]["id"]).begins_with("garde-"), "un garde du territoire neutre")
		b = await s.resultat_guerre(str(b["id"]), true)
		assert_eq(b["combats"].size(), i + 1, "le combat est noté")
	assert_true((await s.combat_guerre(str(b["id"]))).is_empty(), "plus de combat ce soir")
	assert_true((await s.resultat_guerre(str(b["id"]), true)).is_empty(), "rien en cours : rien à noter")
	assert_true(Guerre.score(b, "attaquant") > 0.0, "un score")
	assert_false(Carte.tenus_par(await s.territoires(saison), str(g["id"])).has(cible), "pas encore pris : le résultat tombe demain")
	# Le lendemain : la bataille est résolue, le territoire est à moi, protégé ; ses revenus arrivent.
	var demain := Guerre.jour_plus(jour, 1)
	var suite: Array = await s.batailles(demain)
	assert_eq(suite.size(), int(donnees.guerre["simule"]["attaques_par_jour"]), "les batailles du lendemain")
	assert_true(Carte.tenus_par(await s.territoires(saison), str(g["id"])).has(cible), "le territoire est pris")
	assert_eq(str(s.protections().get(cible, "")), Guerre.jour_plus(demain, 2), "protégé deux jours")
	var apres_demain := Guerre.jour_plus(jour, 2)
	await s.batailles(apres_demain)
	var mienne: Dictionary = await s.ma_guilde()
	var ter := Carte.territoire(cible, donnees)
	if str(ter["type"]) == "mine":
		assert_true(int(mienne["influence"]) > 0, "une Mine rapporte de l'Influence")
	elif str(ter["type"]) == "sanctuaire":
		assert_true((await s.xp_territoires()) > 0, "un Sanctuaire rapporte de l'XP")
		assert_eq(await s.xp_territoires(), 0, "rendue une fois")
	s.free()
