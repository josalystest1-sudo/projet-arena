## Le serveur simulé (scenes/net/serveur.gd) : tant qu'il n'y a pas de vrai serveur, un monde de joueurs générés avec
## la graine de data/serveur.json (pseudo, classe, niveau, roue par défaut ; une évolution au-delà du niveau 30), et ta
## fiche gardée dans le profil. Le Marché : les annonces du jour sont tirées avec la date (engine/marche.gd) ; celles
## que tu achètes disparaissent (gardées dans le profil) ; tes annonces vivent dans le profil, et le monde simulé en
## achète une de temps en temps (une chance par jour, tirée avec la date et l'identifiant). Tout répond tout de suite.
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


func selectionner(id: String) -> bool:
	var faites: Dictionary = profile.serveur.get("selections_faites", {})
	faites[id] = int(faites.get(id, 0)) + 1
	profile.serveur["selections_faites"] = faites
	profile.save()
	return true


func adversaires(niveau: int, n: int) -> Array:
	return Serveur.plus_proches(joueurs, niveau, n)


## Le classement simulé : des points tirés pour chaque joueur avec sa graine et la saison (de 0 à 10 + 8 × niveau), et
## ta fiche si elle est publiée pour cette saison.
func classement(saison: int, n: int) -> Array:
	var fiches: Array = []
	for f in joueurs:
		var copie: Dictionary = f.duplicate()
		var rng := RandomNumberGenerator.new()
		rng.seed = int(str(f["graine"])) * 31 + saison
		copie["points"] = rng.randi_range(0, 10 + 8 * int(f["niveau"]))
		copie["saison"] = saison
		fiches.append(copie)
	var mienne: Dictionary = profile.serveur.get("fiche", {})
	if not mienne.is_empty() and int(mienne.get("saison", -1)) == saison:
		fiches.append(mienne)
	return Serveur.par_points(fiches, n)


func annonces(n: int) -> Array:
	var jour := Time.get_date_string_from_system()
	var achetees: Array = profile.serveur.get("achetees", [])
	var out: Array = []
	for a in Marche.annonces_simulees(joueurs, jour, donnees):
		if not achetees.has(str(a["id"])):
			out.append(a)
	for a in profile.serveur.get("annonces", []):
		if not bool(a.get("vendu", false)):
			var copie: Dictionary = a.duplicate(true)
			copie["mienne"] = true
			out.append(copie)
	return out.slice(0, n)


func deposer(annonce: Dictionary) -> bool:
	if not est_connecte() or not Marche.annonce_valide(annonce, donnees):
		erreur = "annonce refusée"
		return false
	var miennes: Array = profile.serveur.get("annonces", [])
	var copie := annonce.duplicate(true)
	copie["vendeur"] = compte_id
	copie["jour"] = Time.get_date_string_from_system()
	copie["vendu"] = false
	copie["encaisse"] = false
	miennes.append(copie)
	profile.serveur["annonces"] = miennes
	profile.save()
	return true


func retirer(id: String) -> Dictionary:
	var miennes: Array = profile.serveur.get("annonces", [])
	for i in range(miennes.size()):
		var a: Dictionary = miennes[i]
		if str(a["id"]) == id and not bool(a.get("vendu", false)):
			miennes.remove_at(i)
			profile.serveur["annonces"] = miennes
			profile.save()
			return a
	return {}


func acheter(id: String) -> Dictionary:
	for a in annonces(1000):
		if str(a["id"]) != id or bool(a.get("mienne", false)):
			continue
		var achetees: Array = profile.serveur.get("achetees", [])
		achetees.append(id)
		profile.serveur["achetees"] = achetees
		profile.save()
		return a
	return {}


## Le monde simulé achète : chaque jour après celui du dépôt, une annonce a une chance (vente_par_jour) d'être vendue,
## tirée avec la date et son identifiant ; les ventes pas encore encaissées sont rendues et marquées.
func encaisser() -> Array:
	var jour := Time.get_date_string_from_system()
	var miennes: Array = profile.serveur.get("annonces", [])
	var out: Array = []
	var change := false
	for a in miennes:
		if not bool(a.get("vendu", false)) and str(a.get("jour", jour)) != jour:
			var rng := RandomNumberGenerator.new()
			rng.seed = (jour + str(a["id"])).hash()
			if rng.randf_range(0.0, 1.0) < float(donnees.marche["simule"]["vente_par_jour"]):
				a["vendu"] = true
				change = true
		if bool(a.get("vendu", false)) and not bool(a.get("encaisse", false)):
			a["encaisse"] = true
			change = true
			out.append({"annonce": a.duplicate(true), "net": Marche.net(int(a["prix"]), donnees)})
	if change:
		profile.serveur["annonces"] = miennes
		profile.save()
	return out


func nombre_personnages() -> int:
	return joueurs.size() + (1 if profile.serveur.has("fiche") else 0)
