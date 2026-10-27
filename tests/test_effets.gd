## Dégâts, soins, états, passifs et Synergies, en duo.
extends "res://tests/test_case.gd"

const GM := ["guerrier", "mage"]
const GP := ["guerrier", "pretre"]
const MP := ["mage", "pretre"]

var mage_power: float = 1.0


func setup() -> void:
	super.setup()
	mage_power = class_power("mage")


func test_degats_de_base_et_peau_de_fer() -> void:
	var combat := duo_combat(GM, GM)
	var events := combat.resolve_turn([action("a1", "taillade", "b2"), action("b1", "taillade", "a2")])
	assert_eq(damage_from(events, "a1", "b2"), int(round(skill_power("taillade") * class_power("guerrier"))), "Taillade sur le Mage")
	var combat_2 := duo_combat(GM, GM)
	var events_2 := combat_2.resolve_turn([action("a2", "boule_de_feu", "b1")])
	# Boule de feu × puissance du Mage × (1 - réduction de Peau de fer)
	assert_eq(damage_from(events_2, "a2", "b1"), int(round(skill_power("boule_de_feu") * mage_power * (1.0 - pp("peau_de_fer", "reduction")))), "Boule de feu sur le Guerrier à Peau de fer")


func test_focalisation_et_cible_unique() -> void:
	var combat := duo_combat(GM, GM, {"mage": {"passive": 1}})
	var events := combat.resolve_turn([action("a2", "boule_de_feu", "b2")])
	assert_eq(damage_from(events, "a2", "b2"), int(round(skill_power("boule_de_feu") * mage_power * (1.0 + pp("focalisation", "bonus")))), "Focalisation")


func test_provocation_redirige_tout_le_duo_adverse() -> void:
	var combat := duo_combat(GM, MP)
	var events := combat.resolve_turn([
		action("a1", "provocation", "b2"),
		action("b1", "boule_de_feu", "a2"),
		action("b2", "chatiment", "a2"),
	])
	var hits := {}
	for event in events_of_type(events, "action"):
		hits[event["actor"]] = event["targets"]
	# La cible choisie (b2) et le prochain ennemi à agir (b1) sont provoqués : en duo, c'est tout le camp adverse.
	assert_eq(hits["b1"], ["a1"], "le Mage provoqué frappe le Guerrier")
	assert_eq(hits["b2"], ["a1"], "le Prêtre provoqué frappe le Guerrier")
	assert_false(combat.get_unit("b2").has_status("provoque"), "la provocation ne dure qu'un tour")


func test_provocation_ne_vise_que_deux_ennemis_sur_trois() -> void:
	# À la Tour, un groupe de 3 ennemis : le troisième garde sa cible.
	var combat := Combat.create(data, duo_team(GM), [member("guerrier"), member("mage"), member("pretre")])
	var events := combat.resolve_turn([
		action("a1", "provocation", "b2"),
		action("b1", "taillade", "a2"),
		action("b2", "boule_de_feu", "a2"),
		action("b3", "chatiment", "a2"),
	])
	var hits := {}
	for event in events_of_type(events, "action"):
		hits[event["actor"]] = event["targets"]
	assert_eq(hits["b2"], ["a1"], "la cible choisie est provoquée")
	assert_eq(hits["b1"], ["a1"], "le prochain ennemi à agir est provoqué")
	assert_eq(hits["b3"], ["a2"], "le troisième garde sa cible")


func test_provocation_frappe_sa_cible() -> void:
	var combat := duo_combat(GM, MP)
	var events := combat.resolve_turn([action("a1", "provocation", "b2")])
	assert_eq(damage_from(events, "a1", "b2"), int(round(skill_power("provocation") * class_power("guerrier"))), "la Provocation porte un petit coup")


func test_provocation_ne_detourne_pas_un_soin() -> void:
	var combat := duo_combat(GM, GP, {}, {"pretre": {"basique": 1}})
	var events := combat.resolve_turn([
		action("a1", "provocation", "b2"),
		action("b2", "priere", "b1"),
	])
	for event in events_of_type(events, "action"):
		if event["actor"] == "b2":
			assert_eq(event["targets"], ["b1"], "la Prière reste sur l'allié")


func test_rempart_absorbe_un_coup_et_bastion_en_absorbe_deux() -> void:
	var combat := duo_combat(GM, GM, {"guerrier": {"moyenne": 1}})
	var events := combat.resolve_turn([
		action("a1", "rempart", "a2"),
		action("b1", "taillade", "a2"),
		action("b2", "boule_de_feu", "a2"),
	])
	assert_eq(events_of_type(events, "absorbed").size(), 1, "un seul coup absorbé")
	assert_eq(damage_from(events, "b2", "a2"), int(round(skill_power("boule_de_feu") * mage_power)), "le second coup passe")
	assert_false(combat.get_unit("a2").has_status("rempart"), "le Rempart a servi")

	var combat_2 := duo_combat(GP, GM, {"guerrier": {"moyenne": 1}, "pretre": {"basique": 1}})
	var events_2 := combat_2.resolve_turn([
		action("a1", "rempart", "a2"),
		action("a2", "priere", "a2"),
		action("b1", "taillade", "a2"),
		action("b2", "boule_de_feu", "a2"),
	])
	assert_eq(events_of_type(events_2, "synergy").size(), 1, "Synergie Bastion déclenchée")
	# La Prière (lente) arrive après les coups : le Rempart se reforme pour le tour suivant.
	assert_true(combat_2.get_unit("a2").has_status("rempart"), "le Rempart s'est reformé")
	var events_3 := combat_2.resolve_turn([action("b1", "taillade", "a2")])
	assert_eq(damage_from(events_3, "b1", "a2"), 0, "le coup suivant est absorbé")


func test_synergie_provocation_nova() -> void:
	var combat := duo_combat(GM, GP)
	jump_to_turn(combat, 3)
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
	# b2 (cible) et b1 (prochain ennemi à agir) sont provoqués : Nova +50 % sur les deux.
	var boost := 1.0 + sp("provocation_nova", "bonus")
	assert_eq(nova_hits["b2"], int(round(skill_power("nova") * mage_power * boost)), "Prêtre provoqué : Nova renforcée")
	assert_eq(nova_hits["b1"], int(round(skill_power("nova") * mage_power * boost * (1.0 - pp("peau_de_fer", "reduction")))), "Guerrier provoqué (Peau de fer) : Nova renforcée")


func test_synergie_nova_resolue_avant_provocation() -> void:
	# Le Guerrier est gelé : la Nova part avant la Provocation. Le bonus s'applique quand même.
	var combat := duo_combat(GM, GP)
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
	var combat := duo_combat(MP, GM)
	var events := combat.resolve_turn([action("a1", "trait_de_givre", "b1"), action("a2", "chatiment", "b1")])
	assert_eq(events_of_type(events, "synergy").size(), 1, "Éclat sur la même cible")
	var combat_2 := duo_combat(MP, GM)
	var events_2 := combat_2.resolve_turn([action("a1", "trait_de_givre", "b1"), action("a2", "chatiment", "b2")])
	assert_eq(events_of_type(events_2, "synergy").size(), 0, "pas d'Éclat sur des cibles différentes")


func test_synergie_entre_les_deux_camps_impossible() -> void:
	var combat := duo_combat(["mage", "guerrier"], ["pretre", "guerrier"])
	var events := combat.resolve_turn([action("a1", "trait_de_givre", "b2"), action("b1", "chatiment", "b2")])
	assert_eq(events_of_type(events, "synergy").size(), 0, "une Synergie se joue entre membres d'un même duo")


func test_saignement_et_plaie_brulante() -> void:
	var combat := duo_combat(GM, MP)
	advance_to_turn(combat, 3)
	heal_all(combat)
	combat.resolve_turn([action("a1", "fendoir", "b2")])
	var bleed := combat.get_unit("b2").get_status("saignement")
	assert_eq(int(bleed["turns"]), 2, "saignement : 3 tours, un déjà écoulé")
	var combat_2 := duo_combat(GM, MP)
	advance_to_turn(combat_2, 3)
	heal_all(combat_2)
	var events := combat_2.resolve_turn([action("a1", "fendoir", "b2"), action("a2", "boule_de_feu", "b2")])
	assert_eq(events_of_type(events, "synergy").size(), 1, "Plaie brûlante déclenchée")
	var extra := int(data.synergy_param("fendoir_boule_de_feu", "extra_turns", 2))
	assert_eq(int(combat_2.get_unit("b2").get_status("saignement")["turns"]), 2 + extra, "saignement prolongé")
	var dot := 0
	for event in events_of_type(events, "damage"):
		if event["kind"] == "dot":
			dot += int(event["amount"])
	var bleed_value := int(round(skill_power("fendoir", "status") * (1.0 + sp("fendoir_boule_de_feu", "bonus"))))
	assert_eq(dot, bleed_value, "le saignement, renforcé, a fait ses dégâts en fin de tour")


func test_synergie_forteresse_protege_tout_le_duo() -> void:
	var combat := duo_combat(GM, GM, {"guerrier": {"forte": 1}, "mage": {"forte": 1}})
	jump_to_turn(combat, 3)
	var events := combat.resolve_turn([action("a1", "cri_de_guerre", "b1"), action("a2", "bouclier_de_mana", "a1")])
	assert_eq(events_of_type(events, "synergy").size(), 1, "Forteresse déclenchée")
	# Le Bouclier de mana se pose aussi sur le Mage, que personne ne frappe ce tour.
	var shield := int(round(skill_power("bouclier_de_mana", "barrier") * mage_power))
	assert_eq(combat.get_unit("a2").barrier_amount(), int(round(shield * sp("cri_de_guerre_bouclier_de_mana", "share"))), "l'autre membre du duo reçoit le bouclier (à sa part)")
	assert_true(combat.get_unit("a1").has_status("barriere"), "la cible garde son bouclier")


func test_synergie_jugement_frappe_l_autre_ennemi_provoque() -> void:
	var combat := duo_combat(GP, GM)
	var events := combat.resolve_turn([action("a1", "provocation", "b1"), action("a2", "chatiment", "b1")])
	assert_eq(events_of_type(events, "synergy").size(), 1, "Jugement déclenché")
	var pretre_power := class_power("pretre")
	assert_eq(damage_from(events, "a2", "b1", "hit"), int(round(skill_power("chatiment") * pretre_power * (1.0 - pp("peau_de_fer", "reduction")))), "le Châtiment frappe sa cible (Peau de fer)")
	var echo := data.synergy_param("provocation_chatiment", "mult", 1.0)
	assert_eq(damage_from(events, "a2", "b2", "synergie"), int(round(skill_power("chatiment") * pretre_power * echo)), "et l'autre ennemi provoqué")


func test_synergie_courant_de_vie_soigne_tout_le_duo() -> void:
	var combat := duo_combat(MP, GM, {"mage": {"moyenne": 1}, "pretre": {"basique": 1, "passive": 3}})
	combat.get_unit("a1").hp = 120
	combat.get_unit("a2").hp = 120
	var events := combat.resolve_turn([action("a1", "arc_de_foudre", "b1"), action("a2", "priere", "a2")])
	assert_eq(events_of_type(events, "synergy").size(), 1, "Courant de vie déclenché")
	var bonus := 0
	for event in events_of_type(events, "heal"):
		if event["target"] == "a1" and event["kind"] == "synergie":
			bonus += int(event["amount"])
	assert_eq(bonus, int(round(round(skill_power("priere", "heal") * sp("arc_de_foudre_priere", "mult")) * class_power("pretre"))), "le Mage reçoit aussi la Prière")


func test_courant_de_vie_sur_un_allie_a_fond_pose_une_barriere() -> void:
	var combat := duo_combat(MP, GM, {"mage": {"moyenne": 1}, "pretre": {"basique": 1, "passive": 3}})
	combat.get_unit("a2").hp = 120
	combat.resolve_turn([action("a1", "arc_de_foudre", "b1"), action("a2", "priere", "a2"), action("b1", "taillade", "a2"), action("b2", "boule_de_feu", "a2")])
	var expected := int(round(round(skill_power("priere", "heal") * sp("arc_de_foudre_priere", "mult")) * class_power("pretre")))
	assert_eq(combat.get_unit("a1").hp, combat.get_unit("a1").max_hp, "le Mage avait tous ses PV")
	assert_eq(combat.get_unit("a1").barrier_amount(), expected, "le soin du Courant de vie devient une barrière")


func test_le_budget_du_destin_ajuste_pv_et_puissance() -> void:
	data.destins = {"kit_items": {"resurrection": 0.02}, "kit_pairs": {CombatData.pair_key("priere", "resurrection"): 0.02, CombatData.pair_key("egide", "priere"): -0.04},
		"kit_triples": {"chatiment+egide+restauration": 0.5, "priere+restauration+resurrection": 0.01}}
	var picks := {"basique": 1, "moyenne": 0, "forte": 1, "passive": 0}
	var unit := CombatUnit.from_class(data, "pretre", picks, "a1", 0, 0)
	assert_eq(unit.skills["basique"], "priere", "kit tiré")
	assert_eq(unit.skills["forte"], "resurrection", "kit tiré")
	var stats: Dictionary = data.classes["pretre"]["stats"]
	assert_eq(unit.max_hp, int(round(float(stats["max_hp"]) * 1.05)), "+2 % pour la Résurrection, +2 % pour la paire Prière + Résurrection, +1 % pour le trio")
	assert_eq(unit.power, int(round(float(stats["power"]) * 1.05)), "et +5 % de puissance")
	picks["forte"] = 0
	var other := CombatUnit.from_class(data, "pretre", picks, "a1", 0, 0)
	assert_eq(other.max_hp, int(round(float(stats["max_hp"]) * 0.96)), "-4 % pour la paire Prière + Égide")
	data.destins = {"kit_pairs": {}}


func test_en_duo_le_budget_depend_du_partenaire() -> void:
	data.destins = {"duo_items": {"guerrier": {"bouclier_de_mana": -0.05}}, "duo_classes": {CombatData.pair_key("guerrier", "mage"): 0.02}, "acolyte_classes": {"mage": 0.01}}
	var combat := duo_combat(GM, MP, {"mage": {"forte": 1}}, {"mage": {"forte": 1}})
	var stats: Dictionary = data.classes["mage"]["stats"]
	assert_eq(combat.get_unit("a2").skills["forte"], "bouclier_de_mana", "kit tiré")
	assert_eq(combat.get_unit("a2").max_hp, int(round(float(stats["max_hp"]) * 0.98)), "Bouclier de mana à côté d'un Guerrier : -5 %, duo Guerrier + Mage : +2 %, acolyte Mage : +1 %")
	assert_eq(combat.get_unit("a1").max_hp, int(round(float(data.classes["guerrier"]["stats"]["max_hp"]) * 1.02)), "le Guerrier : +2 % pour la composition")
	assert_eq(combat.get_unit("b1").max_hp, int(stats["max_hp"]), "le même Mage à côté d'un Prêtre : rien")
	data.destins = {"kit_pairs": {}}


func test_brasier_brule_un_tour() -> void:
	var combat := duo_combat(GM, GM, {"mage": {"passive": 2}})
	var events := combat.resolve_turn([action("a2", "boule_de_feu", "b2")])
	var burn := 0
	for event in events_of_type(events, "damage"):
		if event["kind"] == "dot" and event["target"] == "b2":
			burn += int(event["amount"])
	assert_eq(burn, int(data.passive_param("brasier", "value", 10)), "brûlure en fin de tour")
	assert_false(combat.get_unit("b2").has_status("brulure"), "brûlure terminée après 1 tour")


func test_purification_retire_un_etat_negatif() -> void:
	var combat := duo_combat(MP, GM, {"pretre": {"moyenne": 1}})
	advance_to_turn(combat, 3)
	heal_all(combat)
	combat.resolve_turn([action("b1", "fendoir", "a1")])
	heal_all(combat)
	assert_true(combat.get_unit("a1").has_status("saignement"), "le Mage saigne")
	var events := combat.resolve_turn([action("a2", "purification", "a1")])
	assert_eq(events_of_type(events, "status_removed").size(), 1, "un état retiré")
	assert_false(combat.get_unit("a1").has_status("saignement"), "plus de saignement")


func test_priere_le_surplus_devient_une_barriere() -> void:
	var combat := duo_combat(["mage", "pretre"], GM, {"pretre": {"basique": 1, "passive": 3}})
	combat.get_unit("a1").hp = combat.get_unit("a1").max_hp - 10
	combat.resolve_turn([action("a2", "priere", "a1"), action("b1", "taillade", "a2"), action("b2", "boule_de_feu", "a2")])
	assert_eq(combat.get_unit("a1").hp, combat.get_unit("a1").max_hp, "10 PV soignés")
	assert_eq(combat.get_unit("a1").barrier_amount(), int(round(skill_power("priere", "heal") * class_power("pretre"))) - 10, "le reste devient une barrière")


func test_cri_de_guerre_frappe_et_renforce_le_duo() -> void:
	var combat_hit := duo_combat(GM, GM, {"guerrier": {"forte": 1}})
	jump_to_turn(combat_hit, 3)
	var hit_events := combat_hit.resolve_turn([action("a1", "cri_de_guerre", "b2")])
	assert_eq(damage_from(hit_events, "a1", "b2"), int(round(skill_power("cri_de_guerre") * class_power("guerrier"))), "le Cri de guerre frappe sa cible")
	assert_true(combat_hit.get_unit("a2").has_status("cri_de_guerre"), "l'acolyte reçoit le bonus")


func test_cri_de_guerre_augmente_les_degats_trois_tours() -> void:
	var combat := duo_combat(GM, GM, {"guerrier": {"forte": 1}})
	jump_to_turn(combat, 3)
	var boost := 1.0 + float(skill_power("cri_de_guerre", "status")) / 100.0
	var boosted := int(round(skill_power("boule_de_feu") * mage_power * boost))
	var events := combat.resolve_turn([action("a1", "cri_de_guerre", "b1"), action("a2", "boule_de_feu", "b2")])
	assert_eq(damage_from(events, "a2", "b2"), boosted, "Boule de feu renforcée")
	heal_all(combat)
	var events_2 := combat.resolve_turn([action("a2", "boule_de_feu", "b2")])
	assert_eq(damage_from(events_2, "a2", "b2"), boosted, "toujours renforcée au deuxième tour")
	heal_all(combat)
	var events_3 := combat.resolve_turn([action("a2", "boule_de_feu", "b2")])
	assert_eq(damage_from(events_3, "a2", "b2"), boosted, "toujours renforcée au troisième tour")
	heal_all(combat)
	var events_4 := combat.resolve_turn([action("a2", "boule_de_feu", "b2")])
	assert_eq(damage_from(events_4, "a2", "b2"), int(round(skill_power("boule_de_feu") * mage_power)), "plus de bonus au quatrième tour")


func test_soins_restauration_et_foi() -> void:
	var combat := duo_combat(MP, GM)
	combat.get_unit("a1").hp = 50
	var events := combat.resolve_turn([
		action("a2", "restauration", "a1"),
		action("b1", "taillade", "a2"),
		action("b2", "boule_de_feu", "a2"),
	])
	var healed := 0
	for event in events_of_type(events, "heal"):
		if event["target"] == "a1":
			healed += int(event["amount"])
	assert_eq(healed, int(round(skill_power("restauration", "heal") * class_power("pretre") * (1.0 + pp("foi", "bonus")))), "Restauration renforcée par Foi sous le seuil de PV")


func test_egide_pose_une_barriere_sur_tout_le_duo() -> void:
	var combat := duo_combat(GP, GP)
	advance_to_turn(combat, 3)
	heal_all(combat)
	var events := combat.resolve_turn([action("a2", "egide", "a2")])
	for unit_id in ["a1", "a2"]:
		assert_true(combat.get_unit(unit_id).has_status("barriere"), "barrière sur " + unit_id)
	assert_true(events_of_type(events, "absorbed").size() >= 1, "la barrière a absorbé le Prêtre adverse, plus lent")


func test_bouclier_de_mana_et_sanctuaire() -> void:
	var combat := duo_combat(MP, GM, {"mage": {"forte": 1}, "pretre": {"passive": 3}})
	advance_to_turn(combat, 3)
	heal_all(combat)
	combat.resolve_turn([action("a1", "bouclier_de_mana", "a2"), action("a2", "egide", "a2")])
	# Le Bouclier de mana et l'Égide avec Sanctuaire : la plus grosse reste.
	var egide := int(round(skill_power("egide", "barrier") * class_power("pretre") * (1.0 + pp("sanctuaire", "bonus"))))
	assert_true(combat.get_unit("a2").barrier_amount() <= maxi(int(round(skill_power("bouclier_de_mana", "barrier") * mage_power)), egide), "barrière plafonnée à la plus grosse")
	assert_true(combat.get_unit("a1").barrier_amount() <= egide, "Égide renforcée par Sanctuaire")


func test_martyr_encaisse_une_part() -> void:
	var combat := duo_combat(MP, GM, {"pretre": {"passive": 1}})
	var events := combat.resolve_turn([action("b1", "taillade", "a1")])
	var hit := int(round(skill_power("taillade") * class_power("guerrier")))
	var share := int(round(hit * pp("martyr", "share")))
	assert_eq(damage_from(events, "b1", "a1"), hit - share, "le Mage prend le reste")
	assert_eq(damage_from(events, "b1", "a2", "martyr"), share, "le Prêtre Martyr prend sa part")


func test_second_souffle_une_seule_fois() -> void:
	var combat := duo_combat(GM, GM, {"guerrier": {"passive": 1}})
	var guerrier := combat.get_unit("a1")
	guerrier.hp = int(guerrier.max_hp * (pp("second_souffle", "threshold") + 0.03))
	combat.resolve_turn([action("b1", "taillade", "a1"), action("b2", "boule_de_feu", "a1")])
	assert_true(guerrier.flags.get("second_souffle", false), "Second souffle utilisé")
	var found := false
	for event in events_of_type(combat.history, "heal"):
		if event["kind"] == "second_souffle":
			found = true
			assert_eq(int(event["amount"]), int(round(guerrier.max_hp * pp("second_souffle", "heal"))), "soin d'une part des PV max")
	assert_true(found, "un soin Second souffle")


func test_resonance_et_meteorologue() -> void:
	var combat := duo_combat(GM, GM, {"mage": {"moyenne": 1}})
	advance_to_turn(combat, 3)
	heal_all(combat)
	combat.resolve_turn([action("a2", "nova", "b1")])
	assert_eq(combat.cooldown_remaining(combat.get_unit("a2"), "forte"), 3, "Résonance : recharge réduite d'un tour")
	var combat_2 := duo_combat(GM, GM, {"mage": {"passive": 3}})
	advance_to_turn(combat_2, 3)
	heal_all(combat_2)
	combat_2.resolve_turn([action("a2", "nova", "b1")])
	assert_eq(combat_2.cooldown_remaining(combat_2.get_unit("a2"), "forte"), 3, "Météorologue : forte revient 1 tour plus tôt")


func test_veteran_gagne_de_la_vitesse() -> void:
	var combat := duo_combat(GM, GM, {"guerrier": {"passive": 2}})
	combat.get_unit("a2").hp = 0
	combat._actions = {}
	assert_eq(combat.effective_speed(combat.get_unit("a1")), 9 + int(data.passive_param("veteran", "speed", 1)), "bonus de vitesse quand l'acolyte est KO")
	combat.get_unit("a2").hp = 10
	assert_eq(combat.effective_speed(combat.get_unit("a1")), 9, "pas de bonus de vitesse tant que l'acolyte est debout")


func test_resurrection_une_fois_par_combat() -> void:
	var combat := duo_combat(MP, GM, {"pretre": {"forte": 1}})
	advance_to_turn(combat, 3)
	heal_all(combat)
	var mage := combat.get_unit("a1")
	mage.hp = 0
	var events := combat.resolve_turn([action("a2", "resurrection", "a1")])
	assert_eq(events_of_type(events, "revive").size(), 1, "relevé")
	assert_true(mage.is_alive(), "le Mage est debout")
	assert_eq(mage.hp, int(round(mage.max_hp * data.skill("resurrection")["effects"][0]["percent"] / 100.0)), "relevé avec une part de ses PV max")
	assert_true(mage.flags.get("revived", false), "ne peut plus être relevé")
	assert_false(combat.can_use(combat.get_unit("a2"), "forte"), "Résurrection utilisée pour le combat")
	jump_to_turn(combat, 9)
	assert_false(combat.can_use(combat.get_unit("a2"), "forte"), "toujours indisponible après la recharge")
	mage.hp = 0
	assert_false(combat.valid_targets(combat.get_unit("a2"), "resurrection").has(mage), "un perso ne se relève qu'une fois")


func test_prevision_egale_les_degats_reels() -> void:
	var combat := duo_combat(GM, GM, {"mage": {"passive": 1}})
	var mage := combat.get_unit("a2")
	var target := combat.get_unit("b1")
	var forecast := combat.preview(mage, "boule_de_feu", target)
	var hp_before := target.hp
	var events := combat.resolve_turn([action("a2", "boule_de_feu", "b1")])
	assert_eq(int(forecast["damage"]), damage_from(events, "a2", "b1"), "la prévision annonce les vrais dégâts")
	assert_eq(target.hp, hp_before - damage_from_all(events, "b1"), "la prévision ne modifie rien")


func test_prevision_coup_fatal_et_rempart() -> void:
	var combat := duo_combat(GM, GM)
	var target := combat.get_unit("b2")
	target.hp = 20
	assert_true(combat.preview(combat.get_unit("a1"), "taillade", target)["lethal"], "Taillade achève un Mage à 20 PV")
	target.add_status({"id": "rempart", "turns": 1, "value": 1})
	var forecast := combat.preview(combat.get_unit("a1"), "taillade", target)
	assert_true(forecast["blocked"], "le Rempart bloquera le coup")
	assert_false(forecast["lethal"], "donc pas fatal")


func test_partenaires_de_synergie() -> void:
	var combat := duo_combat(GM, GM)
	var found := false
	for partner in combat.synergy_partners(combat.get_unit("a1"))["moyenne"]:
		if partner["skill_id"] == "nova":
			found = true
			assert_eq(partner["ally_id"], "a2", "l'acolyte Mage a la Nova")
			assert_false(partner["available"], "Nova indisponible au tour 1")
	assert_true(found, "Provocation trouve la Nova de l'acolyte")
	jump_to_turn(combat, 3)
	for partner in combat.synergy_partners(combat.get_unit("a1"))["moyenne"]:
		if partner["skill_id"] == "nova":
			assert_true(partner["available"], "Nova disponible au tour 3")
