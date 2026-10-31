## L'état complet d'un combat V2 (docs/SPEC-COMBAT-V2.md, section 13.2), sérialisable en dictionnaire pour le
## serveur et les tests. Deux parties :
## - `statique` : ce qui ne change pas pendant le combat (camp, place, classe, nœuds de la roue avec leurs formes,
##   bonus des éclats, PV max) ; partagé entre les copies, jamais modifié.
## - `persos` : ce qui change à chaque tour (PV, KO, états, barrière, jalons, extinctions, inactivité, dernière voie,
##   cibles choisies) ; copié par `copie()`.
## Un état est posé au tour T pour d tours : il est actif des tours T+1 à T+d (`debut`, `fin`) ; il a donc encore
## `fin - tour + 1` tours à courir pendant le tour `tour`. Module pur : les règles sont dans engine/regles.gd.
class_name EtatCombat
extends RefCounted

## Le tour en cours (1 = le premier) : l'état est toujours celui de la fin de la phase 0 de ce tour.
var tour := 0
var niveau := 1
## « pvp » ou « tour » (la Tour : pas de mort subite).
var mode := "pvp"
## Les règles chiffrées (data/rules.json) et les états (data/etats.json), partagés, en lecture seule.
var regles: Dictionary = {}
var defs_etats: Dictionary = {}
## Les traits légendaires (data/items.json, traits), pour leurs valeurs.
var defs_traits: Dictionary = {}
## L'ordre d'application (section 5.4) : joueur A, acolyte A (ou ses deux Échos), joueur B (ou ennemi 1), acolyte B (ou
## ses deux Échos, ou ennemis 2 à 4).
var ordre: Array[String] = []
var statique: Dictionary = {}
var persos: Dictionary = {}
var fini := false
## « a », « b », ou "" tant que le combat continue.
var vainqueur := ""
## Le journal d'événements du dernier tour résolu (section 13.4), dans l'ordre d'application.
var journal: Array = []
## Les actions du dernier tour résolu, après validation (perso -> action ; absent : KO ou Étourdi).
var actions_jouees: Dictionary = {}


func copie() -> EtatCombat:
	var e := EtatCombat.new()
	e.tour = tour
	e.niveau = niveau
	e.mode = mode
	e.regles = regles
	e.defs_etats = defs_etats
	e.defs_traits = defs_traits
	e.ordre = ordre.duplicate()
	e.statique = statique
	e.persos = persos.duplicate(true)
	e.fini = fini
	e.vainqueur = vainqueur
	e.journal = journal.duplicate(true)
	e.actions_jouees = actions_jouees.duplicate(true)
	return e


func vers_dict() -> Dictionary:
	return {"tour": tour, "niveau": niveau, "mode": mode, "regles": regles.duplicate(true),
		"defs_etats": defs_etats.duplicate(true), "defs_traits": defs_traits.duplicate(true), "ordre": Array(ordre), "statique": statique.duplicate(true),
		"persos": persos.duplicate(true), "fini": fini, "vainqueur": vainqueur, "journal": journal.duplicate(true),
		"actions_jouees": actions_jouees.duplicate(true)}


static func depuis_dict(dico: Dictionary) -> EtatCombat:
	var e := EtatCombat.new()
	e.tour = int(dico["tour"])
	e.niveau = int(dico["niveau"])
	e.mode = str(dico["mode"])
	e.regles = dico["regles"].duplicate(true)
	e.defs_etats = dico["defs_etats"].duplicate(true)
	e.defs_traits = dico.get("defs_traits", {}).duplicate(true)
	for id in dico["ordre"]:
		e.ordre.append(str(id))
	e.statique = dico["statique"].duplicate(true)
	for id in e.statique:
		e.statique[id]["pv_max"] = int(e.statique[id]["pv_max"])
	# Un dictionnaire relu depuis du JSON n'a que des nombres à virgule : les compteurs redeviennent des entiers.
	for id in dico["persos"]:
		var p: Dictionary = dico["persos"][id]
		var etats := {}
		for nom in p["etats"]:
			var s: Dictionary = p["etats"][nom]
			etats[nom] = {"debut": int(s["debut"]), "fin": int(s["fin"]), "valeur": float(s["valeur"]), "source": str(s["source"])}
		var eteints: Array = []
		for v in p["spent_until"]:
			eteints.append(_entiers(v))
		e.persos[id] = {"pv": int(p["pv"]), "ko": bool(p["ko"]), "etats": etats, "barriere": int(p["barriere"]),
			"barrier_until": int(p["barrier_until"]), "jalons": _entiers(p["jalons"]), "spent_until": eteints,
			"inactivite": _entiers(p["inactivite"]), "last_voie": int(p["last_voie"]),
			"cible_ennemie": str(p["cible_ennemie"]), "cible_alliee": str(p["cible_alliee"]), "soins": int(p.get("soins", 0)), "tenacite": bool(p.get("tenacite", false))}
	e.fini = bool(dico["fini"])
	e.vainqueur = str(dico["vainqueur"])
	e.journal = dico["journal"].duplicate(true)
	e.actions_jouees = dico["actions_jouees"].duplicate(true)
	return e


static func _entiers(liste: Array) -> Array:
	var out: Array = []
	for x in liste:
		out.append(int(x))
	return out


# --- Lecture -------------------------------------------------------------------

func perso(id: String) -> Dictionary:
	return persos[id]


func fiche(id: String) -> Dictionary:
	return statique[id]


func camp(id: String) -> String:
	return str(statique[id]["camp"])


func vivant(id: String) -> bool:
	return not bool(persos[id]["ko"])


## Les membres vivants d'un camp, dans l'ordre d'application.
func vivants(p_camp: String) -> Array[String]:
	var out: Array[String] = []
	for id in ordre:
		if camp(id) == p_camp and vivant(id):
			out.append(id)
	return out


func allies_vivants(id: String) -> Array[String]:
	return vivants(camp(id))


func ennemis_vivants(id: String) -> Array[String]:
	return vivants("b" if camp(id) == "a" else "a")


## L'état est-il actif pendant le tour t (par défaut, le tour en cours) ?
func a_etat(id: String, nom: String, t: int = -1) -> bool:
	var etats: Dictionary = persos[id]["etats"]
	if not etats.has(nom):
		return false
	var quand := tour if t < 0 else t
	return int(etats[nom]["debut"]) <= quand and quand <= int(etats[nom]["fin"])


## La valeur d'un état actif ce tour-ci (Renfort, Affaiblissement : une fraction ; DoT, Gardien : par tour), 0 sinon.
func valeur_etat(id: String, nom: String) -> float:
	if not a_etat(id, nom):
		return 0.0
	return float(persos[id]["etats"][nom]["valeur"])


## Les tours qu'il reste à courir à un état, le tour en cours compris (0 s'il est absent ou fini).
func tours_restants(id: String, nom: String) -> int:
	var etats: Dictionary = persos[id]["etats"]
	if not etats.has(nom):
		return 0
	return maxi(0, int(etats[nom]["fin"]) - maxi(tour, int(etats[nom]["debut"])) + 1)


func pv_pourcent(id: String) -> float:
	return float(persos[id]["pv"]) / float(statique[id]["pv_max"])


## Le nœud d'un perso : rang 0 pour le moyeu, sinon la voie (0 à 4) et le rang (1 à 4).
func noeud(id: String, voie: int, rang: int) -> Dictionary:
	if rang == 0:
		return statique[id]["moyeu"]
	return statique[id]["voies"][voie]["noeuds"][rang - 1]


func nb_voies(id: String) -> int:
	return statique[id]["voies"].size()
