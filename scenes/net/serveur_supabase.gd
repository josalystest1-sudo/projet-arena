## Le vrai serveur (scenes/net/serveur.gd) : Supabase, par requêtes HTTP (docs/serveur/GUIDE-SUPABASE.md pour créer le
## projet, docs/serveur/supabase.sql pour la table). L'adresse et la clé publique viennent de data/serveur.json (la clé
## publique est faite pour être dans le jeu : ce sont les règles de la base qui protègent les données). Le compte est
## anonyme (« connexions anonymes » activées dans le projet) : un jeton d'accès (une heure) et un jeton de
## rafraîchissement, gardés dans le profil ; au premier lancement, un compte est créé. Non encore essayé contre un vrai
## projet (il attend l'adresse de Gautier).
extends Serveur

var url := ""
var cle := ""
var jeton := ""
var rafraichir := ""


func _ready() -> void:
	url = str(donnees.serveur["url"]).trim_suffix("/")
	cle = str(donnees.serveur["cle_publique"])
	jeton = str(profile.serveur.get("jeton", ""))
	rafraichir = str(profile.serveur.get("rafraichir", ""))


func mode() -> String:
	return "supabase"


## Le chemin d'une lecture des fiches d'un rôle autour d'un niveau (hors la sienne), triées par fraîcheur.
static func chemin_personnages(table: String, role: String, niveau: int, n: int, moi: String, ecart: int = 10) -> String:
	var out := "/rest/v1/%s?select=*&role=eq.%s&niveau=gte.%d&niveau=lte.%d&order=mis_a_jour.desc&limit=%d" % [table, role, maxi(1, niveau - ecart), niveau + ecart, n * 4]
	if moi != "":
		out += "&id=neq." + moi
	return out


## Le chemin des adversaires possibles : tous rôles, autour du niveau, hors la sienne.
static func chemin_adversaires(table: String, niveau: int, n: int, moi: String, ecart: int = 10) -> String:
	var out := "/rest/v1/%s?select=*&niveau=gte.%d&niveau=lte.%d&order=mis_a_jour.desc&limit=%d" % [table, maxi(1, niveau - ecart), niveau + ecart, n * 4]
	if moi != "":
		out += "&id=neq." + moi
	return out


## Le chemin du classement d'une saison : les points décroissants.
static func chemin_classement(table: String, saison: int, n: int) -> String:
	return "/rest/v1/%s?select=*&saison=eq.%d&order=points.desc,niveau.desc&limit=%d" % [table, saison, n]


func connecter() -> bool:
	erreur = ""
	if rafraichir != "":
		var r := await _requete(HTTPClient.METHOD_POST, "/auth/v1/token?grant_type=refresh_token", {"refresh_token": rafraichir}, false)
		if int(r["code"]) == 200 and r["corps"] is Dictionary:
			_retenir_session(r["corps"])
			return true
	var s := await _requete(HTTPClient.METHOD_POST, "/auth/v1/signup", {}, false)
	if int(s["code"]) == 200 and s["corps"] is Dictionary and s["corps"].has("access_token"):
		_retenir_session(s["corps"])
		return true
	erreur = "connexion impossible (%s)" % _texte_erreur(s)
	return false


func _retenir_session(corps: Dictionary) -> void:
	jeton = str(corps.get("access_token", ""))
	rafraichir = str(corps.get("refresh_token", ""))
	compte_id = str(corps.get("user", {}).get("id", ""))
	profile.serveur["compte"] = compte_id
	profile.serveur["jeton"] = jeton
	profile.serveur["rafraichir"] = rafraichir
	profile.save()


func publier(fiche: Dictionary) -> bool:
	erreur = ""
	if not est_connecte() and not await connecter():
		return false
	if not Serveur.fiche_valide(fiche, donnees):
		erreur = "fiche incomplète"
		return false
	var copie := fiche.duplicate(true)
	copie["id"] = compte_id
	copie.erase("mis_a_jour")
	var r := await _requete_connectee(HTTPClient.METHOD_POST, "/rest/v1/" + str(donnees.serveur["table"]), copie, "resolution=merge-duplicates,return=minimal")
	if int(r["code"]) in [200, 201, 204]:
		profile.serveur["fiche"] = fiche.duplicate(true)
		profile.serveur["fiche"]["mis_a_jour"] = Time.get_datetime_string_from_system()
		profile.save()
		return true
	erreur = "publication refusée (%s)" % _texte_erreur(r)
	return false


func personnages(role: String, niveau: int, n: int) -> Array:
	return await _lire(chemin_personnages(str(donnees.serveur["table"]), role, niveau, n, compte_id), niveau, n)


func adversaires(niveau: int, n: int) -> Array:
	return await _lire(chemin_adversaires(str(donnees.serveur["table"]), niveau, n, compte_id), niveau, n)


func classement(saison: int, n: int) -> Array:
	erreur = ""
	if not est_connecte() and not await connecter():
		return []
	var r := await _requete_connectee(HTTPClient.METHOD_GET, chemin_classement(str(donnees.serveur["table"]), saison, n))
	if int(r["code"]) != 200 or not r["corps"] is Array:
		erreur = "lecture impossible (%s)" % _texte_erreur(r)
		return []
	var fiches: Array = []
	for f in r["corps"]:
		if f is Dictionary and Serveur.fiche_valide(f, donnees):
			fiches.append(f)
	return Serveur.par_points(fiches, n)


## Lire des fiches à un chemin, garder les valides, les plus proches du niveau d'abord.
func _lire(chemin: String, niveau: int, n: int) -> Array:
	erreur = ""
	if not est_connecte() and not await connecter():
		return []
	var r := await _requete_connectee(HTTPClient.METHOD_GET, chemin)
	if int(r["code"]) != 200 or not r["corps"] is Array:
		erreur = "lecture impossible (%s)" % _texte_erreur(r)
		return []
	var fiches: Array = []
	for f in r["corps"]:
		if f is Dictionary and Serveur.fiche_valide(f, donnees):
			fiches.append(f)
	return Serveur.plus_proches(fiches, niveau, n)


# --- Le Marché : la table « annonces » (docs/serveur/supabase.sql) ; jamais essayé contre un vrai projet. ------------

func annonces(n: int) -> Array:
	erreur = ""
	if not est_connecte() and not await connecter():
		return []
	var r := await _requete_connectee(HTTPClient.METHOD_GET, "/rest/v1/annonces?select=*&acheteur=is.null&order=cree.desc&limit=%d" % n)
	if int(r["code"]) != 200 or not r["corps"] is Array:
		erreur = "lecture impossible (%s)" % _texte_erreur(r)
		return []
	var out: Array = []
	for a in r["corps"]:
		if a is Dictionary and Marche.annonce_valide(a, donnees):
			a["mienne"] = str(a["vendeur"]) == compte_id
			out.append(a)
	return out


func deposer(annonce: Dictionary) -> bool:
	erreur = ""
	if not est_connecte() and not await connecter():
		return false
	var corps := {"id": annonce["id"], "vendeur": compte_id, "objet": annonce["objet"], "prix": int(annonce["prix"]),
		"rarete": str(annonce.get("rarete", "")), "niveau": int(annonce.get("niveau", 1))}
	var r := await _requete_connectee(HTTPClient.METHOD_POST, "/rest/v1/annonces", corps, "return=minimal")
	if int(r["code"]) in [200, 201, 204]:
		return true
	erreur = "dépôt refusé (%s)" % _texte_erreur(r)
	return false


func retirer(id: String) -> Dictionary:
	var r := await _requete_connectee(HTTPClient.METHOD_DELETE, "/rest/v1/annonces?id=eq.%s&vendeur=eq.%s&acheteur=is.null" % [id, compte_id], null, "return=representation")
	if int(r["code"]) == 200 and r["corps"] is Array and not r["corps"].is_empty():
		return r["corps"][0]
	return {}


## Au premier acheteur : la mise à jour ne touche la ligne que si personne ne l'a prise avant.
func acheter(id: String) -> Dictionary:
	var r := await _requete_connectee(HTTPClient.METHOD_PATCH, "/rest/v1/annonces?id=eq.%s&acheteur=is.null&vendeur=neq.%s" % [id, compte_id], {"acheteur": compte_id}, "return=representation")
	if int(r["code"]) == 200 and r["corps"] is Array and not r["corps"].is_empty():
		return r["corps"][0]
	return {}


func encaisser(taux: float = -1.0) -> Array:
	var r := await _requete_connectee(HTTPClient.METHOD_PATCH, "/rest/v1/annonces?vendeur=eq.%s&acheteur=not.is.null&encaisse=is.false" % compte_id, {"encaisse": true}, "return=representation")
	var out: Array = []
	if int(r["code"]) == 200 and r["corps"] is Array:
		for a in r["corps"]:
			out.append({"annonce": a, "net": Marche.net(int(a["prix"]), donnees, taux)})
	return out


# --- L'économie : la table « mouvements » (docs/serveur/supabase.sql) ; jamais essayé contre un vrai projet. ----------

func mouvement(m: Dictionary) -> bool:
	if not Economie.mouvement_valide(m) or (not est_connecte() and not await connecter()):
		return false
	var corps := {"compte": compte_id, "type": str(m["type"]), "montant": int(m["montant"]), "jour": str(m["jour"]), "semaine": int(m["semaine"])}
	var r := await _requete_connectee(HTTPClient.METHOD_POST, "/rest/v1/mouvements", corps, "return=minimal")
	return int(r["code"]) in [200, 201, 204]


func bilan(semaine: int) -> Dictionary:
	var out := {"entre": 0, "detruit": 0, "echange": 0}
	if not est_connecte() and not await connecter():
		return out
	var r := await _requete_connectee(HTTPClient.METHOD_GET, "/rest/v1/mouvements?select=type,montant,semaine&semaine=eq.%d&limit=10000" % semaine)
	if int(r["code"]) == 200 and r["corps"] is Array:
		return Economie.bilan(r["corps"], semaine)
	return out


func nombre_personnages() -> int:
	return int(profile.serveur.get("nombre", 0))


# --- Les guildes : la table « guildes » (docs/serveur/supabase.sql), la guilde entière dans sa ligne (membres compris) ;
# jamais essayé contre un vrai projet. Chaque changement relit la ligne, applique la règle (engine/guilde.gd) et la
# réécrit : deux membres qui agissent en même temps peuvent s'écraser (prototype). ------------------------------------

## La carte : la table « territoires » (docs/serveur/supabase.sql), une ligne par territoire tenu et par saison ; jamais
## essayé contre un vrai projet.
func territoires(saison: int) -> Dictionary:
	var out := {}
	if not est_connecte() and not await connecter():
		return out
	var r := await _requete_connectee(HTTPClient.METHOD_GET, "/rest/v1/territoires?select=*&saison=eq.%d" % saison)
	if int(r["code"]) == 200 and r["corps"] is Array:
		for ligne in r["corps"]:
			if ligne is Dictionary and ligne.has("territoire"):
				out[str(ligne["territoire"])] = {"guilde": str(ligne.get("guilde", "")), "nom": str(ligne.get("nom", "")), "banniere": ligne.get("banniere", {}), "depuis": str(ligne.get("depuis", ""))}
	return out


func nombre_guildes() -> int:
	return (await _lire_guildes("/rest/v1/guildes?select=*&limit=1000")).size()


func _lire_guildes(chemin: String) -> Array:
	if not est_connecte() and not await connecter():
		return []
	var r := await _requete_connectee(HTTPClient.METHOD_GET, chemin)
	var out: Array = []
	if int(r["code"]) == 200 and r["corps"] is Array:
		for g in r["corps"]:
			if g is Dictionary and Guilde.guilde_valide(g, donnees):
				out.append(g)
	return out


func _ecrire_guilde(g: Dictionary) -> Dictionary:
	var corps := {"id": g["id"], "nom": g["nom"], "banniere": g["banniere"], "influence": int(g["influence"]), "influence_totale": int(g["influence_totale"]),
		"effets": g["effets"], "membres": g["membres"], "cree": str(g["cree"]), "chef": str(Guilde.chef(g).get("id", "")),
		"roles": g["roles"], "annonce": str(g.get("annonce", "")), "ouvert": bool(g.get("ouvert", true))}
	var r := await _requete_connectee(HTTPClient.METHOD_POST, "/rest/v1/guildes", corps, "resolution=merge-duplicates,return=minimal")
	if int(r["code"]) in [200, 201, 204]:
		profile.serveur["guilde_id"] = str(g["id"])
		profile.save()
		return g
	erreur = "guilde refusée (%s)" % _texte_erreur(r)
	return {}


func guildes(n: int) -> Array:
	var out: Array = []
	for g in await _lire_guildes("/rest/v1/guildes?select=*&order=influence_totale.desc&limit=%d" % n):
		out.append(Serveur.resume_guilde(g, donnees))
	return out


func ma_guilde() -> Dictionary:
	var id := str(profile.serveur.get("guilde_id", ""))
	if id == "":
		return {}
	var liste := await _lire_guildes("/rest/v1/guildes?select=*&id=eq.%s" % id)
	if liste.is_empty() or Guilde.membre(liste[0], compte_id).is_empty():
		profile.serveur.erase("guilde_id")
		profile.save()
		return {}
	return liste[0]


func creer_guilde(nom: String, banniere: Dictionary, fiche: Dictionary) -> Dictionary:
	if not (await ma_guilde()).is_empty() or not Guilde.nom_valide(nom, donnees) or not Guilde.banniere_valide(banniere, donnees):
		return {}
	return await _ecrire_guilde(Guilde.nouvelle("g-%s-%d" % [compte_id, Time.get_unix_time_from_system()], nom, banniere, fiche, Time.get_date_string_from_system(), donnees))


func rejoindre_guilde(id: String, fiche: Dictionary) -> Dictionary:
	if not (await ma_guilde()).is_empty():
		return {}
	var liste := await _lire_guildes("/rest/v1/guildes?select=*&id=eq.%s" % id)
	if liste.is_empty():
		return {}
	var avec := Guilde.ajouter(liste[0], fiche, Time.get_date_string_from_system(), donnees)
	if avec["membres"].size() == liste[0]["membres"].size():
		return {}
	return await _ecrire_guilde(avec)


func _changer(nouvelle: Dictionary, ancienne: Dictionary) -> Dictionary:
	if ancienne.is_empty() or nouvelle == ancienne:
		return {}
	if nouvelle.is_empty():
		await _requete_connectee(HTTPClient.METHOD_DELETE, "/rest/v1/guildes?id=eq.%s" % ancienne["id"])
		profile.serveur.erase("guilde_id")
		profile.save()
		return {}
	var ecrite := await _ecrire_guilde(nouvelle)
	if Guilde.membre(nouvelle, compte_id).is_empty():
		profile.serveur.erase("guilde_id")
		profile.save()
	return ecrite


func quitter_guilde() -> bool:
	var g := await ma_guilde()
	if g.is_empty():
		return false
	await _changer(Guilde.retirer(g, compte_id), g)
	return true


func influence_guilde(gain: int) -> bool:
	var g := await ma_guilde()
	return not g.is_empty() and gain > 0 and not (await _changer(Guilde.gagner(g, gain), g)).is_empty()


func acheter_effet(effet: String) -> Dictionary:
	var g := await ma_guilde()
	return await _changer(Guilde.acheter(g, compte_id, effet, donnees), g)


func role_guilde(membre: String, role: String) -> Dictionary:
	var g := await ma_guilde()
	return await _changer(Guilde.changer_role(g, compte_id, membre, role, donnees), g)


func exclure_guilde(membre: String) -> Dictionary:
	var g := await ma_guilde()
	return await _changer(Guilde.exclure(g, compte_id, membre), g)


func definir_role(r: Dictionary) -> Dictionary:
	var g := await ma_guilde()
	return await _changer(Guilde.definir_role(g, compte_id, r, donnees), g)


func supprimer_role(id_role: String) -> Dictionary:
	var g := await ma_guilde()
	return await _changer(Guilde.supprimer_role(g, compte_id, id_role), g)


func annonce_guilde(texte: String) -> Dictionary:
	var g := await ma_guilde()
	return await _changer(Guilde.changer_annonce(g, compte_id, texte, donnees), g)


func recrutement_guilde(ouvert: bool) -> Dictionary:
	var g := await ma_guilde()
	return await _changer(Guilde.changer_recrutement(g, compte_id, ouvert), g)


func banniere_guilde(b: Dictionary) -> Dictionary:
	var g := await ma_guilde()
	return await _changer(Guilde.changer_banniere(g, compte_id, b, donnees), g)


## Inviter : sur le vrai serveur, le personnage entre tout de suite (l'acceptation viendra avec le chat).
func inviter_guilde(fiche: Dictionary) -> Dictionary:
	var g := await ma_guilde()
	return await _changer(Guilde.inviter(g, compte_id, fiche, Time.get_date_string_from_system(), donnees), g)


## Une requête avec le jeton ; si le serveur dit que le jeton a expiré (401), on se reconnecte et on réessaie une fois.
func _requete_connectee(methode: HTTPClient.Method, chemin: String, corps: Variant = null, prefer: String = "") -> Dictionary:
	var r := await _requete(methode, chemin, corps, true, prefer)
	if int(r["code"]) == 401 and await connecter():
		r = await _requete(methode, chemin, corps, true, prefer)
	return r


## Une requête HTTP vers le projet. Renvoie {code, corps (le JSON lu, ou null), erreur}.
func _requete(methode: HTTPClient.Method, chemin: String, corps: Variant = null, avec_jeton: bool = true, prefer: String = "") -> Dictionary:
	var http := HTTPRequest.new()
	add_child(http)
	var entetes := PackedStringArray(["apikey: " + cle, "Content-Type: application/json", "Accept: application/json"])
	if avec_jeton and jeton != "":
		entetes.append("Authorization: Bearer " + jeton)
	elif not avec_jeton:
		entetes.append("Authorization: Bearer " + cle)
	if prefer != "":
		entetes.append("Prefer: " + prefer)
	var envoi := http.request(url + chemin, entetes, methode, JSON.stringify(corps) if corps != null else "")
	if envoi != OK:
		http.queue_free()
		return {"code": 0, "corps": null, "erreur": "requête impossible"}
	var res: Array = await http.request_completed
	http.queue_free()
	var texte := (res[3] as PackedByteArray).get_string_from_utf8()
	var lu: Variant = JSON.parse_string(texte) if texte.strip_edges() != "" else null
	return {"code": int(res[1]), "corps": lu, "erreur": "" if int(res[0]) == HTTPRequest.RESULT_SUCCESS else "réseau"}


static func _texte_erreur(r: Dictionary) -> String:
	if str(r.get("erreur", "")) != "":
		return str(r["erreur"])
	if r.get("corps") is Dictionary:
		for cle_msg in ["msg", "message", "error_description", "error"]:
			if r["corps"].has(cle_msg):
				return str(r["corps"][cle_msg])
	return "code %d" % int(r.get("code", 0))
