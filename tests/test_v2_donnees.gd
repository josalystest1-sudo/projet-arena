## Combat V2 : les données et le budget (docs/SPEC-COMBAT-V2.md, section 14, tests 1 à 4).
extends "res://tests/test_case.gd"

## La colonne « Posé par » de la table 6 : les classes qui posent chaque état.
const POSE_PAR := {
	"etourdi": ["mage", "voleur", "archer", "alchimiste", "invocateur", "barde", "diplomate", "pugiliste"],
	"gele": ["guerrier", "mage", "voleur", "alchimiste", "invocateur", "barde"],
	"silencie": ["mage", "pretre", "barde", "diplomate", "pugiliste"],
	"enracine": ["guerrier", "mage", "voleur", "archer", "invocateur", "pugiliste"],
	"aveugle": ["voleur", "archer", "alchimiste"],
	"desarme": ["guerrier", "voleur", "alchimiste", "barde", "diplomate", "pugiliste"],
	"provoque": ["guerrier", "diplomate", "pugiliste"],
	"egare": ["mage", "voleur", "alchimiste", "barde", "diplomate", "pugiliste"],
	"saignement": ["guerrier", "voleur", "invocateur"],
	"brulure": ["mage", "archer"],
	"poison": ["voleur", "alchimiste"],
	"familier": ["invocateur"],
	"gardien": ["invocateur"],
	"barriere": ["guerrier", "mage", "voleur", "archer", "pretre", "alchimiste", "invocateur", "diplomate", "pugiliste"],
	"renfort": ["guerrier", "mage", "archer", "pretre", "alchimiste", "invocateur", "barde", "diplomate", "pugiliste"],
	"affaiblissement": ["archer", "pretre", "alchimiste", "barde", "diplomate"],
}

# 1. Chaque classe a 5 voies de 4 nœuds (rangs 1 à 4, dans l'ordre) et un moyeu ; les 3 premières sont celles de l'acolyte.
func test_01_chaque_classe_a_cinq_voies_de_quatre_noeuds_et_un_moyeu() -> void:
	assert_eq(donnees.ordre_classes.size(), 10, "dix classes")
	for id in donnees.ordre_classes:
		var cls := donnees.classe(id)
		assert_false(cls.get("moyeu", {}).get("effets", []).is_empty(), id + " : un moyeu avec des effets")
		assert_eq(cls.get("voies", []).size(), 5, id + " : 5 voies")
		var ids := {}
		for v in range(cls.get("voies", []).size()):
			var voie: Dictionary = cls["voies"][v]
			ids[voie["id"]] = true
			assert_eq(voie["acolyte"], v < 3, "%s : la voie %d est-elle celle de l'acolyte" % [id, v + 1])
			assert_eq(voie["noeuds"].size(), 4, "%s %s : 4 nœuds" % [id, voie["id"]])
			for r in range(voie["noeuds"].size()):
				assert_eq(int(voie["noeuds"][r]["rang"]), r + 1, "%s %s : rang du nœud %d" % [id, voie["id"], r + 1])
		assert_eq(ids.size(), 5, id + " : 5 voies d'identifiants différents")
		assert_true(donnees.classes.has(str(cls.get("acolyte", ""))), id + " : classe de l'acolyte connue")


# 2. tools/budget.gd passe : chaque nœud des dix classes est dans ±6 % du budget de son rang.
func test_02_tous_les_noeuds_sont_dans_leur_budget() -> void:
	for f in Budget.fautes(donnees):
		failures.append("%s · %s · rang %d · %s : %s" % [f["classe"], f["voie"], f["rang"], f["nom"], f["faute"]])


func test_02_grille_des_couts() -> void:
	var r := donnees.regles
	assert_almost(Budget.cout_effet(r, {"type": "degats", "valeur": 54, "cible": "tous_les_ennemis"}), 70.2, "dégâts à tous ×1,3")
	assert_almost(Budget.cout_effet(r, {"type": "dot", "sous_type": "saignement", "par_tour": 12, "tours": 3, "cible": "un_ennemi"}), 25.2, "DoT sur le total")
	assert_almost(Budget.cout_effet(r, {"type": "etat", "nom": "silencie", "tours": 2, "cible": "un_ennemi"}), 90.0, "état par tour")
	assert_almost(Budget.cout_effet(r, {"type": "purge", "cible": "duo"}), 100.0, "Purge duo = 100")
	assert_almost(Budget.cout_effet(r, {"type": "egare", "cible": "tous_les_ennemis"}), 78.0, "Égaré à tous ×1,3")
	# Hémorragie (Guerrier, voie du Sang, N3) : 140,92 pour un budget de 140.
	assert_almost(Budget.cout(r, donnees.noeud("guerrier", 0, 3)), 140.92, "coût d'Hémorragie")
	var hors := {"rang": 2, "nom": "Essai", "genre": "m", "effets": [{"type": "degats", "valeur": 107, "cible": "un_ennemi"}]}
	assert_ne(Budget.faute(r, hors), "", "107 pour un budget de 100 : hors des ±6 %")
	hors["budget_override"] = 108
	assert_eq(Budget.faute(r, hors), "", "budget_override de 108 : accepté")
	hors["budget_override"] = 111
	assert_ne(Budget.faute(r, hors), "", "budget_override à plus de 10 % du rang : refusé")


# 3. Toutes les clés des fichiers JSON sont connues.
func test_03_toutes_les_cles_json_sont_connues() -> void:
	for erreur in donnees.erreurs:
		failures.append(erreur)
	var cls: Dictionary = donnees.classe("mage").duplicate(true)
	cls["vitesse"] = 8
	cls["voies"][0]["noeuds"][0]["effets"][0]["critique"] = 0.1
	var erreurs := Donnees.valider_classe(cls, "mage")
	assert_eq(erreurs.size(), 2, "une clé inconnue dans la classe et une dans un effet sont signalées (%s)" % str(erreurs))


# 4. Chaque état de la table 6 est posé par au moins 2 classes (Familier et Gardien, les invocations, par l'Invocateur seul).
func test_04_chaque_etat_est_pose_par_au_moins_deux_classes() -> void:
	var poseurs := {}
	for id in donnees.ordre_classes:
		var cls := donnees.classe(id)
		var noeuds: Array = [cls["moyeu"]]
		for voie in cls["voies"]:
			noeuds.append_array(voie["noeuds"])
		for n in noeuds:
			for effet in n["effets"]:
				var etat := _etat_pose(effet)
				if etat != "":
					if not poseurs.has(etat):
						poseurs[etat] = []
					if not id in poseurs[etat]:
						poseurs[etat].append(id)
	for etat in Donnees.ETATS:
		var attendu: Array = POSE_PAR[etat].duplicate()
		var obtenu: Array = poseurs.get(etat, []).duplicate()
		attendu.sort()
		obtenu.sort()
		assert_eq(obtenu, attendu, "classes qui posent « %s » (table 6)" % etat)
		if not etat in ["familier", "gardien"]:
			assert_true(obtenu.size() >= 2, etat + " : posé par au moins 2 classes")


func _etat_pose(effet: Dictionary) -> String:
	match str(effet["type"]):
		"etat":
			return str(effet["nom"])
		"dot":
			return str(effet["sous_type"])
		"gardien", "barriere", "renfort", "affaiblissement", "egare":
			return str(effet["type"])
	return ""
