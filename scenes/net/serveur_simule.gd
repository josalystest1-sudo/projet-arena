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
	var jour := profile.aujourd_hui()
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
	copie["jour"] = profile.aujourd_hui()
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
	var jour := profile.aujourd_hui()
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

## La carte : les guildes du monde simulé tiennent des territoires tirés avec la saison (engine/carte.gd) ; la tienne,
## ceux que le profil lui donne (les guerres, plus tard).
func territoires(saison: int) -> Dictionary:
	var resumes: Array = []
	for g in _guildes_du_monde():
		resumes.append(Serveur.resume_guilde(g, donnees))
	var etat := Carte.monde_simule(resumes, saison, nombre_guildes(), donnees)
	var mienne: Dictionary = profile.serveur.get("guilde", {})
	if not mienne.is_empty():
		for t in profile.serveur.get("territoires", {}).get(str(saison), []):
			etat[str(t)] = {"guilde": str(mienne["id"]), "nom": str(mienne["nom"]), "banniere": mienne["banniere"], "depuis": "saison %d" % saison}
	# Les guerres : ce que les batailles résolues ont changé (une prise, ou un territoire redevenu neutre : null).
	var prises: Dictionary = _guerre().get("prises", {}).get(str(saison), {})
	for t in prises:
		if prises[t] == null:
			etat.erase(str(t))
		else:
			etat[str(t)] = prises[t]
	return etat


func nombre_guildes() -> int:
	return _guildes_du_monde().size() + (1 if profile.serveur.has("guilde") else 0)


func _guildes_du_monde() -> Array:
	return Guilde.guildes_simulees(joueurs, profile.aujourd_hui(), donnees)


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
	var jour := profile.aujourd_hui()
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
		g["dernier_jour"] = profile.aujourd_hui()
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
	var jour := profile.aujourd_hui()
	return _garder_guilde(Guilde.nouvelle("g-%s-%d" % [compte_id, Time.get_unix_time_from_system()], nom, banniere, fiche, jour, donnees))


func rejoindre_guilde(id: String, fiche: Dictionary) -> Dictionary:
	if not est_connecte() or profile.serveur.has("guilde"):
		return {}
	for g in _guildes_du_monde():
		if str(g["id"]) == id:
			var avec := Guilde.ajouter(g, fiche, profile.aujourd_hui(), donnees)
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


func _appliquer(apres: Dictionary) -> Dictionary:
	var g: Dictionary = profile.serveur.get("guilde", {})
	return {} if g.is_empty() or apres == g else _garder_guilde(apres)


func definir_role(r: Dictionary) -> Dictionary:
	return _appliquer(Guilde.definir_role(profile.serveur.get("guilde", {}), compte_id, r, donnees))


func supprimer_role(id_role: String) -> Dictionary:
	return _appliquer(Guilde.supprimer_role(profile.serveur.get("guilde", {}), compte_id, id_role))


func annonce_guilde(texte: String) -> Dictionary:
	return _appliquer(Guilde.changer_annonce(profile.serveur.get("guilde", {}), compte_id, texte, donnees))


func recrutement_guilde(ouvert: bool) -> Dictionary:
	return _appliquer(Guilde.changer_recrutement(profile.serveur.get("guilde", {}), compte_id, ouvert))


func banniere_guilde(b: Dictionary) -> Dictionary:
	return _appliquer(Guilde.changer_banniere(profile.serveur.get("guilde", {}), compte_id, b, donnees))


## Inviter un personnage : dans le monde simulé, il accepte tout de suite.
func inviter_guilde(fiche: Dictionary) -> Dictionary:
	return _appliquer(Guilde.inviter(profile.serveur.get("guilde", {}), compte_id, fiche, profile.aujourd_hui(), donnees))


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


# --- Les guerres de guilde (engine/guerre.gd) : les batailles vivent dans le profil ; celles des guildes du monde sont
# tirées avec le jour et jouées par l'IA ; les tiennes se jouent (tes combats) et se défendent (l'IA) ; les soirs passés
# se résolvent à la première lecture d'un jour nouveau. ------------------------------------------------------------

func _guerre() -> Dictionary:
	if not profile.serveur.has("guerre"):
		profile.serveur["guerre"] = {"batailles": {}, "prises": {}, "protections": {}, "derniers": {}, "en_cours": {}, "xp": 0, "jours_resolus": []}
	return profile.serveur["guerre"]


func _fiche_de(id: String) -> Dictionary:
	if id == compte_id:
		return profile.serveur.get("fiche", {})
	for f in joueurs:
		if str(f["id"]) == id:
			return f
	return {}


## Les fiches des membres d'une guilde (la tienne : celles du monde plus la tienne si elle est publiée).
func _membres(guilde_id: String) -> Array:
	var g: Dictionary = profile.serveur.get("guilde", {})
	if g.is_empty() or str(g["id"]) != guilde_id:
		g = {}
		for x in _guildes_du_monde():
			if str(x["id"]) == guilde_id:
				g = x
	var out: Array = []
	for m in g.get("membres", []):
		var f := _fiche_de(str(m["id"]))
		if not f.is_empty():
			out.append(f)
	return out


## Un garde d'un territoire neutre : un trio généré au niveau de l'attaquant (engine/arene.gd).
func _garde(niveau: int, graine: int) -> Dictionary:
	var adv := Arene.adversaire(niveau, graine, donnees)
	return {"id": "garde-%d" % graine, "pseudo": str(adv["nom"]), "classe": str(adv["classe"]), "graine": str(adv["graine"]), "niveau": int(adv["niveau"]), "allumage": [], "equipement": []}


## Les combats que l'IA joue dans une bataille : chaque attaquant donné (des fiches) fait ses trois combats contre un
## défenseur (ou un garde si le territoire est neutre) ; chaque défenseur donné fait ses trois combats contre un attaquant.
func _combats_ia(b: Dictionary, attaquants: Array, defenseurs: Array, tous_attaquants: Array) -> Dictionary:
	var graine := (str(b["id"]) + str(b["jour"])).hash()
	var k := 0
	for a in attaquants:
		for _i in range(int(donnees.guerre["combats_par_membre"])):
			k += 1
			var adv := Guerre.defenseur(b, defenseurs, graine + k, donnees)
			if adv.is_empty():
				adv = _garde(int(a["niveau"]), graine + k)
			b = Guerre.enregistrer(b, str(a["id"]), "attaquant", Guerre.combat_ia(a, adv, graine + k, donnees), int(adv["niveau"]), str(adv["id"]), donnees)
	for df in defenseurs:
		for _i in range(int(donnees.guerre["combats_par_membre"])):
			k += 1
			if tous_attaquants.is_empty():
				break
			var adv: Dictionary = tous_attaquants[k % tous_attaquants.size()]
			b = Guerre.enregistrer(b, str(df["id"]), "defenseur", Guerre.combat_ia(df, adv, graine + k, donnees), int(adv["niveau"]), str(adv["id"]), donnees)
	return b


func _batailles_du(jour: String) -> Array:
	return _guerre()["batailles"].get(jour, [])


func _ecrire_bataille(b: Dictionary) -> void:
	var liste: Array = _batailles_du(str(b["jour"]))
	for i in range(liste.size()):
		if str(liste[i]["id"]) == str(b["id"]):
			liste[i] = b
			_guerre()["batailles"][str(b["jour"])] = liste
			profile.save()
			return
	liste.append(b)
	_guerre()["batailles"][str(b["jour"])] = liste
	profile.save()


## Les attaques des guildes du monde ce soir, créées une fois par jour et jouées tout de suite par l'IA (ta guilde se
## défend avec ton personnage si c'est l'un de tes territoires).
func _attaques_du_monde(jour: String) -> void:
	var g := _guerre()
	if g["batailles"].has(jour):
		return
	g["batailles"][jour] = []
	var saison := Arene.saison(jour, donnees)
	var etat := territoires(saison)
	var resumes: Array = []
	for x in _guildes_du_monde():
		resumes.append(Serveur.resume_guilde(x, donnees))
	var n := 0
	for att in Guerre.attaques_simulees(resumes, etat, g["protections"], jour, donnees):
		n += 1
		var tenue: Dictionary = etat.get(str(att["territoire"]), {})
		var defenseur := {}
		if not tenue.is_empty():
			defenseur = {"id": str(tenue["guilde"]), "nom": str(tenue["nom"]), "banniere": tenue["banniere"], "membres": _membres(str(tenue["guilde"])).size()}
		var b := Guerre.nouvelle_bataille("sim-%s-%d" % [jour, n], jour, str(att["territoire"]), att["attaquant"], defenseur, n)
		var attaquants := _membres(str(att["attaquant"]["id"]))
		var defenseurs: Array = _membres(str(tenue["guilde"])) if not tenue.is_empty() else []
		b = _combats_ia(b, attaquants, defenseurs, attaquants)
		_ecrire_bataille(b)


## Résoudre les soirs passés (avant `jour`) : le résultat de chaque bataille, la carte qui change, les protections, les
## territoires sans combat depuis sept jours, et les revenus de tes territoires (Influence tout de suite, XP à donner).
func _resoudre_avant(jour: String) -> void:
	var g := _guerre()
	var jours: Array = g["batailles"].keys()
	jours.sort()
	for j in jours:
		if str(j) >= jour or g["jours_resolus"].has(str(j)):
			continue
		var saison := Arene.saison(str(j), donnees)
		var lendemain := Guerre.jour_plus(str(j), 1)
		var prises: Dictionary = g["prises"].get(str(saison), {})
		var liste: Array = g["batailles"][j]
		for i in range(liste.size()):
			var b: Dictionary = liste[i]
			if bool(b["resolue"]):
				continue
			var etat := territoires(saison)
			var r := Guerre.resultat(b, etat, donnees)
			b["resolue"] = true
			b["resultat"] = r
			var apres := Guerre.appliquer(etat, g["protections"], b, r, lendemain, donnees)
			if r == "attaquant":
				prises[str(b["territoire"])] = apres["etat"][str(b["territoire"])]
				g["protections"] = apres["protections"]
			g["derniers"][str(b["territoire"])] = str(j)
			liste[i] = b
		g["prises"][str(saison)] = prises
		g["batailles"][j] = liste
		# Les territoires sans combat depuis sept jours redeviennent neutres.
		var etat_j := territoires(saison)
		var neutre := Guerre.neutraliser(etat_j, g["derniers"], lendemain, donnees)
		for t in etat_j:
			if not neutre.has(t):
				prises[str(t)] = null
		g["prises"][str(saison)] = prises
		# Les revenus de tes territoires pour ce jour.
		var mienne: Dictionary = profile.serveur.get("guilde", {})
		if not mienne.is_empty():
			var tenus := Carte.tenus_par(territoires(saison), str(mienne["id"]))
			if not tenus.is_empty():
				var rev := Carte.revenus(tenus, {}, donnees)
				profile.serveur["guilde"] = Guilde.gagner(profile.serveur["guilde"], int(rev["influence"]))
				g["xp"] = int(g["xp"]) + int(rev["xp"])
		g["jours_resolus"].append(str(j))
		if g["jours_resolus"].size() > 30:
			g["jours_resolus"] = g["jours_resolus"].slice(g["jours_resolus"].size() - 30)
	profile.save()


func batailles(jour: String) -> Array:
	if not est_connecte():
		return []
	_resoudre_avant(jour)
	_attaques_du_monde(jour)
	var out: Array = []
	for b in _batailles_du(jour):
		out.append(b.duplicate(true))
	return out


func protections() -> Dictionary:
	return _guerre()["protections"].duplicate()


func declarer_guerre(territoire: String) -> Dictionary:
	var jour := profile.aujourd_hui()
	var mienne: Dictionary = profile.serveur.get("guilde", {})
	if not est_connecte() or mienne.is_empty():
		erreur = "il faut une guilde"
		return {}
	var liste := batailles(jour)
	var saison := Arene.saison(jour, donnees)
	var etat := territoires(saison)
	erreur = Guerre.empeche(etat, _guerre()["protections"], mienne, territoire, jour, liste, donnees)
	if erreur != "":
		return {}
	var tenue: Dictionary = etat.get(territoire, {})
	var defenseur := {}
	if not tenue.is_empty():
		defenseur = {"id": str(tenue["guilde"]), "nom": str(tenue["nom"]), "banniere": tenue["banniere"], "membres": _membres(str(tenue["guilde"])).size()}
	var b := Guerre.nouvelle_bataille("%s-%s-%s" % [compte_id, jour, territoire], jour, territoire, Serveur.resume_guilde(mienne, donnees), defenseur, liste.size() + 1)
	# Les défenseurs se battent tout de suite (l'IA) contre tes membres ; tes combats, tu les joues.
	var attaquants := _membres(str(mienne["id"]))
	var autres: Array = attaquants.filter(func(f): return str(f["id"]) != compte_id)
	b = _combats_ia(b, autres, _membres(str(tenue["guilde"])) if not tenue.is_empty() else [], attaquants)
	_ecrire_bataille(b)
	return b.duplicate(true)


func combat_guerre(id: String) -> Dictionary:
	var jour := profile.aujourd_hui()
	for b in batailles(jour):
		if str(b["id"]) != id or str(b["attaquant"].get("id", "")) != str(profile.serveur.get("guilde", {}).get("id", "?")):
			continue
		if Guerre.reste(b, compte_id, "attaquant", donnees) <= 0:
			return {}
		var graine := (id + str(b["combats"].size())).hash()
		var adv := Guerre.defenseur(b, _membres(str(b["defenseur"].get("id", ""))) if not b["defenseur"].is_empty() else [], graine, donnees)
		if adv.is_empty():
			adv = _garde(profile.level, graine)
		_guerre()["en_cours"] = {"bataille": id, "adversaire": adv}
		profile.save()
		return {"bataille": b, "adversaire": adv}
	return {}


func resultat_guerre(id: String, gagne: bool) -> Dictionary:
	var en_cours: Dictionary = _guerre().get("en_cours", {})
	if en_cours.is_empty() or str(en_cours.get("bataille", "")) != id:
		return {}
	var jour := profile.aujourd_hui()
	for b in _batailles_du(jour):
		if str(b["id"]) == id:
			var adv: Dictionary = en_cours["adversaire"]
			var apres := Guerre.enregistrer(b, compte_id, "attaquant", gagne, int(adv["niveau"]), str(adv["id"]), donnees)
			_guerre()["en_cours"] = {}
			_ecrire_bataille(apres)
			return apres.duplicate(true)
	return {}


## L'XP que les Sanctuaires de ta guilde t'ont réservée : rendue une fois, puis remise à zéro.
func xp_territoires() -> int:
	var xp := int(_guerre().get("xp", 0))
	_guerre()["xp"] = 0
	if xp > 0:
		profile.save()
	return xp
