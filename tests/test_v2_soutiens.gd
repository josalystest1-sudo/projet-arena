## Les Soutiens presque sans dégâts (décision de Gautier du 29 octobre au soir ; docs/PLAN.md, PR 1.3) : une seule voie
## de dégâts par Soutien, et toujours au moins deux actions utiles quand personne n'est blessé.
extends "res://tests/test_case.gd"

## Ce qui sert même quand toute l'équipe a ses PV (un soin, une Purge sans rien à retirer, un Gardien : rien).
const UTILES := ["degats", "dot", "barriere", "renfort", "affaiblissement", "etat", "egare", "dissipe"]


func _soutiens() -> Array[String]:
	return Trio.classes_du_role("soutien", donnees)


# Une seule voie de dégâts (dégâts directs ou sur la durée) par Soutien ; le moyeu, le geste de la classe, n'en est pas une.
func test_une_seule_voie_de_degats() -> void:
	for classe in _soutiens():
		var voies: Array[String] = []
		for voie in donnees.classe(classe)["voies"]:
			for n in voie["noeuds"]:
				var frappe := false
				for ef in n["effets"]:
					frappe = frappe or ef["type"] in ["degats", "dot"]
				if frappe:
					voies.append(str(voie["id"]))
					break
		assert_eq(voies.size(), 1, "%s : une seule voie de dégâts (%s)" % [classe, ", ".join(voies)])


# Toute l'équipe à PV pleins, dès le premier tour, à tous les niveaux : au moins deux actions utiles, que l'IA joue.
func test_toujours_deux_actions_utiles() -> void:
	for classe in _soutiens():
		for niveau in [1, 10, 30]:
			var joueur := Generateur.generer(classe, 7, niveau)
			var e := combat(Trio.camp(joueur, niveau, donnees), Trio.camp(Generateur.generer("guerrier", 8, niveau), niveau, donnees), niveau)
			var utiles := 0
			for a in Regles.actions_legales(e, "a1"):
				for ef in Regles.noeud_de(e, a)["effets"]:
					if ef["type"] in UTILES:
						utiles += 1
						break
			assert_true(utiles >= 2, "%s, niveau %d, PV pleins : %d actions utiles" % [classe, niveau, utiles])
			var choix := IA.choisir(e, "a1")
			var utile := false
			for ef in Regles.noeud_de(e, choix)["effets"]:
				utile = utile or ef["type"] in UTILES
			assert_true(utile, "%s, niveau %d : l'IA joue une action utile (%s)" % [classe, niveau, Regles.noeud_de(e, choix)["nom"]])
