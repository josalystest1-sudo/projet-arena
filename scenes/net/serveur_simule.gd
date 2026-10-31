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
func encaisser(taux: float = -1.0) -> Array:
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
			out.append({"annonce": a.duplicate(true), "net": Marche.net(int(a["prix"]), donnees, taux)})
	if change:
		profile.serveur["annonces"] = miennes
		profile.save()
	return out


func nombre_personnages() -> int:
	return joueurs.size() + (1 if profile.serveur.has("fiche") else 0)


# --- Les guildes : ta guilde vit dans le profil ; les autres sont celles du monde simulé (engine/guilde.gd). ------------

func _guildes_du_monde() -> Array:
	return Guilde.guildes_simulees(joueurs, Time.get_date_string_from_system(), donnees)


func guildes(n: int) -> Array:
	var out: Array = []
	var mienne: Dictionary = profile.serveur.get("guilde", {})
	for g in _guildes_du_monde():
		if not mienne.is_empty() and str(g["id"]) == str(mienne["id"]):
			continue
		out.append(Serveur.resume_guilde(g, donnees))
	if not mienne.is_empty():
		out.push_front(Serveur.resume_guilde(mienne, donnees))
	return out.slice(0, n)


## Ta guilde ; ses membres simulés apportent leur Influence pour chaque jour passé depuis la dernière lecture.
func ma_guilde() -> Dictionary:
	var g: Dictionary = profile.serveur.get("guilde", {})
	if g.is_empty():
		return {}
	var jour := Time.get_date_string_from_system()
	var dernier := str(g.get("dernier_jour", jour))
	var n_jours := Arene.jours(jour) - Arene.jours(dernier)
	if n_jours > 0:
		g = Guilde.gagner(g, Guilde.influence_simulee(g, jour, n_jours, donnees))
	g["dernier_jour"] = jour
	profile.serveur["guilde"] = g
	profile.save()
	return g.duplicate(true)


func _garder_guilde(g: Dictionary) -> Dictionary:
	if g.is_empty() or Guilde.membre(g, compte_id).is_empty():
		profile.serveur.erase("guilde")
	else:
		g["dernier_jour"] = Time.get_date_string_from_system()
		profile.serveur["guilde"] = g
	profile.save()
	return g.duplicate(true) if profile.serveur.has("guilde") else {}


func creer_guilde(nom: String, banniere: Dictionary, fiche: Dictionary) -> Dictionary:
	if not est_connecte() or profile.serveur.has("guilde") or not Guilde.nom_valide(nom, donnees) or not Guilde.banniere_valide(banniere, donnees):
		erreur = "guilde refusée"
		return {}
	for g in _guildes_du_monde():
		if str(g["nom"]).to_lower() == nom.strip_edges().to_lower():
			erreur = "ce nom est déjà pris"
			return {}
	var jour := Time.get_date_string_from_system()
	return _garder_guilde(Guilde.nouvelle("g-%s-%d" % [compte_id, Time.get_unix_time_from_system()], nom, banniere, fiche, jour, donnees))


func rejoindre_guilde(id: String, fiche: Dictionary) -> Dictionary:
	if not est_connecte() or profile.serveur.has("guilde"):
		return {}
	for g in _guildes_du_monde():
		if str(g["id"]) == id:
			var avec := Guilde.ajouter(g, fiche, Time.get_date_string_from_system(), donnees)
			if avec.get("membres", []).size() == g["membres"].size():
				erreur = "plus de place"
				return {}
			return _garder_guilde(avec)
	return {}


func quitter_guilde() -> bool:
	var g: Dictionary = profile.serveur.get("guilde", {})
	if g.is_empty():
		return false
	_garder_guilde(Guilde.retirer(g, compte_id))
	return true


func influence_guilde(gain: int) -> bool:
	var g: Dictionary = profile.serveur.get("guilde", {})
	if g.is_empty() or gain <= 0:
		return false
	_garder_guilde(Guilde.gagner(g, gain))
	return true


func acheter_effet(effet: String) -> Dictionary:
	var g: Dictionary = profile.serveur.get("guilde", {})
	var apres := Guilde.acheter(g, compte_id, effet, donnees)
	return {} if g.is_empty() or apres == g else _garder_guilde(apres)


func role_guilde(membre: String, role: String) -> Dictionary:
	var g: Dictionary = profile.serveur.get("guilde", {})
	var apres := Guilde.changer_role(g, compte_id, membre, role, donnees)
	return {} if g.is_empty() or apres == g else _garder_guilde(apres)


func exclure_guilde(membre: String) -> Dictionary:
	var g: Dictionary = profile.serveur.get("guilde", {})
	var apres := Guilde.exclure(g, compte_id, membre)
	return {} if g.is_empty() or apres == g else _garder_guilde(apres)


## L'économie : tes mouvements dans le profil (les 400 derniers) ; le bilan d'une semaine, les tiens plus ceux du
## monde simulé (engine/economie.gd, monde_simule).
func mouvement(m: Dictionary) -> bool:
	if not est_connecte() or not Economie.mouvement_valide(m):
		return false
	var liste: Array = profile.serveur.get("mouvements", [])
	liste.append(m.duplicate(true))
	if liste.size() > 400:
		liste = liste.slice(liste.size() - 400)
	profile.serveur["mouvements"] = liste
	profile.save()
	return true


func bilan(semaine: int) -> Dictionary:
	return Economie.somme(Economie.bilan(profile.serveur.get("mouvements", []), semaine), Economie.monde_simule(joueurs.size(), semaine, donnees))
