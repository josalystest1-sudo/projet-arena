## Le Comptoir (docs/GDD_V2.md, § 10.2 ; docs/PLAN.md, PR 5.5) : le seul robinet d'Or du jeu. Il achète tout objet
## échangeable au prix plancher (selon la rareté, le niveau et la qualité : data/comptoir.json) et vend chaque jour un
## étal d'objets liés (un commun, un rare, du niveau du joueur, tirés avec la date) contre des Éclats. L'Or (la monnaie
## échangeable) ne tombe jamais du contenu : il naît de la chance (un objet échangeable vendu) ; il servira à la Boutique
## et au Marché. La fourchette de prix du Marché (de 1 à N fois le plancher selon la rareté) est écrite ici pour plus
## tard. Module pur : le hasard vient de la date.
class_name Comptoir
extends RefCounted


## Un objet peut-il se vendre (il est échangeable) ?
static func vendable(objet: Dictionary) -> bool:
	return not objet.is_empty() and not bool(objet.get("lie", true))


## Le prix plancher d'un objet, en Or : la base de sa rareté × (1 + pente × niveau ÷ 30) × (base de qualité + (1 − base)
## × qualité ÷ 100), arrondi, au moins 1.
static func prix_plancher(objet: Dictionary, d: Donnees) -> int:
	var c: Dictionary = d.comptoir
	var base := float(c["plancher"].get(str(objet.get("rarete", "")), 0.0))
	if base <= 0.0:
		return 0
	var niveau := float(c["niveau_pente"]) * float(int(objet.get("niveau", 1))) / 30.0
	var q := float(c["qualite_base"]) + (1.0 - float(c["qualite_base"])) * float(int(objet.get("qualite", 0))) / 100.0
	return maxi(1, roundi(base * (1.0 + niveau) * q))


## La fourchette de prix autorisée au Marché (GDD V2, § 10.2) : du plancher à plancher × le multiple de la rareté.
static func fourchette_marche(objet: Dictionary, d: Donnees) -> Array:
	var plancher := prix_plancher(objet, d)
	return [plancher, plancher * int(d.comptoir["marche"].get(str(objet.get("rarete", "")), 1))]


## L'étal du jour : un objet lié par rareté de l'étal, du niveau donné, tiré avec la date (le même pour tout le monde).
static func etal_du_jour(jour: String, niveau: int, d: Donnees) -> Array:
	var out: Array = []
	var bases: Array = d.objets["bases"].keys()
	bases.sort()
	var rng := RandomNumberGenerator.new()
	rng.seed = jour.hash() ^ 0x0C0A7E12
	for rarete in d.comptoir["etal"]["raretes"]:
		var base: String = bases[rng.randi_range(0, bases.size() - 1)]
		out.append(Equipement.tirer(base, str(rarete), maxi(1, niveau), rng.randi_range(0, 0x7FFFFFFF), d, true))
	return out


## Le prix d'un objet de l'étal, en Éclats (selon sa rareté).
static func prix_etal(objet: Dictionary, d: Donnees) -> int:
	return int(d.comptoir["etal"]["prix"].get(str(objet.get("rarete", "")), 0))
