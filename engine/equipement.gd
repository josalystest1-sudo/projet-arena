## L'équipement (docs/GDD_V2.md, § 10.1 ; docs/PLAN.md, PR 3.1) : un objet est un paquet de modificateurs dans la langue
## du Destin ; il n'a de valeur que pour un Destin. Huit emplacements (Arme, Casque, Armure, Cape, Bottes, Ceinture, Anneau,
## Amulette ; décision de Gautier du 1er novembre), cinq raretés (commun 1 ligne, peu commun 2, rare 2 plus larges, épique 3,
## légendaire 4), quarante-huit bases aux noms fixes (data/items.json : six par emplacement, chaque ligne dans vingt-quatre
## réserves), chacune avec sa réserve de quatre lignes possibles, et des paliers
## de niveau qui donnent au nom son matériau (« Épée d'acier épique » : de fer, d'acier, d'argent, de mithril, runique,
## de dragon). Les huit lignes (décision de Gautier du 29 octobre) : PV max, Force (toutes les
## valeurs), Dégâts, Soins, Barrières, Poisons et brûlures (DoT), Clés, Ouvertures (moyeu et N1). Une ligne a une
## fourchette connue, affichée, qui grandit avec le niveau de l'objet et sa rareté ; ses chiffres sont tirés à la
## trouvaille (graine fournie), et la qualité en % dit où le tirage est tombé dans ses fourchettes. Des plafonds par
## ligne, sur le total des objets portés, pour qu'aucune ligne ne fasse un personnage à elle seule (les fourchettes sont
## taillées pour qu'un jeu complet épique vaille environ +50 %, décision du 29 octobre, quel que soit le nombre d'emplacements).
## Un objet : {base, rarete, niveau, lignes: [{stat, valeur (en %)}], qualite (0 à 100), lie, reforges, trait (un objet
## légendaire seulement : l'identifiant de son trait, data/items.json traits, tiré à la trouvaille ; un passif de combat
## que engine/regles.gd applique au porteur ; un même trait porté deux fois ne compte qu'une fois)}.
## Lié ou échangeable : un objet est échangeable seulement s'il vient d'un premier passage ; il devient lié dès
## qu'on l'équipe, et le reste. La reforge retire une ligne contre des Éclats, à coût croissant.
## Les bonus d'un équipement entrent dans un combat par `Destin.mods` (engine/destin.gd), lus une fois à la création
## du combat (engine/regles.gd) : les PV max et le multiplicateur de classe, puis chaque valeur selon son type.
## Module pur : le hasard vient de la graine fournie.
class_name Equipement
extends RefCounted

## Les huit lignes, dans l'ordre d'affichage.
const STATS := ["pv", "force", "degats", "soins", "barrieres", "dot", "cle", "ouverture"]
## La ligne qui s'applique à un type d'effet (engine/regles.gd, valeur).
const STAT_PAR_TYPE := {"degats": "degats", "soin": "soins", "gardien": "soins", "barriere": "barrieres", "dot": "dot"}


# --- Les fourchettes ------------------------------------------------------------

## L'échelle du niveau d'un objet : plancher au niveau 1, 1 au niveau plein (30) et au-delà (data/items.json).
static func echelle_niveau(niveau: int, d: Donnees) -> float:
	var plancher := float(d.objets["niveau"]["plancher"])
	var plein := float(d.objets["niveau"]["plein"])
	if plein <= 1.0:
		return 1.0
	return plancher + (1.0 - plancher) * (minf(float(maxi(1, niveau)), plein) - 1.0) / (plein - 1.0)


## La fourchette d'une ligne (en %, à 0,1 près) pour un objet de cette rareté et de ce niveau : celle des données
## (rareté commune au niveau plein) × l'échelle de la rareté × celle du niveau. [min, max].
static func fourchette(stat: String, rarete: String, niveau: int, d: Donnees) -> Array:
	var f: Array = d.objets["lignes"][stat]["fourchette"]
	var echelle := float(d.objets["raretes"][rarete]["echelle"]) * echelle_niveau(niveau, d)
	return [_dixieme(float(f[0]) * echelle), _dixieme(float(f[1]) * echelle)]


## Le nombre de lignes d'un objet : celui de sa rareté, au plus la réserve de sa base.
static func nb_lignes(base_id: String, rarete: String, d: Donnees) -> int:
	return mini(int(d.objets["raretes"][rarete]["lignes"]), d.objets["bases"][base_id]["lignes"].size())


static func _dixieme(x: float) -> float:
	return roundf(x * 10.0) / 10.0


# --- Le tirage ----------------------------------------------------------------------

## Un objet trouvé : ses lignes tirées dans la réserve de sa base (toutes différentes), chaque chiffre dans sa
## fourchette, avec la graine. Échangeable ou lié selon sa provenance.
static func tirer(base_id: String, rarete: String, niveau: int, graine: int, d: Donnees, lie: bool = true) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = graine
	var reserve: Array = d.objets["bases"][base_id]["lignes"].duplicate()
	var objet := {"base": base_id, "rarete": rarete, "niveau": maxi(1, niveau), "lignes": [], "qualite": 0, "lie": lie, "reforges": 0}
	for i in range(nb_lignes(base_id, rarete, d)):
		var stat: String = reserve.pop_at(rng.randi_range(0, reserve.size() - 1))
		objet["lignes"].append(_ligne(stat, rarete, objet["niveau"], rng, d))
	objet["qualite"] = qualite(objet, d)
	if a_trait(rarete, d):
		var ids: Array = d.objets["traits"].keys()
		ids.sort()
		objet["trait"] = str(ids[rng.randi_range(0, ids.size() - 1)])
	return objet


## Un objet de cette rareté porte-t-il un trait ? Seulement la rareté la plus haute (légendaire).
static func a_trait(rarete: String, d: Donnees) -> bool:
	var rang_max := 0
	for r in d.objets["raretes"]:
		rang_max = maxi(rang_max, int(d.objets["raretes"][r]["rang"]))
	return int(d.objets["raretes"][rarete]["rang"]) == rang_max and not d.objets.get("traits", {}).is_empty()


## Les traits des objets portés, chacun une fois, dans l'ordre des données.
static func traits(objets: Array, d: Donnees) -> Array[String]:
	var out: Array[String] = []
	for id in d.objets.get("traits", {}):
		for o in objets:
			if str(o.get("trait", "")) == str(id) and not str(id) in out:
				out.append(str(id))
	return out


## « Soif : chaque dégât direct qu'il inflige le soigne de 10 % de ce dégât ».
static func texte_trait(id: String, d: Donnees) -> String:
	if not d.objets.get("traits", {}).has(id):
		return ""
	var t: Dictionary = d.objets["traits"][id]
	return "%s : %s" % [t["nom"], str(t["texte"]).replace("{v}", chiffre(float(t["valeur"]) * 100.0))]


## Une ligne tirée : son chiffre entre les bornes de sa fourchette.
static func _ligne(stat: String, rarete: String, niveau: int, rng: RandomNumberGenerator, d: Donnees) -> Dictionary:
	var f := fourchette(stat, rarete, niveau, d)
	return {"stat": stat, "valeur": _dixieme(rng.randf_range(float(f[0]), float(f[1])))}


## La qualité d'un objet (0 à 100) : où ses chiffres sont tombés dans leurs fourchettes, en moyenne.
static func qualite(objet: Dictionary, d: Donnees) -> int:
	if objet["lignes"].is_empty():
		return 0
	var somme := 0.0
	for l in objet["lignes"]:
		var f := fourchette(str(l["stat"]), str(objet["rarete"]), int(objet["niveau"]), d)
		somme += clampf((float(l["valeur"]) - float(f[0])) / maxf(0.0001, float(f[1]) - float(f[0])), 0.0, 1.0)
	return roundi(100.0 * somme / float(objet["lignes"].size()))


## Un jeu complet : un objet de cette rareté et de ce niveau par emplacement (sa base tirée parmi celles de
## l'emplacement), avec la graine. Pour le simulateur et les essais.
static func jeu(niveau: int, rarete: String, graine: int, d: Donnees) -> Array:
	var out: Array = []
	var rng := RandomNumberGenerator.new()
	rng.seed = graine ^ 0x7A3B9C1D
	var i := 0
	for emplacement in d.objets["emplacements"]:
		var bases := bases_de(str(emplacement), d)
		var base: String = bases[rng.randi_range(0, bases.size() - 1)]
		out.append(tirer(base, rarete, niveau, graine + i, d))
		i += 1
	return out


## Les bases d'un emplacement, dans l'ordre des données.
static func bases_de(emplacement: String, d: Donnees) -> Array[String]:
	var out: Array[String] = []
	for id in d.objets["bases"]:
		if str(d.objets["bases"][id]["emplacement"]) == emplacement:
			out.append(str(id))
	return out


## L'emplacement d'un objet.
static func emplacement(objet: Dictionary, d: Donnees) -> String:
	return str(d.objets["bases"][objet["base"]]["emplacement"])


# --- Le butin --------------------------------------------------------------------------

## Le butin d'une source (« etage », « gardien » ou « grand_gardien », data/items.json) à ce niveau : sa rareté tirée selon
## les poids de la source, sa base parmi toutes ; échangeable seulement au premier passage. Un étage ordinaire ne lâche
## pas toujours un objet (« butin non assuré », décision de Gautier du 1er novembre : `chance_etage` au premier passage,
## `rejoue` ensuite ; vide alors, et l'étage ne donne que ses Éclats et son XP). Un Gardien en lâche toujours. La Tour
## lâche du commun et du peu commun ; les raretés au-dessus viennent des donjons (le grand Gardien lâche parfois un rare,
## proposition à valider).
## bonus_rejoue : des points de chance en plus sur un étage rejoué (la Chasse de guilde, engine/guilde.gd).
static func butin(source: String, niveau: int, premier_passage: bool, graine: int, d: Donnees, bonus_rejoue: float = 0.0) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = graine ^ 0x2F6E1B35
	if source == "etage":
		var chance := float(d.objets["butin"]["chance_etage"]) if premier_passage else float(d.objets["butin"]["rejoue"]) + bonus_rejoue
		if rng.randf_range(0.0, 1.0) >= chance:
			return {}
	var poids: Dictionary = d.objets["butin"][source]
	var total := 0.0
	for r in poids:
		total += float(poids[r])
	var tirage := rng.randf_range(0.0, 1.0) * total
	var rarete := ""
	var raretes: Array = poids.keys()
	raretes.sort()
	for r in raretes:
		rarete = str(r)
		tirage -= float(poids[r])
		if tirage < 0.0:
			break
	var bases: Array = d.objets["bases"].keys()
	bases.sort()
	var base: String = bases[rng.randi_range(0, bases.size() - 1)]
	return tirer(base, rarete, niveau, rng.randi_range(0, 0x7FFFFFFF), d, not premier_passage)


# --- Les bonus ----------------------------------------------------------------------------

## Aucun bonus : chaque ligne à zéro.
static func mods_vides() -> Dictionary:
	var out := {}
	for s in STATS:
		out[s] = 0.0
	return out


## Les bonus d'un ensemble d'objets (ceux qu'on porte) : la somme de leurs lignes, en fraction, chacune sous son plafond.
static func mods(objets: Array, d: Donnees) -> Dictionary:
	var out := mods_vides()
	for o in objets:
		for l in o["lignes"]:
			out[str(l["stat"])] = float(out[str(l["stat"])]) + float(l["valeur"]) / 100.0
	for s in STATS:
		out[s] = minf(float(out[s]), float(d.objets["lignes"][s]["plafond"]) / 100.0)
	return out


## Vrai si un jeu de bonus n'apporte rien.
static func sans_bonus(p_mods: Dictionary) -> bool:
	for s in p_mods:
		if float(p_mods[s]) > 0.0:
			return false
	return true


## Le bonus d'un équipement sur une valeur d'un nœud, selon le type de l'effet (dégâts, soin, gardien, barrière, DoT)
## et le rang du nœud (0 ou 1 : Ouvertures ; 4 : Clés). Rien pour un type inconnu hors des Clés et des Ouvertures.
static func bonus(p_mods: Dictionary, rang: int, type: String) -> float:
	if p_mods.is_empty():
		return 0.0
	var b := 0.0
	if STAT_PAR_TYPE.has(type):
		b += float(p_mods.get(STAT_PAR_TYPE[type], 0.0))
	if rang == 4:
		b += float(p_mods.get("cle", 0.0))
	elif rang <= 1:
		b += float(p_mods.get("ouverture", 0.0))
	return b


# --- Équiper, reforger ----------------------------------------------------------------------

## L'objet une fois équipé : lié, pour toujours.
static func equiper(objet: Dictionary) -> Dictionary:
	var o := objet.duplicate(true)
	o["lie"] = true
	return o


## Le coût en Éclats de la prochaine reforge d'un objet : croissant avec le nombre de reforges déjà faites.
static func cout_reforge(objet: Dictionary, d: Donnees) -> int:
	var r: Dictionary = d.objets["reforge"]
	return roundi(float(r["cout"]) * (1.0 + float(r["pente"]) * float(int(objet.get("reforges", 0)))))


## La reforge d'une ligne : elle est retirée avec la graine (une autre ligne de la réserve de la base, que l'objet n'a
## pas déjà, ou la même si la réserve est épuisée ; un chiffre dans sa fourchette). Les autres lignes ne bougent pas ;
## l'objet reste lié ou échangeable comme il était. Un index hors de l'objet : l'objet tel quel.
static func reforger(objet: Dictionary, index: int, graine: int, d: Donnees) -> Dictionary:
	var o := objet.duplicate(true)
	if index < 0 or index >= o["lignes"].size():
		return o
	var rng := RandomNumberGenerator.new()
	rng.seed = graine
	var prises: Array = []
	for i in range(o["lignes"].size()):
		if i != index:
			prises.append(o["lignes"][i]["stat"])
	var reserve: Array = d.objets["bases"][o["base"]]["lignes"].filter(func(s): return not s in prises)
	var stat: String = reserve[rng.randi_range(0, reserve.size() - 1)]
	o["lignes"][index] = _ligne(stat, str(o["rarete"]), int(o["niveau"]), rng, d)
	o["reforges"] = int(o.get("reforges", 0)) + 1
	o["qualite"] = qualite(o, d)
	return o


# --- Les Éclats ------------------------------------------------------------------------------------

## Les Éclats rendus par le recyclage d'un objet : selon sa rareté (data/items.json).
static func recyclage(objet: Dictionary, d: Donnees) -> int:
	return int(d.objets["recyclage"][objet["rarete"]])


## Les Éclats d'un duel : gagné ou perdu.
static func eclats_duel(gagne: bool, d: Donnees) -> int:
	return int(d.objets["eclats"]["duel_gagne" if gagne else "duel_perdu"])


## Les Éclats d'un étage franchi de la Tour : base + pente × étage ; une part seulement si l'étage est rejoué.
static func eclats_etage(n: int, premier_passage: bool, d: Donnees) -> int:
	var e: Dictionary = d.objets["eclats"]
	var total := float(e["etage_base"]) + float(e["etage_pente"]) * float(maxi(1, n))
	return Regles.plancher(total * (1.0 if premier_passage else float(e["rejoue"])))


# --- L'aperçu sur la roue ------------------------------------------------------------------------

## Ce qu'un changement d'équipement fait aux valeurs de la roue d'un Destin : jusqu'à trois exemples, « Boule de feu :
## 48 → 54 », parmi les nœuds allumés dont un chiffre change (le moyeu d'abord, puis par voie et par rang ; chacun sur
## son premier effet à valeur, type compris). Vide si aucun chiffre de la roue ne change (des PV max, par exemple).
## Les valeurs sont celles d'un combat au niveau donné.
static func apercu(destin: Destin, avant: Dictionary, apres: Dictionary, niveau: int, d: Donnees) -> Array[String]:
	var sauve := destin.mods
	destin.mods = avant
	var e0 := Regles.nouveau_combat([destin], [destin], niveau, "pvp", d)
	destin.mods = apres
	var e1 := Regles.nouveau_combat([destin], [destin], niveau, "pvp", d)
	destin.mods = sauve
	var out: Array[String] = []
	var candidats: Array = [[-1, 0, destin.moyeu]]
	for v in range(destin.voies.size()):
		for r in range(4):
			var noeud: Dictionary = destin.voies[v]["noeuds"][r]
			if bool(noeud.get("allume", false)):
				candidats.append([v, r + 1, noeud])
	for c in candidats:
		var ef: Dictionary = _effet_a_valeur(c[2])
		if ef.is_empty():
			continue
		var base := float(ef.get("valeur", ef.get("par_tour", 0.0)))
		var x0 := Regles.plancher(Regles.valeur(e0, "a1", int(c[0]), int(c[1]), base, str(ef["type"])))
		var x1 := Regles.plancher(Regles.valeur(e1, "a1", int(c[0]), int(c[1]), base, str(ef["type"])))
		if x0 != x1:
			out.append("%s : %d → %d" % [Texte.nom(c[2], d), x0, x1])
		if out.size() >= 3:
			break
	return out


## Le premier effet à valeur d'un nœud (dégâts, soin, barrière, DoT, Gardien) ; vide s'il n'en a pas.
static func _effet_a_valeur(noeud: Dictionary) -> Dictionary:
	for ef in noeud.get("effets", []):
		if STAT_PAR_TYPE.has(str(ef["type"])):
			return ef
	return {}


# --- Textes et contrôle ------------------------------------------------------------------------

## Le palier d'un niveau d'objet (data/items.json, paliers) : le dernier dont le niveau minimal est atteint.
static func palier(niveau: int, d: Donnees) -> Dictionary:
	var out: Dictionary = {}
	for p in d.objets.get("paliers", []):
		if int(p["niveau_min"]) <= maxi(1, niveau):
			out = p
	return out


## « Épée d'acier épique », « Cotte de mailles de fer commune », « Bottes de fer communes » (une base au pluriel) : la base,
## le matériau de son palier, la rareté accordée.
static func nom(objet: Dictionary, d: Donnees) -> String:
	var base: Dictionary = d.objets["bases"][objet["base"]]
	var genre := "f" if str(base["genre"]) == "f" else "m"
	var p := palier(int(objet["niveau"]), d)
	var materiau := (" " + str(p["suffixe"])) if p.has("suffixe") else ""
	var rarete := str(d.objets["raretes"][objet["rarete"]]["nom"][genre])
	if bool(base.get("pluriel", false)):
		rarete += "s"
	return "%s%s %s" % [base["nom"], materiau, rarete]


## Un chiffre en % à la française : « 5,3 ».
static func chiffre(v: float) -> String:
	var t := "%.1f" % v
	if t.ends_with(".0"):
		t = t.substr(0, t.length() - 2)
	return t.replace(".", ",")


## « +5,3 % de dégâts directs ».
static func texte_ligne(ligne: Dictionary, d: Donnees) -> String:
	return str(d.objets["lignes"][ligne["stat"]]["texte"]).replace("{v}", chiffre(float(ligne["valeur"])))


## « [4,2 – 7,8] » : la fourchette d'une ligne, telle qu'elle est affichée.
static func texte_fourchette(stat: String, objet: Dictionary, d: Donnees) -> String:
	var f := fourchette(stat, str(objet["rarete"]), int(objet["niveau"]), d)
	return "[%s – %s]" % [chiffre(float(f[0])), chiffre(float(f[1]))]


## La fiche d'un objet, prête à afficher : nom, emplacement, rareté, niveau, lignes (texte et fourchette), qualité,
## lié ou échangeable, coût de la prochaine reforge.
static func fiche(objet: Dictionary, d: Donnees) -> Dictionary:
	var lignes: Array = []
	for l in objet["lignes"]:
		lignes.append({"stat": l["stat"], "nom": d.objets["lignes"][l["stat"]]["nom"], "texte": texte_ligne(l, d),
			"fourchette": texte_fourchette(str(l["stat"]), objet, d), "valeur": float(l["valeur"])})
	return {"nom": nom(objet, d), "emplacement": d.objets["emplacements"][emplacement(objet, d)]["nom"],
		"description": str(d.objets["bases"][objet["base"]].get("description", "")),
		"rarete": d.objets["raretes"][objet["rarete"]]["nom"]["m"], "rang": int(d.objets["raretes"][objet["rarete"]]["rang"]),
		"niveau": int(objet["niveau"]), "lignes": lignes, "qualite": int(objet["qualite"]), "lie": bool(objet["lie"]),
		"trait": str(objet.get("trait", "")), "texte_trait": texte_trait(str(objet.get("trait", "")), d),
		"reforge": cout_reforge(objet, d)}


## Un objet est-il conforme aux données : base et rareté connues, lignes de sa réserve, toutes différentes, chacune dans
## sa fourchette ?
static func valide(objet: Dictionary, d: Donnees) -> bool:
	for cle in ["base", "rarete", "niveau", "lignes", "qualite", "lie", "reforges"]:
		if not objet.has(cle):
			return false
	if not d.objets["bases"].has(objet["base"]) or not d.objets["raretes"].has(objet["rarete"]):
		return false
	if objet.has("trait") and (not a_trait(str(objet["rarete"]), d) or not d.objets["traits"].has(str(objet["trait"]))):
		return false
	var reserve: Array = d.objets["bases"][objet["base"]]["lignes"]
	var vues: Array = []
	for l in objet["lignes"]:
		if not l is Dictionary or not reserve.has(l.get("stat", "")) or vues.has(l["stat"]):
			return false
		vues.append(l["stat"])
		var f := fourchette(str(l["stat"]), str(objet["rarete"]), int(objet["niveau"]), d)
		if float(l["valeur"]) < float(f[0]) - 0.0001 or float(l["valeur"]) > float(f[1]) + 0.0001:
			return false
	return objet["lignes"].size() <= nb_lignes(str(objet["base"]), str(objet["rarete"]), d)
