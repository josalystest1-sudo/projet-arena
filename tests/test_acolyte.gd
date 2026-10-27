## L'IA de l'acolyte et du joueur IA : chaque posture donne le coup qu'un joueur qui la connaît devinerait.
extends "res://tests/test_case.gd"

const GM := ["guerrier", "mage"]


func announce(combat: Combat, posture: String, leader_action: CombatAction = null) -> Dictionary:
	return CombatAI.decide_acolyte(combat, combat.acolyte_of(0), posture, leader_action)


func assert_move(decision: Dictionary, skill: String, target: String, message: String) -> void:
	var chosen: CombatAction = decision["action"]
	assert_eq("%s → %s" % [chosen.skill_id, chosen.target_id], "%s → %s" % [skill, target], message)


# --- Libre : chacun joue son rôle ----------------------------------------------

func test_libre_un_front_te_protege_des_que_possible() -> void:
	var combat := duo_combat(["mage", "guerrier"], GM, {"guerrier": {"moyenne": 1}})
	var decision := announce(combat, CombatAI.LIBRE)
	assert_move(decision, "rempart", "a1", "le Guerrier pose son Rempart sur toi")
	assert_eq(decision["rule"], "protege", "règle : il te protège")
	combat.get_unit("a1").add_status({"id": "rempart", "turns": 2, "value": 1})
	assert_move(announce(combat, CombatAI.LIBRE), "taillade", "b2", "Rempart déjà posé : il frappe l'ennemi le plus fragile")


func test_libre_un_front_provoque_puis_joue_sa_forte_puis_frappe_le_plus_bas() -> void:
	var combat := duo_combat(["mage", "guerrier"], ["guerrier", "pretre"])
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
	combat.get_unit("a1").hp = 140
	assert_eq(announce(combat, CombatAI.LIBRE)["action"].skill_id, "trait_de_givre", "à 56 % de PV, il attaque")
	combat.get_unit("a1").hp = 110
	var decision := announce(combat, CombatAI.LIBRE)
	assert_move(decision, "bouclier_de_mana", "a1", "sous 50 %, son Bouclier de mana va sur toi")
	assert_eq(decision["rule"], "secours", "règle : secours")


func test_libre_un_soutien_soigne_le_plus_blesse_sous_la_moitie_des_pv() -> void:
	var combat := duo_combat(["mage", "pretre"], GM)
	combat.get_unit("a1").hp = 105
	assert_move(announce(combat, CombatAI.LIBRE), "chatiment", "b2", "au-dessus de 50 %, il frappe le plus fragile")
	combat.get_unit("a1").hp = 80
	assert_move(announce(combat, CombatAI.LIBRE), "restauration", "a1", "sous 50 % : son plus gros soin, sur toi")
	combat.get_unit("a2").hp = 60
	assert_move(announce(combat, CombatAI.LIBRE), "restauration", "a2", "il soigne le plus blessé des deux, lui compris")


func test_libre_un_soutien_joue_sa_forte_des_qu_elle_est_prete() -> void:
	var combat := duo_combat(["mage", "pretre"], GM)
	jump_to_turn(combat, 3)
	var decision := announce(combat, CombatAI.LIBRE)
	assert_eq(decision["action"].skill_id, "egide", "Égide dès le tour 3")
	assert_eq(decision["rule"], "forte", "règle : forte prête")


# --- Protège-moi : tout pour ta survie ----------------------------------------

func test_protege_moi_protections_puis_soins_sur_toi() -> void:
	var combat := duo_combat(["mage", "pretre"], GM)
	combat.get_unit("a1").hp = 122
	var decision := announce(combat, CombatAI.PROTEGE_MOI)
	assert_move(decision, "restauration", "a1", "tu as perdu plus d'un quart de tes PV : il te soigne")
	assert_eq(decision["rule"], "soin_toi", "règle : il te soigne")
	combat.get_unit("a1").hp = 140
	assert_move(announce(combat, CombatAI.PROTEGE_MOI), "chatiment", "b2", "à 80 %, il riposte (personne ne t'a encore frappé : le plus fragile)")
	jump_to_turn(combat, 3)
	assert_eq(announce(combat, CombatAI.PROTEGE_MOI)["action"].skill_id, "egide", "sa forte protège : il la joue")


func test_protege_moi_riposte_sur_celui_qui_t_a_frappe() -> void:
	var combat := duo_combat(GM, GM)
	combat.resolve_turn([action("b1", "taillade", "a1"), action("b2", "boule_de_feu", "a2")])
	assert_eq(combat.get_unit("a1").last_hit_by, "b1", "le moteur retient qui t'a frappé")
	combat.get_unit("b2").hp = 40
	var decision := announce(combat, CombatAI.PROTEGE_MOI)
	assert_eq(decision["action"].target_id, "b1", "il frappe ton agresseur, pas l'ennemi le plus bas")
	assert_eq(decision["rule"], "riposte", "règle : riposte")
	assert_eq(announce(combat, CombatAI.LIBRE)["action"].target_id, "b2", "en Libre, il aurait frappé le plus bas")


func test_protege_moi_protege_d_abord_puis_frappe_avec_sa_forte() -> void:
	var combat := duo_combat(GM, GM, {"mage": {"forte": 1}})
	jump_to_turn(combat, 3)
	combat.get_unit("a1").last_hit_by = "b1"
	combat.get_unit("b2").hp = 40
	assert_move(announce(combat, CombatAI.PROTEGE_MOI), "bouclier_de_mana", "a1", "son Bouclier de mana sur toi, même à fond de PV")
	assert_eq(announce(combat, CombatAI.LIBRE)["action"].skill_id, "trait_de_givre", "en Libre, il le garde pour quand tu passes sous 50 %")
	var nova_mage := duo_combat(GM, GM)
	jump_to_turn(nova_mage, 3)
	nova_mage.get_unit("a1").last_hit_by = "b1"
	assert_eq(announce(nova_mage, CombatAI.PROTEGE_MOI)["action"].skill_id, "nova", "rien pour te protéger : il joue sa forte")


func test_protege_moi_un_front_pose_son_rempart_sur_toi() -> void:
	var combat := duo_combat(["mage", "guerrier"], GM, {"guerrier": {"moyenne": 1}})
	assert_move(announce(combat, CombatAI.PROTEGE_MOI), "rempart", "a1", "Rempart sur toi")


# --- Fonce : tout en dégâts, sur ta cible -------------------------------------

func test_fonce_suit_ta_cible() -> void:
	var combat := duo_combat(GM, GM)
	combat.get_unit("b2").hp = 30
	var decision := announce(combat, CombatAI.FONCE, action("a1", "taillade", "b1"))
	assert_move(decision, "trait_de_givre", "b1", "il frappe ta cible, même si une autre est plus basse")
	assert_eq(decision["rule"], "fonce", "règle : fonce")
	assert_eq(announce(combat, CombatAI.FONCE, action("a1", "taillade", "b2"))["action"].target_id, "b2", "tu changes de cible, il suit")


func test_fonce_sans_choix_suit_ta_cible_du_tour_precedent() -> void:
	var combat := duo_combat(GM, GM)
	combat.get_unit("a1").last_target = "b1"
	assert_eq(announce(combat, CombatAI.FONCE)["action"].target_id, "b1", "ta cible du tour précédent")


func test_fonce_forte_des_qu_elle_est_prete() -> void:
	var combat := duo_combat(["mage", "guerrier"], GM)
	jump_to_turn(combat, 3)
	assert_move(announce(combat, CombatAI.FONCE, action("a1", "boule_de_feu", "b1")), "fendoir", "b1", "Fendoir sur ta cible")


func test_fonce_un_soutien_ne_soigne_plus() -> void:
	var combat := duo_combat(["mage", "pretre"], GM)
	combat.get_unit("a1").hp = 30
	assert_move(announce(combat, CombatAI.FONCE, action("a1", "boule_de_feu", "b1")), "chatiment", "b1", "même à 17 % de PV, il frappe ta cible")


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
	for posture in CombatAI.POSTURES:
		var decision := announce(combat, posture)
		assert_move(decision, "resurrection", "a1", posture + " : il te relève")
		assert_eq(decision["rule"], "releve", posture + " : règle relève")


func test_en_libre_et_protege_moi_l_annonce_ne_depend_pas_de_ton_choix() -> void:
	# L'acolyte annonce en premier : en Libre et en Protège-moi, ton choix ne change jamais son coup.
	var rng := RandomNumberGenerator.new()
	rng.seed = 21
	var checked := 0
	for i in range(25):
		var combat := Combat.create(data, Duo.random_duo(data, rng), Duo.random_duo(data, rng))
		jump_to_turn(combat, 1 + i % 5)
		for unit in combat.units:
			unit.hp = maxi(1, int(unit.max_hp * rng.randf_range(0.2, 1.0)))
		var leader := combat.leader_of(0)
		for posture in [CombatAI.LIBRE, CombatAI.PROTEGE_MOI]:
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
	var combat := duo_combat(["pretre", "guerrier"], GM)
	for posture in CombatAI.POSTURES:
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
	var combat := duo_combat(GM, GM)
	assert_eq(CombatAI.choose_posture(combat, 1), CombatAI.LIBRE, "par défaut : Libre")
	combat.get_unit("a2").hp = 50
	assert_eq(CombatAI.choose_posture(combat, 1), CombatAI.FONCE, "un adversaire sous 35 % : Fonce")
	combat.get_unit("b1").hp = 80
	assert_eq(CombatAI.choose_posture(combat, 1), CombatAI.PROTEGE_MOI, "lui-même sous 40 % : Protège-moi")
	heal_all(combat)
	jump_to_turn(combat, 3)
	combat.get_unit("b1").cooldown_until["forte"] = 4
	assert_eq(CombatAI.choose_posture(combat, 1), CombatAI.GARDE_TA_FORTE, "sa forte revient au prochain tour : l'acolyte garde la sienne")


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
	assert_eq(postures.size(), 4, "les 4 postures servent")
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
