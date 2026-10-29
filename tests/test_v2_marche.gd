## Le Marché (docs/GDD_V2.md, § 10.2 ; docs/PLAN.md, PR 5.5) : ouverture, fourchette, taxe, annonces simulées, et le
## serveur simulé (déposer, retirer, acheter, encaisser).
extends "res://tests/test_case.gd"


func _profil() -> PlayerProfile:
	PlayerProfile.chemin = "user://test_profil_marche.cfg"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PlayerProfile.chemin))
	return PlayerProfile.new()


func _objet(rarete: String = "rare") -> Dictionary:
	return Equipement.tirer("epee", rarete, 20, 5, donnees, false)


# Les règles : ouvert au niveau 15 et après 7 jours ; ce qui manque ; le prix dans la fourchette ; la taxe.
func test_regles() -> void:
	assert_eq(donnees.erreurs, [] as Array[String], "aucune erreur de données")
	assert_false(Marche.ouvert(14, 10, donnees), "fermé avant le niveau 15")
	assert_false(Marche.ouvert(20, 6, donnees), "fermé avant 7 jours de compte")
	assert_true(Marche.ouvert(15, 7, donnees), "ouvert au niveau 15 et 7 jours")
	assert_eq(Marche.manque(15, 7, donnees), "", "rien ne manque")
	assert_true("niveau 15" in Marche.manque(12, 7, donnees) and not "jours" in Marche.manque(12, 7, donnees), "il manque le niveau")
	assert_true("encore 4 jours" in Marche.manque(20, 3, donnees), "il manque des jours")
	var o := _objet()
	var f := Comptoir.fourchette_marche(o, donnees)
	assert_true(Marche.prix_valide(o, int(f[0]), donnees) and Marche.prix_valide(o, int(f[1]), donnees), "les bornes sont permises")
	assert_false(Marche.prix_valide(o, int(f[0]) - 1, donnees) or Marche.prix_valide(o, int(f[1]) + 1, donnees), "hors fourchette : refusé")
	var lie := o.duplicate(true)
	lie["lie"] = true
	assert_false(Marche.prix_valide(lie, int(f[0]), donnees), "un objet lié ne se vend pas")
	assert_eq(Marche.taxe(100, donnees), 15, "15 % de taxe")
	assert_eq(Marche.taxe(1, donnees), 1, "arrondie au-dessus")
	assert_eq(Marche.net(100, donnees), 85, "le vendeur touche le reste")
	var a := Marche.annonce(o, int(f[0]), "moi", "a1")
	assert_true(Marche.annonce_valide(a, donnees), "une annonce valide")
	assert_false(bool(a["objet"]["lie"]), "l'objet d'une annonce est échangeable")
	a["prix"] = int(f[1]) + 100
	assert_false(Marche.annonce_valide(a, donnees), "un prix hors fourchette : annonce refusée")


# Les annonces simulées : le bon nombre, toutes valides et anonymes dans leur forme, les mêmes pour une même date.
func test_annonces_simulees() -> void:
	var joueurs: Array = []
	for i in range(5):
		joueurs.append({"id": "sim-%d" % i, "niveau": 5 + 8 * i})
	var a := Marche.annonces_simulees(joueurs, "2026-10-30", donnees)
	assert_eq(a.size(), int(donnees.marche["simule"]["annonces"]), "le nombre d'annonces")
	var raretes := {}
	for x in a:
		assert_true(Marche.annonce_valide(x, donnees), x["id"] + " : valide")
		raretes[str(x["rarete"])] = true
	assert_true(raretes.size() >= 2, "plusieurs raretés")
	assert_eq(JSON.stringify(Marche.annonces_simulees(joueurs, "2026-10-30", donnees)), JSON.stringify(a), "même date, mêmes annonces")
	assert_ne(JSON.stringify(Marche.annonces_simulees(joueurs, "2026-10-31", donnees)), JSON.stringify(a), "une autre date, d'autres annonces")
	assert_eq(Marche.annonces_simulees([], "2026-10-30", donnees).size(), 0, "sans joueurs, rien")


# Le serveur simulé : déposer, voir ses annonces, retirer (l'objet revient), acheter (une fois seulement), encaisser.
func test_serveur_simule() -> void:
	var profile := _profil()
	var s: Serveur = Serveur.creer(donnees, profile)
	s._ready()
	await s.connecter()
	var avant: Array = await s.annonces(50)
	assert_true(avant.size() >= 3, "des annonces simulées")
	for a in avant:
		assert_false(bool(a.get("mienne", false)), "aucune n'est à moi")
	var o := _objet("epique")
	var prix := int(Comptoir.fourchette_marche(o, donnees)[0]) + 3
	var mienne := Marche.annonce(o, prix, s.compte_id, "moi-1")
	assert_true(await s.deposer(mienne), "déposée")
	var apres: Array = await s.annonces(50)
	assert_eq(apres.size(), avant.size() + 1, "une de plus")
	var trouvee := false
	for a in apres:
		if str(a["id"]) == "moi-1":
			trouvee = bool(a.get("mienne", false))
	assert_true(trouvee, "la mienne est marquée")
	assert_true((await s.acheter("moi-1")).is_empty(), "je n'achète pas ma propre annonce")
	var cible: Dictionary = avant[0]
	var achetee: Dictionary = await s.acheter(str(cible["id"]))
	assert_eq(str(achetee.get("id", "")), str(cible["id"]), "achetée")
	assert_true((await s.acheter(str(cible["id"]))).is_empty(), "plus disponible : au premier acheteur")
	assert_eq((await s.annonces(50)).size(), avant.size(), "elle a disparu de la liste")
	var retiree: Dictionary = await s.retirer("moi-1")
	assert_eq(str(retiree.get("id", "")), "moi-1", "retirée")
	assert_true((await s.retirer("moi-1")).is_empty(), "plus rien à retirer")
	assert_true((await s.encaisser()) is Array, "encaisser répond")
	s.free()
