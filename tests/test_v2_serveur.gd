## Le lien au serveur (docs/PLAN.md, phase 5, PR 5.1) : les fiches, le serveur simulé, les chemins du vrai serveur.
extends "res://tests/test_case.gd"

const ServeurSimule := preload("res://scenes/net/serveur_simule.gd")
const ServeurSupabase := preload("res://scenes/net/serveur_supabase.gd")


func _profil() -> PlayerProfile:
	PlayerProfile.chemin = "user://test_profil_serveur.cfg"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PlayerProfile.chemin))
	return PlayerProfile.new()


func _simule(profile: PlayerProfile) -> Serveur:
	var s: Serveur = Serveur.creer(donnees, profile)
	s._ready()
	return s


# Les données : sans adresse, le serveur créé est le simulé ; les mots de pseudo ; les pseudos par défaut.
func test_donnees_et_pseudos() -> void:
	assert_eq(donnees.erreurs, [] as Array[String], "aucune erreur de données")
	assert_eq(str(donnees.serveur["url"]), "", "pas encore d'adresse : serveur simulé")
	var s := _simule(_profil())
	assert_eq(s.mode(), "simule", "le serveur simulé")
	assert_eq(Serveur.pseudo_defaut(7, donnees), Serveur.pseudo_defaut(7, donnees), "même graine, même pseudo")
	assert_ne(Serveur.pseudo_defaut(7, donnees), Serveur.pseudo_defaut(8, donnees), "graines différentes, pseudos différents")
	assert_true(Serveur.pseudo_valide("Aube 427") and Serveur.pseudo_valide("  Ok "), "des pseudos acceptables")
	assert_false(Serveur.pseudo_valide("A") or Serveur.pseudo_valide("Un pseudo beaucoup trop long"), "trop court ou trop long")
	s.free()


# Le monde simulé : des joueurs de toutes les classes et des trois rôles, du niveau 1 au niveau le plus haut, évolués
# au-delà du niveau 30 ; les plus proches d'un niveau d'abord.
func test_monde_simule() -> void:
	var s := _simule(_profil())
	var joueurs: Array = s.joueurs
	assert_eq(joueurs.size(), int(donnees.serveur["simule"]["joueurs"]), "le nombre de joueurs")
	var roles := {}
	for f in joueurs:
		assert_true(Serveur.fiche_valide(f, donnees), f["pseudo"] + " : une fiche valide")
		roles[str(f["role"])] = true
		assert_eq(Evolution.rang(str(f["classe"]), donnees), Evolution.rang_du_niveau(int(f["niveau"]), donnees), f["pseudo"] + " : évolué si son niveau le veut")
	assert_eq(roles.size(), 3, "les trois rôles")
	var fronts := await s.personnages("front", 10, 3)
	assert_eq(fronts.size(), 3, "trois Fronts")
	for f in fronts:
		assert_eq(str(f["role"]), "front", "du bon rôle")
	assert_true(absi(int(fronts[0]["niveau"]) - 10) <= absi(int(fronts[2]["niveau"]) - 10), "les plus proches du niveau d'abord")
	assert_eq(s.nombre_personnages(), joueurs.size(), "sans fiche publiée : les joueurs simulés seuls")
	s.free()


# Le compte simulé : créé à la première connexion, gardé dans le profil ; la fiche publiée est gardée et comptée ; une
# fiche incomplète est refusée.
func test_compte_et_publication() -> void:
	var profile := _profil()
	var s := _simule(profile)
	assert_false(s.est_connecte(), "pas connecté au départ")
	assert_true(await s.connecter(), "la connexion")
	assert_true(s.est_connecte() and str(profile.serveur["compte"]) == s.compte_id, "le compte est dans le profil")
	var fiche := {"id": "", "pseudo": "Aube 427", "classe": "mage", "role": "degats", "graine": "123456789012345678", "niveau": 12, "allumage": ["v1.n2"], "equipement": []}
	assert_true(Serveur.fiche_valide(fiche, donnees), "une fiche valide")
	assert_true(await s.publier(fiche), "la publication")
	assert_eq(str(profile.serveur["fiche"]["id"]), s.compte_id, "la fiche publiée porte le compte")
	assert_eq(s.nombre_personnages(), s.joueurs.size() + 1, "ma fiche est comptée")
	var mauvaise := fiche.duplicate()
	mauvaise["classe"] = "dragon"
	assert_false(await s.publier(mauvaise), "une classe inconnue est refusée")
	mauvaise = fiche.duplicate()
	mauvaise.erase("graine")
	assert_false(Serveur.fiche_valide(mauvaise, donnees), "une clé manquante est refusée")
	# Le Destin d'une fiche : sa classe, sa graine, son niveau, ses nœuds, marqué Écho.
	var d := Serveur.destin_de(fiche, donnees)
	assert_eq(d.classe_id, "mage", "la classe")
	assert_true(d.echo, "un Écho")
	assert_true(bool(d.voies[0]["noeuds"][1]["allume"]), "son nœud allumé")
	# Un autre serveur sur le même profil retrouve le compte.
	var encore := _simule(profile)
	assert_eq(encore.compte_id, s.compte_id, "le compte est retrouvé")
	s.free()
	encore.free()


# Le vrai serveur : les chemins de lecture (rôle, fourchette de niveau, pas sa propre fiche).
func test_chemins_supabase() -> void:
	var chemin := ServeurSupabase.chemin_personnages("personnages", "front", 12, 3, "abc")
	assert_true(chemin.begins_with("/rest/v1/personnages?select=*&role=eq.front&niveau=gte.2&niveau=lte.22"), "le chemin : " + chemin)
	assert_true("&id=neq.abc" in chemin and "limit=12" in chemin, "sans ma fiche, quatre fois plus de lignes que demandé")
	assert_false("neq" in ServeurSupabase.chemin_personnages("personnages", "front", 1, 3, ""), "sans compte, pas de filtre")
	assert_true("niveau=gte.1&" in ServeurSupabase.chemin_personnages("personnages", "front", 1, 3, ""), "jamais sous le niveau 1")
