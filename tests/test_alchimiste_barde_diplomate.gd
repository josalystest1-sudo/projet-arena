## Alchimiste, Barde, Diplomate : leurs compétences, leurs passifs, leurs Synergies et ce qu'en fait l'IA.
extends "res://tests/test_case.gd"

const GM := ["guerrier", "mage"]
const AG := ["alchimiste", "guerrier"]
const BG := ["barde", "guerrier"]
const DG := ["diplomate", "guerrier"]


func hits_of(events: Array, actor: String) -> Array:
	for event in events_of_type(events, "action"):
		if event["actor"] == actor:
			return event["targets"]
	return []


## Fait agir une unité en premier ce tour (Célérité), pour tester un effet qui s'applique au reste du tour.
func first(combat: Combat, unit_id: String) -> void:
	combat.get_unit(unit_id).add_status({"id": "celerite", "turns": 1})


# --- L'Alchimiste -----------------------------------------------------------------

func test_fumigene_cache_un_allie() -> void:
	# (Sans Distillation, qui prolongerait la fumée d'un tour.)
	var combat := duo_combat(AG, GM, {"alchimiste": {"moyenne": 1, "passive": 1}})
	first(combat, "a1")
	var events := combat.resolve_turn([action("a1", "fumigene", "a2"), action("b1", "taillade", "a2"), action("b2", "boule_de_feu", "a2")])
	assert_eq(hits_of(events, "b1"), ["a1"], "la Taillade ne trouve plus le Guerrier : elle frappe l'Alchimiste")
	assert_eq(hits_of(events, "b2"), ["a1"], "la Boule de feu aussi")
	assert_false(combat.get_unit("a2").has_status("fumee"), "la fumée se dissipe en fin de tour")


func test_elixir_acide_bombe_catalyseur() -> void:
	# Élixir : petit soin et de la vitesse.
	var combat := duo_combat(AG, GM, {"alchimiste": {"basique": 1}})
	combat.get_unit("a2").hp = 100
	var events := combat.resolve_turn([action("a1", "elixir", "a2")])
	var healed := 0
	for event in events_of_type(events, "heal"):
		if event["target"] == "a2" and event["kind"] == "elixir":
			healed += int(event["amount"])
	assert_eq(healed, int(round(skill_power("elixir", "heal") * class_power("alchimiste"))), "le soin de l'Élixir")
	assert_true(combat.get_unit("a2").has_status("vif"), "et le Guerrier est vif")
	combat._actions = {}
	assert_eq(combat.effective_speed(combat.get_unit("a2")), combat.get_unit("a2").base_speed + skill_power("elixir", "status"), "+2 vitesse")
	# Acide : la cible frappe moins fort.
	var acid := duo_combat(AG, GM)
	var mage := acid.get_unit("b2")
	var before := acid._damage_amount(mage, acid.get_unit("a1"), 40, 1.0, true, "feu")
	acid.resolve_turn([action("a1", "acide", "b2")])
	heal_all(acid)
	var malus := 1.0 - float(skill_power("acide", "status")) / 100.0
	assert_eq(acid._damage_amount(mage, acid.get_unit("a1"), 40, 1.0, true, "feu"), int(round(before * malus)), "-30 % de dégâts infligés")
	# Bombe : tous les ennemis. Catalyseur : toutes les recharges d'un allié remises à zéro.
	var bomb := duo_combat(AG, GM)
	jump_to_turn(bomb, 3)
	assert_eq(hits_of(bomb.resolve_turn([action("a1", "bombe", "b1")]), "a1").size(), 2, "la Bombe touche les deux")
	var reset := duo_combat(AG, GM, {"alchimiste": {"forte": 1}})
	jump_to_turn(reset, 3)
	var guerrier := reset.get_unit("a2")
	guerrier.cooldown_until = {"moyenne": 6, "forte": 8}
	var events_2 := reset.resolve_turn([action("a1", "catalyseur", "a2")])
	assert_eq(events_of_type(events_2, "cooldowns_reset").size(), 1, "recharges remises à zéro")
	assert_true(reset.can_use(guerrier, "moyenne") and reset.can_use(guerrier, "forte"), "sa moyenne et sa forte sont prêtes")


func test_distillation_peau_de_mercure_sang_acide_baume() -> void:
	# Distillation : ses états durent un tour de plus.
	var combat := duo_combat(AG, GM)
	combat.resolve_turn([action("a1", "acide", "b2")])
	assert_eq(int(combat.get_unit("b2").get_status("affaibli")["turns"]), skill_power("acide", "status") * 0 + int(data.skill("acide")["effects"][1]["turns"]), "un tour de plus (2 + 1, un déjà écoulé)")
	var plain := duo_combat(AG, GM, {"alchimiste": {"passive": 1}})
	plain.resolve_turn([action("a1", "acide", "b2")])
	assert_eq(int(plain.get_unit("b2").get_status("affaibli")["turns"]), int(data.skill("acide")["effects"][1]["turns"]) - 1, "sans Distillation : la durée normale")
	# Peau de mercure : moins de dégâts élémentaires, pas moins de dégâts physiques.
	var mercury := duo_combat(AG, GM, {"alchimiste": {"passive": 1}})
	var hits := mercury.resolve_turn([action("b1", "taillade", "a1"), action("b2", "boule_de_feu", "a1")])
	assert_eq(damage_from(hits, "b2", "a1"), int(round(skill_power("boule_de_feu") * class_power("mage") * (1.0 - pp("peau_de_mercure", "elemental_reduction")))), "Boule de feu amortie")
	assert_eq(damage_from(hits, "b1", "a1"), int(round(skill_power("taillade") * class_power("guerrier"))), "Taillade entière")
	# Sang acide : riposte au contact seulement.
	var acid := duo_combat(AG, GM, {"alchimiste": {"passive": 2}})
	var contact := acid.resolve_turn([action("b1", "taillade", "a1"), action("b2", "boule_de_feu", "a1")])
	assert_eq(damage_from(contact, "a1", "b1", "sang_acide"), int(round(pp("sang_acide", "contact_riposte") * class_power("alchimiste"))), "le Guerrier, au contact, est brûlé par l'acide")
	assert_eq(damage_from(contact, "a1", "b2", "sang_acide"), 0, "le Mage, à distance, non")
	# Baume : l'allié le plus blessé se soigne en fin de tour.
	var balm := duo_combat(AG, GM, {"alchimiste": {"passive": 3}})
	balm.get_unit("a2").hp = 100
	var events := balm.resolve_turn([action("a1", "fiole", "b2"), action("b1", "taillade", "a1"), action("b2", "boule_de_feu", "a1")])
	var healed := 0
	for event in events_of_type(events, "heal"):
		if event["kind"] == "baume":
			healed += int(event["amount"])
			assert_eq(event["target"], "a2", "le plus blessé")
	assert_eq(healed, int(round(balm.get_unit("a2").max_hp * pp("baume", "ally_regen"))), "une part de ses PV max")


# --- Le Barde ----------------------------------------------------------------------

func test_hymne_fait_agir_le_duo_en_premier() -> void:
	var combat := duo_combat(["barde", "pretre"], GM)
	assert_eq(action_order(combat.resolve_turn([])), ["a1", "b1", "b2", "a2"], "sans Hymne : Barde (9, prioritaire), Guerrier (9), Mage (8), Prêtre (7)")
	heal_all(combat)
	var events := combat.resolve_turn([action("a1", "hymne", "b2")])
	assert_eq(action_order(events), ["a1", "a2", "b1", "b2"], "avec l'Hymne : tout le duo avant les ennemis")


func test_dissonance_crescendo_berceuse() -> void:
	var combat := duo_combat(BG, GM, {"barde": {"moyenne": 1}})
	combat.resolve_turn([action("a1", "dissonance", "b2")])
	assert_eq(int(combat.get_unit("b2").get_status("affaibli")["value"]), skill_power("dissonance", "status"), "la cible est affaiblie")
	# Crescendo : plus fort à chaque tour écoulé.
	var per_turn: float = float(data.skill("crescendo")["effects"][0]["per_turn"])
	var early := duo_combat(BG, GM)
	jump_to_turn(early, 3)
	var events := early.resolve_turn([action("a1", "crescendo", "b1")])
	assert_eq(damage_from(events, "a1", "b2"), int(round(skill_power("crescendo") * class_power("barde") * (1.0 + per_turn * 2.0))), "au tour 3 : +16 %")
	var late := duo_combat(BG, GM)
	jump_to_turn(late, 7)
	var later := late.resolve_turn([action("a1", "crescendo", "b1")])
	assert_eq(damage_from(later, "a1", "b2"), int(round(skill_power("crescendo") * class_power("barde") * (1.0 + per_turn * 6.0))), "au tour 7 : +48 %")
	# Berceuse : la cible perd son action du tour suivant.
	var lullaby := duo_combat(BG, GM, {"barde": {"forte": 1}})
	jump_to_turn(lullaby, 3)
	lullaby.resolve_turn([action("a1", "berceuse", "b1")])
	assert_true(lullaby.get_unit("b1").has_status("etourdi"), "endormi")
	heal_all(lullaby)
	var lost := events_of_type(lullaby.resolve_turn([]), "action_lost")
	assert_eq(lost.size(), 1, "il perd son action")


func test_rythme_inspiration_virtuose_vibrato() -> void:
	# Rythme : la moyenne revient un tour plus tôt.
	var combat := duo_combat(BG, GM)
	combat.resolve_turn([action("a1", "hymne", "b2")])
	assert_eq(combat.cooldown_remaining(combat.get_unit("a1"), "moyenne"), 1, "un seul tour de recharge")
	# Inspiration : chaque Synergie du duo galvanise l'équipe.
	var muse := duo_combat(BG, GM, {"barde": {"passive": 1, "moyenne": 1}})
	jump_to_turn(muse, 3)
	var events := muse.resolve_turn([action("a1", "dissonance", "b2"), action("a2", "fendoir", "b2")])
	assert_eq(events_of_type(events, "synergy").size(), 1, "Fausse note se déclenche")
	for unit_id in ["a1", "a2"]:
		assert_eq(int(muse.get_unit(unit_id).get_status("galvanise").get("value", 0)), int(round(pp("inspiration", "synergy_team_bonus") * 100.0)), unit_id + " est galvanisé")
	# Virtuose : ses chansons durent un tour de plus.
	var virtuoso := duo_combat(BG, GM, {"barde": {"passive": 2, "moyenne": 1}})
	virtuoso.resolve_turn([action("a1", "dissonance", "b2")])
	assert_eq(int(virtuoso.get_unit("b2").get_status("affaibli")["turns"]), int(data.skill("dissonance")["effects"][1]["turns"]), "2 + 1 tours, un déjà écoulé")
	# Vibrato : une part des dégâts passe à travers la barrière.
	var vibrato := duo_combat(BG, GM, {"barde": {"passive": 3}})
	vibrato.get_unit("b2").add_status({"id": "barriere", "turns": 3, "value": 1000})
	var pierce := vibrato.resolve_turn([action("a1", "note", "b2")])
	var full := int(round(skill_power("note") * class_power("barde")))
	assert_eq(damage_from(pierce, "a1", "b2"), int(round(full * pp("vibrato", "barrier_pierce"))), "la moitié passe")


# --- Le Diplomate ------------------------------------------------------------------

func test_ultimatum_force_et_fait_payer() -> void:
	var combat := duo_combat(DG, ["pretre", "mage"])
	var events := combat.resolve_turn([action("a1", "ultimatum", "b1"), action("b1", "chatiment", "a2")])
	assert_eq(hits_of(events, "b1"), ["a1"], "le Prêtre sommé frappe le Diplomate")
	assert_eq(damage_from(events, "a1", "b1", "ultimatum"), int(round(skill_power("ultimatum", "status") * class_power("diplomate"))), "et le paie")
	assert_false(combat.get_unit("b1").has_status("ultimatum"), "la sommation ne dure qu'un tour")


func test_treve_bloque_dans_les_deux_sens() -> void:
	var combat := duo_combat(DG, ["pretre", "pretre"], {"diplomate": {"moyenne": 1}})
	first(combat, "a1")
	var events := combat.resolve_turn([action("a1", "treve", "b2"), action("a2", "taillade", "b2"), action("b2", "chatiment", "a2"), action("b1", "chatiment", "a1")])
	assert_eq(hits_of(events, "a2"), ["b1"], "ton Guerrier ne peut plus viser l'ennemi en trêve : il frappe l'autre")
	assert_eq(hits_of(events, "b2"), ["a1"], "l'ennemi en trêve ne peut plus viser ton Guerrier : il frappe le Diplomate")
	assert_eq(hits_of(events, "b1"), ["a1"], "l'autre ennemi n'est pas concerné")


func test_discours_encouragement_chantage() -> void:
	var combat := duo_combat(DG, GM)
	jump_to_turn(combat, 3)
	combat.resolve_turn([action("a1", "discours", "a1")])
	for unit_id in ["a1", "a2"]:
		assert_eq(int(combat.get_unit(unit_id).get_status("galvanise")["value"]), skill_power("discours", "status"), unit_id + " galvanisé par le Discours")
	var cheer := duo_combat(DG, GM, {"diplomate": {"basique": 1}})
	first(cheer, "a1")
	var events := cheer.resolve_turn([action("a1", "encouragement", "a2"), action("a2", "taillade", "b2")])
	var boost := 1.0 + float(skill_power("encouragement", "status")) / 100.0
	assert_eq(damage_from(events, "a2", "b2"), int(round(skill_power("taillade") * class_power("guerrier") * boost)), "le Guerrier encouragé frappe plus fort")
	var blackmail := duo_combat(DG, GM, {"diplomate": {"forte": 1}})
	jump_to_turn(blackmail, 3)
	blackmail.resolve_turn([action("a1", "chantage", "b1")])
	assert_false(blackmail.can_use(blackmail.get_unit("b1"), "forte"), "au tour 4, pas de forte pour le Guerrier adverse")
	heal_all(blackmail)
	blackmail.resolve_turn([])
	assert_true(blackmail.can_use(blackmail.get_unit("b1"), "forte"), "au tour 5, il la retrouve")


func test_charisme_impassible_reseau_protocole() -> void:
	# Charisme : un coup sur N visant l'allié vise le Diplomate.
	var combat := duo_combat(DG, GM)
	var every := int(pp("charisme", "redirect_every"))
	for i in range(every - 1):
		assert_eq(hits_of(combat.resolve_turn([action("b1", "taillade", "a2")]), "b1"), ["a2"], "coup %d : le Guerrier est touché" % (i + 1))
		heal_all(combat)
	assert_eq(hits_of(combat.resolve_turn([action("b1", "taillade", "a2")]), "b1"), ["a1"], "coup %d : détourné sur le Diplomate" % every)
	# Impassible : ni provoqué, ni gelé.
	var stoic := duo_combat(DG, GM, {"diplomate": {"passive": 1}})
	var controls := stoic.resolve_turn([action("b1", "provocation", "a1"), action("b2", "trait_de_givre", "a1"), action("a1", "argument", "b2")])
	assert_false(stoic.get_unit("a1").has_status("gele"), "pas gelé")
	assert_eq(hits_of(controls, "a1"), ["b2"], "pas provoqué : il frappe qui il veut")
	assert_true(events_of_type(controls, "immune").size() >= 2, "immunisé aux deux contrôles")
	# Réseau : +1 vitesse par ennemi sous un de ses états.
	var network := duo_combat(DG, GM, {"diplomate": {"passive": 2, "forte": 1}})
	jump_to_turn(network, 3)
	network.resolve_turn([action("a1", "chantage", "b1")])
	network._actions = {}
	assert_eq(network.effective_speed(network.get_unit("a1")), network.get_unit("a1").base_speed + 1, "le Guerrier adverse est sous Chantage : +1 vitesse")
	# Protocole : un état de contrôle retiré à l'allié en fin de tour.
	var protocol := duo_combat(DG, GM, {"diplomate": {"passive": 3}})
	var events := protocol.resolve_turn([action("b2", "trait_de_givre", "a2")])
	assert_eq(events_of_type(events, "status_removed").size(), 1, "un état retiré")
	assert_false(protocol.get_unit("a2").has_status("gele"), "le Guerrier n'est plus gelé")


# --- Les Synergies ------------------------------------------------------------------

## Les choix de kit qui contiennent une compétence donnée.
func picks_with(skill_id: String) -> Dictionary:
	var class_id := str(data.skill(skill_id)["class"])
	var picks := {}
	for tier in CombatUnit.TIERS:
		var pool: Array = data.classes[class_id]["skills"][tier]
		if pool.has(skill_id):
			picks[tier] = pool.find(skill_id)
	return picks


func target_for(combat: Combat, actor_id: String, skill_id: String) -> String:
	match str(data.skill(skill_id).get("target")):
		"ally", "allies_all":
			return "a1"
		"self":
			return actor_id
	return "b1"


func test_chaque_synergie_se_declenche() -> void:
	# Pour chaque Synergie : un duo des deux classes, les deux compétences jouées le même tour sur la même cible.
	for synergy in data.synergies:
		var skills: Array = synergy["skills"]
		if str(skills[0]).begins_with("*") or str(skills[1]).begins_with("*"):
			continue
		var class_a := str(data.skill(skills[0])["class"])
		var class_b := str(data.skill(skills[1])["class"])
		var combat := duo_combat([class_a, class_b], GM, {class_a: picks_with(skills[0]), class_b: picks_with(skills[1])})
		jump_to_turn(combat, 3)
		var events := combat.resolve_turn([action("a1", skills[0], target_for(combat, "a1", skills[0])), action("a2", skills[1], target_for(combat, "a2", skills[1]))])
		var fired := events_of_type(events, "synergy")
		assert_eq(fired.size(), 1, "%s (%s + %s) se déclenche" % [synergy["name"], skills[0], skills[1]])
		if not fired.is_empty():
			assert_eq(fired[0]["id"], synergy["id"], "la bonne Synergie")


func test_hymne_et_n_importe_quelle_forte() -> void:
	# GDD : « Hymne + n'importe quelle forte : la forte revient 1 tour plus tôt ».
	var combat := duo_combat(["barde", "guerrier"], GM)
	jump_to_turn(combat, 3)
	var events := combat.resolve_turn([action("a1", "hymne", "b2"), action("a2", "fendoir", "b2")])
	assert_eq(events_of_type(events, "synergy").size(), 1, "Mesure se déclenche")
	assert_eq(combat.cooldown_remaining(combat.get_unit("a2"), "forte"), 3, "le Fendoir revient un tour plus tôt")
	assert_eq(combat.cooldown_remaining(combat.get_unit("a1"), "moyenne"), 1, "l'Hymne garde sa recharge (Rythme : 1 tour)")
	var mage := duo_combat(["barde", "mage"], GM, {"mage": {"forte": 1, "passive": 1}})
	jump_to_turn(mage, 3)
	mage.resolve_turn([action("a1", "hymne", "b2"), action("a2", "bouclier_de_mana", "a1")])
	assert_eq(mage.cooldown_remaining(mage.get_unit("a2"), "forte"), 3, "avec le Bouclier de mana aussi")


func test_quelques_effets_de_synergie() -> void:
	# Double riposte (GDD) : l'ennemi forcé d'attaquer subit les deux contre-attaques.
	var combat := duo_combat(["diplomate", "pugiliste"], ["pretre", "mage"])
	var events := combat.resolve_turn([action("a1", "ultimatum", "b1"), action("a2", "garde_haute", "a2"), action("b1", "chatiment", "a2")])
	assert_eq(events_of_type(events, "synergy").size(), 1, "Double riposte")
	assert_true(damage_from(events, "a1", "b1", "ultimatum") > 0, "la riposte du Diplomate")
	assert_true(damage_from(events, "a2", "b1", "garde") > 0, "et celle du Pugiliste, bien que le Prêtre ait frappé le Diplomate")
	# Corrosion : l'Acide gicle sur tous les ennemis provoqués.
	var acid := duo_combat(["alchimiste", "guerrier"], GM)
	acid.resolve_turn([action("a1", "acide", "b1"), action("a2", "provocation", "b1")])
	assert_true(acid.get_unit("b2").has_status("affaibli"), "le second ennemi est affaibli aussi")
	# Mesure avec Catalyseur : Recharge arcanique rend 2 tours au Bouclier de mana.
	var arcane := duo_combat(["alchimiste", "mage"], GM, {"alchimiste": {"forte": 1}, "mage": {"forte": 1, "passive": 1}})
	jump_to_turn(arcane, 3)
	arcane.resolve_turn([action("a1", "catalyseur", "a2"), action("a2", "bouclier_de_mana", "a1")])
	assert_eq(arcane.cooldown_remaining(arcane.get_unit("a2"), "forte"), 2, "4 tours de recharge, moins 2")


# --- Ce qu'en fait l'IA -------------------------------------------------------------

func test_un_acolyte_alchimiste_enfume_le_joueur_entame() -> void:
	var combat := duo_combat(["guerrier", "alchimiste"], GM, {"alchimiste": {"moyenne": 1, "forte": 1}})
	assert_eq(CombatAI.decide_acolyte(combat, combat.get_unit("a2"))["action"].skill_id, "fiole", "tout va bien : il lance une fiole")
	combat.get_unit("a1").hp = 200
	var decision := CombatAI.decide_acolyte(combat, combat.get_unit("a2"))
	assert_eq("%s → %s" % [decision["action"].skill_id, decision["action"].target_id], "fumigene → a1", "tu as perdu des PV : il te cache")
	assert_eq(decision["rule"], "protege", "règle : il te protège")
	# Catalyseur : seulement si tu as une recharge en cours.
	jump_to_turn(combat, 3)
	combat.get_unit("a2").cooldown_until["moyenne"] = 9
	heal_all(combat)
	assert_eq(CombatAI.decide_acolyte(combat, combat.get_unit("a2"))["action"].skill_id, "fiole", "rien en recharge chez toi : pas de Catalyseur")
	combat.get_unit("a1").cooldown_until = {"moyenne": 5, "forte": 7}
	var reset := CombatAI.decide_acolyte(combat, combat.get_unit("a2"))
	assert_eq("%s → %s" % [reset["action"].skill_id, reset["action"].target_id], "catalyseur → a1", "ta moyenne et ta forte en recharge : Catalyseur sur toi")


func test_un_acolyte_diplomate_encourage_le_joueur() -> void:
	var combat := duo_combat(["mage", "diplomate"], GM, {"diplomate": {"basique": 1, "moyenne": 1}})
	var decision := CombatAI.decide_acolyte(combat, combat.get_unit("a2"))
	assert_eq("%s → %s" % [decision["action"].skill_id, decision["action"].target_id], "encouragement → a1", "l'Encouragement va au joueur, pas à lui")
	combat.get_unit("a1").hp = 150
	var truce := CombatAI.decide_acolyte(combat, combat.get_unit("a2"))
	assert_eq(truce["action"].skill_id, "treve", "tu as perdu des PV : une Trêve")
	assert_eq(truce["rule"], "protege", "règle : il te protège")
