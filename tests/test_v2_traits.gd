## Les traits légendaires (data/items.json, traits ; engine/equipement.gd ; engine/regles.gd) : un objet légendaire porte un
## trait tiré à la trouvaille, un passif de combat de son porteur. Chaque trait est vérifié sur un petit combat d'essai.
extends "res://tests/test_case.gd"


func _avec(nom_trait: String, voies: Array = [], pv: int = 1000) -> Destin:
	var d := essai(voies, pv)
	d.traits = [nom_trait] as Array[String]
	return d


# Les données : dix traits connus du moteur, un texte avec sa valeur ; un objet légendaire en porte un, pas un épique ;
# les traits portés comptent une fois ; un trait inconnu est signalé.
func test_donnees_et_objets() -> void:
	assert_eq(donnees.objets["traits"].size(), 10, "dix traits")
	for id in donnees.objets["traits"]:
		assert_true(str(id) in Donnees.TRAITS_CONNUS, "%s : connu du moteur" % id)
		assert_true(Equipement.texte_trait(str(id), donnees).begins_with(str(donnees.objets["traits"][id]["nom"])), "%s : son texte commence par son nom" % id)
	assert_eq(Equipement.texte_trait("soif", donnees), "Soif : chaque dégât direct qu'il inflige le soigne de 10 % de ce dégât", "la valeur dans le texte")
	var vus := {}
	for graine in range(1, 41):
		var o := Equipement.tirer("epee", "legendaire", 30, graine, donnees)
		assert_true(o.has("trait") and donnees.objets["traits"].has(o["trait"]), "graine %d : un légendaire porte un trait" % graine)
		assert_true(Equipement.valide(o, donnees), "graine %d : un légendaire à trait est valide" % graine)
		vus[o["trait"]] = true
		assert_false(Equipement.tirer("epee", "epique", 30, graine, donnees).has("trait"), "graine %d : pas de trait sur un épique" % graine)
	assert_true(vus.size() >= 6, "les traits varient avec la graine (%d vus)" % vus.size())
	var o1 := Equipement.tirer("epee", "legendaire", 30, 3, donnees)
	var o2 := o1.duplicate(true)
	o2["base"] = "cotte"
	assert_eq(Equipement.traits([o1, o2], donnees), [str(o1["trait"])] as Array[String], "un même trait porté deux fois compte une fois")
	assert_eq(Equipement.traits([Equipement.tirer("epee", "rare", 30, 3, donnees)], donnees), [] as Array[String], "rien sans légendaire")
	var faux := o1.duplicate(true)
	faux["trait"] = "inconnu"
	assert_false(Equipement.valide(faux, donnees), "un trait inconnu : objet invalide")
	var epique := Equipement.tirer("epee", "epique", 30, 3, donnees)
	epique["trait"] = "soif"
	assert_false(Equipement.valide(epique, donnees), "un trait sur un épique : objet invalide")
	assert_true(str(Equipement.fiche(o1, donnees)["texte_trait"]) != "", "la fiche porte le texte du trait")
	assert_eq(Equipement.reforger(o1, 0, 9, donnees)["trait"], o1["trait"], "la reforge garde le trait")
	var d2 := Donnees.charger()
	d2.objets["traits"]["vol"] = {"nom": "Vol", "texte": "x", "valeur": 1}
	d2.erreurs.clear()
	d2._valider_objets()
	assert_false(d2.erreurs.is_empty(), "un trait inconnu du moteur est signalé")
	# Un Destin garde ses traits en dictionnaire ; un combat les porte dans sa fiche.
	var dst := _avec("soif")
	assert_eq(Destin.depuis_dict(dst.vers_dict()).traits, ["soif"] as Array[String], "les traits survivent à vers_dict / depuis_dict")
	var e := combat([dst, essai()], [essai(), essai()])
	assert_eq(e.fiche("a1")["traits"], ["soif"] as Array[String], "la fiche du combat porte les traits")
	assert_eq(e.copie().fiche("a1")["traits"], ["soif"] as Array[String], "et sa copie")
	assert_eq(EtatCombat.depuis_dict(e.vers_dict()).fiche("a1")["traits"], ["soif"] as Array[String], "et sa version sérialisée")


# Ténacité : la première fois que ses PV tomberaient à zéro, il reste à 1 PV ; la seconde fois, il tombe.
func test_tenacite() -> void:
	var e := combat([_avec("tenacite", [[[deg(0)]]], 100), essai()], [essai([[[deg(500)]]]), essai([[[deg(500)]]])])
	e = tour(e, {"b1": jouer(e, "b1", 0, "a1"), "b2": jouer(e, "b2", 0, "a1")})
	assert_eq(int(e.perso("a1")["pv"]), 1, "il reste à 1 PV")
	assert_true(e.vivant("a1"), "pas KO")
	assert_true(evenements(e, "tenacite").size() == 1, "l'événement Ténacité")
	e = tour(e, {"b2": jouer(e, "b2", 0, "a1")})
	assert_false(e.vivant("a1"), "la seconde fois (le second nœud de b2, 10 dégâts), il tombe")


# Soif : 10 % des dégâts directs infligés reviennent en soin. Épines : 10 % des dégâts directs subis repartent sur
# l'attaquant, sans chaîne.
func test_soif_et_epines() -> void:
	var a := _avec("soif", [[[deg(200)]]])
	var b := _avec("epines", [[[deg(100)]]])
	var e := combat([a, essai()], [b, essai()])
	e.perso("a1")["pv"] = 500
	e = tour(e, {"a1": jouer(e, "a1", 0, "b1"), "b1": jouer(e, "b1", 0, "a1")})
	# a1 : −100 (b1), +20 (Soif sur ses 200), −20 (Épines de b1 : 10 % des 200 reçus) ; b1 : −200.
	assert_eq(int(e.perso("a1")["pv"]), 500 - 100 + 20 - 20, "Soif soigne 20, Épines rend 20")
	assert_eq(int(e.perso("b1")["pv"]), 800, "b1 subit 200")
	assert_eq(evenements(e, "epines").size(), 1, "un seul renvoi (pas de chaîne)")
	assert_eq(evenements(e, "soin").size(), 1, "un soin de Soif")


# Férocité : +20 % de dégâts directs sur un ennemi sous 30 % de ses PV. Grâce : soins reçus +15 %.
func test_ferocite_et_grace() -> void:
	var e := combat([_avec("ferocite", [[[deg(100)]]]), essai()], [essai(), essai()])
	e.perso("b1")["pv"] = 290
	e = tour(e, {"a1": jouer(e, "a1", 0, "b1")})
	assert_eq(int(e.perso("b1")["pv"]), 290 - 120, "sous 30 % : 120 au lieu de 100")
	var e2 := combat([_avec("ferocite", [[[deg(100)]]]), essai()], [essai(), essai()])
	e2.perso("b1")["pv"] = 310
	e2 = tour(e2, {"a1": jouer(e2, "a1", 0, "b1")})
	assert_eq(int(e2.perso("b1")["pv"]), 210, "au-dessus de 30 % : 100")
	var e3 := combat([_avec("grace"), essai([[[soin(100, "un_allie")]]])], [essai(), essai()])
	e3.perso("a1")["pv"] = 500
	e3 = tour(e3, {"a2": jouer(e3, "a2", 0, "", "a1")})
	assert_eq(int(e3.perso("a1")["pv"]), 615, "un soin de 100 devient 115")


# Carapace : une barrière de 15 % des PV max dès le tour 1, pour trois tours.
func test_carapace() -> void:
	var e := combat([_avec("carapace", [], 1000), essai()], [essai([[[deg(100)]]]), essai()])
	assert_eq(int(e.perso("a1")["barriere"]), 150, "150 de barrière au départ")
	e = tour(e, {"b1": jouer(e, "b1", 0, "a1")})
	assert_eq(int(e.perso("a1")["pv"]), 1000, "le coup est absorbé")
	assert_eq(int(e.perso("a1")["barriere"]), 50, "il en reste 50")
	e = tour(e, {})
	e = tour(e, {})
	assert_eq(int(e.perso("a1")["barriere"]), 0, "elle expire au bout de trois tours")


# Endurance : un état négatif subi dure un tour de moins (jamais moins d'un) ; un état positif n'est pas raccourci.
# Persistance : un DoT posé dure un tour de plus.
func test_endurance_et_persistance() -> void:
	var e := combat([_avec("endurance"), essai()], [essai([[[etat("silencie", 3)]]]), essai([[[renfort(10, "un_allie")], [etat("gele", 1)]]])])
	e = tour(e, {"b1": jouer(e, "b1", 0, "a1")})
	assert_eq(e.tours_restants("a1", "silencie"), 2, "Silencié 3 tours → 2")
	var e2 := combat([_avec("endurance"), essai()], [essai([[[etat("gele", 1)]]]), essai()])
	e2 = tour(e2, {"b1": jouer(e2, "b1", 0, "a1")})
	assert_eq(e2.tours_restants("a1", "gele"), 1, "Gelé 1 tour reste 1 tour")
	# (Le moyeu de a1 ne frappe pas, sinon Harmonie, Renfort + dégâts, ajouterait un tour.)
	var endurant := _avec("endurance")
	endurant.moyeu["effets"] = [barriere(0)]
	var e3 := combat([endurant, essai([[[renfort(10, "un_allie")]]])], [essai(), essai()])
	e3 = tour(e3, {"a2": jouer(e3, "a2", 0, "", "a1")})
	assert_eq(e3.tours_restants("a1", "renfort"), 2, "un Renfort reçu garde ses 2 tours")
	var e4 := combat([_avec("persistance", [[[dot("poison", 10, 2)]]]), essai()], [essai(), essai()])
	e4 = tour(e4, {"a1": jouer(e4, "a1", 0, "b1")})
	assert_eq(e4.tours_restants("b1", "poison"), 3, "un poison de 2 tours en dure 3")
	var e5 := combat([essai([[[dot("poison", 10, 2)]]]), essai()], [essai(), essai()])
	e5 = tour(e5, {"a1": jouer(e5, "a1", 0, "b1")})
	assert_eq(e5.tours_restants("b1", "poison"), 2, "sans le trait : 2")


# Ancrage : une voie refroidit au bout de trois tours d'inactivité au lieu de deux. Fulgurance : une Clé s'éteint
# deux tours au lieu de trois.
func test_ancrage_et_fulgurance() -> void:
	var e := combat([_avec("ancrage", [[], []]), essai()], [essai(), essai()])
	e = tour(e, {"a1": jouer(e, "a1", 0, "b1")})
	assert_eq(int(e.perso("a1")["jalons"][0]), 1, "jalon 1 sur la voie 1")
	e = tour(e, {"a1": jouer(e, "a1", 1, "b1")})
	e = tour(e, {"a1": jouer(e, "a1", 1, "b1")})
	assert_eq(int(e.perso("a1")["jalons"][0]), 1, "deux tours sans la jouer : elle tient encore (Ancrage)")
	e = tour(e, {"a1": jouer(e, "a1", 1, "b1")})
	assert_eq(int(e.perso("a1")["jalons"][0]), 0, "trois tours : elle refroidit")
	var sans := combat([essai([[], []]), essai()], [essai(), essai()])
	sans = tour(sans, {"a1": jouer(sans, "a1", 0, "b1")})
	sans = tour(sans, {"a1": jouer(sans, "a1", 1, "b1")})
	sans = tour(sans, {"a1": jouer(sans, "a1", 1, "b1")})
	assert_eq(int(sans.perso("a1")["jalons"][0]), 0, "sans le trait : deux tours suffisent")
	var f := combat([_avec("fulgurance", [[]]), essai()], [essai(), essai()])
	for _i in range(4):
		f = tour(f, {"a1": jouer(f, "a1", 0, "b1")})
	# La Clé (rang 4) jouée au tour 4 s'éteint jusqu'au tour 4 + 2 + 1 = 7 au lieu de 8.
	assert_eq(int(f.perso("a1")["spent_until"][0][3]), 7, "la Clé s'éteint un tour de moins")
	assert_eq(int(f.perso("a1")["spent_until"][0][0]), 1 + 3 + 1, "le rang 1 garde son extinction de trois tours")


# Les traits ne changent rien à qui ne les porte pas : un combat sans trait est le même qu'avant, au bit près.
func test_sans_trait_rien_ne_change() -> void:
	var a := Generateur.generer("guerrier", 5, 30, Generateur.PAR_DEFAUT, donnees)
	var b := Generateur.generer("mage", 6, 30, Generateur.PAR_DEFAUT, donnees)
	var e := Regles.nouveau_combat(Trio.camp(a, 30, donnees), Trio.camp(b, 30, donnees), 30, "pvp", donnees)
	while not e.fini and e.tour <= 60:
		e = tour(e, IA.declarer(e))
	assert_true(e.fini, "le combat se termine")
	assert_true(evenements(e, "tenacite").is_empty() and evenements(e, "epines").is_empty(), "aucun événement de trait")
