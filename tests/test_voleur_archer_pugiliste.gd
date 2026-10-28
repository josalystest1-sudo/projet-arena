## Voleur, Archer, Pugiliste : leurs compétences, leurs passifs, leurs Synergies et ce qu'en fait l'IA.
extends "res://tests/test_case.gd"

const GM := ["guerrier", "mage"]
const VG := ["voleur", "guerrier"]
const AG := ["archer", "guerrier"]
const PM := ["pugiliste", "mage"]


func hits_of(events: Array, actor: String) -> Array:
	for event in events_of_type(events, "action"):
		if event["actor"] == actor:
			return event["targets"]
	return []


# --- Le Voleur ------------------------------------------------------------------

func test_voile_rend_intouchable_puis_fait_agir_en_premier() -> void:
	var combat := duo_combat(VG, GM, {}, {"mage": {"basique": 1}})
	var events := combat.resolve_turn([action("a1", "voile", "a1"), action("b1", "taillade", "a1"), action("b2", "etincelle", "a1")])
	# L'Étincelle (vitesse 14) part avant le Voile ; la Taillade (9), après : elle se rabat sur l'autre membre du duo.
	assert_eq(hits_of(events, "b2"), ["a1"], "l'Étincelle, plus rapide que le Voile, touche encore le Voleur")
	assert_eq(hits_of(events, "b1"), ["a2"], "la Taillade ne peut plus viser le Voleur : elle frappe le Guerrier")
	assert_false(combat.get_unit("a1").has_status("voile"), "le Voile tombe en fin de tour")
	combat.get_unit("a1").add_status({"id": "voile", "turns": 1})
	assert_false(combat.valid_targets(combat.get_unit("b1"), "taillade").has(combat.get_unit("a1")), "tant qu'il est voilé, on ne peut pas le choisir comme cible")
	combat.get_unit("a1").remove_status("voile")
	heal_all(combat)
	var next := combat.resolve_turn([action("b2", "etincelle", "a1")])
	assert_eq(action_order(next)[0], "a1", "au tour suivant, le Voleur agit en premier, avant même l'Étincelle")
	assert_eq(hits_of(next, "b2"), ["a1"], "et il est de nouveau visible")


func test_poison_fait_des_degats_trois_tours() -> void:
	var combat := duo_combat(VG, GM, {"voleur": {"moyenne": 1}})
	var value := skill_power("poison", "status")
	var events := combat.resolve_turn([action("a1", "poison", "b2")])
	assert_eq(damage_from(events, "a1", "b2", "dot"), value, "le poison frappe en fin de tour")
	assert_true(data.is_negative_status("poison"), "un état négatif")
	heal_all(combat)
	combat.resolve_turn([])
	heal_all(combat)
	var third := combat.resolve_turn([])
	assert_eq(damage_from(third, "a1", "b2", "dot"), value, "encore au troisième tour")
	assert_false(combat.get_unit("b2").has_status("poison"), "puis il s'arrête")


func test_coup_bas_double_sur_une_cible_qui_n_a_pas_agi() -> void:
	var combat := duo_combat(VG, GM)
	jump_to_turn(combat, 3)
	var events := combat.resolve_turn([action("a1", "coup_bas", "b2")])
	assert_eq(damage_from(events, "a1", "b2"), int(round(skill_power("coup_bas") * 2.0)), "le Voleur (vitesse 11) frappe avant le Mage : doublé")
	var slow := duo_combat(VG, GM, {}, {"mage": {"basique": 1}})
	jump_to_turn(slow, 3)
	var late := slow.resolve_turn([action("a1", "coup_bas", "b2"), action("b2", "etincelle", "a2")])
	assert_eq(damage_from(late, "a1", "b2"), skill_power("coup_bas"), "le Mage à l'Étincelle a déjà agi : dégâts normaux")


func test_sabotage_renvoie_la_forte_adverse_en_recharge() -> void:
	var combat := duo_combat(VG, GM, {"voleur": {"forte": 1}})
	jump_to_turn(combat, 3)
	assert_true(combat.can_use(combat.get_unit("b1"), "forte"), "la forte adverse est prête")
	var events := combat.resolve_turn([action("a1", "sabotage", "b1")])
	assert_eq(events_of_type(events, "cooldown_delayed").size(), 1, "recharge retardée")
	assert_eq(combat.cooldown_remaining(combat.get_unit("b1"), "forte"), 4, "comme si le Guerrier venait de la jouer")


func test_opportuniste_fuite_doigts_agiles_mise_a_mort() -> void:
	# Opportuniste : +30 % sur une cible déjà touchée ce tour (le Mage à l'Étincelle frappe avant lui).
	var combat := duo_combat(["voleur", "mage"], GM, {"mage": {"basique": 1}})
	var events := combat.resolve_turn([action("a1", "dague", "b2"), action("a2", "etincelle", "b2")])
	assert_eq(damage_from(events, "a1", "b2"), int(round(skill_power("dague") * (1.0 + pp("opportuniste", "hit_target_bonus")))), "Opportuniste")
	# Fuite : la première attaque du combat est esquivée.
	var fleeing := duo_combat(VG, GM, {"voleur": {"passive": 1}})
	var dodge := fleeing.resolve_turn([action("b1", "taillade", "a1"), action("b2", "boule_de_feu", "a1")])
	assert_eq(events_of_type(dodge, "dodged").size(), 1, "une esquive")
	assert_eq(damage_from(dodge, "b1", "a1"), 0, "la Taillade (la première) ne touche pas")
	assert_true(damage_from(dodge, "b2", "a1") > 0, "la Boule de feu passe")
	assert_true(fleeing.preview(fleeing.get_unit("b1"), "taillade", fleeing.get_unit("a1"))["damage"] > 0, "la prévision annonce des dégâts une fois l'esquive dépensée")
	# Doigts agiles : la moyenne revient un tour plus tôt.
	var agile := duo_combat(VG, GM, {"voleur": {"passive": 2, "moyenne": 1}})
	agile.resolve_turn([action("a1", "poison", "b2")])
	assert_eq(agile.cooldown_remaining(agile.get_unit("a1"), "moyenne"), 1, "un seul tour de recharge")
	# Mise à mort : +30 % sous 35 % de PV.
	var killer := duo_combat(VG, GM, {"voleur": {"passive": 3}})
	set_ratio(killer, "b2", 0.3)
	var kill := killer.resolve_turn([action("a1", "dague", "b2")])
	assert_eq(damage_from(kill, "a1", "b2"), int(round(skill_power("dague") * (1.0 + pp("mise_a_mort", "execute_bonus")))), "Mise à mort")


# --- L'Archer -------------------------------------------------------------------

func test_marque_augmente_les_degats_subis() -> void:
	var combat := duo_combat(AG, GM, {"archer": {"passive": 3}})
	var events := combat.resolve_turn([action("a1", "marque", "b2"), action("a2", "taillade", "b2")])
	assert_true(combat.get_unit("b2").has_status("marque"), "la cible est marquée")
	var boost := 1.0 + float(skill_power("marque", "status")) / 100.0
	assert_eq(damage_from(events, "a2", "b2"), int(round(skill_power("taillade") * class_power("guerrier") * boost)), "le Guerrier, plus lent, frappe une cible marquée")


func test_piege_etourdit_le_prochain_attaquant() -> void:
	var combat := duo_combat(AG, GM, {"archer": {"moyenne": 1}})
	var events := combat.resolve_turn([action("a1", "piege", "a2"), action("b1", "taillade", "a2"), action("b2", "boule_de_feu", "a2")])
	assert_eq(events_of_type(events, "trapped").size(), 1, "le piège se referme une fois")
	var guerrier := combat.get_unit("b1")
	assert_true(guerrier.has_status("etourdi"), "le Guerrier adverse, premier à frapper, est étourdi")
	assert_false(combat.get_unit("b2").has_status("etourdi"), "le Mage ne l'est pas")
	heal_all(combat)
	var next := combat.resolve_turn([action("b1", "provocation", "a1")])
	var lost := events_of_type(next, "action_lost")
	assert_eq(lost.size(), 1, "il perd son action")
	assert_eq(lost[0]["reason"], "etourdi", "parce qu'il est étourdi")
	assert_true(combat.can_use(guerrier, "moyenne"), "sa Provocation n'a pas été dépensée")
	assert_false(guerrier.has_status("etourdi"), "l'étourdissement est passé")


func test_fleche_barbelee_et_pluie_de_fleches() -> void:
	var combat := duo_combat(AG, GM)
	jump_to_turn(combat, 3)
	combat.resolve_turn([action("a1", "fleche_barbelee", "b2")])
	assert_eq(int(combat.get_unit("b2").get_status("saignement")["value"]), skill_power("fleche_barbelee", "status"), "lourd saignement")
	var rain := duo_combat(AG, GM, {"archer": {"forte": 1}})
	jump_to_turn(rain, 3)
	var events := rain.resolve_turn([action("a1", "pluie_de_fleches", "b1")])
	assert_eq(hits_of(events, "a1").size(), 2, "tous les ennemis")


func test_oeil_de_faucon_calme_sang_froid_traqueur() -> void:
	# Œil de faucon : +15 % sur une cible marquée.
	var combat := duo_combat(AG, GM)
	combat.get_unit("b2").add_status({"id": "marque", "turns": 2, "value": 25})
	var events := combat.resolve_turn([action("a1", "tir", "b2")])
	assert_eq(damage_from(events, "a1", "b2"), int(round(skill_power("tir") * (1.0 + pp("oeil_de_faucon", "marked_target_bonus")) * 1.25)), "Œil de faucon et la Marque")
	# Calme : agit en dernier, +25 %.
	var calm := duo_combat(AG, GM, {"archer": {"passive": 1}})
	var late := calm.resolve_turn([action("a1", "tir", "b2")])
	assert_eq(action_order(late)[3], "a1", "l'Archer calme agit en dernier")
	assert_eq(damage_from(late, "a1", "b2"), int(round(skill_power("tir") * (1.0 + pp("calme", "act_last_bonus")))), "+25 % de dégâts")
	# Sang-froid : ni gelé, ni repoussé.
	var cool := duo_combat(AG, GM, {"archer": {"passive": 2}}, {"guerrier": {"basique": 1}})
	var controls := cool.resolve_turn([action("b2", "trait_de_givre", "a1"), action("b1", "coup_de_bouclier", "a1")])
	assert_false(cool.get_unit("a1").has_status("gele"), "pas gelé")
	assert_eq(events_of_type(controls, "immune").size(), 2, "immunisé au gel et au Coup de bouclier")
	# Traqueur : +15 % sur une cible qui saigne.
	var tracker := duo_combat(AG, GM, {"archer": {"passive": 3}})
	tracker.get_unit("b2").add_status({"id": "saignement", "turns": 2, "value": 5, "source": "a2"})
	var track := tracker.resolve_turn([action("a1", "tir", "b2")])
	assert_eq(damage_from(track, "a1", "b2", "hit"), int(round(skill_power("tir") * (1.0 + pp("traqueur", "dot_target_bonus")))), "Traqueur")


# --- Le Pugiliste ---------------------------------------------------------------

func test_jab_puis_crochet() -> void:
	var combat := duo_combat(PM, GM, {"pugiliste": {"moyenne": 1}})
	var first := combat.resolve_turn([action("a1", "jab", "b2")])
	assert_eq(action_order(first)[0], "a1", "le Jab part en premier")
	heal_all(combat)
	var second := combat.resolve_turn([action("a1", "crochet", "b2")])
	assert_eq(damage_from(second, "a1", "b2"), int(round(skill_power("crochet") * 2.0 * class_power("pugiliste"))), "Crochet doublé après un Jab qui a touché")
	var cold := duo_combat(PM, GM, {"pugiliste": {"moyenne": 1}})
	var plain := cold.resolve_turn([action("a1", "crochet", "b2")])
	assert_eq(damage_from(plain, "a1", "b2"), int(round(skill_power("crochet") * class_power("pugiliste"))), "sans Jab au tour d'avant : dégâts normaux")


func test_garde_haute_reduit_les_degats_et_riposte_au_contact() -> void:
	var combat := duo_combat(PM, ["guerrier", "voleur"], {}, {"voleur": {"basique": 1}})
	var events := combat.resolve_turn([action("a1", "garde_haute", "a1"), action("b1", "taillade", "a1"), action("b2", "lancer", "a1")])
	var garde: Dictionary = data.skill("garde_haute")["effects"][0]
	var reduced := int(round(skill_power("taillade") * class_power("guerrier") * (1.0 - float(garde["value"]) / 100.0)))
	assert_eq(damage_from(events, "b1", "a1"), reduced, "la Taillade est amortie")
	assert_true(damage_from(events, "a1", "b1", "garde") > 0, "le Guerrier, au contact, prend une contre-attaque")
	assert_eq(damage_from(events, "a1", "b2", "garde"), 0, "le Lancer, à distance, n'en prend pas")
	var spell := duo_combat(PM, GM)
	var magic := spell.resolve_turn([action("a1", "garde_haute", "a1"), action("b2", "boule_de_feu", "a1")])
	assert_eq(damage_from(magic, "a1", "b2", "garde"), 0, "un sort non plus")
	assert_true(spell.get_unit("a1").has_status("garde"), "la garde tient jusqu'à la fin du tour suivant")


func test_uppercut_et_enchainement() -> void:
	var combat := duo_combat(PM, GM)
	jump_to_turn(combat, 3)
	combat.resolve_turn([action("a1", "uppercut", "b1")])
	assert_true(combat.get_unit("b1").has_status("gele"), "la cible est sonnée")
	heal_all(combat)
	assert_eq(action_order(combat.resolve_turn([]))[3], "b1", "elle agit en dernier au tour suivant")
	var chain := duo_combat(PM, GM, {"pugiliste": {"forte": 1}})
	jump_to_turn(chain, 3)
	var events := chain.resolve_turn([action("a1", "enchainement", "b2")])
	var blows := 0
	for event in events_of_type(events, "damage"):
		if event["source"] == "a1" and event["kind"] == "hit":
			blows += 1
	assert_eq(blows, 3, "trois coups")


func test_cardio_machoire_esquive_enchaineur() -> void:
	# Cardio : +1 vitesse par tour sans être touché, remis à zéro au premier coup.
	var combat := duo_combat(PM, GM)
	combat.resolve_turn([action("b1", "taillade", "a2"), action("b2", "boule_de_feu", "a2")])
	heal_all(combat)
	combat.resolve_turn([action("b1", "taillade", "a2"), action("b2", "boule_de_feu", "a2")])
	combat._actions = {}
	var pugiliste := combat.get_unit("a1")
	assert_eq(combat.effective_speed(pugiliste), pugiliste.base_speed + 2, "deux tours tranquilles : +2")
	heal_all(combat)
	combat.resolve_turn([action("b1", "taillade", "a1")])
	combat._actions = {}
	assert_eq(combat.effective_speed(pugiliste), pugiliste.base_speed, "touché : remis à zéro")
	# Mâchoire d'acier : -25 % de dégâts physiques, rien contre le feu.
	var jaw := duo_combat(PM, GM, {"pugiliste": {"passive": 1}})
	var hits := jaw.resolve_turn([action("b1", "taillade", "a1"), action("b2", "boule_de_feu", "a1")])
	assert_eq(damage_from(hits, "b1", "a1"), int(round(skill_power("taillade") * class_power("guerrier") * (1.0 - pp("machoire_d_acier", "physical_reduction")))), "Taillade amortie")
	assert_eq(damage_from(hits, "b2", "a1"), int(round(skill_power("boule_de_feu") * class_power("mage"))), "Boule de feu entière")
	# Esquive : une au début, une de plus à partir du tour donné.
	var dodger := duo_combat(PM, GM, {"pugiliste": {"passive": 2}})
	var first := dodger.resolve_turn([action("b1", "taillade", "a1"), action("b2", "boule_de_feu", "a1")])
	assert_eq(events_of_type(first, "dodged").size(), 1, "la première attaque est esquivée")
	heal_all(dodger)
	jump_to_turn(dodger, int(pp("esquive", "dodge_again_from_turn")))
	var later := dodger.resolve_turn([action("b1", "taillade", "a1"), action("b2", "boule_de_feu", "a1")])
	assert_eq(events_of_type(later, "dodged").size(), 1, "une esquive de plus en seconde moitié de combat")
	# Enchaîneur : chaque coup consécutif sur la même cible est plus fort, changer de cible remet à zéro.
	var combo := duo_combat(PM, GM, {"pugiliste": {"passive": 3, "basique": 1}})
	var base := skill_power("direct") * class_power("pugiliste")
	var bonus := pp("enchaineur", "combo_bonus")
	assert_eq(damage_from(combo.resolve_turn([action("a1", "direct", "b2")]), "a1", "b2"), int(round(base)), "premier coup : normal")
	heal_all(combo)
	assert_eq(damage_from(combo.resolve_turn([action("a1", "direct", "b2")]), "a1", "b2"), int(round(base * (1.0 + bonus))), "deuxième coup sur la même cible : +8 %")
	heal_all(combo)
	assert_eq(damage_from(combo.resolve_turn([action("a1", "direct", "b2")]), "a1", "b2"), int(round(base * (1.0 + 2.0 * bonus))), "troisième : +16 %")
	heal_all(combo)
	var switched := combo.resolve_turn([action("a1", "direct", "b1")])
	assert_eq(damage_from(switched, "a1", "b1"), int(round(base * (1.0 - pp("peau_de_fer", "reduction")))), "autre cible : le compte repart de zéro")


# --- Les Synergies des trois classes ----------------------------------------------

func fire(combat: Combat, actions: Array, name: String) -> Array:
	var events := combat.resolve_turn(actions)
	var fired := events_of_type(events, "synergy")
	assert_eq(fired.size(), 1, name + " se déclenche")
	if not fired.is_empty():
		assert_eq(fired[0]["name"], name, "la bonne Synergie")
	return events


func test_synergies_du_voleur() -> void:
	# Lame souillée : le Fendoir +50 % sur la cible empoisonnée.
	var combat := duo_combat(VG, GM, {"voleur": {"moyenne": 1}})
	jump_to_turn(combat, 3)
	var events := fire(combat, [action("a1", "poison", "b2"), action("a2", "fendoir", "b2")], "Lame souillée")
	assert_eq(damage_from(events, "a2", "b2", "hit"), int(round(skill_power("fendoir") * class_power("guerrier") * (1.0 + sp("poison_fendoir", "bonus")))), "Fendoir renforcé")
	# Embuscade : la forte du Voleur revient 1 tour plus tôt.
	var ambush := duo_combat(VG, GM, {"guerrier": {"forte": 1}})
	jump_to_turn(ambush, 4)
	ambush.get_unit("a1").cooldown_until["forte"] = 8
	fire(ambush, [action("a1", "voile", "a1"), action("a2", "cri_de_guerre", "b1")], "Embuscade")
	assert_eq(ambush.cooldown_remaining(ambush.get_unit("a1"), "forte"), 2, "au tour 5, il reste 2 tours au lieu de 3")
	# Accablement : la cible est affaiblie.
	var crush := duo_combat(["voleur", "pretre"], GM)
	jump_to_turn(crush, 3)
	fire(crush, [action("a1", "coup_bas", "b2"), action("a2", "chatiment", "b2")], "Accablement")
	assert_eq(int(crush.get_unit("b2").get_status("affaibli")["value"]), int(sp("coup_bas_chatiment", "value")), "affaibli")
	# Larcin : la moyenne du Prêtre revient 1 tour plus tôt.
	var theft := duo_combat(["voleur", "pretre"], GM, {"voleur": {"forte": 1}, "pretre": {"basique": 1}})
	jump_to_turn(theft, 3)
	theft.get_unit("a2").cooldown_until["moyenne"] = 6
	fire(theft, [action("a1", "sabotage", "b2"), action("a2", "priere", "a1")], "Larcin")
	assert_eq(theft.cooldown_remaining(theft.get_unit("a2"), "moyenne"), 1, "un tour de moins")
	# Une-deux : 30 dégâts de plus sur la cible.
	var combo := duo_combat(["voleur", "pugiliste"], GM, {"pugiliste": {"moyenne": 1}})
	var blows := fire(combo, [action("a1", "dague", "b2"), action("a2", "crochet", "b2")], "Une-deux")
	assert_eq(damage_from(blows, "a2", "b2", "synergie"), int(sp("dague_crochet", "damage")), "dégâts bonus")
	# Couverture : le Voleur reçoit une garde à moitié.
	var cover := duo_combat(["voleur", "pugiliste"], GM, {"voleur": {"basique": 1}})
	fire(cover, [action("a1", "lancer", "b2"), action("a2", "garde_haute", "a2")], "Couverture")
	assert_eq(int(cover.get_unit("a1").get_status("garde")["value"]), int(round(float(skill_power("garde_haute", "status")) * sp("lancer_garde_haute", "share"))), "garde partagée")


func test_synergies_de_l_archer() -> void:
	# Proie : le Fendoir +40 % sur la cible marquée (et la Marque elle-même : +25 %).
	var combat := duo_combat(AG, GM)
	jump_to_turn(combat, 3)
	var events := fire(combat, [action("a1", "marque", "b2"), action("a2", "fendoir", "b2")], "Proie")
	assert_eq(damage_from(events, "a2", "b2", "hit"), int(round(skill_power("fendoir") * class_power("guerrier") * (1.0 + sp("marque_fendoir", "bonus")) * 1.25)), "Fendoir renforcé")
	# Guet-apens : le duo gagne de la vitesse.
	var trap := duo_combat(AG, GM, {"archer": {"moyenne": 1}, "guerrier": {"forte": 1}})
	jump_to_turn(trap, 3)
	fire(trap, [action("a1", "piege", "a2"), action("a2", "cri_de_guerre", "b1")], "Guet-apens")
	assert_true(trap.get_unit("a1").has_status("vif") and trap.get_unit("a2").has_status("vif"), "tout le duo est vif")
	# Révélation : la cible est marquée.
	var light := duo_combat(["archer", "pretre"], GM)
	fire(light, [action("a1", "tir", "b2"), action("a2", "chatiment", "b2")], "Révélation")
	assert_true(light.get_unit("b2").has_status("marque"), "marquée")
	# Purge : un état négatif retiré à chacun.
	var purge := duo_combat(["archer", "pretre"], GM, {"archer": {"basique": 1}, "pretre": {"basique": 1}})
	purge.get_unit("a1").add_status({"id": "saignement", "turns": 3, "value": 5, "source": "b1"})
	purge.get_unit("a2").add_status({"id": "poison", "turns": 3, "value": 5, "source": "b1"})
	fire(purge, [action("a1", "tir_rapide", "b2"), action("a2", "priere", "a2")], "Purge")
	assert_false(purge.get_unit("a1").has_status("saignement") or purge.get_unit("a2").has_status("poison"), "les deux sont purgés")
	# Hallali : une part des dégâts du couple soigne le plus blessé.
	var hunt := duo_combat(["archer", "pugiliste"], GM)
	jump_to_turn(hunt, 3)
	hunt.get_unit("a1").hp = 100
	var kill := fire(hunt, [action("a1", "fleche_barbelee", "b2"), action("a2", "jab", "b2")], "Hallali")
	var healed := 0
	for event in events_of_type(kill, "heal"):
		if event["kind"] == "synergie":
			healed += int(event["amount"])
	assert_eq(healed, int(round(float(damage_from(kill, "a1", "b2", "hit") + damage_from(kill, "a2", "b2", "hit")) * sp("fleche_barbelee_jab", "share"))), "soin d'une part des dégâts")
	# Déluge : tous les ennemis agiront en dernier.
	var rain := duo_combat(["archer", "pugiliste"], GM, {"archer": {"forte": 1}, "pugiliste": {"basique": 1}})
	jump_to_turn(rain, 3)
	fire(rain, [action("a1", "pluie_de_fleches", "b1"), action("a2", "direct", "b1")], "Déluge")
	assert_true(rain.get_unit("b1").has_status("gele") and rain.get_unit("b2").has_status("gele"), "les deux ennemis sont gelés")


func test_synergies_du_pugiliste() -> void:
	# Givre brisé (GDD) : la cible gelée est étourdie, elle perd son action du tour suivant.
	var combat := duo_combat(PM, GM, {"pugiliste": {"moyenne": 1}})
	fire(combat, [action("a1", "crochet", "b1"), action("a2", "trait_de_givre", "b1")], "Givre brisé")
	assert_true(combat.get_unit("b1").has_status("etourdi"), "étourdi")
	heal_all(combat)
	var next := combat.resolve_turn([])
	assert_eq(events_of_type(next, "action_lost").size(), 1, "le Guerrier adverse perd son action")
	# Paratonnerre : barrière sur le duo.
	var rod := duo_combat(PM, GM, {"mage": {"moyenne": 1}})
	fire(rod, [action("a1", "garde_haute", "a1"), action("a2", "arc_de_foudre", "b1")], "Paratonnerre")
	assert_true(rod.get_unit("a1").has_status("barriere") and rod.get_unit("a2").has_status("barriere"), "les deux ont une barrière")
	# Coup du ciel : des dégâts de lumière en plus.
	var sky := duo_combat(["pugiliste", "pretre"], GM)
	jump_to_turn(sky, 3)
	var events := fire(sky, [action("a1", "uppercut", "b2"), action("a2", "chatiment", "b2")], "Coup du ciel")
	assert_eq(damage_from(events, "a2", "b2", "synergie"), int(sp("uppercut_chatiment", "damage")), "dégâts de lumière bonus")
	# Litanie : tout le duo se soigne.
	var litany := duo_combat(["pugiliste", "pretre"], GM, {"pugiliste": {"forte": 1}, "pretre": {"basique": 1, "passive": 3}})
	jump_to_turn(litany, 3)
	litany.get_unit("a1").hp = 100
	litany.get_unit("a2").hp = 100
	var heals := fire(litany, [action("a1", "enchainement", "b2"), action("a2", "priere", "a2")], "Litanie")
	var healed := {}
	for event in events_of_type(heals, "heal"):
		if event["kind"] == "synergie":
			healed[event["target"]] = int(event["amount"])
	assert_eq(healed.get("a1", 0), int(round(sp("enchainement_priere", "power") * class_power("pretre"))), "le Pugiliste est soigné")
	assert_true(healed.has("a2"), "le Prêtre aussi")


# --- Ce qu'en fait l'IA -------------------------------------------------------------

func test_un_acolyte_pugiliste_se_met_en_garde_quand_il_a_perdu_des_pv() -> void:
	var combat := duo_combat(["mage", "pugiliste"], GM)
	var decision := CombatAI.decide_acolyte(combat, combat.get_unit("a2"))
	assert_eq(decision["action"].skill_id, "jab", "à fond : il frappe")
	combat.get_unit("a2").hp = 200
	decision = CombatAI.decide_acolyte(combat, combat.get_unit("a2"))
	assert_eq(decision["action"].skill_id, "garde_haute", "entamé : il se met en garde")
	assert_eq(decision["action"].target_id, "a2", "sur lui-même")
	assert_eq(decision["rule"], "protege", "règle : il protège")
	combat.get_unit("a2").add_status({"id": "garde", "turns": 2, "value": 30})
	assert_eq(CombatAI.decide_acolyte(combat, combat.get_unit("a2"))["action"].skill_id, "jab", "déjà en garde : il frappe")


func test_un_acolyte_archer_piege_le_joueur_en_danger() -> void:
	var combat := duo_combat(["guerrier", "archer"], GM, {"archer": {"moyenne": 1}})
	assert_eq(CombatAI.decide_acolyte(combat, combat.get_unit("a2"))["action"].skill_id, "tir", "tout va bien : il tire")
	set_ratio(combat, "a1", 0.4)
	var decision := CombatAI.decide_acolyte(combat, combat.get_unit("a2"))
	assert_eq("%s → %s" % [decision["action"].skill_id, decision["action"].target_id], "piege → a1", "sous 50 % : il piège devant toi")
	var voleur := duo_combat(["guerrier", "voleur"], GM)
	set_ratio(voleur, "a1", 0.4)
	assert_eq(CombatAI.decide_acolyte(voleur, voleur.get_unit("a2"))["action"].skill_id, "dague", "un Voleur ne peut pas te voiler : il frappe")
	set_ratio(voleur, "a2", 0.3)
	assert_eq(CombatAI.decide_acolyte(voleur, voleur.get_unit("a2"))["action"].skill_id, "voile", "mais il se voile quand c'est lui qui est en danger")
