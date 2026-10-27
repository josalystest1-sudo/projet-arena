## L'IA de l'acolyte et du joueur IA : chaque posture donne le coup qu'un joueur qui la connaît devinerait.
extends "res://tests/test_case.gd"

const GM := ["guerrier", "mage"]


func announce(combat: Combat, posture: String, leader_action: CombatAction = null) -> Dictionary:
	return CombatAI.decide_acolyte(combat, combat.acolyte_of(0), posture, leader_action)


func assert_move(decision: Dictionary, skill: String, target: String, message: String) -> void:
	var chosen: CombatAction = decision["action"]
	assert_eq("%s → %s" % [chosen.skill_id, chosen.target_id], "%s → %s" % [skill, target], message)


# --- Libre : chacun joue son rôle ----------------------------------------------

func test_libre_un_front_te_protege_des_que_tu_as_perdu_des_pv() -> void:
	var combat := duo_combat(["mage", "guerrier"], GM, {"guerrier": {"moyenne": 1}})
	assert_eq(announce(combat, CombatAI.LIBRE)["action"].skill_id, "taillade", "tu as tous tes PV : il frappe")
	combat.get_unit("a1").hp = 160
	var decision := announce(combat, CombatAI.LIBRE)
	assert_move(decision, "rempart", "a1", "le Guerrier pose son Rempart sur toi")
	assert_eq(decision["rule"], "protege", "règle : il te protège")
	combat.get_unit("a1").add_status({"id": "rempart", "turns": 2, "value": 1})
	assert_move(announce(combat, CombatAI.LIBRE), "taillade", "b2", "Rempart déjà posé : il frappe l'ennemi le plus fragile")


func test_libre_un_front_provoque_puis_joue_sa_forte_puis_frappe_le_plus_bas() -> void:
	var combat := duo_combat(["mage", "guerrier"], ["guerrier", "pretre"])
	combat.get_unit("a1").hp = 160
	combat.get_unit("b2").hp = 150
	assert_move(announce(combat, CombatAI.LIBRE), "provocation", "b2", "Provocation sur l'ennemi le plus bas")
	jump_to_turn(combat, 3)
	combat.acolyte_of(0).cooldown_until["moyenne"] = 5
	assert_move(announce(combat, CombatAI.LIBRE), "fendoir", "b2", "moyenne en recharge : forte dès qu'elle est prête")
	combat.acolyte_of(0).cooldown_until["forte"] = 7
	combat.get_unit("b1").hp = 50
	assert_move(announce(combat, CombatAI.LIBRE), "taillade", "b1", "sinon la basique sur l'ennemi le plus bas (en % de PV)")


func test_libre_un_degats_frappe_le_plus_bas_forte_puis_moyenne_puis_basique() -> void:
	var combat := duo_combat(GM, GM)
	# Tour 1 : tout le monde à fond, à égalité c'est le plus fragile (le Mage, 175 PV).
	assert_move(announce(combat, CombatAI.LIBRE), "trait_de_givre", "b2", "moyenne sur l'ennemi le plus fragile")
	jump_to_turn(combat, 3)
	assert_eq(announce(combat, CombatAI.LIBRE)["action"].skill_id, "nova", "forte dès qu'elle est prête")
	combat.acolyte_of(0).cooldown_until = {"moyenne": 5, "forte": 7}
	combat.get_unit("b1").hp = 100
	assert_move(announce(combat, CombatAI.LIBRE), "boule_de_feu", "b1", "sinon la basique sur l'ennemi le plus bas")


func test_libre_un_degats_ne_te_secourt_que_sous_la_moitie_de_tes_pv() -> void:
	var combat := duo_combat(GM, GM, {"mage": {"forte": 1}})
	jump_to_turn(combat, 3)
	set_ratio(combat, "a1", 0.56)
	assert_eq(announce(combat, CombatAI.LIBRE)["action"].skill_id, "trait_de_givre", "à 56 % de PV, il attaque")
	set_ratio(combat, "a1", 0.44)
	var decision := announce(combat, CombatAI.LIBRE)
	assert_move(decision, "bouclier_de_mana", "a1", "sous 50 %, son Bouclier de mana va sur toi")
	assert_eq(decision["rule"], "secours", "règle : secours")


func test_libre_un_soutien_soigne_le_plus_blesse_sous_son_seuil() -> void:
	var combat := duo_combat(["mage", "pretre"], GM)
	var below := float(data.postures["thresholds"]["libre_heal_below"])
	set_ratio(combat, "a1", below + 0.05)
	assert_move(announce(combat, CombatAI.LIBRE), "chatiment", "b2", "au-dessus du seuil, il frappe le plus fragile")
	set_ratio(combat, "a1", below - 0.05)
	assert_move(announce(combat, CombatAI.LIBRE), "restauration", "a1", "sous le seuil : son plus gros soin, sur toi")
	set_ratio(combat, "a2", below - 0.2)
	assert_move(announce(combat, CombatAI.LIBRE), "restauration", "a1", "toi d'abord, même s'il est plus blessé que toi")
	set_ratio(combat, "a1", below + 0.05)
	assert_move(announce(combat, CombatAI.LIBRE), "restauration", "a2", "toi au-dessus du seuil : il se soigne lui-même")


func test_libre_un_soutien_joue_sa_forte_des_qu_elle_sert() -> void:
	var combat := duo_combat(["mage", "pretre"], GM)
	jump_to_turn(combat, 3)
	assert_eq(announce(combat, CombatAI.LIBRE)["action"].skill_id, "chatiment", "personne n'a perdu de PV : il garde son Égide")
	set_ratio(combat, "a1", 0.9)
	var decision := announce(combat, CombatAI.LIBRE)
	assert_eq(decision["action"].skill_id, "egide", "tu as perdu des PV : Égide dès qu'elle est prête")
	assert_eq(decision["rule"], "forte", "règle : forte prête")


# --- Front : Tiens la ligne, Cogne ---------------------------------------------

func test_tiens_la_ligne_rempart_sur_toi_meme_a_fond_de_pv() -> void:
	var combat := duo_combat(["mage", "guerrier"], GM, {"guerrier": {"moyenne": 1}})
	var decision := announce(combat, CombatAI.TIENS_LA_LIGNE)
	assert_move(decision, "rempart", "a1", "Rempart sur toi, même à fond de PV")
	assert_eq(decision["rule"], "tiens", "règle : il tient la ligne")
	assert_eq(announce(combat, CombatAI.LIBRE)["action"].skill_id, "taillade", "en Libre, à fond de PV, il frappe")


func test_tiens_la_ligne_provoque_et_riposte_sur_celui_qui_t_a_fait_le_plus_mal() -> void:
	var combat := duo_combat(["mage", "guerrier"], GM)
	combat.resolve_turn([action("a2", "taillade", "b2"), action("b1", "taillade", "a1"), action("b2", "boule_de_feu", "a2")])
	combat.resolve_turn([action("a2", "taillade", "b2"), action("b1", "taillade", "a1"), action("b2", "boule_de_feu", "a2")])
	heal_all(combat)
	combat.resolve_turn([action("a2", "taillade", "b2"), action("b1", "taillade", "a2"), action("b2", "boule_de_feu", "a1")])
	assert_eq(combat.get_unit("a1").last_hit_by, "b2", "le dernier à t'avoir frappé : le Mage")
	assert_true(int(combat.get_unit("a1").damage_taken_from["b1"]) > int(combat.get_unit("a1").damage_taken_from["b2"]), "mais le Guerrier t'a fait plus mal")
	heal_all(combat)
	combat.get_unit("b2").hp = 40
	assert_move(announce(combat, CombatAI.TIENS_LA_LIGNE), "provocation", "b1", "Provocation sur celui qui t'a fait le plus mal")
	combat.acolyte_of(0).cooldown_until["moyenne"] = combat.turn + 2
	var decision := announce(combat, CombatAI.TIENS_LA_LIGNE)
	assert_move(decision, "fendoir", "b1", "Provocation en recharge : sa forte sur le même, pas sur l'ennemi le plus bas")
	assert_eq(decision["rule"], "riposte", "règle : riposte")
	combat.acolyte_of(0).cooldown_until["forte"] = combat.turn + 4
	assert_move(announce(combat, CombatAI.TIENS_LA_LIGNE), "taillade", "b1", "forte en recharge : sa basique, toujours sur lui")


func test_cogne_ses_coups_avant_ses_protections() -> void:
	var combat := duo_combat(["mage", "guerrier"], GM, {"guerrier": {"moyenne": 1}})
	var protect_below := float(data.postures["thresholds"]["cogne_protect_below"])
	set_ratio(combat, "a1", protect_below + 0.05)
	assert_eq(announce(combat, CombatAI.LIBRE)["action"].skill_id, "rempart", "en Libre, tu as perdu des PV : il te protège")
	var decision := announce(combat, CombatAI.COGNE)
	assert_move(decision, "taillade", "b2", "en Cogne, il frappe l'ennemi le plus fragile")
	assert_eq(decision["rule"], "cogne", "règle : cogne")
	jump_to_turn(combat, 3)
	assert_eq(announce(combat, CombatAI.COGNE)["action"].skill_id, "fendoir", "forte dès qu'elle est prête")
	set_ratio(combat, "a1", protect_below - 0.05)
	var urgent := announce(combat, CombatAI.COGNE)
	assert_move(urgent, "rempart", "a1", "sous son seuil : son Rempart sur toi")
	assert_eq(urgent["rule"], "urgence", "règle : urgence")


func test_cogne_une_provocation_compte_comme_un_coup() -> void:
	var combat := duo_combat(["mage", "guerrier"], GM)
	var decision := announce(combat, CombatAI.COGNE)
	assert_move(decision, "provocation", "b2", "la Provocation frappe : en Cogne, c'est un coup, sur l'ennemi le plus fragile")
	assert_eq(decision["rule"], "cogne", "règle : cogne")


# --- Dégâts : Même cible que moi, Achève ------------------------------------------

func test_meme_cible_suit_ta_cible() -> void:
	var combat := duo_combat(GM, GM)
	combat.get_unit("b2").hp = 30
	assert_eq(announce(combat, CombatAI.LIBRE, action("a1", "taillade", "b1"))["action"].target_id, "b2", "en Libre, l'ennemi le plus bas")
	var decision := announce(combat, CombatAI.MEME_CIBLE, action("a1", "taillade", "b1"))
	assert_move(decision, "trait_de_givre", "b1", "il frappe ta cible, même si une autre est plus basse")
	assert_eq(decision["rule"], "meme_cible", "règle : même cible")
	assert_eq(announce(combat, CombatAI.MEME_CIBLE, action("a1", "taillade", "b2"))["action"].target_id, "b2", "tu changes de cible, il suit")
	combat.get_unit("a1").last_target = "b1"
	assert_eq(announce(combat, CombatAI.MEME_CIBLE)["action"].target_id, "b1", "sans choix : ta cible du tour précédent")


func test_meme_cible_garde_le_secours_de_libre() -> void:
	var combat := duo_combat(GM, GM, {"mage": {"forte": 1}})
	jump_to_turn(combat, 3)
	set_ratio(combat, "a1", 0.44)
	assert_move(announce(combat, CombatAI.MEME_CIBLE, action("a1", "taillade", "b1")), "bouclier_de_mana", "a1", "sous 50 %, il te secourt comme en Libre")


func test_acheve_vise_l_ennemi_le_plus_proche_du_ko() -> void:
	var combat := duo_combat(GM, GM)
	set_ratio(combat, "b1", 0.4)
	set_ratio(combat, "b2", 0.5)
	assert_true(combat.get_unit("b2").hp < combat.get_unit("b1").hp, "le Mage a moins de PV restants, mais un plus haut pourcentage")
	assert_eq(announce(combat, CombatAI.LIBRE)["action"].target_id, "b1", "Libre : le plus bas en pourcentage")
	var decision := announce(combat, CombatAI.ACHEVE, action("a1", "taillade", "b1"))
	assert_move(decision, "trait_de_givre", "b2", "Achève : le moins de PV restants, même si tu vises l'autre")
	assert_eq(decision["rule"], "acheve", "règle : achève")
	combat.get_unit("b2").add_status({"id": "barriere", "turns": 2, "value": combat.get_unit("b1").hp})
	assert_eq(announce(combat, CombatAI.ACHEVE)["action"].target_id, "b1", "une barrière compte : l'autre est plus proche du KO")


func test_acheve_garde_le_secours_de_libre() -> void:
	var combat := duo_combat(GM, GM, {"mage": {"forte": 1}})
	jump_to_turn(combat, 3)
	set_ratio(combat, "a1", 0.3)
	assert_move(announce(combat, CombatAI.ACHEVE), "bouclier_de_mana", "a1", "sous 50 %, il te secourt comme en Libre : seule la cible change")


# --- Soutien : Soigne d'abord, Affaiblis-les --------------------------------------

func test_soigne_d_abord_te_soigne_plus_tot_que_libre() -> void:
	var combat := duo_combat(["mage", "pretre"], GM)
	var libre_below := float(data.postures["thresholds"]["libre_heal_below"])
	var first_below := float(data.postures["thresholds"]["heal_first_below"])
	assert_true(first_below > libre_below + 0.05, "Soigne d'abord soigne plus tôt que Libre")
	set_ratio(combat, "a1", (libre_below + first_below) / 2.0)
	assert_eq(announce(combat, CombatAI.LIBRE)["action"].skill_id, "chatiment", "en Libre, au-dessus de son seuil, il frappe")
	var decision := announce(combat, CombatAI.SOIGNE_D_ABORD)
	assert_move(decision, "restauration", "a1", "sous le seuil de Soigne d'abord : son plus gros soin sur toi")
	assert_eq(decision["rule"], "soin_toi", "règle : il te soigne")
	set_ratio(combat, "a1", first_below + 0.05)
	assert_eq(announce(combat, CombatAI.SOIGNE_D_ABORD)["action"].skill_id, "chatiment", "au-dessus : comme en Libre")


func test_soigne_d_abord_toi_avant_lui() -> void:
	var combat := duo_combat(["mage", "pretre"], GM)
	set_ratio(combat, "a1", float(data.postures["thresholds"]["heal_first_below"]) - 0.05)
	set_ratio(combat, "a2", 0.3)
	assert_move(announce(combat, CombatAI.LIBRE), "restauration", "a2", "en Libre, le plus blessé : lui")
	assert_move(announce(combat, CombatAI.SOIGNE_D_ABORD), "restauration", "a1", "en Soigne d'abord : toi")


func test_affaiblis_les_un_pretre_joue_libre_sur_ta_cible() -> void:
	var combat := duo_combat(["mage", "pretre"], GM)
	combat.get_unit("b2").hp = 60
	assert_move(announce(combat, CombatAI.LIBRE), "chatiment", "b2", "en Libre, il frappe l'ennemi le plus bas")
	var decision := announce(combat, CombatAI.AFFAIBLIS, action("a1", "boule_de_feu", "b1"))
	assert_move(decision, "chatiment", "b1", "le Prêtre n'a ni affaiblissement ni contrôle : Libre, sur ta cible")
	assert_eq(decision["rule"], "affaiblit_coups", "règle : il frappe ta cible")
	set_ratio(combat, "a1", 0.45)
	assert_move(announce(combat, CombatAI.AFFAIBLIS, action("a1", "boule_de_feu", "b1")), "restauration", "a1", "il soigne comme en Libre")


func test_affaiblis_les_ses_affaiblissements_d_abord() -> void:
	# Un Mage n'est pas Soutien ; on vérifie la règle sur un Soutien fictif qui aurait Trait de givre (il fait agir en dernier).
	var combat := duo_combat(["guerrier", "pretre"], GM)
	var acolyte := combat.acolyte_of(0)
	acolyte.skills["moyenne"] = "trait_de_givre"
	var decision := announce(combat, CombatAI.AFFAIBLIS, action("a1", "taillade", "b1"))
	assert_move(decision, "trait_de_givre", "b1", "son contrôle d'abord, sur ta cible")
	assert_eq(decision["rule"], "affaiblit", "règle : affaiblit")


func test_affaiblis_les_sans_attaque_joue_comme_en_libre() -> void:
	var combat := duo_combat(["mage", "pretre"], GM, {"pretre": {"basique": 1}})
	set_ratio(combat, "a1", 0.4)
	assert_move(announce(combat, CombatAI.AFFAIBLIS, action("a1", "boule_de_feu", "b1")), "restauration", "a1", "Prière, Restauration : il te soigne comme en Libre")


func test_ce_qui_affaiblit_ou_controle() -> void:
	for skill_id in ["coup_de_bouclier", "trait_de_givre", "fendoir"]:
		assert_true(CombatAI.weakens(data, skill_id), skill_id + " affaiblit ou contrôle")
	for skill_id in ["chatiment", "taillade", "cri_de_guerre", "provocation", "priere"]:
		assert_false(CombatAI.weakens(data, skill_id), skill_id + " n'affaiblit pas")


# --- Garde ta forte : sa forte part avec la tienne ------------------------------

func test_garde_ta_forte_attend_la_tienne() -> void:
	var combat := duo_combat(GM, GM)
	jump_to_turn(combat, 3)
	var held := announce(combat, CombatAI.GARDE_TA_FORTE, action("a1", "taillade", "b1"))
	assert_eq(held["action"].skill_id, "trait_de_givre", "tu ne joues pas ta forte : il garde la sienne")
	assert_true(held["held_forte"], "il signale qu'il garde une forte prête")
	var together := announce(combat, CombatAI.GARDE_TA_FORTE, action("a1", "fendoir", "b1"))
	assert_move(together, "nova", "b1", "tu joues ta forte : la sienne part avec")
	assert_eq(together["rule"], "avec_toi", "règle : forte avec la tienne")


func test_garde_ta_forte_part_aussi_sur_une_synergie() -> void:
	var combat := duo_combat(GM, GM)
	jump_to_turn(combat, 3)
	var decision := announce(combat, CombatAI.GARDE_TA_FORTE, action("a1", "provocation", "b2"))
	assert_eq(decision["action"].skill_id, "nova", "Provocation + Nova : Piège de feu, la Nova part")


# --- Règles communes et prévisibilité ----------------------------------------

func test_toutes_les_postures_relevent_un_allie_ko() -> void:
	var combat := duo_combat(["mage", "pretre"], GM, {"pretre": {"forte": 1}})
	jump_to_turn(combat, 3)
	combat.get_unit("a1").hp = 0
	for posture in CombatAI.postures_for(data, "pretre"):
		var decision := announce(combat, posture)
		assert_move(decision, "resurrection", "a1", posture + " : il te relève")
		assert_eq(decision["rule"], "releve", posture + " : règle relève")


func test_les_postures_dependent_du_role() -> void:
	assert_eq(CombatAI.postures_for(data, "guerrier"), [CombatAI.LIBRE, CombatAI.TIENS_LA_LIGNE, CombatAI.COGNE, CombatAI.GARDE_TA_FORTE], "Front")
	assert_eq(CombatAI.postures_for(data, "mage"), [CombatAI.LIBRE, CombatAI.MEME_CIBLE, CombatAI.ACHEVE, CombatAI.GARDE_TA_FORTE], "Dégâts")
	assert_eq(CombatAI.postures_for(data, "pretre"), [CombatAI.LIBRE, CombatAI.SOIGNE_D_ABORD, CombatAI.AFFAIBLIS, CombatAI.GARDE_TA_FORTE], "Soutien")
	for posture in [CombatAI.TIENS_LA_LIGNE, CombatAI.COGNE, CombatAI.MEME_CIBLE, CombatAI.ACHEVE, CombatAI.SOIGNE_D_ABORD, CombatAI.AFFAIBLIS]:
		assert_true(data.postures["postures"].has(posture), posture + " : textes dans les données")


func test_les_textes_des_postures_sont_remplis() -> void:
	for class_id in data.classes:
		for posture in CombatAI.postures_for(data, class_id):
			var text := data.posture_description(posture, class_id)
			assert_true(text.length() > 20, "%s / %s : un texte" % [class_id, posture])
			assert_false(text.contains("{"), "%s / %s : seuils remplis (%s)" % [class_id, posture, text])
	assert_true(data.posture_description(CombatAI.LIBRE, "pretre").contains("%d %%" % int(round(100 * float(data.postures["thresholds"]["libre_heal_below"])))), "le seuil de soin de Libre vient des données")


func test_une_posture_d_un_autre_role_compte_comme_libre() -> void:
	var combat := duo_combat(GM, GM)
	set_ratio(combat, "a1", 0.6)
	assert_eq(announce(combat, CombatAI.TIENS_LA_LIGNE)["action"].to_dict(), announce(combat, CombatAI.LIBRE)["action"].to_dict(), "un Mage n'a pas « Tiens la ligne » : il joue Libre")


func test_l_annonce_ne_depend_pas_de_ton_choix_sauf_quand_il_suit_ta_cible_ou_ta_forte() -> void:
	# L'acolyte annonce en premier : ton choix ne change son coup que dans les postures qui suivent ta cible
	# (Même cible que moi, Affaiblis-les) ou ta forte (Garde ta forte).
	var reacting := [CombatAI.MEME_CIBLE, CombatAI.AFFAIBLIS, CombatAI.GARDE_TA_FORTE]
	var rng := RandomNumberGenerator.new()
	rng.seed = 21
	var checked := 0
	for i in range(30):
		var combat := Combat.create(data, Duo.random_duo(data, rng), Duo.random_duo(data, rng))
		jump_to_turn(combat, 1 + i % 5)
		for unit in combat.units:
			unit.hp = maxi(1, int(unit.max_hp * rng.randf_range(0.2, 1.0)))
		var leader := combat.leader_of(0)
		for posture in CombatAI.postures_for(data, combat.acolyte_of(0).class_id):
			if reacting.has(posture):
				continue
			var alone: CombatAction = announce(combat, posture)["action"]
			for tier in CombatUnit.TIERS:
				if not combat.can_use(leader, tier):
					continue
				for target in combat.valid_targets(leader, leader.skills[tier]):
					var answer: CombatAction = announce(combat, posture, action(leader.id, leader.skills[tier], target.id))["action"]
					assert_eq(answer.to_dict(), alone.to_dict(), "%s : l'annonce ne bouge pas" % posture)
					checked += 1
	assert_true(checked > 100, "assez de situations vérifiées")


func test_meme_situation_meme_coup() -> void:
	for classes in [["pretre", "guerrier"], ["guerrier", "mage"], ["mage", "pretre"]]:
		var combat := duo_combat(classes, GM)
		for posture in CombatAI.postures_for(data, classes[1]):
			assert_eq(announce(combat, posture)["action"].to_dict(), announce(combat, posture)["action"].to_dict(), posture)


# --- Le joueur IA d'en face ----------------------------------------------------

func test_le_joueur_ia_construit_la_synergie_annoncee_par_son_acolyte() -> void:
	var combat := duo_combat(["pretre", "mage"], GM)
	var decision := CombatAI.decide_leader(combat, combat.get_unit("a1"), action("a2", "trait_de_givre", "b1"))
	assert_move(decision, "chatiment", "b1", "Trait de givre annoncé sur b1 : Châtiment sur b1 (Éclat)")
	assert_eq(decision["rule"], "synergie", "règle : synergie")


func test_le_joueur_ia_frappe_la_cible_de_son_acolyte() -> void:
	var combat := duo_combat(GM, GM)
	combat.get_unit("a1").cooldown_until["moyenne"] = 3
	combat.get_unit("b2").hp = 30
	var decision := CombatAI.decide_leader(combat, combat.get_unit("a1"), action("a2", "boule_de_feu", "b1"))
	assert_move(decision, "taillade", "b1", "il concentre sur la cible de son acolyte")


func test_le_joueur_ia_choisit_la_posture_de_son_acolyte() -> void:
	var front := duo_combat(GM, ["mage", "guerrier"])
	assert_eq(CombatAI.choose_posture(front, 1), CombatAI.LIBRE, "par défaut : Libre")
	set_ratio(front, "a2", 0.3)
	assert_eq(CombatAI.choose_posture(front, 1), CombatAI.COGNE, "un adversaire sous 35 % : son Guerrier cogne")
	set_ratio(front, "b1", 0.3)
	assert_eq(CombatAI.choose_posture(front, 1), CombatAI.TIENS_LA_LIGNE, "lui-même sous 40 % : son Guerrier tient la ligne")
	var support := duo_combat(GM, ["mage", "pretre"])
	set_ratio(support, "a2", 0.3)
	assert_eq(CombatAI.choose_posture(support, 1), CombatAI.AFFAIBLIS, "un adversaire sous 35 % : son Prêtre l'affaiblit")
	set_ratio(support, "b1", 0.3)
	assert_eq(CombatAI.choose_posture(support, 1), CombatAI.SOIGNE_D_ABORD, "lui-même sous 40 % : son Prêtre le soigne d'abord")
	var damage := duo_combat(GM, GM)
	set_ratio(damage, "a2", 0.3)
	set_ratio(damage, "b1", 0.3)
	assert_eq(CombatAI.choose_posture(damage, 1), CombatAI.ACHEVE, "un Mage n'a pas de posture qui protège : il achève")
	heal_all(damage)
	jump_to_turn(damage, 3)
	damage.get_unit("b1").cooldown_until["forte"] = 4
	assert_eq(CombatAI.choose_posture(damage, 1), CombatAI.GARDE_TA_FORTE, "sa forte revient au prochain tour : l'acolyte garde la sienne")


# --- Pour l'écran : les Synergies possibles -------------------------------------

func test_synergies_possibles_suivent_l_annonce_et_la_cible() -> void:
	var combat := duo_combat(["pretre", "mage"], GM)
	# L'acolyte Mage annonce Trait de givre sur le Mage adverse (le plus fragile).
	var options := CombatAI.synergy_options(combat, combat.get_unit("a1"), combat.get_unit("a2"), CombatAI.LIBRE)
	assert_eq(options.size(), 1, "une seule Synergie possible")
	if options.size() == 1:
		assert_eq(options[0]["skill_id"], "chatiment", "avec ton Châtiment")
		assert_eq(options[0]["synergy"]["name"], "Éclat", "Éclat")
		assert_eq(options[0]["targets"], ["b2"], "seulement sur la cible de l'acolyte")


func test_la_posture_change_les_synergies_possibles() -> void:
	var combat := duo_combat(GM, GM, {"guerrier": {"forte": 1}, "mage": {"forte": 1}})
	jump_to_turn(combat, 3)
	var leader := combat.get_unit("a1")
	var acolyte := combat.get_unit("a2")
	assert_true(CombatAI.synergy_options(combat, leader, acolyte, CombatAI.LIBRE).is_empty(), "en Libre, il ne joue pas son Bouclier : pas de Synergie")
	var options := CombatAI.synergy_options(combat, leader, acolyte, CombatAI.GARDE_TA_FORTE)
	assert_eq(options.size(), 1, "en Garde ta forte, une Synergie apparaît")
	if options.size() == 1:
		assert_eq(options[0]["tier"], "forte", "sur ta forte")
		assert_eq(options[0]["synergy"]["name"], "Forteresse", "Forteresse")


# --- Combats complets -----------------------------------------------------------

func test_combats_ia_contre_ia_se_terminent() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 2026
	var wins := {0: 0, 1: 0}
	var turns_total := 0
	var synergies := 0
	var postures := {}
	for i in range(30):
		var combat := Combat.create(data, Duo.random_duo(data, rng), Duo.random_duo(data, rng), i % 2)
		while not combat.finished:
			var plan_a := CombatAI.plan_team(combat, 0)
			var plan_b := CombatAI.plan_team(combat, 1)
			postures[plan_a["posture"]] = true
			var actions: Array = plan_a["actions"]
			actions.append_array(plan_b["actions"])
			assert_eq(actions.size(), combat.team_units(0, true).size() + combat.team_units(1, true).size(), "une Intention par perso debout")
			var events := combat.resolve_turn(actions)
			synergies += events_of_type(events, "synergy").size()
			assert_true(combat.turn <= combat.forced_end_turn + 1, "jamais au-delà du tour de fin forcée")
		wins[combat.winner] += 1
		turns_total += combat.turn
	assert_eq(wins[0] + wins[1], 30, "30 vainqueurs")
	assert_true(synergies > 0, "des Synergies se déclenchent en IA contre IA")
	assert_true(postures.size() >= 4, "plusieurs postures servent")
	assert_between(float(turns_total) / 30.0, 5.0, 15.0, "durée moyenne des combats (tours)")
	print("    (IA vs IA : %d / %d victoires, %.1f tours en moyenne, %d synergies)" % [wins[0], wins[1], float(turns_total) / 30.0, synergies])


func test_un_groupe_sans_acolyte_joue_aussi() -> void:
	# Les ennemis de la Tour : 3 persos sans acolyte, chacun joue son rôle en concentrant la même cible.
	var combat := Combat.create(data, duo_team(GM), [member("guerrier"), member("mage"), member("pretre")])
	var plan := CombatAI.plan_team(combat, 1)
	assert_eq(plan["actions"].size(), 3, "une Intention par ennemi")
	var targets := {}
	for chosen in plan["actions"]:
		if combat.is_hostile(chosen.skill_id):
			targets[chosen.target_id] = true
	assert_eq(targets.size(), 1, "ils concentrent la même cible")
	var guard := 0
	while not combat.finished and guard < 20:
		var actions: Array = CombatAI.choose_team(combat, 0)
		actions.append_array(CombatAI.choose_team(combat, 1))
		combat.resolve_turn(actions)
		guard += 1
	assert_true(combat.finished, "le combat 2 contre 3 se termine")
