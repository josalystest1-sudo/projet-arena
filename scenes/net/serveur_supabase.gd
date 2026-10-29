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


func nombre_personnages() -> int:
	return int(profile.serveur.get("nombre", 0))


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
