## L'Arène classée (docs/GDD_V2.md, § 7 ; docs/PLAN.md, PR 5.3), jouée hors ligne en attendant le serveur : cinq combats
## classés par jour contre le trio d'un « autre joueur » (généré : une classe, une graine, un niveau proche du tien, un
## équipement tiré comme un butin ; avec le serveur, de vrais personnages pilotés par l'IA), des points (gagné +20,
## perdu −10, jamais sous zéro), une ligue par puissance (Aspirants pour les classes de base ; Élus et Ascendants avec
## les évolutions, phase 8), une saison de 3 mois qui remet les points à zéro, un coffre par semaine (un objet lié dont
## la rareté suit les victoires classées de la semaine), les amicaux illimités. Les chiffres : data/arene.json.
## Module pur : le hasard vient des graines fournies ; les dates sont des « AAAA-MM-JJ ».
class_name Arene
extends RefCounted

## Le niveau le plus haut d'un adversaire généré : le plafond du rang le plus haut qui existe (engine/evolution.gd).
static func niveau_max(d: Donnees) -> int:
	return Evolution.niveau_max(Evolution.rang_max(d), d)


# --- Le temps --------------------------------------------------------------------------

## Le nombre de jours écoulés depuis le 1er janvier 1970 pour une date « AAAA-MM-JJ » (0 si la date est mal formée).
static func jours(jour: String) -> int:
	var parts := jour.substr(0, 10).split("-")
	if parts.size() != 3 or parts[0].length() != 4 or parts[1].length() != 2 or parts[2].length() != 2:
		return 0
	for p in parts:
		if not p.is_valid_int():
			return 0
	var t := Time.get_unix_time_from_datetime_string(jour.substr(0, 10) + "T00:00:00")
	return int(floor(float(t) / 86400.0))


## Le numéro de la saison d'une date : 0 pour la première (data/arene.json : son début et sa durée en jours).
static func saison(jour: String, d: Donnees) -> int:
	var s: Dictionary = d.objets_arene["saison"]
	return maxi(0, int(floor(float(jours(jour) - jours(str(s["debut"]))) / float(maxi(1, int(s["jours"]))))))


## Le numéro de la semaine d'une date (les semaines commencent le lundi).
static func semaine(jour: String) -> int:
	return int(floor(float(jours(jour) + 3) / 7.0))


## Le jour où la saison en cours se termine (le premier jour de la suivante).
static func fin_de_saison(jour: String, d: Donnees) -> String:
	var s: Dictionary = d.objets_arene["saison"]
	var debut := jours(str(s["debut"])) + (saison(jour, d) + 1) * int(s["jours"])
	return Time.get_date_string_from_unix_time(debut * 86400)


# --- Le classement -----------------------------------------------------------------------

## Les points après un combat classé : +points_gagne ou −points_perdu, jamais sous zéro.
static func points_apres(points: int, gagne: bool, d: Donnees) -> int:
	var a: Dictionary = d.objets_arene
	return maxi(0, points + (int(a["points_gagne"]) if gagne else -int(a["points_perdu"])))


## La ligue d'un personnage selon le rang de sa classe (0 : classe de base ; 1 : évolution de rang 1 ; 2 : rang 2 ou
## classe de grimoire), et son nom.
static func ligue(rang_classe: int) -> String:
	return ["aspirants", "elus", "ascendants"][clampi(rang_classe, 0, 2)]


static func nom_ligue(id: String, d: Donnees) -> String:
	return str(d.objets_arene["ligues"].get(id, id))


## La rareté du coffre de la semaine d'après les victoires classées de la semaine ("" : pas de coffre).
static func rarete_coffre(victoires: int, d: Donnees) -> String:
	var seuils: Dictionary = d.objets_arene["coffre"]
	var out := ""
	var meilleur := -1
	for r in seuils:
		if victoires >= int(seuils[r]) and int(seuils[r]) > meilleur:
			meilleur = int(seuils[r])
			out = str(r)
	return out


## Le coffre de la semaine : un objet lié du niveau donné, de la rareté des victoires ; vide s'il n'y a pas de coffre.
static func coffre(victoires: int, niveau: int, graine: int, d: Donnees) -> Dictionary:
	var rarete := rarete_coffre(victoires, d)
	if rarete == "":
		return {}
	var bases: Array = d.objets["bases"].keys()
	bases.sort()
	var rng := RandomNumberGenerator.new()
	rng.seed = graine ^ 0x1C0FFEE5
	return Equipement.tirer(bases[rng.randi_range(0, bases.size() - 1)], rarete, niveau, rng.randi_range(0, 0x7FFFFFFF), d, true)


# --- L'adversaire ----------------------------------------------------------------------------

## Un adversaire classé pour un joueur de ce niveau, tiré avec la graine : sa classe, sa graine, son niveau (à
## niveau_ecart près, dans 1 à 60 ; une évolution de sa classe au-delà du niveau 30), son nom, son équipement (une
## rareté de jeu complet tirée selon les poids, ou rien).
static func adversaire(niveau: int, graine: int, d: Donnees) -> Dictionary:
	var a: Dictionary = d.objets_arene["adversaire"]
	var rng := RandomNumberGenerator.new()
	rng.seed = graine ^ 0x5A17E3C9
	var classe: String = d.ordre_classes[rng.randi_range(0, d.ordre_classes.size() - 1)]
	var ecart := int(a["niveau_ecart"])
	var nv := clampi(niveau + rng.randi_range(-ecart, ecart), 1, niveau_max(d))
	classe = Evolution.classe_au_niveau(classe, nv, graine, d)
	var noms: Array = d.objets_arene["noms"]
	var nom: String = noms[rng.randi_range(0, noms.size() - 1)]
	var poids: Dictionary = a["equipement"]
	var total := 0.0
	for r in poids:
		total += float(poids[r])
	var tirage := rng.randf_range(0.0, total)
	var rarete := ""
	var raretes: Array = poids.keys()
	raretes.sort()
	for r in raretes:
		rarete = str(r)
		tirage -= float(poids[r])
		if tirage < 0.0:
			break
	return {"classe": classe, "graine": rng.randi_range(0, 0x7FFFFFFF), "niveau": nv, "nom": nom, "equipement": rarete}


## Le trio d'un adversaire : sa roue à son niveau, équipée s'il l'est, et ses deux Échos.
static func trio_adverse(adv: Dictionary, d: Donnees) -> Array[Destin]:
	var joueur := Generateur.generer(str(adv["classe"]), int(adv["graine"]), int(adv["niveau"]), Generateur.PAR_DEFAUT, d)
	if str(adv.get("equipement", "")) != "":
		joueur.mods = Equipement.mods(Equipement.jeu(int(adv["niveau"]), str(adv["equipement"]), int(adv["graine"]) ^ 0x33, d), d)
	return Trio.camp(joueur, int(adv["niveau"]), d)
