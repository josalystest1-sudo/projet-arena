## Dégâts, soins, états, passifs et Synergies.
extends "res://tests/test_case.gd"


func test_degats_de_base_et_peau_de_fer() -> void:
	var combat := standard_combat()
	var events := combat.resolve_turn([action("a1", "taillade", "b2"), action("b1", "taillade", "a2")])
	assert_eq(damage_from(events, "a1", "b2"), 34, "Taillade sur le Mage")
	var combat_2 := standard_combat()
	var events_2 := combat_2.resolve_turn([action("a2", "boule_de_feu", "b1")])
	# 34 × 1,1 (puissance du Mage) × 0,85 (Peau de fer) = 31,79 → 32
	assert_eq(damage_from(events_2, "a2", "b1"), 32, "Boule de feu sur le Guerrier à Peau de fer")


func test_focalisation_et_cible_unique() -> void:
	var combat := standard_combat({"mage": {"passive": 1}})
	var events := combat.resolve_turn([action("a2", "boule_de_feu", "b2")])
	# 34 × 1,1 × 1,2 = 44,88 → 45
	assert_eq(damage_from(events, "a2", "b2"), 45, "Focalisation +20 %")


func test_provocation_redirige_deux_ennemis() -> void:
	var combat := standard_combat()
	var events := combat.resolve_turn([
		action("a1", "provocation", "b2"),
		action("b2", "boule_de_feu", "a3"),
		action("b3", "chatiment", "a2"),
		action("b1", "taillade", "a3"),
	])
	var hits := {}
	for event in events_of_type(events, "action"):
		hits[event["actor"]] = event["targets"]
	# La cible choisie (b2) et le prochain ennemi à agir (b1) sont provoqués ; b3 garde sa cible.
	assert_eq(hits["b2"], ["a1"], "le Mage provoqué frappe le Guerrier")
	assert_eq(hits["b1"], ["a1"], "le Guerrier ennemi provoqué frappe le Guerrier")
	assert_eq(hits["b3"], ["a2"], "le Prêtre non provoqué garde sa cible")
	assert_false(combat.get_unit("b2").has_status("provoque"), "la provocation ne dure qu'un tour")


func test_provocation_ne_detourne_pas_un_soin() -> void:
	var combat := standard_combat({}, {"pretre": {"basique": 1}})
	var events := combat.resolve_turn([
		action("a1", "provocation", "b3"),
		action("b3", "priere", "b2"),
	])
	for event in events_of_type(events, "action"):
		if event["actor"] == "b3":
			assert_eq(event["targets"], ["b2"], "la Prière reste sur l'allié")


func test_rempart_absorbe_un_coup_et_bastion_en_absorbe_deux() -> void:
	var combat := standard_combat({"guerrier": {"moyenne": 1}})
	var events := combat.resolve_turn([
		action("a1", "rempart", "a2"),
		action("b1", "taillade", "a2"),
		action("b2", "boule_de_feu", "a2"),
	])
	assert_eq(events_of_type(events, "absorbed").size(), 1, "un seul coup absorbé")
	assert_eq(damage_from(events, "b2", "a2"), 37, "le second coup passe (34 × 1,1)")
	assert_false(combat.get_unit("a2").has_status("rempart"), "le Rempart a servi")

	var combat_2 := standard_combat({"guerrier": {"moyenne": 1}, "pretre": {"basique": 1}})
	var events_2 := combat_2.resolve_turn([
		action("a1", "rempart", "a2"),
		action("a3", "priere", "a2"),
		action("b1", "taillade", "a2"),
		action("b2", "boule_de_feu", "a2"),
	])
	assert_eq(events_of_type(events_2, "synergy").size(), 1, "Synergie Bastion déclenchée")
	# La Prière (lente) arrive après les coups : le Rempart se reforme pour le tour suivant.
	assert_true(combat_2.get_unit("a2").has_status("rempart"), "le Rempart s'est reformé")
	var events_3 := combat_2.resolve_turn([action("b1", "taillade", "a2")])
	assert_eq(damage_from(events_3, "b1", "a2"), 0, "le coup suivant est absorbé")


func test_synergie_provocation_nova() -> void:
	var combat := standard_combat()
	jump_to_turn(combat, 3)
	var mage_power := 1.1
	var events := combat.resolve_turn([
		action("a1", "provocation", "b2"),
		action("a2", "nova", "b1"),
	])
	assert_eq(events_of_type(events, "synergy_ready").size(), 1, "Synergie annoncée à la révélation")
	assert_eq(events_of_type(events, "synergy").size(), 1, "Synergie déclenchée")
	var nova_hits := {}
	for event in events_of_type(events, "damage"):
		if event["source"] == "a2":
			nova_hits[event["target"]] = int(event["amount"])
	# b2 (cible) et b1 (prochain ennemi à agir) sont provoqués : Nova +50 %.
	assert_eq(nova_hits["b2"], int(round(55 * mage_power * 1.5)), "Mage provoqué : Nova +50 %")
	assert_eq(nova_hits["b1"], int(round(55 * mage_power * 1.5 * 0.85)), "Guerrier provoqué (Peau de fer) : Nova +50 %")
	assert_eq(nova_hits["b3"], int(round(55 * mage_power)), "Prêtre non provoqué : Nova normale")


func test_synergie_nova_resolue_avant_provocation() -> void:
	# Le Guerrier est gelé : la Nova part avant la Provocation. Le bonus s'applique quand même.
	var combat := standard_combat()
	jump_to_turn(combat, 3)
	combat.get_unit("a1").add_status({"id": "gele", "turns": 1, "value": 0})
	var events := combat.resolve_turn([
		action("a1", "provocation", "b2"),
		action("a2", "nova", "b1"),
	])
	var order := action_order(events)
	assert_true(order.find("a2") < order.find("a1"), "la Nova part avant la Provocation")
	var bonus := 0
	for event in events_of_type(events, "damage"):
		if event["kind"] == "synergie":
			bonus += int(event["amount"])
	assert_true(bonus > 0, "dégâts bonus appliqués après coup")


func test_synergie_eclat_meme_cible_seulement() -> void:
	var combat := standard_combat()
	var events := combat.resolve_turn([action("a2", "trait_de_givre", "b1"), action("a3", "chatiment", "b1")])
	assert_eq(events_of_type(events, "synergy").size(), 1, "Éclat sur la même cible")
	var combat_2 := standard_combat()
	var events_2 := combat_2.resolve_turn([action("a2", "trait_de_givre", "b1"), action("a3", "chatiment", "b2")])
	assert_eq(events_of_type(events_2, "synergy").size(), 0, "pas d'Éclat sur des cibles différentes")


func test_saignement_et_plaie_brulante() -> void:
	var combat := standard_combat()
	advance_to_turn(combat, 3)
	combat.resolve_turn([action("a1", "fendoir", "b3")])
	var bleed := combat.get_unit("b3").get_status("saignement")
	assert_eq(int(bleed["turns"]), 2, "saignement : 3 tours, un déjà écoulé")
	var combat_2 := standard_combat()
	advance_to_turn(combat_2, 3)
	var events := combat_2.resolve_turn([action("a1", "fendoir", "b3"), action("a2", "boule_de_feu", "b3")])
	assert_eq(events_of_type(events, "synergy").size(), 1, "Plaie brûlante déclenchée")
	assert_eq(int(combat_2.get_unit("b3").get_status("saignement")["turns"]), 4, "saignement prolongé de 2 tours")
	var dot := 0
	for event in events_of_type(events, "damage"):
		if event["kind"] == "dot":
			dot += int(event["amount"])
	assert_eq(dot, 12, "le saignement a fait 12 dégâts en fin de tour")


func test_brasier_brule_un_tour() -> void:
	var combat := standard_combat({"mage": {"passive": 2}})
	var events := combat.resolve_turn([action("a2", "boule_de_feu", "b2")])
	var burn := 0
	for event in events_of_type(events, "damage"):
		if event["kind"] == "dot" and event["target"] == "b2":
			burn += int(event["amount"])
	assert_eq(burn, 8, "brûlure de 8 en fin de tour")
	assert_false(combat.get_unit("b2").has_status("brulure"), "brûlure terminée après 1 tour")


func test_purification_retire_un_etat_negatif() -> void:
	var combat := standard_combat({"pretre": {"moyenne": 1}})
	advance_to_turn(combat, 3)
	combat.resolve_turn([action("b1", "fendoir", "a2")])
	assert_true(combat.get_unit("a2").has_status("saignement"), "le Mage saigne")
	var events := combat.resolve_turn([action("a3", "purification", "a2")])
	assert_eq(events_of_type(events, "status_removed").size(), 1, "un état retiré")
	assert_false(combat.get_unit("a2").has_status("saignement"), "plus de saignement")


func test_cri_de_guerre_augmente_les_degats_trois_tours() -> void:
	var combat := standard_combat({"guerrier": {"forte": 1}})
	jump_to_turn(combat, 3)
	var events := combat.resolve_turn([action("a1", "cri_de_guerre", "a1"), action("a2", "boule_de_feu", "b2")])
	assert_eq(damage_from(events, "a2", "b2"), int(round(34 * 1.1 * 1.3)), "Boule de feu +30 %")
	var events_2 := combat.resolve_turn([action("a2", "boule_de_feu", "b2")])
	assert_eq(damage_from(events_2, "a2", "b2"), int(round(34 * 1.1 * 1.3)), "toujours +30 % au deuxième tour")
	var events_3 := combat.resolve_turn([action("a2", "boule_de_feu", "b2")])
	assert_eq(damage_from(events_3, "a2", "b2"), int(round(34 * 1.1 * 1.3)), "toujours +30 % au troisième tour")
	var events_4 := combat.resolve_turn([action("a2", "boule_de_feu", "b2")])
	assert_eq(damage_from(events_4, "a2", "b2"), int(round(34 * 1.1)), "plus de bonus au quatrième tour")


func test_soins_priere_restauration_et_foi() -> void:
	var combat := standard_combat()
	var mage := combat.get_unit("a2")
	mage.hp = 50
	var events := combat.resolve_turn([action("a3", "restauration", "a2")])
	var healed := 0
	for event in events_of_type(events, "heal"):
		if event["target"] == "a2":
			healed += int(event["amount"])
	assert_eq(healed, int(round(85 * 1.2)), "Restauration +20 % grâce à Foi sous 40 % de PV")


func test_egide_pose_une_barriere_sur_toute_l_equipe() -> void:
	var combat := standard_combat()
	advance_to_turn(combat, 3)
	var events := combat.resolve_turn([action("a3", "egide", "a3")])
	for unit_id in ["a1", "a2", "a3"]:
		assert_true(combat.get_unit(unit_id).has_status("barriere"), "barrière sur " + unit_id)
	var barrier_events := events_of_type(events, "absorbed")
	assert_true(barrier_events.size() >= 1, "la barrière a absorbé des coups ennemis ce tour")


func test_bouclier_de_mana_et_sanctuaire() -> void:
	var combat := standard_combat({"mage": {"forte": 1}, "pretre": {"passive": 3}})
	advance_to_turn(combat, 3)
	combat.resolve_turn([action("a2", "bouclier_de_mana", "a3"), action("a3", "egide", "a3")])
	# Le Bouclier de mana (150 × 1,1 = 165) et l'Égide avec Sanctuaire (60 × 1,25 = 75) : la plus grosse reste.
	assert_true(combat.get_unit("a3").barrier_amount() <= 165, "barrière plafonnée à la plus grosse")
	assert_true(combat.get_unit("a1").barrier_amount() <= 75, "Égide +25 % avec Sanctuaire")


func test_martyr_encaisse_une_part() -> void:
	var combat := standard_combat({"pretre": {"passive": 1}})
	var events := combat.resolve_turn([action("b1", "taillade", "a2")])
	assert_eq(damage_from(events, "b1", "a2"), 27, "le Mage prend 80 %")
	assert_eq(damage_from(events, "b1", "a3", "martyr"), 7, "le Prêtre Martyr prend 20 %")


func test_second_souffle_une_seule_fois() -> void:
	var combat := standard_combat({"guerrier": {"passive": 1}})
	var guerrier := combat.get_unit("a1")
	guerrier.hp = 110
	combat.resolve_turn([action("b1", "taillade", "a1"), action("b2", "boule_de_feu", "a1"), action("b3", "chatiment", "a1")])
	assert_true(guerrier.flags.get("second_souffle", false), "Second souffle utilisé")
	var heals := events_of_type(combat.history, "heal")
	var found := false
	for event in heals:
		if event["kind"] == "second_souffle":
			found = true
			assert_eq(int(event["amount"]), 33, "soin de 10 % des PV max")
	assert_true(found, "un soin Second souffle")


func test_resonance_et_meteorologue() -> void:
	var combat := standard_combat({"mage": {"moyenne": 1}})
	advance_to_turn(combat, 3)
	combat.resolve_turn([action("a2", "nova", "b1")])
	assert_eq(combat.cooldown_remaining(combat.get_unit("a2"), "forte"), 3, "Résonance : recharge réduite d'un tour")
	var combat_2 := standard_combat({"mage": {"passive": 3}})
	advance_to_turn(combat_2, 3)
	combat_2.resolve_turn([action("a2", "nova", "b1")])
	assert_eq(combat_2.cooldown_remaining(combat_2.get_unit("a2"), "forte"), 3, "Météorologue : forte revient 1 tour plus tôt")


func test_veteran_gagne_de_la_vitesse() -> void:
	var combat := standard_combat({"guerrier": {"passive": 2}})
	combat.get_unit("a2").hp = 0
	combat.get_unit("a3").hp = 0
	combat._actions = {}
	assert_eq(combat.effective_speed(combat.get_unit("a1")), 11, "+1 vitesse par allié KO")


func test_resurrection_une_fois_par_combat() -> void:
	var combat := standard_combat({"pretre": {"forte": 1}})
	advance_to_turn(combat, 3)
	var mage := combat.get_unit("a2")
	mage.hp = 0
	var events := combat.resolve_turn([action("a3", "resurrection", "a2")])
	assert_eq(events_of_type(events, "revive").size(), 1, "relevé")
	assert_true(mage.is_alive(), "le Mage est debout")
	assert_eq(mage.hp, 69, "30 % de 230")
	assert_true(mage.flags.get("revived", false), "ne peut plus être relevé")
	assert_false(combat.can_use(combat.get_unit("a3"), "forte"), "Résurrection utilisée pour le combat")
	jump_to_turn(combat, 9)
	assert_false(combat.can_use(combat.get_unit("a3"), "forte"), "toujours indisponible après la recharge")
	mage.hp = 0
	assert_false(combat.valid_targets(combat.get_unit("a3"), "resurrection").has(mage), "un perso ne se relève qu'une fois")
