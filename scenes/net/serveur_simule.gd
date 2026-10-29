## Le serveur simulé (scenes/net/serveur.gd) : tant qu'il n'y a pas de vrai serveur, un monde de joueurs générés avec
## la graine de data/serveur.json (pseudo, classe, niveau, roue par défaut ; une évolution au-delà du niveau 30), et ta
## fiche gardée dans le profil. Tout répond tout de suite, sans réseau.
extends Serveur

var joueurs: Array = []


func _ready() -> void:
	_generer_joueurs()


func _generer_joueurs() -> void:
	joueurs.clear()
	var sim: Dictionary = donnees.serveur["simule"]
	var rng := RandomNumberGenerator.new()
	rng.seed = int(sim["graine"])
	var nb := int(sim["joueurs"])
	for i in range(nb):
		var classe: String = donnees.ordre_classes[rng.randi_range(0, donnees.ordre_classes.size() - 1)]
		var niveau := 1 + int(float(i) / float(maxi(1, nb - 1)) * float(int(sim["niveau_max"]) - 1))
		var graine := rng.randi_range(1, 0x7FFFFFFF)
		classe = Evolution.classe_au_niveau(classe, niveau, graine, donnees)
		joueurs.append({"id": "sim-%d" % (i + 1), "pseudo": Serveur.pseudo_defaut(graine, donnees), "classe": classe,
			"role": str(donnees.classe(classe)["role"]), "graine": str(graine), "niveau": niveau, "allumage": [], "equipement": [],
			"mis_a_jour": "2026-10-30"})


func mode() -> String:
	return "simule"


func connecter() -> bool:
	if compte_id == "":
		var rng := RandomNumberGenerator.new()
		rng.randomize()
		compte_id = "moi-%d" % rng.randi_range(1000, 999999)
		profile.serveur["compte"] = compte_id
		profile.save()
	return true


func publier(fiche: Dictionary) -> bool:
	if not est_connecte() or not Serveur.fiche_valide(fiche, donnees):
		erreur = "fiche incomplète"
		return false
	var copie := fiche.duplicate(true)
	copie["id"] = compte_id
	copie["mis_a_jour"] = Time.get_datetime_string_from_system()
	profile.serveur["fiche"] = copie
	profile.save()
	return true


func personnages(role: String, niveau: int, n: int) -> Array:
	var du_role: Array = joueurs.filter(func(f): return str(f["role"]) == role)
	return Serveur.plus_proches(du_role, niveau, n)


func nombre_personnages() -> int:
	return joueurs.size() + (1 if profile.serveur.has("fiche") else 0)
