## Le lien au serveur (docs/GDD_V2.md, § 5 et § 7 ; docs/PLAN.md, phase 5 ; décision de Gautier du 30 octobre :
## « gratuit d'abord », Supabase). Ce que le jeu demande au serveur passe par cette classe : se connecter (un compte
## anonyme, propre à l'appareil), publier sa fiche de personnage (pour que les autres joueurs puissent le prendre comme
## Écho, l'affronter à l'Arène, le voir dans les classements), lire les fiches des autres. Deux mises en œuvre :
## - ServeurSimule (scenes/net/serveur_simule.gd) : tant que data/serveur.json n'a pas d'adresse, un monde simulé sur
##   l'appareil (des joueurs générés avec une graine, ta fiche gardée dans le profil) ; tout se teste sans réseau ;
## - ServeurSupabase (scenes/net/serveur_supabase.gd) : le vrai serveur, par requêtes HTTP (docs/serveur/GUIDE-SUPABASE.md).
## Toutes les méthodes se lisent avec `await` : la version simulée répond tout de suite, la vraie attend le réseau.
## Une fiche : {id, pseudo, classe, role, graine (texte : au-delà de 2^53 un nombre JSON perd sa précision), niveau,
## allumage (liste de nœuds), equipement (objets portés), mis_a_jour ; et, pour l'Arène, points et saison}.
class_name Serveur
extends Node

const CLES_FICHE := ["id", "pseudo", "classe", "role", "graine", "niveau", "allumage", "equipement"]

var donnees: Donnees
var profile: PlayerProfile
## L'identifiant du compte (vide tant qu'on n'est pas connecté).
var compte_id := ""
## La dernière erreur rencontrée, en français courant (vide si tout va bien).
var erreur := ""


## Le serveur qui convient aux données : le vrai si data/serveur.json a une adresse, le simulé sinon.
static func creer(p_donnees: Donnees, p_profile: PlayerProfile) -> Serveur:
	var s: Serveur
	if str(p_donnees.serveur.get("url", "")) != "":
		s = load("res://scenes/net/serveur_supabase.gd").new()
	else:
		s = load("res://scenes/net/serveur_simule.gd").new()
	s.donnees = p_donnees
	s.profile = p_profile
	s.compte_id = str(p_profile.serveur.get("compte", ""))
	return s


## « simule » ou « supabase ».
func mode() -> String:
	return "simule"


## Le nom du mode, pour l'écran.
func nom_mode() -> String:
	return "simulé sur cet appareil" if mode() == "simule" else "en ligne"


func est_connecte() -> bool:
	return compte_id != ""


## Se connecter (un compte anonyme, créé à la première fois, gardé dans le profil). Renvoie vrai si c'est fait.
func connecter() -> bool:
	return false


## Publier sa fiche (créée ou remplacée). Renvoie vrai si c'est fait.
func publier(_fiche: Dictionary) -> bool:
	return false


## Les fiches des autres joueurs d'un rôle, les plus proches du niveau donné, n au plus.
func personnages(_role: String, _niveau: int, _n: int) -> Array:
	return []


## Dire au serveur qu'un personnage vient d'être pris comme Écho (GDD V2, § 5 : son propriétaire sera récompensé, un
## plafond par jour). Renvoie vrai si c'est noté. Le simulé compte seulement ; le vrai serveur attend sa table.
func selectionner(_id: String) -> bool:
	return true


## Les fiches des autres joueurs, de tous rôles, les plus proches du niveau donné, n au plus : les adversaires
## possibles d'un combat classé (GDD V2, § 7).
func adversaires(_niveau: int, _n: int) -> Array:
	return []


## Le classement d'une saison de l'Arène : les fiches aux points les plus hauts (pseudo, classe, niveau, points), n au
## plus, la tienne comprise si elle est publiée.
func classement(_saison: int, _n: int) -> Array:
	return []


## Le Marché (engine/marche.gd). Les annonces en vente, n au plus, les tiennes marquées `mienne` ; déposer une annonce
## (vrai si c'est fait) ; retirer une des tiennes (l'annonce retirée, vide sinon) ; acheter (l'annonce si elle est
## encore là : au premier acheteur ; vide sinon ; jamais une des tiennes) ; encaisser tes ventes pas encore encaissées
## ([{annonce, net}]).
func annonces(_n: int) -> Array:
	return []


func deposer(_annonce: Dictionary) -> bool:
	return false


func retirer(_id: String) -> Dictionary:
	return {}


func acheter(_id: String) -> Dictionary:
	return {}


func encaisser() -> Array:
	return []


## Le nombre de fiches publiées (la tienne comprise).
func nombre_personnages() -> int:
	return 0


## Une fiche est-elle complète et cohérente avec les données ?
static func fiche_valide(fiche: Dictionary, d: Donnees) -> bool:
	for cle in CLES_FICHE:
		if not fiche.has(cle):
			return false
	if not d.classes.has(str(fiche["classe"])) or not str(fiche["role"]) in Donnees.ROLES:
		return false
	if str(fiche["pseudo"]).strip_edges() == "" or not str(fiche["graine"]).is_valid_int():
		return false
	return int(fiche["niveau"]) >= 1 and fiche["allumage"] is Array and fiche["equipement"] is Array


## Le Destin d'une fiche : sa classe, sa graine, son niveau, ses nœuds allumés, ses objets portés ; marqué Écho.
static func destin_de(fiche: Dictionary, d: Donnees) -> Destin:
	var allumage: Array[String] = []
	for cle in fiche.get("allumage", []):
		allumage.append(str(cle))
	var destin := Generateur.generer(str(fiche["classe"]), int(str(fiche["graine"])), int(fiche["niveau"]), allumage if not allumage.is_empty() else Generateur.PAR_DEFAUT, d)
	destin.echo = true
	destin.mods = Equipement.mods(fiche.get("equipement", []), d)
	return destin


## Les fiches par points décroissants (puis niveau décroissant), n au plus.
static func par_points(fiches: Array, n: int) -> Array:
	var copie := fiches.duplicate()
	copie.sort_custom(func(a, b):
		if int(a.get("points", 0)) != int(b.get("points", 0)):
			return int(a.get("points", 0)) > int(b.get("points", 0))
		return int(a["niveau"]) > int(b["niveau"]))
	return copie.slice(0, n)


## Les fiches les plus proches d'un niveau (écart de niveau croissant, puis l'ordre donné), n au plus.
static func plus_proches(fiches: Array, niveau: int, n: int) -> Array:
	var copie := fiches.duplicate()
	copie.sort_custom(func(a, b): return absi(int(a["niveau"]) - niveau) < absi(int(b["niveau"]) - niveau))
	return copie.slice(0, n)


## Un pseudo par défaut : un mot de la liste et un nombre, tirés avec une graine.
static func pseudo_defaut(graine: int, d: Donnees) -> String:
	var mots: Array = d.serveur["pseudos"]
	var rng := RandomNumberGenerator.new()
	rng.seed = graine
	return "%s %d" % [mots[rng.randi_range(0, mots.size() - 1)], rng.randi_range(100, 999)]


## Un pseudo acceptable : de 2 à 16 caractères visibles.
static func pseudo_valide(pseudo: String) -> bool:
	var p := pseudo.strip_edges()
	return p.length() >= 2 and p.length() <= 16
