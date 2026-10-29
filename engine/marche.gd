## Le Marché (docs/GDD_V2.md, § 10.2 ; docs/PLAN.md, PR 5.5) : l'hôtel des ventes entre joueurs. Le vendeur fixe le prix
## qu'il veut dans la fourchette autorisée (engine/comptoir.gd : du plancher à plancher × le multiple de la rareté) ;
## les annonces sont anonymes et vont au premier acheteur ; chaque vente détruit une taxe (15 %) ; le Marché s'ouvre au
## niveau 15 et après 7 jours de compte (data/marche.json). Aucun autre canal d'échange. Les annonces vivent sur le
## serveur (scenes/net/serveur.gd) ; ce module dit les règles et fabrique les annonces. Module pur : le hasard du monde
## simulé vient de la date.
class_name Marche
extends RefCounted

const CLES_ANNONCE := ["id", "objet", "prix", "vendeur"]


## Le Marché est-il ouvert à ce joueur (niveau et âge du compte) ?
static func ouvert(niveau: int, jours_compte: int, d: Donnees) -> bool:
	return niveau >= int(d.marche["niveau_min"]) and jours_compte >= int(d.marche["jours_min"])


## Ce qui manque pour qu'il s'ouvre, en français courant ("" s'il est ouvert).
static func manque(niveau: int, jours_compte: int, d: Donnees) -> String:
	var bouts: Array[String] = []
	var nmin := int(d.marche["niveau_min"])
	var jmin := int(d.marche["jours_min"])
	if niveau < nmin:
		bouts.append("le niveau %d (tu es niveau %d)" % [nmin, niveau])
	if jours_compte < jmin:
		var reste := jmin - jours_compte
		bouts.append("%d jours de compte (encore %d jour%s)" % [jmin, reste, "s" if reste > 1 else ""])
	return " et ".join(bouts)


## Un prix est-il permis pour cet objet (dans la fourchette du Marché) ?
static func prix_valide(objet: Dictionary, prix: int, d: Donnees) -> bool:
	var f := Comptoir.fourchette_marche(objet, d)
	return Comptoir.vendable(objet) and prix >= int(f[0]) and prix <= int(f[1])


## La taxe d'une vente (détruite), arrondie au-dessus.
static func taxe(prix: int, d: Donnees) -> int:
	return int(ceil(float(prix) * float(d.marche["taxe"])))


## Ce que touche le vendeur.
static func net(prix: int, d: Donnees) -> int:
	return maxi(0, prix - taxe(prix, d))


## Une annonce : l'objet (échangeable), le prix, le vendeur (son compte ; jamais montré aux autres), un identifiant.
static func annonce(objet: Dictionary, prix: int, vendeur: String, id: String) -> Dictionary:
	var copie := objet.duplicate(true)
	copie["lie"] = false
	return {"id": id, "objet": copie, "prix": prix, "vendeur": vendeur, "rarete": str(objet.get("rarete", "")), "niveau": int(objet.get("niveau", 1))}


static func annonce_valide(a: Dictionary, d: Donnees) -> bool:
	for cle in CLES_ANNONCE:
		if not a.has(cle):
			return false
	return a["objet"] is Dictionary and Equipement.valide(a["objet"], d) and prix_valide(a["objet"], int(a["prix"]), d)


## Les annonces du monde simulé pour un jour : des objets tirés avec la date, vendus par des joueurs simulés, à un
## prix dans la fourchette (plutôt bas : le carré d'un tirage uniforme).
static func annonces_simulees(joueurs: Array, jour: String, d: Donnees) -> Array:
	var out: Array = []
	if joueurs.is_empty():
		return out
	var sim: Dictionary = d.marche["simule"]
	var bases: Array = d.objets["bases"].keys()
	bases.sort()
	var raretes: Array = sim["raretes"].keys()
	raretes.sort()
	var total := 0.0
	for r in raretes:
		total += float(sim["raretes"][r])
	for i in range(int(sim["annonces"])):
		var rng := RandomNumberGenerator.new()
		rng.seed = jour.hash() ^ (0x3A8C1 * (i + 1))
		var vendeur: Dictionary = joueurs[rng.randi_range(0, joueurs.size() - 1)]
		var tirage := rng.randf_range(0.0, total)
		var rarete := str(raretes[0])
		for r in raretes:
			rarete = str(r)
			tirage -= float(sim["raretes"][r])
			if tirage < 0.0:
				break
		var base: String = bases[rng.randi_range(0, bases.size() - 1)]
		var objet := Equipement.tirer(base, rarete, maxi(1, int(vendeur["niveau"])), rng.randi_range(0, 0x7FFFFFFF), d, false)
		var f := Comptoir.fourchette_marche(objet, d)
		var t := rng.randf_range(0.0, 1.0)
		var prix := int(f[0]) + roundi(float(int(f[1]) - int(f[0])) * t * t)
		out.append(annonce(objet, prix, str(vendeur["id"]), "sim-%s-%d" % [jour, i]))
	return out
