## Les donjons à routes (docs/GDD_V2.md, § 8 ; docs/PLAN.md, PR 6.3), joués en solo avec ses deux Échos en attendant
## le serveur (le GDD les veut à trois humains, avec un boss unique au serveur et des cartes de guilde). Un donjon est un
## arbre de routes : à chaque embranchement, trois portes ; au bout d'une route, un élite, sauf sur une seule route, la
## route du boss. Chaque porte mène à une vague de monstres de la famille du donjon, qui ne dépend que de la profondeur.
## Les portes sans nom (§ 8.2) : les trois portes sont identiques et leur ordre est propre à chaque joueur (une
## permutation calculée avec sa graine et l'embranchement) ; le jeu connaît la vraie identité de chaque porte et traduit
## pour chacun. La route du boss est tirée avec la chasse (le numéro du boss en cours) : quand il meurt, nouvelle chasse,
## nouvelles routes, carte remise à zéro. La carte personnelle : les routes qu'on a parcourues (chemins vrais) ; un
## fragment (sur un élite) révèle la porte du boss au premier embranchement où elle n'est pas connue.
## Une descente : les portes, une vague, les portes, une vague, les portes, une vague, puis l'élite ou le boss ; les PV sont gardés entre les
## vagues (+20 %, un Écho KO revient à 20 %) ; tomber laisse la carte, pas la récompense.
## Module pur : le hasard vient des graines fournies (joueur, chasse) et du chemin.
class_name Donjon
extends RefCounted

var donnees: Donnees
var id := ""
var regles: Dictionary = {}
var def: Dictionary = {}
## La chasse en cours (le numéro du boss), la graine du joueur (son ordre des portes) et le niveau du trio.
var chasse := 0
var graine_joueur := 0
var niveau := 1
var membres: Array[Destin] = []
## Le chemin vrai choisi jusqu'ici (indices vrais des portes, dans l'ordre), et la phase : « portes » (choisir),
## « combat » (une vague, l'élite ou le boss à jouer), « fini ».
var chemin: Array[int] = []
var phase := "portes"
## Le résultat une fois fini : « elite », « boss » (vaincu) ou « tombe ».
var resultat := ""
## Vrai quand les vagues sont passées et qu'il reste le combat final (l'élite ou le boss).
var finale := false
var pv := {}
var ko := {}


# --- L'arbre et les portes --------------------------------------------------------------

## Un chemin en texte (« 0.2.1 »), pour la carte.
static func texte_chemin(c: Array) -> String:
	var parts: Array[String] = []
	for i in c:
		parts.append(str(i))
	return ".".join(parts)


## La route du boss d'un donjon pour une chasse : une porte vraie par profondeur, tirée avec le donjon et la chasse.
static func route_boss(donjon_id: String, p_chasse: int, d: Donnees) -> Array[int]:
	var rng := RandomNumberGenerator.new()
	rng.seed = (donjon_id.hash() ^ (p_chasse * 0x9E3779B1)) ^ 0x0B055D00
	var out: Array[int] = []
	for k in range(int(d.donjons["profondeur"])):
		out.append(rng.randi_range(0, int(d.donjons["portes"]) - 1))
	return out


## L'ordre des portes d'un joueur à un embranchement (le chemin vrai parcouru jusque-là) : position affichée -> porte
## vraie. Une permutation propre au joueur et à l'embranchement ; les mêmes entrées donnent toujours le même ordre.
static func ordre_portes(p_graine_joueur: int, donjon_id: String, prefixe: Array, d: Donnees) -> Array[int]:
	var rng := RandomNumberGenerator.new()
	rng.seed = p_graine_joueur ^ ("%s|%s" % [donjon_id, texte_chemin(prefixe)]).hash()
	var vraies: Array[int] = []
	for i in range(int(d.donjons["portes"])):
		vraies.append(i)
	var out: Array[int] = []
	while not vraies.is_empty():
		out.append(vraies.pop_at(rng.randi_range(0, vraies.size() - 1)))
	return out


# --- Une descente --------------------------------------------------------------------------

static func commencer(donjon_id: String, p_membres: Array, p_niveau: int, p_graine_joueur: int, p_chasse: int, p_donnees: Donnees = null) -> Donjon:
	var dj := Donjon.new()
	dj.donnees = p_donnees if p_donnees != null else Donnees.defaut()
	dj.regles = dj.donnees.donjons
	dj.id = donjon_id
	dj.def = definition(donjon_id, dj.donnees)
	dj.chasse = p_chasse
	dj.graine_joueur = p_graine_joueur
	dj.niveau = maxi(1, p_niveau)
	for m in p_membres:
		dj.membres.append(m)
	for i in range(dj.membres.size()):
		dj.ko["a%d" % (i + 1)] = false
	return dj


## La définition d'un donjon par son identifiant (vide s'il n'existe pas).
static func definition(donjon_id: String, d: Donnees) -> Dictionary:
	for dj in d.donjons["donjons"]:
		if str(dj["id"]) == donjon_id:
			return dj
	return {}


## La profondeur en cours (0 : avant la première porte).
func profondeur() -> int:
	return chemin.size()


## La descente est-elle au bout de ses portes (il reste l'élite ou le boss) ?
func au_bout() -> bool:
	return chemin.size() >= int(regles["profondeur"])


## Le chemin suivi est-il la route du boss ?
func sur_la_route_du_boss() -> bool:
	return chemin == route_boss(id, chasse, donnees)


## Les trois portes de l'embranchement en cours, dans l'ordre du joueur, avec ce que sa carte en sait : « exploree »
## (il est déjà passé par là), « revelee » (un fragment l'a montrée : c'est la porte du boss), « inconnue ».
## carte : {explorees: [chemins], revelees: [chemins]} (les chemins vrais, en texte).
func portes(carte: Dictionary) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var ordre := ordre_portes(graine_joueur, id, chemin, donnees)
	for position in range(ordre.size()):
		var vraie := ordre[position]
		var suite := chemin.duplicate()
		suite.append(vraie)
		var cle := texte_chemin(suite)
		var etat := "inconnue"
		if carte.get("revelees", []).has(cle):
			etat = "revelee"
		elif carte.get("explorees", []).has(cle):
			etat = "exploree"
		out.append({"position": position, "vraie": vraie, "chemin": cle, "etat": etat})
	return out


## Choisir une porte (sa position dans l'ordre du joueur) : la descente passe au combat de la vague.
func choisir(position: int) -> bool:
	if phase != "portes" or au_bout():
		return false
	var ordre := ordre_portes(graine_joueur, id, chemin, donnees)
	if position < 0 or position >= ordre.size():
		return false
	chemin.append(ordre[position])
	phase = "combat"
	return true


## Le chemin suivi, en texte (pour la carte).
func chemin_texte() -> String:
	return texte_chemin(chemin)


# --- Les vagues ------------------------------------------------------------------------------

## La graine de la vague d'une profondeur : celle du donjon et de la chasse, mêlée à la profondeur (pas à la porte :
## les trois portes mènent à la même vague).
func graine_vague(k: int) -> int:
	return (id.hash() ^ (chasse * 0x9E3779B1)) ^ (k * 0x85EBCA6B)


## Les monstres d'une vague de profondeur k (1 à profondeur) : k + 1 monstres de la famille (sbires et soldats), tirés
## avec la graine de la vague.
func monstres_vague(k: int) -> Array[String]:
	var tous: Dictionary = donnees.bestiaire["monstres"]
	var permis: Array = []
	for mid in tous:
		if str(tous[mid]["famille"]) == str(def["famille"]) and str(tous[mid]["rang"]) in ["sbire", "soldat"]:
			permis.append(mid)
	permis.sort()
	var rng := RandomNumberGenerator.new()
	rng.seed = graine_vague(k)
	var out: Array[String] = []
	for i in range(mini(k + 1, 6)):
		out.append(str(permis[rng.randi_range(0, permis.size() - 1)]))
	return out


## L'élite du donjon (le monstre de rang élite de la famille) ou son boss (data : un Gardien du bestiaire, plus fort).
func monstre_final() -> String:
	if sur_la_route_du_boss():
		return str(def["boss"])
	var tous: Dictionary = donnees.bestiaire["monstres"]
	var elites: Array = []
	for mid in tous:
		if str(tous[mid]["famille"]) == str(def["famille"]) and str(tous[mid]["rang"]) == "elite":
			elites.append(mid)
	elites.sort()
	return str(elites[0]) if not elites.is_empty() else str(def["boss"])


## Les monstres du combat en cours, avec leurs roues : au niveau du donjon, ramenés au niveau du trio (comme la Tour).
func monstres() -> Array[Destin]:
	var ids: Array[String] = []
	var mult := 1.0
	var k := profondeur()
	if finale:
		ids.append(monstre_final())
		mult = float(regles["boss_mult"]) if sur_la_route_du_boss() else float(regles["elite_mult"])
	else:
		ids = monstres_vague(k)
	var nv := int(def["niveau"])
	var pente := float(donnees.regles["niveau_pente"])
	var ratio := (1.0 + pente * float(nv - 1)) / (1.0 + pente * float(niveau - 1))
	var out: Array[Destin] = []
	for i in range(ids.size()):
		var m := Generateur.monstre(ids[i], graine_vague(k) + i, nv, donnees)
		m.k *= ratio * mult
		m.pv_mult *= ratio * mult
		out.append(m)
	return out


## Le combat en cours (une vague, l'élite ou le boss) : le trio avec ses PV gardés, contre les monstres.
func combat() -> EtatCombat:
	var e := Regles.nouveau_combat(membres, monstres(), niveau, "tour", donnees)
	for pid in ko:
		if pv.has(pid):
			e.perso(pid)["pv"] = mini(int(pv[pid]), int(e.fiche(pid)["pv_max"]))
		if ko[pid]:
			e.perso(pid)["ko"] = true
			e.perso(pid)["pv"] = 0
	return e


## La fin d'un combat : tombé (la descente s'arrête), ou gagné : les PV rendus, et la suite (les portes, ou fini après
## l'élite ou le boss).
func terminer(e: EtatCombat) -> void:
	if e.vainqueur != "a":
		phase = "fini"
		resultat = "tombe"
		return
	var rendu := float(regles["pv_entre_vagues"])
	for pid in ko:
		var pv_max := int(e.fiche(pid)["pv_max"])
		if e.vivant(pid):
			pv[pid] = mini(int(e.perso(pid)["pv"]) + Regles.plancher(rendu * float(pv_max)), pv_max)
			ko[pid] = false
		elif pid != "a1":
			pv[pid] = Regles.plancher(rendu * float(pv_max))
			ko[pid] = false
		else:
			pv[pid] = 0
			ko[pid] = true
	if finale:
		phase = "fini"
		resultat = "boss" if sur_la_route_du_boss() else "elite"
	elif au_bout():
		# Les vagues sont passées : le combat final vient sans porte à choisir.
		finale = true
		phase = "combat"
	else:
		phase = "portes"


## Abandonner entre deux vagues : la carte est gardée, pas la récompense.
func abandonner() -> void:
	phase = "fini"
	resultat = "tombe"


# --- La carte et les récompenses ------------------------------------------------------------

## Les chemins explorés par cette descente (chaque préfixe du chemin), à ajouter à la carte.
func chemins_explores() -> Array[String]:
	var out: Array[String] = []
	for k in range(1, chemin.size() + 1):
		out.append(texte_chemin(chemin.slice(0, k)))
	return out


## Un fragment de carte : le chemin de la porte du boss au premier embranchement où la carte ne la connaît pas encore
## ("" si tout est connu).
static func reveler(donjon_id: String, p_chasse: int, carte: Dictionary, d: Donnees) -> String:
	var route := route_boss(donjon_id, p_chasse, d)
	for k in range(1, route.size() + 1):
		var cle := texte_chemin(route.slice(0, k))
		if not carte.get("revelees", []).has(cle):
			return cle
	return ""


## La récompense d'une descente finie : {rarete, lie, fragments, eclats} (vide si tombé).
func recompense() -> Dictionary:
	if resultat != "elite" and resultat != "boss":
		return {}
	var r: Dictionary = regles["recompenses"][resultat]
	return {"rarete": str(r["rarete"]), "lie": resultat != "boss", "fragments": int(r["fragments"]), "eclats": int(r["eclats"])}


## L'objet de la récompense, tiré avec la chasse, le chemin et la graine du joueur.
func butin(graine: int) -> Dictionary:
	var r := recompense()
	if r.is_empty():
		return {}
	var bases: Array = donnees.objets["bases"].keys()
	bases.sort()
	var rng := RandomNumberGenerator.new()
	rng.seed = graine ^ graine_vague(99)
	return Equipement.tirer(bases[rng.randi_range(0, bases.size() - 1)], str(r["rarete"]), int(def["niveau"]), rng.randi_range(0, 0x7FFFFFFF), donnees, bool(r["lie"]))
