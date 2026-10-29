## La Tour infinie (docs/GDD_V2.md, § 6 ; docs/PLAN.md, PR 2.1 ; docs/SPEC-COMBAT-V2.md, sections 5.6 et 10.4) : le
## trio (ou un duo) grimpe des étages générés sans fin, chacun de 1 à 6 monstres du bestiaire. La Tour est absolue, le
## joueur est relatif : un étage a toujours la même force, quel que soit le niveau du trio. Ses monstres ont le niveau
## de l'étage (data/tour.json : niveau_par_etage) et la somme de leurs multiplicateurs de PV grandit doucement avec les
## étages, jusqu'à un plafond. Même moteur, mêmes phases, pas de mort subite, pas de limite de tours : les soins des
## monstres s'affaiblissent à chaque usage (Regles, mode « tour »). Entre deux étages : +20 % des PV max à chaque
## membre vivant, un acolyte ou un Écho KO revient avec 20 %, et tout le reste repart à zéro (jalons, extinctions,
## états). La montée s'arrête quand tout le camp tombe ; l'étage atteint est le record.
## Les paliers : un Gardien tous les 5 étages ; une fois le Gardien d'un étage franchi, les montées suivantes peuvent
## reprendre à l'étage d'après, avec tous leurs PV (palier_apres). Les étages d'un même numéro sont les mêmes pour tous :
## leurs monstres sont tirés avec la graine de la montée, mais leur force ne dépend que du numéro.
## Module pur : le hasard vient de la graine de la montée.
class_name Tour
extends RefCounted

var donnees: Donnees
var graine := 0
var niveau := 1
## L'étage de départ de la montée (1, ou un palier), l'étage en cours, et l'étage atteint (le record : celui où le camp
## est tombé).
var depart := 1
var etage := 1
var atteint := 1
var fini := false
## Le camp qui monte : le joueur d'abord, puis son acolyte (ou ses deux Échos).
var membres: Array[Destin] = []
var joueur: Destin
var acolyte: Destin
## Les PV du camp, gardés d'un étage à l'autre (« a1 » : le joueur, « a2 » : l'acolyte ou le premier Écho, « a3 » : le
## second Écho), et qui est KO.
var pv := {}
var ko := {}


static func commencer(p_joueur: Destin, p_acolyte: Destin, p_niveau: int, p_graine: int, p_donnees: Donnees = null) -> Tour:
	return commencer_camp([p_joueur, p_acolyte], p_niveau, p_graine, p_donnees)


## Une montée avec un camp quelconque : [joueur, acolyte] ou [joueur, Écho, Écho] (engine/trio.gd), à partir de
## l'étage p_depart (1, ou un palier), tous ses PV.
static func commencer_camp(p_membres: Array, p_niveau: int, p_graine: int, p_donnees: Donnees = null, p_depart: int = 1) -> Tour:
	var t := Tour.new()
	t.donnees = p_donnees if p_donnees != null else Donnees.defaut()
	for m in p_membres:
		t.membres.append(m)
	t.joueur = t.membres[0]
	t.acolyte = t.membres[1] if t.membres.size() == 2 else null
	for i in range(t.membres.size()):
		t.ko["a%d" % (i + 1)] = false
	t.niveau = maxi(1, p_niveau)
	t.graine = p_graine
	t.depart = maxi(1, p_depart)
	t.etage = t.depart
	t.atteint = t.depart
	return t


## Le palier où reprendre quand on a franchi l'étage n : l'étage qui suit le dernier Gardien franchi (1 avant le premier).
static func palier_apres(franchi: int, gardien_tous_les: int) -> int:
	return 1 + gardien_tous_les * (maxi(0, franchi) / gardien_tous_les)


## Les paliers d'où partir quand on a franchi l'étage n : 1, puis l'étage qui suit chaque Gardien franchi.
static func paliers(franchi: int, gardien_tous_les: int) -> Array[int]:
	var out: Array[int] = []
	var p := 1
	while p <= palier_apres(franchi, gardien_tous_les):
		out.append(p)
		p += gardien_tous_les
	return out


## La graine d'un étage : celle de la montée, mêlée au numéro de l'étage.
func graine_etage(n: int) -> int:
	return graine ^ (n * 0x9E3779B1)


## Le niveau des monstres d'un étage : 1 au premier, puis niveau_par_etage de plus à chaque étage.
func niveau_etage(n: int) -> int:
	return maxi(1, floori(1.0 + float(donnees.tour["niveau_par_etage"]) * float(n - 1) + 0.000001))


## La force totale des monstres d'un étage : la somme de leurs multiplicateurs de PV tombe entre `bas` et
## `bas + largeur`, où bas = départ + pente × (étage − 1), plafonné (data/tour.json). La même pour tous les trios.
func fourchette(n: int) -> Vector2:
	var regles := donnees.tour
	var bas := clampf(float(regles["somme_depart"]) + float(regles["somme_pente"]) * float(n - 1), 0.0, float(regles["somme_max"]))
	return Vector2(bas, bas + float(regles["somme_largeur"]))


## Les monstres d'un étage (identifiants du bestiaire), tirés avec la graine de l'étage : une famille, puis des monstres
## de cette famille jusqu'à ce que la somme de leurs multiplicateurs de PV tombe dans la fourchette de l'étage (6 au
## plus) ; un Gardien d'abord tous les 5 étages, s'il y tient. Après 60 essais, toutes les familles sont permises ;
## après 120, le groupe le plus proche de la fourchette.
func tirer_etage(n: int) -> Array[String]:
	var regles := donnees.tour
	var monstres: Dictionary = donnees.bestiaire["monstres"]
	var rng := RandomNumberGenerator.new()
	rng.seed = graine_etage(n)
	var familles: Array = donnees.bestiaire["familles"].keys()
	var gardien_etage := int(regles["gardien_tous_les"]) > 0 and n % int(regles["gardien_tous_les"]) == 0
	var famille: String = familles[rng.randi_range(0, familles.size() - 1)]
	var gardien := ""
	if gardien_etage:
		var gardiens: Array = []
		for id in monstres:
			if monstres[id]["rang"] == "gardien":
				gardiens.append(id)
		gardien = gardiens[rng.randi_range(0, gardiens.size() - 1)]
		famille = str(monstres[gardien]["famille"])
	var f := fourchette(n)
	var mini := f.x
	var maxi_ := f.y
	if gardien != "" and float(monstres[gardien]["pv_mult"]) > maxi_ + 0.0001:
		gardien = ""
	var plus_proche: Array[String] = []
	var ecart_proche := INF
	for essai in range(int(regles["tirages"]) * 2):
		var toutes_familles := essai >= int(regles["tirages"])
		var permis: Array = []
		for id in monstres:
			if monstres[id]["rang"] != "gardien" and (toutes_familles or monstres[id]["famille"] == famille):
				permis.append(id)
		var liste: Array[String] = []
		var somme := 0.0
		if gardien != "":
			liste.append(gardien)
			somme = float(monstres[gardien]["pv_mult"])
		while (somme < mini or liste.is_empty()) and liste.size() < int(regles["monstres_max"]):
			var id: String = permis[rng.randi_range(0, permis.size() - 1)]
			liste.append(id)
			somme += float(monstres[id]["pv_mult"])
		if somme >= mini - 0.0001 and somme <= maxi_ + 0.0001:
			return liste
		var ecart := maxf(mini - somme, somme - maxi_)
		if ecart < ecart_proche:
			ecart_proche = ecart
			plus_proche = liste
	return plus_proche


## Les monstres d'un étage, avec leurs roues : formes tirées avec la graine de l'étage, allumées au niveau de l'étage.
## Le combat se joue au niveau du trio : la force des monstres est ramenée à celle du niveau de l'étage (leur
## multiplicateur de classe et de PV × M(niveau de l'étage) ÷ M(niveau du trio)).
func monstres(n: int = -1) -> Array[Destin]:
	var quel := etage if n < 0 else n
	var out: Array[Destin] = []
	var ids := tirer_etage(quel)
	var nv := niveau_etage(quel)
	var pente := float(donnees.regles["niveau_pente"])
	var ratio := (1.0 + pente * float(nv - 1)) / (1.0 + pente * float(niveau - 1))
	for i in range(ids.size()):
		var m := Generateur.monstre(ids[i], graine_etage(quel) + i, nv, donnees)
		m.k *= ratio
		m.pv_mult *= ratio
		out.append(m)
	return out


## Le combat de l'étage en cours : le camp (avec ses PV et ses KO gardés) contre les monstres de l'étage.
func combat() -> EtatCombat:
	var e := Regles.nouveau_combat(membres, monstres(), niveau, "tour", donnees)
	for id in ko:
		if pv.has(id):
			e.perso(id)["pv"] = pv[id]
		if ko[id]:
			e.perso(id)["ko"] = true
			e.perso(id)["pv"] = 0
	return e


## La fin d'un étage : le camp a gagné et monte, avec ses PV rendus ; ou il est tombé.
func terminer(e: EtatCombat) -> void:
	if e.vainqueur != "a":
		fini = true
		atteint = etage
		return
	var rendu := float(donnees.tour["pv_entre_etages"])
	for id in ko:
		var pv_max := int(e.fiche(id)["pv_max"])
		if e.vivant(id):
			pv[id] = mini(int(e.perso(id)["pv"]) + Regles.plancher(rendu * float(pv_max)), pv_max)
			ko[id] = false
		elif id != "a1":
			# Un acolyte (ou un Écho) KO revient au début de l'étage suivant avec 20 % de ses PV ; le joueur KO, lui,
			# reste KO.
			pv[id] = Regles.plancher(rendu * float(pv_max))
			ko[id] = false
		else:
			pv[id] = 0
			ko[id] = true
	etage += 1
	atteint = etage


## Arrêter la montée entre deux étages : l'étage atteint est celui qui allait se jouer.
func arreter() -> void:
	fini = true
	atteint = etage
