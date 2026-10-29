## Les évolutions de classe (docs/GDD_V2.md, § 3 ; décisions de Gautier du 30 octobre, docs/JOURNAL-COMBAT-V2.md) :
## au niveau 30, un personnage peut évoluer en l'une des trois évolutions de sa classe (rang 1) ; au niveau 60, en l'une
## des évolutions de son évolution (rang 2 ; une par évolution de rang 1 pour l'instant). Une évolution est une classe à
## part entière (data/evolutions/<id>.json : nom, rôle, PV, k, moyeu, 5 voies), avec son parent (`base` : la classe de
## base pour le rang 1, l'évolution de rang 1 pour le rang 2) et son rang. Évoluer : nouvelle roue, zéro point de Destin,
## puis un point par niveau jusqu'au plafond du rang suivant (31 à 60, puis 61 à 90) ; la graine ne change pas. Le saut de puissance du GDD (×2,5)
## est porté par data/rules.json (`evolution.puissance_pv` et `puissance_valeurs` : PV ×2,5 et valeurs ×2,5, pour qu'un
## évolué à roue vide batte un niveau 29 à roue pleine, même en trio ; tools/mesure_evolution.gd le mesure), appliqué aux
## PV et au multiplicateur de classe de tout Destin évolué (Destin.de_base). Module pur.
class_name Evolution
extends RefCounted


## Le nombre de niveaux d'un rang (30 : la classe de base évolue au niveau 30, le rang 1 au niveau 60).
static func niveaux_par_rang(d: Donnees) -> int:
	return int(d.regles["evolution"]["niveau"])


## Le rang d'une classe : 0 pour une classe de base, 1 pour une évolution.
static func rang(classe_id: String, d: Donnees) -> int:
	return int(d.classe(classe_id).get("rang", 0))


## Le parent d'une classe : sa classe de base pour un rang 1, son évolution de rang 1 pour un rang 2 ; elle-même pour
## une classe de base.
static func parent(classe_id: String, d: Donnees) -> String:
	return str(d.classe(classe_id).get("base", classe_id))


## La classe de base au bout de la lignée (elle-même pour une classe de base) : elle porte les records de la Tour et
## le sprite.
static func base(classe_id: String, d: Donnees) -> String:
	var c := classe_id
	for _i in range(8):
		var p := parent(c, d)
		if p == c:
			return c
		c = p
	return c


## Les évolutions d'une classe, dans l'ordre de data/evolutions.json.
static func evolutions_de(classe_id: String, d: Donnees) -> Array[String]:
	var out: Array[String] = []
	for id in d.ordre_evolutions:
		if str(d.classe(id).get("base", "")) == classe_id:
			out.append(id)
	return out


## Les évolutions d'un rang et d'un rôle (le rôle de l'évolution, pas celui de sa classe de base).
static func du_role(role: String, d: Donnees, p_rang: int = 1) -> Array[String]:
	var out: Array[String] = []
	for id in d.ordre_evolutions:
		if str(d.classe(id).get("role", "")) == role and rang(id, d) == p_rang:
			out.append(id)
	return out


## Le rang le plus haut qui existe dans les données (0 tant qu'il n'y a pas d'évolution).
static func rang_max(d: Donnees) -> int:
	var out := 0
	for id in d.ordre_evolutions:
		out = maxi(out, rang(id, d))
	return out


## Le niveau le plus haut d'un rang : 30 pour la classe de base, 60 pour le rang 1, 90 pour le rang 2.
static func niveau_max(p_rang: int, d: Donnees) -> int:
	return niveaux_par_rang(d) * (p_rang + 1)


## Le rang attendu d'un personnage de ce niveau : 0 jusqu'au niveau 30, 1 de 31 à 60, 2 de 61 à 90 (borné par ce qui
## existe).
static func rang_du_niveau(niveau: int, d: Donnees) -> int:
	return clampi((niveau - 1) / niveaux_par_rang(d), 0, rang_max(d))


## Les points de Destin d'un personnage de ce rang à ce niveau : un par niveau au-dessus du plancher de son rang
## (classe de base : niveau 1 = 1 point ; rang 1 : niveau 30 = 0 point, niveau 60 = 30 points).
static func points(niveau: int, p_rang: int, d: Donnees) -> int:
	return maxi(0, niveau - niveaux_par_rang(d) * p_rang)


## Ce personnage peut-il évoluer maintenant ? Au plafond de son rang, si sa classe a des évolutions.
static func peut_evoluer(classe_id: String, niveau: int, d: Donnees) -> bool:
	var r := rang(classe_id, d)
	return r < rang_max(d) and niveau >= niveau_max(r, d) and not evolutions_de(classe_id, d).is_empty()


## Le multiplicateur des PV de base d'un Destin de ce rang (×1 pour une classe de base).
static func puissance_pv(p_rang: int, d: Donnees) -> float:
	return pow(float(d.regles["evolution"]["puissance_pv"]), p_rang)


## Le multiplicateur des valeurs (le k de la classe) d'un Destin de ce rang (×1 pour une classe de base).
static func puissance_valeurs(p_rang: int, d: Donnees) -> float:
	return pow(float(d.regles["evolution"]["puissance_valeurs"]), p_rang)


## L'évolution d'une classe tirée avec une graine (pour les Échos et les adversaires générés au-delà du niveau 30) ;
## la classe elle-même si elle n'en a pas.
static func tirer(classe_id: String, graine: int, d: Donnees) -> String:
	var choix := evolutions_de(classe_id, d)
	if choix.is_empty():
		return classe_id
	var rng := RandomNumberGenerator.new()
	rng.seed = graine ^ 0x2E7A11CE
	return choix[rng.randi_range(0, choix.size() - 1)]


## La classe qu'un personnage généré de ce niveau doit avoir : sa classe de base jusqu'au niveau 30, une de ses
## évolutions (tirée avec la graine) de 31 à 60, une évolution de celle-ci au-delà.
static func classe_au_niveau(classe_id: String, niveau: int, graine: int, d: Donnees) -> String:
	var c := classe_id
	var vise := rang_du_niveau(niveau, d)
	while rang(c, d) < vise:
		var suivante := tirer(c, graine + rang(c, d), d)
		if suivante == c:
			break
		c = suivante
	return c
