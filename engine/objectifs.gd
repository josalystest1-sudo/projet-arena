## Les objectifs du jour (docs/GDD_V2.md, § 10.3 ; docs/PLAN.md, PR 4.1 « Tableau ») : chaque jour, trois objectifs tirés
## dans la réserve de data/objectifs.json avec la date en graine (les mêmes pour tout le monde), chacun un compteur du jeu
## à atteindre (duels joués ou gagnés, étages, Gardiens, objets équipés, reforges, recyclages, Clés jouées, Synergies) et
## une récompense en XP et en Éclats, réclamée une fois. Les compteurs repartent de zéro avec le jour.
## Module pur : le hasard vient de la date.
class_name Objectifs
extends RefCounted

## Les compteurs que l'application sait faire monter.
const COMPTEURS := ["duels", "duels_gagnes", "etages", "gardiens", "equipes", "reforges", "recycles", "cles", "synergies"]


## Les objectifs d'un jour (« AAAA-MM-JJ ») : par_jour identifiants différents, tirés avec la date.
static func du_jour(jour: String, d: Donnees) -> Array[String]:
	var reserve: Array = d.objectifs["reserve"]
	var ids: Array = []
	for o in reserve:
		ids.append(str(o["id"]))
	var rng := RandomNumberGenerator.new()
	rng.seed = jour.hash() ^ 0x6B43A9B5
	var out: Array[String] = []
	while out.size() < int(d.objectifs["par_jour"]) and not ids.is_empty():
		out.append(ids.pop_at(rng.randi_range(0, ids.size() - 1)))
	return out


## La définition d'un objectif par son identifiant (vide s'il n'existe pas).
static func definition(id: String, d: Donnees) -> Dictionary:
	for o in d.objectifs["reserve"]:
		if str(o["id"]) == id:
			return o
	return {}


## L'avancement d'un objectif d'après les compteurs du jour, borné à sa cible.
static func avancement(id: String, compteurs: Dictionary, d: Donnees) -> int:
	var o := definition(id, d)
	if o.is_empty():
		return 0
	return mini(int(compteurs.get(str(o["compteur"]), 0)), int(o["cible"]))


static func fini(id: String, compteurs: Dictionary, d: Donnees) -> bool:
	var o := definition(id, d)
	return not o.is_empty() and avancement(id, compteurs, d) >= int(o["cible"])


## La récompense d'un objectif : {xp, eclats}.
static func recompense(id: String, d: Donnees) -> Dictionary:
	var o := definition(id, d)
	if o.is_empty():
		return {"xp": 0, "eclats": 0}
	return {"xp": int(o["xp"]), "eclats": int(o["eclats"])}


## Les objectifs d'un jour, prêts à afficher : {id, texte, avancement, cible, fini, reclame, xp, eclats}.
static func etat_du_jour(jour: String, compteurs: Dictionary, reclames: Array, d: Donnees) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for id in du_jour(jour, d):
		var o := definition(id, d)
		out.append({"id": id, "texte": str(o["texte"]), "avancement": avancement(id, compteurs, d), "cible": int(o["cible"]),
			"fini": fini(id, compteurs, d), "reclame": reclames.has(id), "xp": int(o["xp"]), "eclats": int(o["eclats"])})
	return out
