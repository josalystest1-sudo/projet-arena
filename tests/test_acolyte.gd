## L'IA de l'acolyte et du joueur IA : des règles fixes par rôle, et un joueur qui connaît le rôle devine le coup.
extends "res://tests/test_case.gd"

const GM := ["guerrier", "mage"]


## L'annonce de l'acolyte du camp 0.
func announce(combat: Combat) -> Dictionary:
	return CombatAI.decide_acolyte(combat, combat.acolyte_of(0))


func assert_move(decision: Dictionary, skill: String, target: String, message: String) -> void:
	var chosen: CombatAction = decision["action"]
	assert_eq("%s → %s" % [chosen.skill_id, chosen.target_id], "%s → %s" % [skill, target], message)


## Un joueur Guerrier (Provocation) et son acolyte Mage (Nova) : Piège de feu. Au tour 3, la Nova est prête et
## la Provocation du joueur revient au tour suivant.
func waiting_combat() -> Combat:
	var combat := duo_combat(GM, GM)
	jump_to_turn(combat, 3)
	combat.get_unit("a1").cooldown_until["moyenne"] = 4
	return combat


# --- Les règles de son rôle --------------------------------------------------------

func test_un_front_te_protege_des_que_tu_as_perdu_des_pv() -> void:
	var combat := duo_combat(["mage", "guerrier"], GM, {"guerrier": {"moyenne": 1}})
	assert_eq(announce(combat)["action"].skill_id, "taillade", "tu as tous tes PV : il frappe")
	combat.get_unit("a1").hp = 160
	var decision := announce(combat)
	assert_move(decision, "rempart", "a1", "le Guerrier pose son Rempart sur toi")
	assert_eq(decision["rule"], "protege", "règle : il te protège")
	combat.get_unit("a1").add_status({"id": "rempart", "turns": 2, "value": 1})
	assert_move(announce(combat), "taillade", "b2", "Rempart déjà posé : il frappe l'ennemi le plus fragile")


func test_un_front_provoque_puis_joue_sa_forte_puis_frappe_le_plus_bas() -> void:
	var combat := duo_combat(["mage", "guerrier"], ["guerrier", "pretre"])
	combat.get_unit("a1").hp = 160
	combat.get_unit("b2").hp = 150
	assert_move(announce(combat), "provocation", "b2", "Provocation sur l'ennemi le plus bas")
	jump_to_turn(combat, 3)
	combat.acolyte_of(0).cooldown_until["moyenne"] = 5
	assert_move(announce(combat), "fendoir", "b2", "moyenne en recharge : forte dès qu'elle est prête")
	combat.acolyte_of(0).cooldown_until["forte"] = 7
	combat.get_unit("b1").hp = 50
	assert_move(announce(combat), "taillade", "b1", "sinon la basique sur l'ennemi le plus bas (en % de PV)")


func test_un_degats_frappe_le_plus_bas_forte_puis_moyenne_puis_basique() -> void:
	var combat := duo_combat(GM, GM)
	# Tour 1 : tout le monde à fond, à égalité c'est le plus fragile (le Mage, 175 PV).
	assert_move(announce(combat), "trait_de_givre", "b2", "moyenne sur l'ennemi le plus fragile")
	jump_to_turn(combat, 3)
	assert_eq(announce(combat)["action"].skill_id, "nova", "forte dès qu'elle est prête")
	combat.acolyte_of(0).cooldown_until = {"moyenne": 5, "forte": 7}
	combat.get_unit("b1").hp = 100
	assert_move(announce(combat), "boule_de_feu", "b1", "sinon la basique sur l'ennemi le plus bas")


func test_un_degats_ne_te_secourt_que_sous_son_seuil() -> void:
	var combat := duo_combat(GM, GM, {"mage": {"forte": 1}})
	jump_to_turn(combat, 3)
	var below := float(data.ai["thresholds"]["rescue_below"])
	set_ratio(combat, "a1", below + 0.06)
	assert_eq(announce(combat)["action"].skill_id, "trait_de_givre", "au-dessus du seuil, il attaque")
	set_ratio(combat, "a1", below - 0.06)
	var decision := announce(combat)
	assert_move(decision, "bouclier_de_mana", "a1", "sous le seuil, son Bouclier de mana va sur toi")
	assert_eq(decision["rule"], "secours", "règle : secours")


func test_un_soutien_soigne_le_plus_blesse_sous_son_seuil() -> void:
	var combat := duo_combat(["mage", "pretre"], GM)
	var below := float(data.ai["thresholds"]["heal_below"])
	set_ratio(combat, "a1", below + 0.05)
	assert_move(announce(combat), "chatiment", "b2", "au-dessus du seuil, il frappe le plus fragile")
	set_ratio(combat, "a1", below - 0.05)
	assert_move(announce(combat), "restauration", "a1", "sous le seuil : son plus gros soin, sur toi")
	set_ratio(combat, "a2", below - 0.2)
	assert_move(announce(combat), "restauration", "a2", "il soigne le plus blessé des deux, lui compris")


func test_un_soutien_joue_sa_forte_des_qu_elle_est_prete() -> void:
	var combat := duo_combat(["mage", "pretre"], GM)
	jump_to_turn(combat, 3)
	var decision := announce(combat)
	assert_eq(decision["action"].skill_id, "egide", "Égide dès le tour 3")
	assert_eq(decision["rule"], "forte", "règle : forte prête")


func test_il_releve_un_allie_ko_avant_tout() -> void:
	var combat := duo_combat(["mage", "pretre"], GM, {"pretre": {"forte": 1}})
	jump_to_turn(combat, 3)
	combat.get_unit("a1").hp = 0
	var decision := announce(combat)
	assert_move(decision, "resurrection", "a1", "il te relève")
	assert_eq(decision["rule"], "releve", "règle : relève")


# --- La règle d'attente pour une Synergie ------------------------------------------

func test_il_garde_sa_forte_un_tour_quand_ta_competence_revient_au_tour_suivant() -> void:
	var combat := waiting_combat()
	var decision := announce(combat)
	assert_move(decision, "trait_de_givre", "b2", "il garde sa Nova et joue ses autres règles (sa moyenne)")
	assert_true(decision.has("waiting"), "il signale qu'il attend")
	if decision.has("waiting"):
		assert_eq(decision["waiting"]["synergy"]["name"], "Piège de feu", "pour Piège de feu")
		assert_eq(decision["waiting"]["skill_id"], "provocation", "avec ta Provocation")
	assert_true(decision["action"].waits_for_synergy, "l'action le note, pour que le combat s'en souvienne")


func test_il_n_attend_pas_si_ta_competence_est_deja_prete_ou_revient_plus_tard() -> void:
	var combat := waiting_combat()
	combat.get_unit("a1").cooldown_until["moyenne"] = 3
	var now := announce(combat)
	assert_eq(now["action"].skill_id, "nova", "ta Provocation est prête : sa Nova part, la Synergie est possible ce tour-ci")
	assert_false(now.has("waiting"), "pas d'attente")
	combat.get_unit("a1").cooldown_until["moyenne"] = 5
	assert_eq(announce(combat)["action"].skill_id, "nova", "ta Provocation revient dans 2 tours : il n'attend pas")


func test_il_n_attend_pas_sans_synergie() -> void:
	var combat := duo_combat(GM, GM, {"guerrier": {"moyenne": 1}})
	jump_to_turn(combat, 3)
	combat.get_unit("a1").cooldown_until["moyenne"] = 4
	assert_eq(announce(combat)["action"].skill_id, "nova", "ton Rempart ne fait pas Synergie avec sa Nova : il la joue")


func test_il_n_attend_jamais_deux_tours_de_suite() -> void:
	var combat := waiting_combat()
	var first: CombatAction = announce(combat)["action"]
	combat.resolve_turn([action("a1", "taillade", "b1"), first, action("b1", "taillade", "a1"), action("b2", "boule_de_feu", "a1")])
	assert_eq(int(combat.acolyte_of(0).flags.get("waited_for_synergy", -1)), 3, "le combat retient qu'il a attendu au tour 3")
	# Ta Provocation devait revenir ; on la repousse encore d'un tour : il n'attend pas une seconde fois.
	combat.get_unit("a1").cooldown_until["moyenne"] = combat.turn + 1
	var second := announce(combat)
	assert_eq(second["action"].skill_id, "nova", "jamais deux tours de suite : sa Nova part")
	assert_false(second.has("waiting"), "plus d'attente")


func test_le_tour_d_apres_il_joue_sa_forte_avec_toi() -> void:
	var combat := waiting_combat()
	var first: CombatAction = announce(combat)["action"]
	combat.resolve_turn([action("a1", "taillade", "b1"), first, action("b1", "taillade", "a1"), action("b2", "boule_de_feu", "a1")])
	assert_true(combat.can_use(combat.get_unit("a1"), "moyenne"), "ta Provocation est revenue")
	# Même si tu as perdu beaucoup de PV, il joue la forte qu'il gardait.
	set_ratio(combat, "a1", 0.3)
	var decision := announce(combat)
	assert_eq(decision["action"].skill_id, "nova", "il joue sa Nova")
	assert_eq(decision["rule"], "avec_toi", "règle : la forte gardée, avec toi")
	var options := CombatAI.synergy_options(combat, combat.get_unit("a1"), combat.acolyte_of(0))
	assert_eq(options.size(), 1, "l'écran te montre la Synergie")
	if options.size() == 1:
		assert_eq(options[0]["skill_id"], "provocation", "avec ta Provocation")
	var events := combat.resolve_turn([action("a1", "provocation", "b1"), decision["action"], action("b1", "taillade", "a1"), action("b2", "boule_de_feu", "a1")])
	assert_eq(events_of_type(events, "synergy").size(), 1, "Piège de feu se déclenche")


func test_il_attend_aussi_pour_une_forte_qui_protege() -> void:
	# Forteresse : son Bouclier de mana (forte) avec ton Cri de guerre (forte). Un Dégâts ne joue son Bouclier qu'en secours ;
	# après l'attente, il le joue quand même avec toi.
	var combat := duo_combat(GM, GM, {"guerrier": {"forte": 1}, "mage": {"forte": 1}})
	jump_to_turn(combat, 3)
	combat.get_unit("a1").cooldown_until["forte"] = 4
	var first := announce(combat)
	assert_true(first.has("waiting"), "il garde son Bouclier pour Forteresse")
	combat.resolve_turn([action("a1", "taillade", "b1"), first["action"], action("b1", "taillade", "a1"), action("b2", "boule_de_feu", "a1")])
	var decision := announce(combat)
	assert_eq(decision["action"].skill_id, "bouclier_de_mana", "le tour d'après, son Bouclier de mana")
	assert_eq(decision["rule"], "avec_toi", "règle : la forte gardée, avec toi")


func test_une_releve_ne_s_attend_pas() -> void:
	# Aucune Synergie n'utilise la Résurrection au prototype : on vérifie la règle avec une Synergie fictive.
	var combat := duo_combat(["guerrier", "pretre"], GM, {"pretre": {"forte": 1}})
	data.synergies.append({"id": "test_releve", "name": "Test", "skills": ["provocation", "resurrection"], "effect": {}})
	jump_to_turn(combat, 3)
	combat.get_unit("a1").cooldown_until["moyenne"] = 4
	assert_true(CombatAI.synergy_wait(combat, combat.acolyte_of(0)).is_empty(), "une relève ne se garde pas")
	data.synergies.pop_back()


# --- Prévisibilité ---------------------------------------------------------------

func test_meme_situation_meme_coup() -> void:
	for classes in [["pretre", "guerrier"], ["guerrier", "mage"], ["mage", "pretre"]]:
		var combat := duo_combat(classes, GM)
		jump_to_turn(combat, 3)
		assert_eq(announce(combat)["action"].to_dict(), announce(combat)["action"].to_dict(), str(classes))


func test_ton_choix_ne_change_jamais_son_annonce() -> void:
	# L'acolyte annonce en premier : quel que soit ton choix, le tour part avec son annonce.
	var rng := RandomNumberGenerator.new()
	rng.seed = 21
	var checked := 0
	for i in range(30):
		var combat := Combat.create(data, Duo.random_duo(data, rng), Duo.random_duo(data, rng))
		jump_to_turn(combat, 1 + i % 5)
		for unit in combat.units:
			unit.hp = maxi(1, int(unit.max_hp * rng.randf_range(0.2, 1.0)))
		var leader := combat.leader_of(0)
		var acolyte := combat.acolyte_of(0)
		var alone: CombatAction = announce(combat)["action"]
		for tier in CombatUnit.TIERS:
			if not combat.can_use(leader, tier):
				continue
			for target in combat.valid_targets(leader, leader.skills[tier]):
				var actions := CombatAI.choose_team(combat, 0, [action(leader.id, leader.skills[tier], target.id)])
				for chosen in actions:
					if chosen.actor_id == acolyte.id:
						assert_eq(chosen.to_dict(), alone.to_dict(), "l'annonce ne bouge pas")
						checked += 1
	assert_true(checked > 100, "assez de situations vérifiées")


func test_les_regles_affichees_sont_remplies() -> void:
	for class_id in data.classes:
		var text := data.acolyte_rules(class_id)
		assert_true(text.length() > 40, class_id + " : un texte")
		assert_false(text.contains("{"), "%s : seuils remplis (%s)" % [class_id, text])
	assert_true(data.acolyte_rules("pretre").contains("%d %%" % int(round(100 * float(data.ai["thresholds"]["heal_below"])))), "le seuil de soin vient des données")
	for rule in ["releve", "protege", "soin", "secours", "purifie", "forte", "moyenne", "basique", "avec_toi", "attend_synergie"]:
		assert_true(data.ai["reasons"].has(rule), rule + " : une phrase pour l'écran")


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


func test_le_joueur_ia_joue_la_synergie_apres_l_attente() -> void:
	var combat := waiting_combat()
	var first := CombatAI.choose_team(combat, 0)
	combat.resolve_turn(first + CombatAI.choose_team(combat, 1))
	var second := CombatAI.choose_team(combat, 0)
	var skills := {}
	for chosen in second:
		skills[chosen.actor_id] = chosen.skill_id
	assert_eq(skills.get("a2"), "nova", "son acolyte joue la Nova gardée")
	assert_eq(skills.get("a1"), "provocation", "il joue sa Provocation avec : Piège de feu")


# --- Pour l'écran : les Synergies possibles -------------------------------------

func test_synergies_possibles_suivent_l_annonce_et_la_cible() -> void:
	var combat := duo_combat(["pretre", "mage"], GM)
	# L'acolyte Mage annonce Trait de givre sur le Mage adverse (le plus fragile).
	var options := CombatAI.synergy_options(combat, combat.get_unit("a1"), combat.get_unit("a2"))
	assert_eq(options.size(), 1, "une seule Synergie possible")
	if options.size() == 1:
		assert_eq(options[0]["skill_id"], "chatiment", "avec ton Châtiment")
		assert_eq(options[0]["synergy"]["name"], "Éclat", "Éclat")
		assert_eq(options[0]["targets"], ["b2"], "seulement sur la cible de l'acolyte")


func test_pas_de_synergie_possible_pendant_l_attente() -> void:
	var combat := waiting_combat()
	assert_true(CombatAI.synergy_options(combat, combat.get_unit("a1"), combat.acolyte_of(0)).is_empty(), "il garde sa Nova : rien à construire ce tour-ci")


# --- Combats complets -----------------------------------------------------------

func test_combats_ia_contre_ia_se_terminent() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 2026
	var wins := {0: 0, 1: 0}
	var turns_total := 0
	var synergies := 0
	for i in range(30):
		var combat := Combat.create(data, Duo.random_duo(data, rng), Duo.random_duo(data, rng), i % 2)
		while not combat.finished:
			var actions: Array = CombatAI.choose_team(combat, 0)
			actions.append_array(CombatAI.choose_team(combat, 1))
			assert_eq(actions.size(), combat.team_units(0, true).size() + combat.team_units(1, true).size(), "une Intention par perso debout")
			var events := combat.resolve_turn(actions)
			synergies += events_of_type(events, "synergy").size()
			assert_true(combat.turn <= combat.forced_end_turn + 1, "jamais au-delà du tour de fin forcée")
		wins[combat.winner] += 1
		turns_total += combat.turn
	assert_eq(wins[0] + wins[1], 30, "30 vainqueurs")
	assert_true(synergies > 0, "des Synergies se déclenchent en IA contre IA")
	assert_between(float(turns_total) / 30.0, 5.0, 15.0, "durée moyenne des combats (tours)")
	print("    (IA vs IA : %d / %d victoires, %.1f tours en moyenne, %d synergies)" % [wins[0], wins[1], float(turns_total) / 30.0, synergies])


func test_un_groupe_sans_acolyte_joue_aussi() -> void:
	# Les ennemis de la Tour : 3 persos sans acolyte, chacun joue son rôle en concentrant la même cible.
	var combat := Combat.create(data, duo_team(GM), [member("guerrier"), member("mage"), member("pretre")])
	var actions := CombatAI.choose_team(combat, 1)
	assert_eq(actions.size(), 3, "une Intention par ennemi")
	var targets := {}
	for chosen in actions:
		if combat.is_hostile(chosen.skill_id):
			targets[chosen.target_id] = true
	assert_eq(targets.size(), 1, "ils concentrent la même cible")
	var guard := 0
	while not combat.finished and guard < 20:
		var turn_actions: Array = CombatAI.choose_team(combat, 0)
		turn_actions.append_array(CombatAI.choose_team(combat, 1))
		combat.resolve_turn(turn_actions)
		guard += 1
	assert_true(combat.finished, "le combat 2 contre 3 se termine")
