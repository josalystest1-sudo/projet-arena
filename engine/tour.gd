## La Tour (docs/SPEC-COMBAT-V2.md, sections 5.6 et 10.4) : le duo grimpe des étages, chacun de 1 à 4 monstres du
## bestiaire au niveau du joueur. La force totale des monstres (la somme de leurs multiplicateurs de PV) monte avec les
## étages (décision de Gautier du 28 octobre : la Tour a sa propre difficulté, réglée par le simulateur). Même moteur, mêmes
## phases, pas de mort subite. Entre deux étages : +20 % des PV max à chaque membre vivant du duo, un acolyte KO revient
## avec 20 %, et tout le reste repart à zéro (jalons, extinctions, états). La montée s'arrête quand le duo tombe ;
## l'étage atteint est le record.
## Règles d'étage gardées de l'ancienne Tour (data/tour.json) : les monstres d'un étage sont d'une même famille, un
## Gardien tous les 5 étages (avec une escorte de sa famille), et des ennemis qui n'ont pas abattu le duo au bout de
## 24 tours abandonnent l'étage. Module pur : le hasard vient de la graine de la montée.
class_name Tour
extends RefCounted

var donnees: Donnees
var graine := 0
var niveau := 1
## L'étage en cours (1 = le premier), et l'étage atteint (le record : celui où le duo est tombé).
var etage := 1
var atteint := 1
var fini := false
var joueur: Destin
var acolyte: Destin
## Les PV du duo, gardés d'un étage à l'autre (« a1 » : le joueur, « a2 » : l'acolyte), et qui est KO.
var pv := {}
var ko := {"a1": false, "a2": false}


static func commencer(p_joueur: Destin, p_acolyte: Destin, p_niveau: int, p_graine: int, p_donnees: Donnees = null) -> Tour:
	var t := Tour.new()
	t.donnees = p_donnees if p_donnees != null else Donnees.defaut()
	t.joueur = p_joueur
	t.acolyte = p_acolyte
	t.niveau = maxi(1, p_niveau)
	t.graine = p_graine
	return t


## La graine d'un étage : celle de la montée, mêlée au numéro de l'étage.
func graine_etage(n: int) -> int:
	return graine ^ (n * 0x9E3779B1)


## La force totale des monstres d'un étage : la somme de leurs multiplicateurs de PV tombe entre `bas` et
## `bas + largeur`, où bas = (départ + pente × facteur de pente de la classe × (étage − 1)) × facteur de la classe
## (data/tour.json : réglés par le simulateur pour que chaque classe atteigne l'étage 10 une fois sur deux et l'étage 20
## dans 5 à 10 % des montées).
func fourchette(n: int) -> Vector2:
	var regles := donnees.tour
	var classe := joueur.classe_id if joueur != null else ""
	var facteur := float(regles["classes"].get(classe, 1.0))
	var pente := float(regles["somme_pente"]) * float(regles["classes_pente"].get(classe, 1.0))
	var bas := maxf(0.0, (float(regles["somme_depart"]) + pente * float(n - 1)) * facteur)
	return Vector2(bas, bas + float(regles["somme_largeur"]))


## Les monstres d'un étage (identifiants du bestiaire), tirés avec la graine de l'étage : une famille, puis des monstres
## de cette famille jusqu'à ce que la somme de leurs multiplicateurs de PV tombe dans la fourchette de l'étage (4 au
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


## Les monstres de l'étage en cours, avec leurs roues (niveau du joueur, formes tirées avec la graine de l'étage).
func monstres(n: int = -1) -> Array[Destin]:
	var quel := etage if n < 0 else n
	var out: Array[Destin] = []
	var ids := tirer_etage(quel)
	for i in range(ids.size()):
		out.append(Generateur.monstre(ids[i], graine_etage(quel) + i, niveau, donnees))
	return out


## Le combat de l'étage en cours : le duo (avec ses PV et ses KO gardés) contre les monstres de l'étage.
func combat() -> EtatCombat:
	var e := Regles.nouveau_combat([joueur, acolyte], monstres(), niveau, "tour", donnees)
	for id in ["a1", "a2"]:
		if pv.has(id):
			e.perso(id)["pv"] = pv[id]
		if ko[id]:
			e.perso(id)["ko"] = true
			e.perso(id)["pv"] = 0
	return e


## Les ennemis abandonnent : le combat n'est pas fini après le tour limite (24) ; l'étage est franchi.
func abandonne(e: EtatCombat) -> bool:
	return not e.fini and e.tour > int(donnees.tour["abandon_tour"])


## La fin d'un étage : le duo a gagné (ou les ennemis ont abandonné) et monte, avec ses PV rendus ; ou il est tombé.
func terminer(e: EtatCombat) -> void:
	var gagne := e.vainqueur == "a" or abandonne(e)
	if not gagne:
		fini = true
		atteint = etage
		return
	var rendu := float(donnees.tour["pv_entre_etages"])
	for id in ["a1", "a2"]:
		var pv_max := int(e.fiche(id)["pv_max"])
		if e.vivant(id):
			pv[id] = mini(int(e.perso(id)["pv"]) + Regles.plancher(rendu * float(pv_max)), pv_max)
			ko[id] = false
		elif id == "a2":
			# Un acolyte KO revient au début de l'étage suivant avec 20 % de ses PV ; le joueur KO, lui, reste KO.
			pv[id] = Regles.plancher(rendu * float(pv_max))
			ko[id] = false
		else:
			pv[id] = 0
			ko[id] = true
	etage += 1
	atteint = etage
