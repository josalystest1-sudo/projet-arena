## Le coût d'un nœud selon la grille de docs/SPEC-COMBAT-V2.md (section 7.2), et la vérification que chaque nœud
## tombe dans ±6 % du budget de son rang (7.3, 7.4). Le coût se calcule sur les chiffres écrits dans la donnée (au
## niveau 1, sans le multiplicateur de classe). Utilisé par tools/budget.gd, les tests et le générateur de Destin.
## Module pur.
class_name Budget
extends RefCounted

## Un budget_override (bouton 2 du simulateur, section 11.3) reste à 10 % au plus du budget de son rang.
const ECART_OVERRIDE := 0.10


## Le coût d'un effet : sa valeur fois le prix unitaire de la grille, puis ×1,3 s'il vise tous les ennemis ou le duo.
## Un effet sans valeur qui a son propre prix en cible multiple (« couts_multi » : Purge duo = 100) prend ce prix.
static func cout_effet(regles: Dictionary, effet: Dictionary) -> float:
	var couts: Dictionary = regles["couts"]
	var type := str(effet["type"])
	var base := 0.0
	match type:
		"degats", "soin", "barriere":
			base = float(effet["valeur"]) * float(couts[type])
		"dot", "gardien":
			base = float(effet["par_tour"]) * float(effet["tours"]) * float(couts[type])
		"renfort", "affaiblissement":
			base = float(effet["pourcent"]) * float(couts[type])
		"etat":
			base = float(couts[str(effet["nom"])]) * float(effet["tours"])
		"egare", "purge", "dissipe":
			base = float(couts[type])
	if not str(effet.get("cible", "")) in Donnees.CIBLES_MULTI:
		return base
	var couts_multi: Dictionary = regles.get("couts_multi", {})
	if couts_multi.has(type):
		return float(couts_multi[type])
	return base * float(regles["multi_cible"])


static func cout(regles: Dictionary, noeud: Dictionary) -> float:
	var total := 0.0
	for effet in noeud.get("effets", []):
		total += cout_effet(regles, effet)
	return total


## Le budget d'un rang : 0 pour le moyeu, 1 à 4 (la Clé).
static func budget_rang(regles: Dictionary, rang: int) -> float:
	return float(regles["budgets"]["moyeu" if rang == 0 else str(rang)])


## Le budget d'un nœud : son budget_override s'il en a un, sinon celui de son rang.
static func budget(regles: Dictionary, noeud: Dictionary) -> float:
	if noeud.has("budget_override"):
		return float(noeud["budget_override"])
	return budget_rang(regles, int(noeud.get("rang", 0)))


## Le problème d'un nœud, ou "" s'il est dans son budget.
static func faute(regles: Dictionary, noeud: Dictionary) -> String:
	var rang := int(noeud.get("rang", 0))
	var b := budget(regles, noeud)
	if noeud.has("budget_override"):
		var b_rang := budget_rang(regles, rang)
		if absf(b - b_rang) > ECART_OVERRIDE * b_rang + 0.0001:
			return "budget_override %s à plus de 10 %% du budget du rang (%s)" % [str(b), str(b_rang)]
	var c := cout(regles, noeud)
	if absf(c - b) > float(regles["tolerance_budget"]) * b + 0.0001:
		return "coût %.2f hors de ±%d %% du budget %s (écart %+.1f %%)" % [c, roundi(100.0 * float(regles["tolerance_budget"])), str(b), 100.0 * (c - b) / b]
	return ""


## Tous les nœuds hors budget des classes chargées : { classe, voie, rang, nom, cout, budget, faute }.
static func fautes(donnees: Donnees) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for id in donnees.ordre_classes:
		var cls: Dictionary = donnees.classes[id]
		var noeuds: Array = [["moyeu", cls.get("moyeu", {})]]
		for voie in cls.get("voies", []):
			for n in voie.get("noeuds", []):
				noeuds.append([str(voie.get("id", "?")), n])
		for paire in noeuds:
			var n: Dictionary = paire[1]
			var f := faute(donnees.regles, n)
			if f != "":
				out.append({"classe": id, "voie": paire[0], "rang": int(n.get("rang", 0)), "nom": str(n.get("nom", "?")),
					"cout": cout(donnees.regles, n), "budget": budget(donnees.regles, n), "faute": f})
	return out
