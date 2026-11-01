## La Forge et le butin (docs/GDD_V2.md, § 10 ; docs/PLAN.md, PR 3.2) : le butin de la Tour, les Éclats, le recyclage,
## le revenu passif, l'aperçu sur la roue, les fiches avec équipement, le profil.
extends "res://tests/test_case.gd"


func _tour(classe: String = "mage", niveau: int = 12, graine: int = 77) -> Tour:
	return Tour.commencer_camp(Trio.camp(Generateur.generer(classe, 5, niveau, Generateur.PAR_DEFAUT, donnees), niveau, donnees), niveau, graine, donnees)


# Le butin d'un étage : du niveau de l'étage, peu commun au Gardien, commun ou peu commun ailleurs (pas toujours) ;
# échangeable au premier passage, lié sinon ; la même graine de montée donne le même objet.
func test_butin_de_la_tour() -> void:
	var t := _tour()
	var b5 := t.butin(5, true)
	assert_eq(str(b5["rarete"]), "peu_commun", "étage 5 (Gardien) : peu commun")
	assert_eq(int(b5["niveau"]), t.niveau_etage(5), "du niveau de l'étage")
	assert_false(bool(b5["lie"]), "premier passage : échangeable")
	assert_eq(_tour().butin(5, true), b5, "même montée, même butin")
	var raretes := {}
	var vides := 0
	var sans := 0
	for n in range(1, 41):
		if n % 5 == 0:
			continue
		var b := t.butin(n, true)
		if b.is_empty():
			sans += 1
		else:
			assert_true(str(b["rarete"]) in ["commun", "peu_commun"], "étage %d : commun ou peu commun" % n)
			raretes[b["rarete"]] = true
		var r := t.butin(n, false)
		if r.is_empty():
			vides += 1
		else:
			assert_true(bool(r["lie"]), "étage %d rejoué : lié" % n)
	assert_eq(raretes.size(), 2, "du commun et du peu commun sur 32 étages")
	assert_between(sans, 3, 18, "un premier passage ne lâche pas toujours (%d étages sans objet sur 32)" % sans)
	assert_between(vides, 6, 26, "un étage rejoué ne lâche rien environ une fois sur deux (%d sur 32)" % vides)
	assert_true(bool(t.butin(10, false)["lie"]) and str(t.butin(10, false)["rarete"]) in ["peu_commun", "rare"], "grand Gardien rejoué : peu commun ou rare, lié")


# Les Éclats : par duel, par étage (moins si rejoué), au recyclage ; le revenu passif plafonné.
func test_eclats_et_revenu() -> void:
	assert_eq(Equipement.eclats_duel(true, donnees), 15, "duel gagné : 15 Éclats")
	assert_eq(Equipement.eclats_duel(false, donnees), 5, "duel perdu : 5 Éclats")
	assert_eq(Equipement.eclats_etage(1, true, donnees), 12, "étage 1 : 10 + 2")
	assert_eq(Equipement.eclats_etage(20, true, donnees), 50, "étage 20 : 10 + 40")
	assert_eq(Equipement.eclats_etage(20, false, donnees), 25, "étage 20 rejoué : la moitié")
	assert_eq(Equipement.recyclage({"rarete": "commun"}, donnees), 5, "recycler un commun : 5")
	assert_eq(Equipement.recyclage({"rarete": "peu_commun"}, donnees), 10, "recycler un peu commun : 10")
	assert_eq(Equipement.recyclage({"rarete": "legendaire"}, donnees), 100, "recycler un légendaire : 100")
	assert_eq(Tour.revenu(0, donnees), {"eclats": 0, "xp": 0}, "sans record, rien")
	assert_eq(Tour.revenu(10, donnees), {"eclats": 30, "xp": 20}, "record 10 : 30 Éclats, 20 XP")
	assert_eq(Tour.revenu(1000, donnees), {"eclats": 150, "xp": 120}, "le revenu plafonne")
	for erreur in donnees.erreurs:
		failures.append(erreur)


# L'aperçu sur la roue : « Nom : avant → après », jusqu'à trois exemples, qui bougent avec les lignes.
func test_apercu_sur_la_roue() -> void:
	var d := Generateur.generer("mage", 3, 20, Generateur.PAR_DEFAUT, donnees)
	var rien := Equipement.mods_vides()
	var mieux := Equipement.mods_vides()
	mieux["degats"] = 0.2
	mieux["force"] = 0.1
	var ex := Equipement.apercu(d, rien, mieux, 20, donnees)
	assert_between(ex.size(), 1, 3, "de un à trois exemples")
	for x in ex:
		assert_true(" → " in x, "un exemple « avant → après » : " + x)
		var parts: PackedStringArray = x.split(" : ")[1].split(" → ")
		assert_true(int(parts[1]) > int(parts[0]), "après est plus grand : " + x)
	assert_true(d.mods.is_empty(), "le Destin est rendu tel quel")
	assert_true(Equipement.apercu(d, rien, rien, 20, donnees).is_empty(), "sans changement, aucun exemple")
	var pv := Equipement.mods_vides()
	pv["pv"] = 0.2
	assert_true(Equipement.apercu(d, rien, pv, 20, donnees).is_empty(), "des PV max seuls : aucun chiffre de la roue ne change")


# Les fiches des nœuds comptent l'équipement : la Force partout, une ligne typée sur ses seuls effets ; en combat comme
# dans l'écran du Destin.
func test_fiches_avec_equipement() -> void:
	var nu := Generateur.generer("guerrier", 3, 30, Generateur.PAR_DEFAUT, donnees)
	var equipe := Generateur.generer("guerrier", 3, 30, Generateur.PAR_DEFAUT, donnees)
	equipe.mods = Equipement.mods_vides()
	equipe.mods["dot"] = 0.5
	# Entaille (voie 1, N1) : « 45 à un ennemi + 12×3 Saignement » : seul le Saignement grandit.
	var f0 := Texte.fiche_destin(nu, 0, 1, 30, donnees)
	var f1 := Texte.fiche_destin(equipe, 0, 1, 30, donnees)
	var l0: PackedStringArray = str(f0["ligne"]).split(" + ")
	var l1: PackedStringArray = str(f1["ligne"]).split(" + ")
	assert_eq(l1[0], l0[0], "les dégâts directs ne bougent pas avec une ligne DoT")
	assert_ne(l1[1], l0[1], "le Saignement grandit avec une ligne DoT")
	assert_eq(f1["pictos"][0]["texte"], f0["pictos"][0]["texte"], "pictogramme des dégâts : le même")
	assert_ne(f1["pictos"][1]["texte"], f0["pictos"][1]["texte"], "pictogramme du Saignement : plus grand")
	# En combat, la même ligne.
	var e := Regles.nouveau_combat(Trio.camp(equipe, 30, donnees), Trio.camp(nu, 30, donnees), 30, "pvp", donnees)
	assert_eq(Texte.ligne_en_combat(e, "a1", 0, 1), str(f1["ligne"]), "en combat, la ligne de la fiche du Destin")
	assert_eq(Texte.fiche(e, "a1", 0, 1, "a1", donnees)["ligne"], str(f1["ligne"]), "la fiche en combat aussi")
	# La Force grandit tout.
	var fort := Generateur.generer("guerrier", 3, 30, Generateur.PAR_DEFAUT, donnees)
	fort.mods = Equipement.mods_vides()
	fort.mods["force"] = 0.5
	var f2 := Texte.fiche_destin(fort, 0, 1, 30, donnees)
	var l2: PackedStringArray = str(f2["ligne"]).split(" + ")
	assert_ne(l2[0], l0[0], "la Force grandit les dégâts")
	assert_ne(l2[1], l0[1], "et le Saignement")
	assert_eq(Texte.fiche_destin(nu, 0, 1, 30, donnees)["ligne"], str(f0["ligne"]), "sans équipement, rien ne change")


# Le profil garde la Forge (objets portés, sac, Éclats, jour du revenu) et se relit ; un profil d'avant n'en a pas.
func test_profil_de_la_forge() -> void:
	var chemin_avant := PlayerProfile.chemin
	PlayerProfile.chemin = "user://test_forge_profil.cfg"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PlayerProfile.chemin))
	var vierge := PlayerProfile.load_profile()
	assert_true(vierge.portes.is_empty() and vierge.sac.is_empty() and vierge.eclats == 0 and vierge.revenu_jour == "", "un profil neuf : rien à la Forge")
	var p := PlayerProfile.new()
	var objet := Equipement.tirer("epee", "rare", 12, 4, donnees, false)
	p.portes["arme"] = Equipement.equiper(objet)
	p.sac.append(Equipement.tirer("robe", "commun", 3, 9, donnees))
	p.eclats = 42
	p.revenu_jour = "2026-10-29"
	p.save()
	var relu := PlayerProfile.load_profile()
	assert_eq(relu.portes.size(), 1, "un objet porté relu")
	assert_true(bool(relu.portes["arme"]["lie"]), "porté : lié")
	assert_eq(relu.portes["arme"]["lignes"], objet["lignes"], "ses lignes, à l'identique")
	assert_true(Equipement.valide(relu.portes["arme"], donnees), "l'objet relu est conforme")
	assert_eq(relu.sac.size(), 1, "le sac relu")
	assert_eq(relu.eclats, 42, "les Éclats relus")
	assert_eq(relu.revenu_jour, "2026-10-29", "le jour du revenu relu")
	assert_eq(Equipement.mods([relu.portes["arme"]], donnees), Equipement.mods([Equipement.equiper(objet)], donnees), "les mêmes bonus après relecture")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PlayerProfile.chemin))
	PlayerProfile.chemin = chemin_avant
