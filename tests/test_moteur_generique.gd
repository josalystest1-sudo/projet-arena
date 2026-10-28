## Le moteur générique : les passifs sont lus par paramètres, les états par drapeaux, les Synergies par type d'effet,
## et les nœuds de Destin passeront par les mêmes clés (CombatUnit.mods).
extends "res://tests/test_case.gd"

const GM := ["guerrier", "mage"]


func test_les_passifs_sont_lus_par_parametres() -> void:
	# Un passif ne compte que par ses clés : « reduction » réduit les dégâts subis, quel que soit son nom.
	data.passives["cuir_epais"] = {"name": "Cuir épais", "class": "mage", "params": {"reduction": 0.5}, "description": "-{reduction%} de dégâts subis."}
	var combat := duo_combat(GM, GM)
	var mage := combat.get_unit("b2")
	var before := combat._damage_amount(combat.get_unit("a1"), mage, 40, 1.0, true, "tranchant")
	mage.passive = "cuir_epais"
	assert_eq(combat._damage_amount(combat.get_unit("a1"), mage, 40, 1.0, true, "tranchant"), int(round(before * 0.5)), "le nouveau passif réduit les dégâts de moitié")
	assert_eq(data.passive_description("cuir_epais"), "-50 % de dégâts subis.", "sa description se remplit avec ses chiffres")


func test_les_modificateurs_du_destin_s_ajoutent_au_passif() -> void:
	var combat := duo_combat(GM, GM)
	var guerrier := combat.get_unit("b1")
	assert_eq(guerrier.passive, "peau_de_fer", "le Guerrier a Peau de fer")
	var attacker := combat.get_unit("a2")
	var before := combat._damage_amount(attacker, guerrier, 40, 1.0, true, "feu")
	guerrier.apply_mods(data, {"reduction": 0.1})
	var total := pp("peau_de_fer", "reduction") + 0.1
	assert_eq(combat._damage_amount(attacker, guerrier, 40, 1.0, true, "feu"), int(round(40.0 * class_power("mage") * (1.0 - total))), "Peau de fer + un nœud « -10 % de dégâts subis »")
	assert_true(combat._damage_amount(attacker, guerrier, 40, 1.0, true, "feu") < before, "moins de dégâts qu'avant")


func test_les_modificateurs_de_stats_et_d_immunite() -> void:
	var combat := duo_combat(GM, GM)
	var mage := combat.get_unit("a2")
	var hp := mage.max_hp
	var power := mage.power
	mage.apply_mods(data, {"hp_pct": 0.1, "power_pct": -0.05, "speed_bonus": 2, "immune": ["gele"]})
	assert_eq(mage.max_hp, int(round(hp * 1.1)), "+10 % de PV max")
	assert_eq(mage.hp, mage.max_hp, "à fond")
	assert_eq(mage.power, int(round(power * 0.95)), "-5 % de puissance")
	combat._actions = {}
	assert_eq(combat.effective_speed(mage), mage.base_speed + 2, "+2 vitesse")
	assert_true(mage.is_immune("gele"), "immunisé au Gelé")
	var events := combat.resolve_turn([action("b2", "trait_de_givre", "a2")])
	assert_false(mage.has_status("gele"), "le Trait de givre ne gèle pas un immunisé")
	assert_eq(events_of_type(events, "immune").size(), 1, "l'immunité est signalée")


func test_les_evolutions_de_competence_du_destin() -> void:
	# Le Mage a Focalisation (pas Résonance, qui rendrait aussi un tour de recharge).
	var combat := duo_combat(GM, GM, {"mage": {"passive": 1}})
	var mage := combat.get_unit("a2")
	mage.apply_mods(data, {}, {"boule_de_feu": {"power_bonus": 0.25}, "nova": {"cooldown_minus": 1}})
	var events := combat.resolve_turn([action("a2", "boule_de_feu", "b2")])
	assert_eq(damage_from(events, "a2", "b2"), int(round(round(skill_power("boule_de_feu") * 1.25) * class_power("mage") * (1.0 + pp("focalisation", "single_target_bonus")))), "Boule de feu +25 % (et Focalisation)")
	jump_to_turn(combat, 3)
	heal_all(combat)
	combat.resolve_turn([action("a2", "nova", "b1")])
	assert_eq(combat.cooldown_remaining(mage, "forte"), 3, "la Nova revient un tour plus tôt")


func test_les_etats_ont_des_drapeaux() -> void:
	assert_eq(data.dot_statuses(), ["saignement", "brulure"], "les dégâts sur la durée, dans l'ordre des données")
	assert_true(data.status_flag("gele", "control"), "Gelé est un contrôle")
	assert_false(data.status_flag("barriere", "negative"), "une barrière n'est pas négative")
	assert_eq(data.status_kind("rempart"), "protection", "un Rempart protège (pour l'IA)")


func test_contact_ou_a_distance() -> void:
	assert_true(data.is_contact("taillade"), "une Taillade se donne au contact")
	assert_false(data.is_contact("boule_de_feu"), "une Boule de feu, non")
	data.skills["lancer_test"] = {"name": "Lancer", "class": "mage", "tier": "basique", "element": "perforant", "target": "enemy", "ranged": true, "effects": [{"type": "damage", "power": 30}]}
	assert_false(data.is_contact("lancer_test"), "une dague lancée est à distance")


func test_une_synergie_joker_de_palier() -> void:
	# « Hymne + n'importe quelle forte » (GDD) : un joker « *forte » accepte toute forte d'une autre classe.
	data.skills["hymne_test"] = {"name": "Hymne", "class": "barde_test", "tier": "moyenne", "element": "foudre", "target": "enemy", "effects": [{"type": "damage", "power": 20}]}
	data.synergies.append({"id": "hymne_test_forte", "name": "Tempo", "skills": ["hymne_test", "*forte"], "effect": {"type": "cooldown_minus", "tier": "forte"}, "params": {"amount": 1}, "description": ""})
	assert_eq(data.find_synergy("hymne_test", "nova")["id"], "hymne_test_forte", "l'Hymne et la Nova font Synergie")
	assert_eq(data.find_synergy("fendoir", "hymne_test")["id"], "hymne_test_forte", "dans les deux sens, avec n'importe quelle forte")
	assert_true(data.find_synergy("hymne_test", "trait_de_givre").is_empty(), "pas avec une moyenne")
	assert_true(data.find_synergy("hymne_test", "hymne_test").is_empty(), "jamais avec elle-même")


func test_chaque_synergie_a_un_effet_connu() -> void:
	var known := ["amplify", "force_condition", "extra_damage", "extend_status", "add_status", "spread_to_duo", "spread_to_enemies",
		"cooldown_minus", "heal_duo", "barrier_duo", "cleanse_duo", "lifesteal", "extra_counter"]
	for synergy in data.synergies:
		var effect: Dictionary = synergy.get("effect", {})
		assert_true(known.has(str(effect.get("type", ""))), "%s : effet de type connu (%s)" % [synergy["id"], str(effect.get("type", "?"))])
		if synergy.has("lever"):
			assert_true(synergy.get("params", {}).has(synergy["lever"]), "%s : son levier est un de ses chiffres" % synergy["id"])
		assert_false(data.synergy_description(synergy).contains("{"), "%s : description remplie" % synergy["id"])
	for passive_id in data.passives:
		var passive: Dictionary = data.passives[passive_id]
		if passive.has("lever"):
			assert_true(passive.get("params", {}).has(passive["lever"]), "%s : son levier est un de ses chiffres" % passive_id)
		assert_false(data.passive_description(passive_id).contains("{"), passive_id + " : description remplie")
