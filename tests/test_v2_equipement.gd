## L'équipement (docs/GDD_V2.md, § 10.1 ; docs/PLAN.md, PR 3.1 ; décisions de Gautier du 29 octobre : +50 % de
## puissance pour un joueur équipé, noms de fantasy classique, huit lignes par effet).
extends "res://tests/test_case.gd"

const Lib := preload("res://tools/equilibrage_lib.gd")
const RARETES := ["commun", "peu_commun", "rare", "epique", "legendaire"]


func _bases() -> Array:
	var out: Array = donnees.objets["bases"].keys()
	out.sort()
	return out


# Les données : tout est connu et cohérent ; huit emplacements de six bases, huit lignes, cinq raretés.
func test_donnees_de_l_equipement() -> void:
	for erreur in donnees.erreurs:
		failures.append(erreur)
	assert_eq(donnees.objets["emplacements"].size(), 8, "huit emplacements")
	assert_eq(donnees.objets["lignes"].size(), 8, "huit lignes")
	assert_eq(donnees.objets["raretes"].size(), 5, "cinq raretés")
	assert_eq(donnees.objets["bases"].size(), 48, "quarante-huit bases")
	for e in donnees.objets["emplacements"]:
		assert_eq(Equipement.bases_de(str(e), donnees).size(), 6, "%s : six bases" % e)
	# Chaque ligne est dans vingt-quatre réserves : aucune n'est plus facile à trouver qu'une autre.
	var compte := {}
	for id in donnees.objets["bases"]:
		assert_eq(donnees.objets["bases"][id]["lignes"].size(), 4, id + " : quatre lignes possibles")
		assert_true(str(donnees.objets["bases"][id]["description"]) != "", id + " : une description")
		for l in donnees.objets["bases"][id]["lignes"]:
			compte[l] = int(compte.get(l, 0)) + 1
	for s in Equipement.STATS:
		assert_eq(int(compte.get(s, 0)), 24, "la ligne « %s » est dans vingt-quatre réserves" % s)
	# Les paliers : du niveau 1 au-delà du plafond, un suffixe chacun.
	assert_eq(str(Equipement.palier(1, donnees)["suffixe"]), "de fer", "niveau 1 : de fer")
	assert_eq(str(Equipement.palier(9, donnees)["suffixe"]), "de fer", "niveau 9 : encore de fer")
	assert_eq(str(Equipement.palier(10, donnees)["suffixe"]), "d'acier", "niveau 10 : d'acier")
	assert_eq(str(Equipement.palier(30, donnees)["suffixe"]), "de mithril", "niveau 30 : de mithril")
	assert_eq(str(Equipement.palier(90, donnees)["suffixe"]), "de dragon", "niveau 90 : de dragon")
	var d3 := Donnees.charger()
	d3.objets["paliers"] = [{"niveau_min": 5, "suffixe": "x"}]
	d3.erreurs.clear()
	d3._valider_objets()
	assert_false(d3.erreurs.is_empty(), "un premier palier qui ne commence pas au niveau 1 est signalé")
	for s in Equipement.STATS:
		assert_true(donnees.objets["lignes"].has(s), "la ligne « %s » existe" % s)
	# Une donnée fausse est signalée : une ligne inconnue dans une base, une fourchette à l'envers.
	var d2 := Donnees.charger()
	d2.objets["bases"]["epee"]["lignes"][0] = "vitesse"
	d2.objets["lignes"]["pv"]["fourchette"] = [6, 3]
	d2.erreurs.clear()
	d2._valider_objets()
	assert_eq(d2.erreurs.size(), 2, "deux erreurs signalées (%s)" % str(d2.erreurs))


# Un objet tiré respecte sa rareté (nombre de lignes), sa base (réserve, lignes toutes différentes) et ses fourchettes ;
# la même graine donne le même objet ; les fourchettes grandissent avec le niveau et la rareté.
func test_tirage_dans_ses_fourchettes() -> void:
	var bases := _bases()
	var differents := 0
	var precedent := {}
	for graine in range(1, 41):
		for rarete in RARETES:
			for niveau in [1, 12, 30, 60]:
				var base: String = bases[(graine + niveau) % bases.size()]
				var o := Equipement.tirer(base, rarete, niveau, graine, donnees)
				var ou := "%s %s niveau %d graine %d" % [base, rarete, niveau, graine]
				assert_true(Equipement.valide(o, donnees), ou + " : objet conforme")
				assert_eq(o["lignes"].size(), int(donnees.objets["raretes"][rarete]["lignes"]), ou + " : lignes de sa rareté")
				assert_between(int(o["qualite"]), 0, 100, ou + " : qualité")
				assert_true(bool(o["lie"]) and int(o["reforges"]) == 0, ou + " : lié par défaut, jamais reforgé")
				var vues: Array = []
				for l in o["lignes"]:
					assert_true(not vues.has(l["stat"]), ou + " : lignes toutes différentes")
					vues.append(l["stat"])
					assert_true(donnees.objets["bases"][base]["lignes"].has(l["stat"]), ou + " : ligne de la réserve de la base")
					var f := Equipement.fourchette(str(l["stat"]), rarete, niveau, donnees)
					assert_between(float(l["valeur"]), float(f[0]) - 0.0001, float(f[1]) + 0.0001, ou + " : %s dans sa fourchette" % l["stat"])
				assert_eq(Equipement.tirer(base, rarete, niveau, graine, donnees), o, ou + " : même graine, même objet")
				if precedent.has(rarete) and precedent[rarete]["lignes"] != o["lignes"]:
					differents += 1
				precedent[rarete] = o
	assert_true(differents > 100, "des graines différentes donnent des objets différents")
	# Les fourchettes : × 0,5 au niveau 1, pleines au niveau 30 et au-delà ; plus larges avec la rareté.
	assert_almost(Equipement.echelle_niveau(1, donnees), 0.5, "échelle du niveau 1")
	assert_almost(Equipement.echelle_niveau(30, donnees), 1.0, "échelle du niveau 30")
	assert_almost(Equipement.echelle_niveau(90, donnees), 1.0, "au-delà du niveau 30, l'échelle ne monte plus")
	assert_eq(Equipement.fourchette("pv", "commun", 30, donnees), [2.0, 4.0], "PV max, commun, niveau 30 : la fourchette des données")
	assert_eq(Equipement.fourchette("pv", "commun", 1, donnees), [1.0, 2.0], "au niveau 1, la moitié")
	assert_eq(Equipement.fourchette("pv", "epique", 30, donnees), [2.7, 5.4], "épique : × 1,35")
	assert_true(float(Equipement.fourchette("cle", "legendaire", 12, donnees)[1]) > float(Equipement.fourchette("cle", "rare", 12, donnees)[1]), "légendaire plus haut que rare")


# Les bonus : la somme des lignes portées, chacune sous son plafond ; un jeu complet couvre les huit emplacements.
func test_bonus_et_plafonds() -> void:
	var vides := Equipement.mods_vides()
	assert_eq(vides.size(), 8, "huit lignes à zéro")
	assert_eq(Equipement.mods([], donnees), vides, "sans objet, aucun bonus")
	assert_true(Equipement.sans_bonus(vides), "des bonus à zéro n'apportent rien")
	var jeu := Equipement.jeu(30, "epique", 11, donnees)
	assert_eq(jeu.size(), 8, "un jeu complet : huit objets")
	var emplacements: Array = []
	for o in jeu:
		emplacements.append(Equipement.emplacement(o, donnees))
		assert_eq(str(o["rarete"]), "epique", "chaque objet du jeu est épique")
	emplacements.sort()
	assert_eq(emplacements, ["amulette", "anneau", "arme", "armure", "bottes", "cape", "casque", "ceinture"], "un objet par emplacement")
	var m := Equipement.mods(jeu, donnees)
	var attendu := Equipement.mods_vides()
	for o in jeu:
		for l in o["lignes"]:
			attendu[l["stat"]] = float(attendu[l["stat"]]) + float(l["valeur"]) / 100.0
	for s in Equipement.STATS:
		assert_almost(float(m[s]), minf(float(attendu[s]), float(donnees.objets["lignes"][s]["plafond"]) / 100.0), s + " : la somme des lignes, sous le plafond")
	assert_false(Equipement.sans_bonus(m), "un jeu épique apporte des bonus")
	# Le plafond : dix objets pleins de PV max ne dépassent pas 25 %.
	var pleins: Array = []
	for i in range(10):
		pleins.append({"base": "cotte", "rarete": "legendaire", "niveau": 30, "lignes": [{"stat": "pv", "valeur": 9.0}], "qualite": 100, "lie": true, "reforges": 0})
	assert_almost(float(Equipement.mods(pleins, donnees)["pv"]), 0.25, "PV max plafonné à 25 %")
	# Le bonus d'une valeur selon le type de l'effet et le rang (Clés, Ouvertures).
	var mods := {"degats": 0.1, "soins": 0.05, "barrieres": 0.3, "dot": 0.2, "cle": 0.3, "ouverture": 0.1, "pv": 0.2, "force": 0.1}
	assert_almost(Equipement.bonus(mods, 2, "degats"), 0.1, "dégâts d'un N2 : la ligne Dégâts")
	assert_almost(Equipement.bonus(mods, 1, "degats"), 0.2, "dégâts d'un N1 : Dégâts + Ouvertures")
	assert_almost(Equipement.bonus(mods, 0, "soin"), 0.15, "soin du moyeu : Soins + Ouvertures")
	assert_almost(Equipement.bonus(mods, 4, "gardien"), 0.35, "Gardien d'une Clé : Soins + Clés")
	assert_almost(Equipement.bonus(mods, 3, "barriere"), 0.3, "barrière d'un N3 : Barrières")
	assert_almost(Equipement.bonus(mods, 4, "dot"), 0.5, "DoT d'une Clé : DoT + Clés")
	assert_almost(Equipement.bonus(mods, 2, "etat"), 0.0, "un état : rien")
	assert_almost(Equipement.bonus(mods, 4, ""), 0.3, "sans type, une Clé : la ligne Clés seule")
	assert_almost(Equipement.bonus({}, 4, "degats"), 0.0, "sans équipement : rien")


# Lié ou échangeable (GDD V2, § 10.1) : échangeable seulement au premier passage ; lié dès qu'on l'équipe, pour
# toujours ; un étage ordinaire ne lâche pas toujours (7 fois sur 10 au premier passage, 1 sur 2 rejoué), un Gardien toujours.
func test_lie_ou_echangeable() -> void:
	var tombes := 0
	var premiers := 0
	var raretes_etage: Dictionary = {}
	for graine in range(1, 201):
		var premier := Equipement.butin("etage", 10, true, graine, donnees)
		if premier.is_empty():
			continue
		premiers += 1
		assert_false(bool(premier["lie"]), "graine %d : échangeable au premier passage" % graine)
		assert_eq(int(premier["niveau"]), 10, "graine %d : du niveau de l'étage" % graine)
		assert_true(Equipement.valide(premier, donnees), "graine %d : objet conforme" % graine)
		raretes_etage[premier["rarete"]] = int(raretes_etage.get(premier["rarete"], 0)) + 1
		var rejoue := Equipement.butin("etage", 10, false, graine, donnees)
		if not rejoue.is_empty():
			tombes += 1
			assert_true(bool(rejoue["lie"]), "graine %d : lié sur un étage rejoué" % graine)
		var gardien := Equipement.butin("gardien", 23, false, graine, donnees)
		assert_false(gardien.is_empty(), "graine %d : un Gardien lâche toujours un objet" % graine)
		assert_eq(str(gardien["rarete"]), "peu_commun", "graine %d : peu commun au Gardien" % graine)
		assert_true(bool(gardien["lie"]), "graine %d : lié quand le Gardien est rejoué" % graine)
		assert_false(bool(Equipement.butin("gardien", 23, true, graine, donnees)["lie"]), "graine %d : échangeable au premier Gardien" % graine)
	assert_between(premiers, 110, 170, "un premier passage lâche un objet environ sept fois sur dix (%d sur 200)" % premiers)
	assert_between(tombes, 60, 140, "un étage rejoué lâche un objet environ une fois sur deux (%d sur 200)" % tombes)
	assert_true(int(raretes_etage.get("commun", 0)) > int(raretes_etage.get("peu_commun", 0)), "à l'étage, plus de commun que de peu commun (%s)" % str(raretes_etage))
	assert_true(int(raretes_etage.get("peu_commun", 0)) > 0, "du peu commun à l'étage")
	assert_false(raretes_etage.has("rare") or raretes_etage.has("epique"), "ni rare ni épique à un étage ordinaire : ils viennent des donjons")
	var trouve := Equipement.butin("gardien", 10, true, 7, donnees)
	var porte := Equipement.equiper(trouve)
	assert_false(bool(trouve["lie"]), "l'objet trouvé n'est pas modifié")
	assert_true(bool(porte["lie"]), "équipé : lié")
	assert_true(bool(Equipement.reforger(porte, 0, 3, donnees)["lie"]), "reforgé après : toujours lié")
	assert_false(bool(Equipement.reforger(trouve, 0, 3, donnees)["lie"]), "reforger ne lie pas un objet échangeable")


# La reforge ne touche qu'une ligne ; son coût grandit à chaque fois.
func test_reforge() -> void:
	var o := Equipement.tirer("epee", "legendaire", 30, 5, donnees)
	assert_eq(o["lignes"].size(), 4, "une épée légendaire : quatre lignes")
	assert_eq(Equipement.cout_reforge(o, donnees), 20, "première reforge : 20 Éclats")
	var r := Equipement.reforger(o, 2, 99, donnees)
	assert_eq(int(o["reforges"]), 0, "l'objet d'origine n'est pas modifié")
	assert_eq(int(r["reforges"]), 1, "une reforge comptée")
	assert_eq(Equipement.cout_reforge(r, donnees), 40, "deuxième reforge : 40 Éclats")
	assert_eq(Equipement.cout_reforge(Equipement.reforger(r, 0, 1, donnees), donnees), 60, "troisième : 60")
	for i in [0, 1, 3]:
		assert_eq(r["lignes"][i], o["lignes"][i], "la ligne %d ne bouge pas" % i)
	assert_true(Equipement.valide(r, donnees), "l'objet reforgé est conforme")
	var autres: Array = [r["lignes"][0]["stat"], r["lignes"][1]["stat"], r["lignes"][3]["stat"]]
	assert_false(autres.has(r["lignes"][2]["stat"]), "la ligne reforgée ne double pas une autre")
	# Quatre lignes sur une réserve de quatre : la ligne reforgée garde sa statistique, seul son chiffre est retiré.
	assert_eq(r["lignes"][2]["stat"], o["lignes"][2]["stat"], "réserve épuisée : la même statistique")
	var change := false
	for graine in range(1, 30):
		if Equipement.reforger(o, 2, graine, donnees)["lignes"][2]["valeur"] != o["lignes"][2]["valeur"]:
			change = true
	assert_true(change, "le chiffre change avec la graine")
	# Une épée commune (une ligne sur quatre possibles) peut changer de statistique.
	var c := Equipement.tirer("epee", "commun", 30, 5, donnees)
	var stats: Dictionary = {}
	for graine in range(1, 40):
		stats[Equipement.reforger(c, 0, graine, donnees)["lignes"][0]["stat"]] = true
	assert_true(stats.size() >= 3, "une seule ligne : la reforge peut en tirer une autre (%s)" % str(stats.keys()))
	assert_eq(Equipement.reforger(o, 7, 1, donnees), o, "un index hors de l'objet : l'objet tel quel")


# En combat : les PV max et la Force à la création, les autres lignes sur chaque valeur selon son type et son rang ;
# sans équipement (ou avec des bonus à zéro), le combat est le même au bit près ; tout passe par la sérialisation.
func test_equipement_en_combat() -> void:
	var sans := Generateur.generer("guerrier", 3, 30, Generateur.PAR_DEFAUT, donnees)
	var avec := Generateur.generer("guerrier", 3, 30, Generateur.PAR_DEFAUT, donnees)
	avec.mods = {"pv": 0.2, "force": 0.1, "degats": 0.1, "soins": 0.05, "barrieres": 0.3, "dot": 0.2, "cle": 0.3, "ouverture": 0.1}
	var ennemis := Trio.camp(Generateur.generer("mage", 9, 30, Generateur.PAR_DEFAUT, donnees), 30, donnees)
	var e0 := Regles.nouveau_combat(Trio.camp(sans, 30, donnees), ennemis, 30, "pvp", donnees)
	var e1 := Regles.nouveau_combat(Trio.camp(avec, 30, donnees), ennemis, 30, "pvp", donnees)
	assert_eq(int(e1.fiche("a1")["pv_max"]), Regles.plancher(float(sans.pv_base) * Regles.multiplicateur_niveau(e0) * (1.0 + sans.bonus_pv()) * 1.2), "PV max × 1,2")
	assert_eq(int(e1.perso("a1")["pv"]), int(e1.fiche("a1")["pv_max"]), "tous ses PV au départ")
	assert_almost(float(e1.fiche("a1")["k"]), float(e0.fiche("a1")["k"]) * 1.1, "Force : le multiplicateur de classe × 1,1")
	assert_eq(int(e1.fiche("a2")["pv_max"]), int(e0.fiche("a2")["pv_max"]), "l'Écho sans équipement garde ses PV")
	assert_eq(int(e1.fiche("b1")["pv_max"]), int(e0.fiche("b1")["pv_max"]), "l'adversaire garde ses PV")
	var b1 := sans.bonus_valeurs(0, 1)
	var b4 := sans.bonus_valeurs(0, 4)
	assert_almost(Regles.valeur(e1, "a1", 0, 1, 100.0, "degats"), Regles.valeur(e0, "a1", 0, 1, 100.0, "degats") * 1.1 * (1.0 + b1 + 0.2) / (1.0 + b1), "dégâts d'un N1 : Force, Dégâts et Ouvertures")
	assert_almost(Regles.valeur(e1, "a1", 0, 4, 100.0, "soin"), Regles.valeur(e0, "a1", 0, 4, 100.0, "soin") * 1.1 * (1.0 + b4 + 0.35) / (1.0 + b4), "soin d'une Clé : Force, Soins et Clés")
	assert_almost(Regles.valeur(e1, "a1", 0, 2, 100.0, "etat"), Regles.valeur(e0, "a1", 0, 2, 100.0, "etat") * 1.1, "un état : la Force seule")
	assert_almost(Regles.valeur(e1, "a1", 0, 0, 100.0, "degats"), Regles.valeur(e0, "a1", 0, 0, 100.0, "degats") * 1.1 * 1.2, "le moyeu : Force, Dégâts et Ouvertures")
	assert_almost(Regles.valeur(e1, "a2", 0, 4, 100.0, "degats"), Regles.valeur(e0, "a2", 0, 4, 100.0, "degats"), "l'Écho : rien")
	# Des bonus à zéro : un duel joué par l'IA se déroule à l'identique, tour par tour.
	var zero := Generateur.generer("guerrier", 3, 30, Generateur.PAR_DEFAUT, donnees)
	zero.mods = Equipement.mods_vides()
	var ea := Regles.nouveau_combat(Trio.camp(sans, 30, donnees), ennemis, 30, "pvp", donnees)
	var ez := Regles.nouveau_combat(Trio.camp(zero, 30, donnees), ennemis, 30, "pvp", donnees)
	assert_eq(int(ez.fiche("a1")["pv_max"]), int(ea.fiche("a1")["pv_max"]), "bonus à zéro : mêmes PV max")
	assert_eq(float(ez.fiche("a1")["k"]), float(ea.fiche("a1")["k"]), "bonus à zéro : même multiplicateur")
	while not ea.fini and ea.tour <= 100:
		ea = tour(ea, IA.declarer(ea))
		ez = tour(ez, IA.declarer(ez))
		for id in ea.ordre:
			assert_eq(int(ez.perso(id)["pv"]), int(ea.perso(id)["pv"]), "tour %d, %s : mêmes PV avec des bonus à zéro" % [ea.tour, id])
	assert_true(ea.fini and ez.fini and ea.vainqueur == ez.vainqueur, "même vainqueur")
	# Un duel entre camps équipés se termine, et l'équipement passe par la sérialisation.
	var jeu := Equipement.jeu(30, "epique", 4, donnees)
	var equipe := Generateur.generer("voleur", 8, 30, Generateur.PAR_DEFAUT, donnees)
	equipe.mods = Equipement.mods(jeu, donnees)
	var copie := Destin.depuis_dict(JSON.parse_string(JSON.stringify(equipe.vers_dict())))
	for s in Equipement.STATS:
		assert_almost(float(copie.mods[s]), float(equipe.mods[s]), s + " : le Destin sérialisé garde ses bonus")
	var ec := Regles.nouveau_combat(Trio.camp(copie, 30, donnees), Trio.camp(equipe, 30, donnees), 30, "pvp", donnees)
	var relu := EtatCombat.depuis_dict(JSON.parse_string(JSON.stringify(ec.vers_dict())))
	assert_almost(Regles.valeur(relu, "a1", 1, 4, 100.0, "degats"), Regles.valeur(ec, "a1", 1, 4, 100.0, "degats"), "l'état sérialisé garde les bonus")
	assert_almost(Regles.valeur(ec, "a1", 1, 4, 100.0, "degats"), Regles.valeur(ec, "b1", 1, 4, 100.0, "degats"), "les deux camps portent le même équipement")
	while not ec.fini and ec.tour <= 100:
		ec = tour(ec, IA.declarer(ec))
	assert_true(ec.fini, "un duel de camps équipés se termine")


# Les textes : « Épée épique », « +5,3 % de dégâts directs », la fiche d'un objet.
func test_textes_de_l_equipement() -> void:
	var o := Equipement.tirer("epee", "epique", 12, 2, donnees)
	assert_eq(Equipement.nom(o, donnees), "Épée d'acier épique", "le nom d'une épée épique du niveau 12 : d'acier")
	assert_eq(Equipement.nom(Equipement.tirer("cotte", "commun", 1, 2, donnees), donnees), "Cotte de mailles de fer commune", "le féminin, de fer au niveau 1")
	assert_eq(Equipement.nom(Equipement.tirer("anneau", "commun", 1, 2, donnees), donnees), "Anneau de fer commun", "le masculin")
	assert_eq(Equipement.nom(Equipement.tirer("couronne", "legendaire", 45, 2, donnees), donnees), "Couronne runique légendaire", "niveau 45 : runique")
	assert_eq(Equipement.nom(Equipement.tirer("sabots", "peu_commun", 12, 2, donnees), donnees), "Sabots d'acier peu communs", "peu commun, au pluriel")
	assert_eq(Equipement.nom(Equipement.tirer("bottes", "commun", 1, 2, donnees), donnees), "Bottes de fer communes", "le féminin pluriel")
	assert_eq(str(Equipement.fiche(o, donnees)["description"]), str(donnees.objets["bases"]["epee"]["description"]), "la fiche porte la description de la base")
	assert_eq(Equipement.texte_ligne({"stat": "degats", "valeur": 5.3}, donnees), "+5,3 % de dégâts directs", "le texte d'une ligne")
	assert_eq(Equipement.texte_ligne({"stat": "pv", "valeur": 5.0}, donnees), "+5 % de PV max", "un chiffre rond")
	assert_eq(Equipement.texte_fourchette("pv", {"rarete": "commun", "niveau": 30}, donnees), "[2 – 4]", "la fourchette affichée")
	var f := Equipement.fiche(o, donnees)
	assert_eq(f["nom"], "Épée d'acier épique", "fiche : nom")
	assert_eq(f["emplacement"], "Arme", "fiche : emplacement")
	assert_eq(f["rarete"], "épique", "fiche : rareté")
	assert_eq(f["rang"], 4, "fiche : rang de la rareté")
	assert_eq(f["niveau"], 12, "fiche : niveau")
	assert_eq(f["lignes"].size(), 3, "fiche : trois lignes")
	for l in f["lignes"]:
		assert_true(str(l["texte"]).begins_with("+"), "fiche : chaque ligne a son texte")
		assert_true(str(l["fourchette"]).begins_with("["), "fiche : chaque ligne a sa fourchette")
	assert_eq(f["qualite"], o["qualite"], "fiche : qualité")
	assert_eq(f["reforge"], 20, "fiche : coût de la reforge")


# Le simulateur sait équiper les camps (critère de la PR 3.1).
func test_simulateur_equipe() -> void:
	var memoire := {}
	Lib.equipement = "epique"
	var camp: Array = Lib.destins(donnees, "mage", 3, memoire, "trio")
	Lib.equipement = ""
	var nu: Array = Lib.destins(donnees, "mage", 3, memoire, "trio")
	assert_eq(camp.size(), 3, "un trio")
	for i in range(3):
		assert_false(Equipement.sans_bonus(camp[i].mods), "membre %d : équipé" % i)
		assert_true(nu[i].mods.is_empty(), "membre %d : sans équipement quand rien n'est demandé" % i)
	assert_eq(camp[0].classe_id, nu[0].classe_id, "le même joueur")


# L'amélioration +1 à +10 (décision de Gautier du 1er novembre) : de l'Or, un coût qui monte à chaque cran, un échec fait
# perdre un cran, chaque cran renforce les lignes ; le nom, la fiche, la validité, la reforge et l'équipement suivent.
func test_amelioration() -> void:
	var a: Dictionary = donnees.objets["amelioration"]
	assert_eq(int(a["max"]), 10, "dix crans")
	var o := Equipement.tirer("epee", "commun", 30, 5, donnees)
	assert_eq(Equipement.cran(o), 0, "un objet trouvé est à +0")
	assert_eq(Equipement.cout_amelioration(o, donnees), 5, "commun niveau 30, +1 : 5 Or")
	assert_eq(Equipement.cout_amelioration(Equipement.tirer("epee", "legendaire", 30, 5, donnees), donnees), 25, "légendaire : × 5 (son rang)")
	assert_eq(Equipement.cout_amelioration(Equipement.tirer("epee", "commun", 1, 5, donnees), donnees), 3, "niveau 1 : la moitié, arrondie")
	var o3 := o.duplicate(true)
	o3["amelioration"] = 3
	assert_eq(Equipement.cout_amelioration(o3, donnees), roundi(5.0 * pow(1.6, 3.0)), "+3 → +4 : 5 × 1,6³")
	var o10 := o.duplicate(true)
	o10["amelioration"] = 10
	assert_eq(Equipement.cout_amelioration(o10, donnees), 0, "au plus haut : plus rien à payer")
	assert_eq(Equipement.chance_amelioration(o10, donnees), 0.0, "au plus haut : aucune chance")
	assert_eq(int(Equipement.ameliorer(o10, 1, donnees)["apres"]), 10, "au plus haut : rien ne bouge")
	# +0 → +1 ne rate jamais.
	assert_eq(Equipement.chance_amelioration(o, donnees), 1.0, "le premier cran est sûr")
	for g in range(20):
		assert_true(bool(Equipement.ameliorer(o, g, donnees)["reussi"]), "+0 → +1 réussit toujours")
	# Plus haut, ça rate parfois, et un échec fait perdre un cran (de +3 : à +2).
	var reussites := 0
	for g in range(200):
		var r := Equipement.ameliorer(o3, g, donnees)
		assert_eq(int(r["avant"]), 3, "avant : +3")
		if bool(r["reussi"]):
			reussites += 1
			assert_eq(int(r["apres"]), 4, "réussi : +4")
		else:
			assert_eq(int(r["apres"]), 2, "raté : +2")
	assert_true(reussites > 110 and reussites < 170, "de +3 à +4 : 70 %% environ (%d sur 200)" % reussites)
	assert_eq(int(o3["amelioration"]), 3, "l'objet d'origine n'est pas modifié")
	# Jamais sous zéro : à +1, un échec ramène à +0.
	var o1 := o.duplicate(true)
	o1["amelioration"] = 1
	var vu_zero := false
	for g in range(200):
		var r := Equipement.ameliorer(o1, g, donnees)
		if not bool(r["reussi"]):
			vu_zero = true
			assert_eq(int(r["apres"]), 0, "raté à +1 : retour à +0")
	assert_true(vu_zero, "à +1, un échec arrive (90 % de réussite)")
	# Le bonus : +5 % par cran sur les lignes ; le nom, la fiche, la validité, la reforge et l'équipement.
	var m0 := Equipement.mods([o], donnees)
	var m3 := Equipement.mods([o3], donnees)
	var s: String = o["lignes"][0]["stat"]
	assert_true(absf(float(m3[s]) - float(m0[s]) * 1.15) < 0.0001, "+3 : les lignes × 1,15")
	assert_true(Equipement.nom(o3, donnees).ends_with(" +3"), "le nom porte le cran")
	assert_false(Equipement.nom(o, donnees).contains("+"), "à +0 : rien dans le nom")
	var f := Equipement.fiche(o3, donnees)
	assert_eq(int(f["amelioration"]), 3, "fiche : le cran")
	assert_eq(int(f["amelioration_max"]), 10, "fiche : le plus haut")
	assert_eq(int(f["chance_amelioration"]), 70, "fiche : la chance en %")
	assert_eq(int(f["cout_amelioration"]), Equipement.cout_amelioration(o3, donnees), "fiche : le coût")
	assert_true(absf(float(f["lignes"][0]["valeur"]) - float(o["lignes"][0]["valeur"]) * 1.15) < 0.0001, "fiche : la ligne avec le cran compté")
	assert_true(str(f["lignes"][0]["base"]) != str(f["lignes"][0]["texte"]), "fiche : le texte de base diffère")
	assert_true(Equipement.valide(o3, donnees), "un objet amélioré est conforme")
	var sans := o.duplicate(true)
	sans.erase("amelioration")
	assert_true(Equipement.valide(sans, donnees), "un objet d'avant l'amélioration (sans la clé) est conforme")
	assert_eq(Equipement.cran(sans), 0, "et il est à +0")
	var trop := o.duplicate(true)
	trop["amelioration"] = 11
	assert_false(Equipement.valide(trop, donnees), "+11 : refusé")
	assert_eq(Equipement.cran(Equipement.reforger(o3, 0, 4, donnees)), 3, "la reforge garde le cran")
	assert_eq(Equipement.cran(Equipement.equiper(o3)), 3, "équiper garde le cran")
