## La Tour infinie (docs/GDD_V2.md, § 6 ; docs/PLAN.md, PR 2.1 ; docs/SPEC-COMBAT-V2.md, sections 5.6 et 10.4) : le
## trio (ou un duo) grimpe des étages générés sans fin, chacun de 1 à 6 monstres du bestiaire. La Tour est absolue, le
## joueur est relatif : un étage a toujours la même force, quel que soit le niveau du trio. Ses monstres ont le niveau
## de l'étage (data/tour.json : niveau_par_etage) et la somme de leurs multiplicateurs de PV grandit doucement avec les
## étages, jusqu'à un plafond. Même moteur, mêmes phases, pas de mort subite, pas de limite de tours : les soins des
## monstres s'affaiblissent à chaque usage (Regles, mode « tour »). Entre deux étages : +20 % des PV max à chaque
## membre vivant, un acolyte ou un Écho KO revient avec 20 %, et tout le reste repart à zéro (jalons, extinctions,
## états). La montée s'arrête quand tout le camp tombe ; l'étage atteint est le record.
## Les murs (décision de Gautier du 31 octobre) : on passe plusieurs étages par niveau, mais des étages bloquent. Un
## Gardien tous les 5 étages, un grand Gardien tous les 10 (data/tour.json : gardien_tous_les, grand_gardien_tous_les).
## Hors Gardiens, chaque étage est plus dur que le précédent (le niveau des monstres monte de niveau_par_etage à chaque
## étage, depuis niveau_depart ; au-delà de etage_coude, de niveau_par_etage_haut : la pente des étages où arrivent les
## évolués, bien plus forts, pour que la Tour garde le même rythme en niveaux après l'évolution). Un Gardien est un mur de puissance : il a la force d'un étage plus loin (avance_gardien :
## 7 étages, avance_grand_gardien : 14 ; etage_force), de sorte que les cinq étages qui le suivent, Gardien moindre
## compris, soient moins forts que lui, et que ce soit le Gardien suivant qui demande des niveaux en plus (ou de
## l'équipement). La courbe « niveau → étage » se règle avec tools/regleur_tour.py.
## Les paliers : une fois le Gardien d'un étage franchi (l'un ou l'autre), les montées suivantes peuvent reprendre à
## l'étage d'après, avec tous leurs PV (palier_apres). Les étages d'un même numéro sont les mêmes pour tous : leurs
## monstres sont tirés avec la graine de la montée, mais leur force ne dépend que du numéro.
## Les Faveurs (GDD V2, § 6 ; data/faveurs.json) : chaque Gardien vaincu pour la première fois offre une Faveur à
## choisir parmi trois (proposer_faveurs). Elles se cumulent (identifiant -> nombre), ne valent que dans la Tour, et
## s'appliquent au début de chaque étage (Vigueur, Puissance, Égide, Effroi) ou entre deux étages (Répit) ; le Savoir
## (XP) est appliqué par l'application. Jamais pendant un combat : l'état statique est partagé entre ses copies.
## Module pur : le hasard vient de la graine de la montée.
class_name Tour
extends RefCounted

var donnees: Donnees
var graine := 0
var niveau := 1
## Les Faveurs acquises par le joueur avec cette classe (identifiant -> nombre de cumuls).
var faveurs: Dictionary = {}
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
## l'étage p_depart (1, ou un palier), tous ses PV, avec les Faveurs déjà acquises (identifiant -> nombre).
static func commencer_camp(p_membres: Array, p_niveau: int, p_graine: int, p_donnees: Donnees = null, p_depart: int = 1, p_faveurs: Dictionary = {}) -> Tour:
	var t := Tour.new()
	t.donnees = p_donnees if p_donnees != null else Donnees.defaut()
	for id in p_faveurs:
		if int(p_faveurs[id]) > 0:
			t.faveurs[str(id)] = int(p_faveurs[id])
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


## La sorte de Gardien d'un étage : « grand » tous les grand_gardien_tous_les étages (10), « gardien » tous les
## gardien_tous_les (5) sinon, « » pour un étage ordinaire.
static func sorte_gardien(n: int, regles: Dictionary) -> String:
	var g := int(regles.get("gardien_tous_les", 0))
	var gg := int(regles.get("grand_gardien_tous_les", 0))
	if gg > 0 and n % gg == 0:
		return "grand"
	if g > 0 and n % g == 0:
		return "gardien"
	return ""


## La sorte de Gardien de l'étage n de cette Tour (voir sorte_gardien).
func gardien_de(n: int) -> String:
	return sorte_gardien(n, donnees.tour)


## L'étage dont l'étage n a la force (les murs) : lui-même pour un étage ordinaire ; un Gardien a la force d'un étage
## plus loin (avance_gardien), un grand Gardien plus loin encore (avance_grand_gardien).
func etage_force(n: int) -> int:
	match gardien_de(n):
		"grand":
			return n + int(donnees.tour["avance_grand_gardien"])
		"gardien":
			return n + int(donnees.tour["avance_gardien"])
	return n


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


## L'étage franchi est-il celui d'un Gardien qu'on bat pour la première fois (avec cette classe) ? C'est le cas quand
## il porte un Gardien et que le palier d'avant ne le dépasse pas encore : il offre alors une Faveur.
static func gardien_premiere_fois(franchi: int, palier_actuel: int, gardien_tous_les: int) -> bool:
	return gardien_tous_les > 0 and franchi % gardien_tous_les == 0 and franchi + 1 > palier_actuel


# --- Les Faveurs ---------------------------------------------------------------

## Le nombre de cumuls d'une Faveur dans cette montée.
func faveur(id: String) -> int:
	return int(faveurs.get(id, 0))


## La valeur cumulée d'une Faveur (sa valeur × son nombre, sous son plafond s'il y en a un), en fraction.
static func valeur_faveur(id: String, n: int, p_donnees: Donnees) -> float:
	if n <= 0 or not p_donnees.faveurs.has(id):
		return 0.0
	var f: Dictionary = p_donnees.faveurs[id]
	var v := float(f["valeur"]) * float(n)
	if f.has("max"):
		v = minf(v, float(f["max"]))
	return v


## Le texte d'une Faveur cumulée n fois : « Vigueur ×2 : +8 % de PV max pour tout le trio ».
static func texte_faveur(id: String, n: int, p_donnees: Donnees) -> String:
	if not p_donnees.faveurs.has(id):
		return id
	var f: Dictionary = p_donnees.faveurs[id]
	var pc := roundi(valeur_faveur(id, maxi(1, n), p_donnees) * 100.0)
	var nom := str(f["nom"]) + (" ×%d" % n if n > 1 else "")
	return "%s : %s" % [nom, str(f["texte"]).replace("{v}", str(pc))]


## Les trois Faveurs proposées quand le Gardien de l'étage n est vaincu pour la première fois : tirées avec la graine
## de l'étage, trois différentes (les six, si moins de trois existent).
func proposer_faveurs(n: int) -> Array[String]:
	var ids: Array[String] = []
	for id in donnees.faveurs:
		ids.append(str(id))
	ids.sort()
	var rng := RandomNumberGenerator.new()
	rng.seed = graine_etage(n) ^ 0x5F4A7C15
	var out: Array[String] = []
	while out.size() < 3 and not ids.is_empty():
		out.append(ids.pop_at(rng.randi_range(0, ids.size() - 1)))
	return out


## Les Faveurs au début d'un étage, sur un combat qui vient d'être créé (avant que ses PV gardés soient posés) :
## Vigueur (PV max du camp), Puissance (le multiplicateur de classe, qui multiplie toutes les valeurs), Effroi (les
## monstres Affaiblis pendant 2 tours). L'Égide vient après les PV gardés (_egide), sur les membres debout.
func _faveurs_au_depart(e: EtatCombat) -> void:
	var vigueur := valeur_faveur("vigueur", faveur("vigueur"), donnees)
	var puissance := valeur_faveur("puissance", faveur("puissance"), donnees)
	var effroi := valeur_faveur("effroi", faveur("effroi"), donnees)
	for id in e.ordre:
		if e.camp(id) == "a":
			if vigueur > 0.0:
				var pv_max := Regles.plancher(float(e.fiche(id)["pv_max"]) * (1.0 + vigueur))
				e.statique[id]["pv_max"] = pv_max
				e.perso(id)["pv"] = pv_max
			if puissance > 0.0:
				e.statique[id]["k"] = float(e.fiche(id)["k"]) * (1.0 + puissance)
		elif effroi > 0.0:
			e.perso(id)["etats"]["affaiblissement"] = {"debut": 1, "fin": 2, "valeur": effroi, "source": ""}


## L'Égide : au début de l'étage, une barrière (8 % des PV max par cumul) sur chaque membre debout, pour 3 tours
## (comme une barrière posée au tour 1).
func _egide(e: EtatCombat) -> void:
	var egide := valeur_faveur("egide", faveur("egide"), donnees)
	if egide <= 0.0:
		return
	for id in e.ordre:
		if e.camp(id) == "a" and e.vivant(id):
			e.perso(id)["barriere"] = Regles.plancher(float(e.fiche(id)["pv_max"]) * egide)
			e.perso(id)["barrier_until"] = e.tour + 2


## Le butin d'un étage franchi (GDD V2, § 10.1) : un objet du niveau de l'étage, tiré avec la graine de l'étage ;
## épique à un Gardien, commun ou rare ailleurs ; échangeable seulement au premier passage, lié sinon ; un étage
## rejoué n'en lâche qu'une fois sur deux (vide alors). Voir Equipement.butin.
func butin(franchi: int, premier_passage: bool) -> Dictionary:
	var source := "gardien" if gardien_de(franchi) != "" else "etage"
	return Equipement.butin(source, niveau_etage(franchi), premier_passage, graine_etage(franchi), donnees)


## Le revenu passif d'un jour (GDD V2, § 6 : « selon la hauteur, plafonné, jamais d'objets ») : des Éclats et de l'XP
## proportionnels au meilleur record, chacun sous son plafond (data/tour.json, revenu). Rien sans record.
static func revenu(record: int, p_donnees: Donnees) -> Dictionary:
	if record <= 0:
		return {"eclats": 0, "xp": 0}
	var r: Dictionary = p_donnees.tour["revenu"]
	return {"eclats": mini(int(r["eclats_max"]), int(r["eclats_par_etage"]) * record),
		"xp": mini(int(r["xp_max"]), int(r["xp_par_etage"]) * record)}


## La graine d'un étage : celle de la montée, mêlée au numéro de l'étage.
func graine_etage(n: int) -> int:
	return graine ^ (n * 0x9E3779B1)


## Le niveau des monstres d'un étage : niveau_depart au premier, puis niveau_par_etage de plus à chaque étage jusqu'à
## etage_coude, puis niveau_par_etage_haut ; un Gardien a le niveau de l'étage dont il a la force (etage_force).
func niveau_etage(n: int) -> int:
	var regles := donnees.tour
	var f := etage_force(n)
	var coude := int(regles["etage_coude"])
	var nv := float(regles["niveau_depart"]) + float(regles["niveau_par_etage"]) * float(mini(f, coude) - 1)
	nv += float(regles["niveau_par_etage_haut"]) * float(maxi(0, f - coude))
	return maxi(1, floori(nv + 0.000001))


## La force totale des monstres d'un étage : la somme de leurs multiplicateurs de PV tombe entre `bas` et
## `bas + largeur`, où bas = départ + pente × (étage − 1), plafonné (data/tour.json) ; un Gardien compte comme l'étage
## dont il a la force (etage_force). La même pour tous les trios.
func fourchette(n: int) -> Vector2:
	var regles := donnees.tour
	var bas := clampf(float(regles["somme_depart"]) + float(regles["somme_pente"]) * float(etage_force(n) - 1), 0.0, float(regles["somme_max"]))
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
	var gardien_etage := gardien_de(n) != ""
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


## Le combat de l'étage en cours : le camp (avec ses PV et ses KO gardés, et ses Faveurs) contre les monstres de
## l'étage.
func combat() -> EtatCombat:
	var e := Regles.nouveau_combat(membres, monstres(), niveau, "tour", donnees)
	_faveurs_au_depart(e)
	for id in ko:
		if pv.has(id):
			e.perso(id)["pv"] = mini(int(pv[id]), int(e.fiche(id)["pv_max"]))
		if ko[id]:
			e.perso(id)["ko"] = true
			e.perso(id)["pv"] = 0
	_egide(e)
	return e


## La fin d'un étage : le camp a gagné et monte, avec ses PV rendus ; ou il est tombé.
func terminer(e: EtatCombat) -> void:
	if e.vainqueur != "a":
		fini = true
		atteint = etage
		return
	# Le Répit : 5 points de PV rendus de plus par cumul (20 % → 25 %).
	var rendu := float(donnees.tour["pv_entre_etages"]) + valeur_faveur("repit", faveur("repit"), donnees)
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
