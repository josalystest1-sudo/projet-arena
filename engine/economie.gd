## L'économie (docs/GDD_V2.md, § 10.2 : prix libres, Or impossible à fabriquer, aucune inflation). L'Or n'entre dans le jeu
## que par le Comptoir (la vente d'un objet échangeable au prix plancher) et n'en sort que par la taxe du Marché (détruite à
## chaque vente entre joueurs). Ce module mesure ces mouvements semaine par semaine (bilan), fait monter la taxe quand
## l'Or créé dépasse de trop l'Or détruit (data/marche.json : taxe, taxe_max, inflation ; la taxe d'une semaine se lit
## sur le bilan de la semaine d'avant, la même pour tout le monde), et tient les garde-fous par jour contre les bots et
## les revendeurs d'Or (data/comptoir.json : ventes_par_jour ; data/marche.json : depots_par_jour, achats_par_jour). Les
## mouvements vivent sur le serveur (scenes/net/serveur.gd : mouvement, bilan) ; ce module dit les règles. Module pur.
class_name Economie
extends RefCounted

## Les types de mouvement : « comptoir » (de l'Or créé : une vente au Comptoir), « taxe » (de l'Or détruit : la taxe d'une
## vente au Marché), « achat » (de l'Or passé d'un joueur à un autre : le prix d'une annonce achetée).
const TYPES := ["comptoir", "taxe", "achat"]
const CLES_MOUVEMENT := ["type", "montant", "jour", "semaine"]
## Les garde-fous par jour : ce qu'on compte -> [le fichier de données, la clé].
const LIMITES := {"ventes": ["comptoir", "ventes_par_jour"], "depots": ["marche", "depots_par_jour"], "achats": ["marche", "achats_par_jour"]}


# --- Les mouvements et le bilan ---------------------------------------------------------------

## Un mouvement d'Or, daté (la semaine est celle du jour : engine/arene.gd).
static func mouvement(type: String, montant: int, jour: String) -> Dictionary:
	return {"type": type, "montant": maxi(0, montant), "jour": jour, "semaine": Arene.semaine(jour)}


static func mouvement_valide(m: Dictionary) -> bool:
	for cle in CLES_MOUVEMENT:
		if not m.has(cle):
			return false
	return str(m["type"]) in TYPES and int(m["montant"]) >= 0


## Le bilan d'une semaine : {entre (créé au Comptoir), detruit (la taxe), echange (passé entre joueurs)}, en Or.
static func bilan(mouvements: Array, semaine: int) -> Dictionary:
	var out := {"entre": 0, "detruit": 0, "echange": 0}
	for m in mouvements:
		if not m is Dictionary or int(m.get("semaine", -1)) != semaine:
			continue
		match str(m.get("type", "")):
			"comptoir":
				out["entre"] += int(m["montant"])
			"taxe":
				out["detruit"] += int(m["montant"])
			"achat":
				out["echange"] += int(m["montant"])
	return out


## Deux bilans additionnés.
static func somme(a: Dictionary, b: Dictionary) -> Dictionary:
	return {"entre": int(a.get("entre", 0)) + int(b.get("entre", 0)), "detruit": int(a.get("detruit", 0)) + int(b.get("detruit", 0)),
		"echange": int(a.get("echange", 0)) + int(b.get("echange", 0))}


## Le bilan du monde simulé pour une semaine (scenes/net/serveur_simule.gd) : par joueur simulé, de l'Or créé, détruit
## et échangé, tirés avec le numéro de la semaine ; en temps ordinaire, l'Or créé vaut environ trois fois l'Or détruit :
## sous le seuil d'inflation.
static func monde_simule(nb_joueurs: int, semaine: int, d: Donnees) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = semaine * 7919 + 0x0EC0
	var out := {"entre": 0, "detruit": 0, "echange": 0}
	var taux := float(d.marche["taxe"])
	for _i in range(maxi(0, nb_joueurs)):
		var cree := rng.randi_range(10, 60)
		var echange := rng.randi_range(20, 120)
		out["entre"] += cree
		out["echange"] += echange
		out["detruit"] += int(ceil(float(echange) * taux))
	return out


# --- La taxe qui monte -------------------------------------------------------------------------

## Le taux de taxe du Marché d'après le bilan de la semaine d'avant : le taux de base tant que l'Or créé ne dépasse pas
## `seuil` fois l'Or détruit (ou reste sous `minimum` Or : trop peu pour juger) ; au-delà, `pas` de plus par cran de `par`
## dans ce rapport, jusqu'à taxe_max. Les fourchettes de prix ne bougent jamais (GDD).
static func taux_taxe(entre: int, detruit: int, d: Donnees) -> float:
	var base := float(d.marche["taxe"])
	var inf: Dictionary = d.marche["inflation"]
	if entre < int(inf["minimum"]):
		return base
	var ratio := float(entre) / float(maxi(1, detruit))
	if ratio <= float(inf["seuil"]):
		return base
	var crans := floori((ratio - float(inf["seuil"])) / float(inf["par"]) + 0.000001) + 1
	return minf(float(d.marche["taxe_max"]), base + float(inf["pas"]) * float(crans))


## Le taux en français : « 15 % ».
static func texte_taux(taux: float) -> String:
	return "%d %%" % roundi(taux * 100.0)


## « Taxe du Marché cette semaine : 15 % (la semaine passée : 840 Or créés au Comptoir, 264 détruits par la taxe). »
static func texte_taxe(bilan_passe: Dictionary, taux: float, d: Donnees) -> String:
	var t := "Taxe du Marché cette semaine : %s" % texte_taux(taux)
	if taux > float(d.marche["taxe"]) + 0.0001:
		t += " (elle monte : trop d'Or créé pour trop peu détruit)"
	return t + " (la semaine passée : %d Or créés au Comptoir, %d détruits par la taxe, %d échangés entre joueurs)." % [
		int(bilan_passe.get("entre", 0)), int(bilan_passe.get("detruit", 0)), int(bilan_passe.get("echange", 0))]


# --- Les garde-fous par jour --------------------------------------------------------------------

## La limite par jour d'une action (« ventes » au Comptoir, « depots » et « achats » au Marché).
static func limite(quoi: String, d: Donnees) -> int:
	var ou: Array = LIMITES[quoi]
	var regles: Dictionary = d.comptoir if str(ou[0]) == "comptoir" else d.marche
	return int(regles[ou[1]])


## Les compteurs du jour, remis à zéro si le jour a changé.
static func compteurs_du_jour(compteurs: Dictionary, jour: String) -> Dictionary:
	if str(compteurs.get("jour", "")) == jour:
		return compteurs.duplicate()
	return {"jour": jour}


## Ce qu'il reste d'une action aujourd'hui.
static func reste(compteurs: Dictionary, jour: String, quoi: String, d: Donnees) -> int:
	var c := compteurs_du_jour(compteurs, jour)
	return maxi(0, limite(quoi, d) - int(c.get(quoi, 0)))


## Une action de plus aujourd'hui : les compteurs mis à jour.
static func compter(compteurs: Dictionary, jour: String, quoi: String) -> Dictionary:
	var c := compteurs_du_jour(compteurs, jour)
	c[quoi] = int(c.get(quoi, 0)) + 1
	return c


## « Ventes au Comptoir aujourd'hui : 2 sur 10. »
static func texte_reste(compteurs: Dictionary, jour: String, quoi: String, d: Donnees) -> String:
	var noms := {"ventes": "Ventes au Comptoir", "depots": "Mises en vente", "achats": "Achats au Marché"}
	var c := compteurs_du_jour(compteurs, jour)
	return "%s aujourd'hui : %d sur %d." % [noms[quoi], int(c.get(quoi, 0)), limite(quoi, d)]
