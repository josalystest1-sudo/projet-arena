## La fatigue (docs/VISION.md § 7 ; décision de Gautier du 1er novembre) : une jauge d'énergie par personnage
## (data/fatigue.json). **Seul le farm fatigue** : rejouer un étage de la Tour déjà franchi (un étage au plus égal au record
## de la classe) et enchaîner les combats de donjon. Le record de la Tour, les combats classés, les amicaux, les guerres
## ne fatiguent jamais. Chaque combat de farm coûte `cout_combat` points d'énergie (10 : fatigué après dix combats) ;
## l'énergie revient toute seule avec le temps (`recuperation_par_heure` 40 : pleine en deux heures et demie). Sous le
## seuil de fatigue (`seuil_fatigue` 50), le personnage est moins performant : ses PV max et toutes ses valeurs baissent,
## linéairement, jusqu'à `malus_max` (30 %) à zéro (« plus il est fatigué, moins il est performant »). À zéro, **il
## s'écroule** : plus de farm tant que l'énergie n'est pas remontée à `reveil` (30 : trois quarts d'heure). La potion
## d'énergie (`potion` : +50, trois par jour, contre des Éclats ou de l'Or) s'achète chez l'Alchimiste du Comptoir.
## Le malus entre dans un combat par `Destin.fatigue` (engine/destin.gd), lu une fois à la création (engine/regles.gd).
## Un état : {energie (flottant), depuis (instant unix de la dernière mise à jour), ecroule, potions (bues ce jour),
## jour_potions}. Module pur : l'instant et le jour sont fournis par l'application (scenes/combat/player_profile.gd :
## `maintenant()`, `aujourd_hui()`), jamais lus ici.
class_name Fatigue
extends RefCounted

const CLES_ETAT := ["energie", "depuis", "ecroule", "potions", "jour_potions"]


# --- L'état ----------------------------------------------------------------------------------

## Un personnage reposé : toute son énergie, pas de potion bue.
static func neuf(maintenant: int, d: Donnees) -> Dictionary:
	return {"energie": float(d.fatigue["energie_max"]), "depuis": maintenant, "ecroule": false, "potions": 0, "jour_potions": ""}


static func etat_valide(etat: Variant) -> bool:
	if not etat is Dictionary:
		return false
	for cle in CLES_ETAT:
		if not etat.has(cle):
			return false
	return true


## L'état mis à jour à cet instant : l'énergie revenue depuis la dernière mise à jour (jamais au-delà du maximum),
## l'écroulement levé dès le réveil. Un état inconnu ou abîmé : un personnage reposé.
static func a_jour(etat: Variant, maintenant: int, d: Donnees) -> Dictionary:
	if not etat_valide(etat):
		return neuf(maintenant, d)
	var out: Dictionary = etat.duplicate(true)
	var ecoule := maxi(0, maintenant - int(out["depuis"]))
	out["energie"] = minf(float(d.fatigue["energie_max"]), float(out["energie"]) + float(ecoule) / 3600.0 * float(d.fatigue["recuperation_par_heure"]))
	out["depuis"] = maintenant
	if bool(out["ecroule"]) and float(out["energie"]) >= float(d.fatigue["reveil"]):
		out["ecroule"] = false
	return out


## L'énergie à cet instant, en points entiers (arrondie vers le bas).
static func energie(etat: Variant, maintenant: int, d: Donnees) -> int:
	return floori(float(a_jour(etat, maintenant, d)["energie"]))


static func est_ecroule(etat: Variant, maintenant: int, d: Donnees) -> bool:
	return bool(a_jour(etat, maintenant, d)["ecroule"])


# --- Le malus et le farm -----------------------------------------------------------------------

## Le malus d'une énergie (une fraction) : rien au-dessus du seuil de fatigue, puis linéaire jusqu'à `malus_max` à zéro.
static func malus(p_energie: float, d: Donnees) -> float:
	var seuil := float(d.fatigue["seuil_fatigue"])
	if p_energie >= seuil or seuil <= 0.0:
		return 0.0
	return float(d.fatigue["malus_max"]) * (seuil - maxf(0.0, p_energie)) / seuil


## Le malus du personnage à cet instant.
static func malus_actuel(etat: Variant, maintenant: int, d: Donnees) -> float:
	return malus(float(a_jour(etat, maintenant, d)["energie"]), d)


## Peut-il faire un combat de farm ? Oui tant qu'il n'est pas écroulé (même presque à bout : il s'écroulera après).
static func peut_combattre(etat: Variant, maintenant: int, d: Donnees) -> bool:
	return not est_ecroule(etat, maintenant, d)


## L'état après un combat de farm : le coût retiré ; à zéro, le personnage s'écroule.
static func apres_combat(etat: Variant, maintenant: int, d: Donnees) -> Dictionary:
	var out := a_jour(etat, maintenant, d)
	out["energie"] = maxf(0.0, float(out["energie"]) - float(d.fatigue["cout_combat"]))
	if float(out["energie"]) <= 0.0:
		out["ecroule"] = true
	return out


## Un étage de la Tour est du farm s'il est au plus égal au record de la classe (déjà franchi) ; le record, jamais.
static func est_farm_tour(etage: int, record: int) -> bool:
	return etage <= record


## Les secondes avant que l'énergie atteigne cette valeur (0 si c'est déjà fait).
static func secondes_avant(etat: Variant, maintenant: int, cible: float, d: Donnees) -> int:
	var e := float(a_jour(etat, maintenant, d)["energie"])
	if e >= cible:
		return 0
	return ceili((cible - e) / float(d.fatigue["recuperation_par_heure"]) * 3600.0)


## Les secondes avant le réveil d'un personnage écroulé (0 s'il ne l'est pas).
static func secondes_reveil(etat: Variant, maintenant: int, d: Donnees) -> int:
	if not est_ecroule(etat, maintenant, d):
		return 0
	return secondes_avant(etat, maintenant, float(d.fatigue["reveil"]), d)


# --- La potion ------------------------------------------------------------------------------------

## Les potions qu'il reste à boire ce jour.
static func potions_restantes(etat: Variant, jour: String, d: Donnees) -> int:
	var bues := 0
	if etat_valide(etat) and str(etat["jour_potions"]) == jour:
		bues = int(etat["potions"])
	return maxi(0, int(d.fatigue["potion"]["par_jour"]) - bues)


static func peut_boire(etat: Variant, jour: String, d: Donnees) -> bool:
	return potions_restantes(etat, jour, d) > 0


## L'état après une potion : l'énergie rendue (jamais au-delà du maximum), la potion comptée pour le jour, l'écroulement
## levé si l'énergie atteint le réveil. Sans potion restante : l'état tel quel.
static func boire(etat: Variant, maintenant: int, jour: String, d: Donnees) -> Dictionary:
	var out := a_jour(etat, maintenant, d)
	if not peut_boire(out, jour, d):
		return out
	if str(out["jour_potions"]) != jour:
		out["jour_potions"] = jour
		out["potions"] = 0
	out["potions"] = int(out["potions"]) + 1
	out["energie"] = minf(float(d.fatigue["energie_max"]), float(out["energie"]) + float(d.fatigue["potion"]["energie"]))
	if bool(out["ecroule"]) and float(out["energie"]) >= float(d.fatigue["reveil"]):
		out["ecroule"] = false
	return out


## Le prix d'une potion : {eclats, or}.
static func prix_potion(d: Donnees) -> Dictionary:
	return {"eclats": int(d.fatigue["potion"]["prix_eclats"]), "or": int(d.fatigue["potion"]["prix_or"])}


# --- Les textes -------------------------------------------------------------------------------------

## « 2 h 05 », « 45 min », « moins d'une minute ».
static func texte_duree(secondes: int) -> String:
	if secondes < 60:
		return "moins d'une minute"
	var minutes := ceili(float(secondes) / 60.0)
	if minutes < 60:
		return "%d min" % minutes
	return "%d h %02d" % [minutes / 60, minutes % 60]


## « Énergie 70 / 100 · en forme », « … · fatigué (−12 %) », « … · écroulé, réveil dans 45 min ».
static func texte_energie(etat: Variant, maintenant: int, d: Donnees) -> String:
	var e := energie(etat, maintenant, d)
	var base := "Énergie %d / %d" % [e, int(d.fatigue["energie_max"])]
	if est_ecroule(etat, maintenant, d):
		return "%s · écroulé de fatigue, réveil dans %s" % [base, texte_duree(secondes_reveil(etat, maintenant, d))]
	var m := malus_actuel(etat, maintenant, d)
	if m <= 0.0:
		return base + " · en forme"
	return "%s · fatigué (−%d %% sur tes PV et tes valeurs)" % [base, roundi(m * 100.0)]
