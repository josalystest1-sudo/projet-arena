## L'IA unique du jeu : l'acolyte, le joueur IA d'en face, et plus tard les Échos, les ennemis de la Tour
## et le simulateur. « Prévisible plutôt que brillante » (GDD) : quelques règles courtes, toujours essayées
## dans le même ordre ; la première qui s'applique décide. Un joueur qui connaît la posture devine le coup.
## Module pur et déterministe : mêmes entrées, même choix.
##
## Règle commune : un allié KO est relevé dès que possible (le joueur d'abord).
## Libre          : chacun joue son rôle (Front protège dès que le joueur a perdu des PV, Dégâts frappe le plus bas, Soutien soigne sous 50 %).
## Protège-moi    : protections et soins sur le joueur d'abord, sinon il frappe celui qui l'a frappé.
## Fonce          : forte, puis moyenne, puis basique de dégâts, toujours sur la cible du joueur.
## Garde ta forte : comme Libre, mais la forte ne part que le tour où le joueur joue la sienne (ou une Synergie avec elle).
class_name CombatAI
extends RefCounted

const LIBRE := "libre"
const PROTEGE_MOI := "protege_moi"
const FONCE := "fonce"
const GARDE_TA_FORTE := "garde_ta_forte"
const POSTURES := [LIBRE, PROTEGE_MOI, FONCE, GARDE_TA_FORTE]
## L'IA regarde toujours ses compétences de la plus forte à la plus faible.
const STRONG_FIRST := ["forte", "moyenne", "basique"]


# ---------------------------------------------------------------------------
# L'acolyte
# ---------------------------------------------------------------------------

## L'annonce de l'acolyte selon sa posture. leader_action : l'Intention actuelle du joueur (null tant qu'il n'a rien choisi).
## Renvoie {action, rule, held_forte} : rule dit quelle règle a décidé (pour l'afficher), held_forte qu'il garde une forte prête.
static func decide_acolyte(combat: Combat, unit: CombatUnit, posture: String, leader_action: CombatAction) -> Dictionary:
	var leader := combat.leader_of(unit.team)
	var decision := _rule_revive(combat, unit)
	if decision.is_empty():
		var leader_up := leader != null and leader.is_alive() and leader != unit
		match posture:
			PROTEGE_MOI:
				decision = _protect_me(combat, unit, leader) if leader_up else _libre(combat, unit, null, false)
			FONCE:
				decision = _fonce(combat, unit, leader, leader_action)
			GARDE_TA_FORTE:
				decision = _keep_strong(combat, unit, leader, leader_action) if leader_up else _libre(combat, unit, null, false)
			_:
				decision = _libre(combat, unit, null, false)
	return _complete(combat, unit, decision)


# ---------------------------------------------------------------------------
# Le joueur IA (duo adverse, Échos) et les ennemis sans acolyte (Tour)
# ---------------------------------------------------------------------------

## Le choix d'un personnage principal piloté par l'IA. Comme un humain, il connaît l'annonce de son acolyte :
## il relève et soigne l'urgence d'abord, puis cherche la Synergie avec elle, puis joue son rôle en frappant la même cible.
static func decide_leader(combat: Combat, unit: CombatUnit, partner_action: CombatAction) -> Dictionary:
	var decision := _rule_revive(combat, unit)
	var hurt := _lowest_ally(combat, unit)
	if decision.is_empty() and Duo.main_role(combat.data, unit.class_id) == "soutien" \
			and hurt != null and hurt.hp_ratio() < _threshold(combat, "libre_heal_below", 0.5):
		decision = _pick_heal(combat, unit, STRONG_FIRST, hurt, "soin")
	if decision.is_empty() and partner_action != null:
		decision = _synergy_with(combat, unit, partner_action)
	if decision.is_empty():
		var focus: CombatUnit = null
		if partner_action != null and combat.is_hostile(partner_action.skill_id):
			focus = combat.get_unit(partner_action.target_id)
		decision = _libre(combat, unit, focus, false)
	return _complete(combat, unit, decision)


## La posture qu'un joueur IA donne à son acolyte en début de tour.
static func choose_posture(combat: Combat, team: int) -> String:
	var leader := combat.leader_of(team)
	var acolyte := combat.acolyte_of(team)
	if leader == null or acolyte == null or not leader.is_alive() or not acolyte.is_alive():
		return LIBRE
	if leader.hp_ratio() < _threshold(combat, "ai_leader_protect_below", 0.4):
		return PROTEGE_MOI
	for enemy in combat.team_units(1 - team, true):
		if enemy.hp_ratio() < _threshold(combat, "ai_leader_finish_below", 0.35):
			return FONCE
	# Sa forte revient au tour suivant : l'acolyte garde la sienne pour les lancer ensemble.
	if combat.can_use(acolyte, "forte") and skill_kind(combat.data, acolyte.skills["forte"]) != "releve" \
			and combat.cooldown_remaining(leader, "forte") == 1:
		return GARDE_TA_FORTE
	return LIBRE


## Les Intentions de tout un camp, dans l'ordre d'un vrai tour : posture, annonce de l'acolyte, choix du joueur,
## puis l'acolyte révise son annonce s'il doit réagir (Fonce suit la cible, Garde ta forte attend la forte).
## fixed_actions : Intentions déjà connues (celle du joueur humain). Renvoie {actions, posture}.
static func plan_team(combat: Combat, team: int, fixed_actions: Array = [], posture: String = "") -> Dictionary:
	var actions: Array = fixed_actions.duplicate()
	if posture == "":
		posture = choose_posture(combat, team)
	var leader := combat.leader_of(team)
	var acolyte := combat.acolyte_of(team)
	if leader != null and acolyte != null:
		var leader_action := _find(actions, leader.id)
		if acolyte.is_alive() and _find(actions, acolyte.id) == null:
			var announce: CombatAction = decide_acolyte(combat, acolyte, posture, leader_action)["action"]
			if leader_action == null and leader.is_alive():
				leader_action = decide_leader(combat, leader, announce)["action"]
				actions.append(leader_action)
			actions.append(decide_acolyte(combat, acolyte, posture, leader_action)["action"])
		elif leader.is_alive() and leader_action == null:
			actions.append(decide_leader(combat, leader, _find(actions, acolyte.id))["action"])
	# Les autres (ennemis de la Tour) : chacun joue son rôle et concentre la cible de ceux qui ont choisi avant lui.
	for unit in combat.team_units(team, true):
		if _find(actions, unit.id) == null:
			actions.append(decide_leader(combat, unit, _first_hostile(combat, actions, team))["action"])
	return {"actions": actions, "posture": posture}


static func choose_team(combat: Combat, team: int, fixed_actions: Array = []) -> Array:
	return plan_team(combat, team, fixed_actions)["actions"]


## Le choix d'une unité seule, sachant les Intentions de ses alliés (acolyte en posture Libre, sinon joueur IA).
static func choose(combat: Combat, unit: CombatUnit, ally_actions: Array = []) -> CombatAction:
	var partner_action := _first_hostile(combat, ally_actions, unit.team, unit.id)
	if partner_action == null:
		for action in ally_actions:
			if action != null and action.actor_id != unit.id:
				partner_action = action
				break
	if unit.is_acolyte:
		return decide_acolyte(combat, unit, LIBRE, partner_action)["action"]
	return decide_leader(combat, unit, partner_action)["action"]


# ---------------------------------------------------------------------------
# Pour l'écran : les Synergies que le joueur peut construire avec son acolyte
# ---------------------------------------------------------------------------

## Pour chaque compétence jouable du joueur, la Synergie qu'elle déclencherait avec la réponse de l'acolyte
## dans sa posture actuelle. Renvoie [{tier, skill_id, synergy, acolyte_skill, targets}] ; targets liste les
## cibles du joueur qui déclenchent la Synergie (toutes, sauf pour une Synergie « même cible »).
static func synergy_options(combat: Combat, leader: CombatUnit, acolyte: CombatUnit, posture: String) -> Array:
	var result: Array = []
	if leader == null or acolyte == null or not leader.is_alive() or not acolyte.is_alive():
		return result
	for tier in CombatUnit.TIERS:
		if not combat.can_use(leader, tier):
			continue
		var skill_id: String = leader.skills[tier]
		var entry := {}
		for target in combat.valid_targets(leader, skill_id):
			var mine := CombatAction.make(leader.id, skill_id, target.id)
			var answer: CombatAction = decide_acolyte(combat, acolyte, posture, mine)["action"]
			if answer == null:
				continue
			var synergy := combat.data.find_synergy(skill_id, answer.skill_id)
			if synergy.is_empty() or (bool(synergy.get("same_target", false)) and answer.target_id != target.id):
				continue
			if entry.is_empty():
				entry = {"tier": tier, "skill_id": skill_id, "synergy": synergy, "acolyte_skill": answer.skill_id, "targets": []}
			entry["targets"].append(target.id)
		if not entry.is_empty():
			result.append(entry)
	return result


## Ce que fait une compétence, vu par l'IA : degats, soin, protection, renfort ou releve.
static func skill_kind(data: CombatData, skill_id: String) -> String:
	var types: Array = []
	for effect in data.skill(skill_id).get("effects", []):
		types.append(str(effect["type"]))
	if types.has("revive"):
		return "releve"
	if types.has("heal") or types.has("cleanse"):
		return "soin"
	if types.has("barrier") or types.has("absorb_next_hit") or types.has("taunt"):
		return "protection"
	if types.has("damage"):
		return "degats"
	return "renfort"


# ---------------------------------------------------------------------------
# Les règles
# ---------------------------------------------------------------------------

## Règle commune : relever un allié KO dès que possible, le joueur avant l'acolyte.
static func _rule_revive(combat: Combat, unit: CombatUnit) -> Dictionary:
	for tier in STRONG_FIRST:
		var skill_id: String = unit.skills[tier]
		if skill_kind(combat.data, skill_id) != "releve" or not combat.can_use(unit, tier):
			continue
		var targets := combat.valid_targets(unit, skill_id)
		if targets.is_empty():
			continue
		var target: CombatUnit = targets[0]
		for candidate in targets:
			if not candidate.is_acolyte:
				target = candidate
				break
		return _decision(unit, skill_id, target, "releve")
	return {}


## Libre : chacun joue son rôle. focus : la cible à frapper si on en impose une (sinon l'ennemi le plus bas).
## hold_forte : la forte est gardée (posture Garde ta forte).
static func _libre(combat: Combat, unit: CombatUnit, focus: CombatUnit, hold_forte: bool) -> Dictionary:
	var enemy := focus if _is_enemy(unit, focus) else _lowest_enemy(combat, unit)
	var hurt := _lowest_ally(combat, unit)
	var hurt_badly := hurt != null and hurt.hp_ratio() < _threshold(combat, "libre_heal_below", 0.5)
	var forte: Array = [] if hold_forte else ["forte"]
	var any_tier: Array = forte + ["moyenne", "basique"]
	var decision := {}
	match Duo.main_role(combat.data, unit.class_id):
		"front":
			# Il protège l'allié le plus fragile (en duo : le joueur) dès que celui-ci a perdu des PV et que sa protection est prête.
			var guarded := _guarded_ally(combat, unit)
			if guarded.hp < guarded.max_hp:
				decision = _pick(combat, unit, any_tier, ["protection"], guarded, enemy, "protege")
			if decision.is_empty():
				decision = _pick(combat, unit, forte, ["degats", "renfort", "protection"], hurt, enemy, "forte")
		"soutien":
			if hurt_badly:
				decision = _pick_heal(combat, unit, any_tier, hurt, "soin")
			if decision.is_empty():
				decision = _pick_cleanse(combat, unit, any_tier, combat.allies_of(unit, true))
			if decision.is_empty():
				decision = _pick(combat, unit, forte, ["protection", "degats", "renfort"], hurt, enemy, "forte")
		_:
			if hurt_badly:
				decision = _pick(combat, unit, any_tier, ["soin", "protection"], hurt, enemy, "secours")
			if decision.is_empty():
				decision = _pick(combat, unit, forte, ["degats", "renfort"], hurt, enemy, "forte")
	if decision.is_empty():
		decision = _pick(combat, unit, ["moyenne"], ["degats"], hurt, enemy, "moyenne")
	if decision.is_empty():
		decision = _pick(combat, unit, ["basique"], ["degats", "soin", "protection", "renfort"], hurt, enemy, "basique")
	return decision


## Protège-moi : tout pour la survie du joueur d'abord, puis il frappe celui qui l'a frappé.
static func _protect_me(combat: Combat, unit: CombatUnit, leader: CombatUnit) -> Dictionary:
	var attacker := combat.get_unit(leader.last_hit_by)
	if not _is_enemy(unit, attacker):
		attacker = _lowest_enemy(combat, unit)
	var all_tiers: Array = STRONG_FIRST
	var decision := _pick(combat, unit, all_tiers, ["protection"], leader, attacker, "protege")
	if decision.is_empty() and leader.hp_ratio() < _threshold(combat, "protect_heal_below", 0.75):
		decision = _pick_heal(combat, unit, all_tiers, leader, "soin_toi")
	if decision.is_empty():
		decision = _pick_cleanse(combat, unit, all_tiers, [leader])
	if decision.is_empty():
		decision = _pick(combat, unit, ["forte"], ["degats", "renfort"], leader, attacker, "riposte")
	if decision.is_empty():
		decision = _pick(combat, unit, ["moyenne", "basique"], ["degats"], leader, attacker, "riposte")
	if decision.is_empty():
		decision = _pick(combat, unit, ["basique"], ["soin", "protection", "renfort"], leader, attacker, "basique_toi")
	return decision


## Fonce : tout en dégâts, sur la cible du joueur.
static func _fonce(combat: Combat, unit: CombatUnit, leader: CombatUnit, leader_action: CombatAction) -> Dictionary:
	var target := _leader_target(combat, unit, leader, leader_action)
	var decision := _pick(combat, unit, ["forte"], ["degats", "renfort"], unit, target, "fonce")
	if decision.is_empty():
		decision = _pick(combat, unit, ["moyenne", "basique"], ["degats"], unit, target, "fonce")
	if decision.is_empty():
		# Rien pour frapper (un Soutien qui n'a que des soins) : il joue comme en Libre, et le dit.
		decision = _libre(combat, unit, target, false)
		decision["rule"] = "sans_attaque"
	return decision


## Garde ta forte : comme Libre, mais la forte attend celle du joueur (ou une compétence qui fait Synergie avec elle).
static func _keep_strong(combat: Combat, unit: CombatUnit, leader: CombatUnit, leader_action: CombatAction) -> Dictionary:
	var strong: String = unit.skills["forte"]
	var ready := combat.can_use(unit, "forte") and skill_kind(combat.data, strong) != "releve"
	if ready and leader_action != null:
		var with_me := leader.tier_of(leader_action.skill_id) == "forte" or not combat.data.find_synergy(leader_action.skill_id, strong).is_empty()
		if with_me:
			var target := _leader_target(combat, unit, leader, leader_action)
			var decision := _pick(combat, unit, ["forte"], ["degats", "renfort", "protection", "soin"], _lowest_ally(combat, unit), target, "avec_toi")
			if not decision.is_empty():
				return decision
	var held := _libre(combat, unit, null, true)
	held["held_forte"] = ready
	return held


## Un personnage principal cherche la Synergie avec l'annonce de son partenaire.
static func _synergy_with(combat: Combat, unit: CombatUnit, partner_action: CombatAction) -> Dictionary:
	for tier in STRONG_FIRST:
		var skill_id: String = unit.skills[tier]
		if not combat.can_use(unit, tier):
			continue
		var synergy := combat.data.find_synergy(skill_id, partner_action.skill_id)
		if synergy.is_empty():
			continue
		var valid := combat.valid_targets(unit, skill_id)
		if bool(synergy.get("same_target", false)):
			var shared := combat.get_unit(partner_action.target_id)
			if valid.has(shared):
				return _decision(unit, skill_id, shared, "synergie")
			continue
		var enemy := combat.get_unit(partner_action.target_id)
		if not _is_enemy(unit, enemy):
			enemy = _lowest_enemy(combat, unit)
		var target := _target_for(combat, unit, skill_id, _lowest_ally(combat, unit), enemy)
		# Pas de Synergie au prix d'un tour gâché (un soin sur un allié à fond, un Rempart déjà posé).
		if target != null and not _wasted(combat, unit, skill_id, target):
			return _decision(unit, skill_id, target, "synergie")
	return {}


# ---------------------------------------------------------------------------
# Choisir une compétence et sa cible
# ---------------------------------------------------------------------------

## La première compétence prête, dans l'ordre des paliers donnés, dont le type est accepté et qui sert à quelque chose.
## ally : cible d'un soin ou d'une protection ; enemy : cible d'une attaque ou d'une provocation.
static func _pick(combat: Combat, unit: CombatUnit, tiers: Array, kinds: Array, ally: CombatUnit, enemy: CombatUnit, rule: String) -> Dictionary:
	for tier in tiers:
		if not combat.can_use(unit, tier):
			continue
		var skill_id: String = unit.skills[tier]
		if not kinds.has(skill_kind(combat.data, skill_id)):
			continue
		var target := _target_for(combat, unit, skill_id, ally, enemy)
		if target == null or (tier != "basique" and _wasted(combat, unit, skill_id, target)):
			continue
		return _decision(unit, skill_id, target, rule)
	return {}


## Le meilleur soin prêt (le plus gros) sur un allié.
static func _pick_heal(combat: Combat, unit: CombatUnit, tiers: Array, target: CombatUnit, rule: String) -> Dictionary:
	var best := ""
	var best_power := 0
	for tier in tiers:
		var skill_id: String = unit.skills[tier]
		if not combat.can_use(unit, tier) or skill_kind(combat.data, skill_id) != "soin":
			continue
		if not combat.valid_targets(unit, skill_id).has(target):
			continue
		var power := 0
		for effect in combat.data.skill(skill_id).get("effects", []):
			if effect["type"] == "heal":
				power += int(effect["power"])
		if power > best_power:
			best = skill_id
			best_power = power
	if best == "":
		return {}
	return _decision(unit, best, target, rule)


## Une compétence qui retire un état négatif, sur le premier allié (de la liste) qui en porte un.
static func _pick_cleanse(combat: Combat, unit: CombatUnit, tiers: Array, allies: Array) -> Dictionary:
	for tier in tiers:
		var skill_id: String = unit.skills[tier]
		if not combat.can_use(unit, tier) or not _has_effect(combat, skill_id, "cleanse"):
			continue
		for ally in allies:
			if not ally.is_alive() or not combat.valid_targets(unit, skill_id).has(ally):
				continue
			for status_id in ally.status_ids():
				if combat.data.is_negative_status(status_id):
					return _decision(unit, skill_id, ally, "purifie")
	return {}


static func _target_for(combat: Combat, unit: CombatUnit, skill_id: String, ally: CombatUnit, enemy: CombatUnit) -> CombatUnit:
	var valid := combat.valid_targets(unit, skill_id)
	if valid.is_empty():
		return null
	match str(combat.data.skill(skill_id).get("target", "enemy")):
		"enemy", "enemies_2", "enemies_all":
			return enemy if valid.has(enemy) else _lowest_enemy(combat, unit)
		"ally":
			return ally if valid.has(ally) else _lowest_ally(combat, unit)
		"ally_ko":
			return null
	return valid[0]


## Une protection ou un soin qui ne servirait à rien : Rempart déjà posé, barrière déjà au moins aussi grosse,
## soin sur un allié à fond. (Les basiques ne sont jamais jugées inutiles : c'est l'action par défaut.)
static func _wasted(combat: Combat, unit: CombatUnit, skill_id: String, target: CombatUnit) -> bool:
	var skill := combat.data.skill(skill_id)
	var group: Array[CombatUnit] = [target]
	if str(skill.get("target")) == "allies_all":
		group = combat.allies_of(unit, true)
	for effect in skill.get("effects", []):
		match str(effect["type"]):
			"absorb_next_hit":
				return target.has_status("rempart")
			"barrier":
				var useless := true
				for member in group:
					if member.barrier_amount() < int(round(float(effect["power"]) * float(unit.power) / 100.0)):
						useless = false
				return useless
			"heal":
				return target.hp >= target.max_hp and not _has_effect(combat, skill_id, "cleanse")
	return false


# ---------------------------------------------------------------------------
# Utilitaires
# ---------------------------------------------------------------------------

## L'ennemi le plus bas en pourcentage de PV (à égalité : le moins de PV, puis l'ordre des places).
static func _lowest_enemy(combat: Combat, unit: CombatUnit) -> CombatUnit:
	return _lowest(combat.enemies_of(unit, true))


## L'allié le plus bas en pourcentage de PV, soi compris (à égalité : le joueur d'abord).
static func _lowest_ally(combat: Combat, unit: CombatUnit) -> CombatUnit:
	return _lowest(combat.allies_of(unit, true))


static func _lowest(list: Array[CombatUnit]) -> CombatUnit:
	var best: CombatUnit = null
	for candidate in list:
		if best == null or candidate.hp_ratio() < best.hp_ratio() - 0.0001 \
				or (absf(candidate.hp_ratio() - best.hp_ratio()) <= 0.0001 and candidate.hp < best.hp):
			best = candidate
	return best


## L'allié qu'un Front protège : le plus fragile des autres (en duo, le joueur) ; lui-même s'il est seul.
static func _guarded_ally(combat: Combat, unit: CombatUnit) -> CombatUnit:
	var best: CombatUnit = null
	for ally in combat.allies_of(unit, true):
		if ally != unit and (best == null or ally.hp_ratio() < best.hp_ratio() - 0.0001):
			best = ally
	return best if best != null else unit


## La cible du joueur : celle de son Intention si elle vise un ennemi, sinon celle du tour précédent, sinon l'ennemi le plus bas.
static func _leader_target(combat: Combat, unit: CombatUnit, leader: CombatUnit, leader_action: CombatAction) -> CombatUnit:
	if leader_action != null and combat.is_hostile(leader_action.skill_id):
		var chosen := combat.get_unit(leader_action.target_id)
		if _is_enemy(unit, chosen):
			return chosen
	if leader != null:
		var previous := combat.get_unit(leader.last_target)
		if _is_enemy(unit, previous):
			return previous
	return _lowest_enemy(combat, unit)


static func _is_enemy(unit: CombatUnit, other: CombatUnit) -> bool:
	return other != null and other.is_alive() and other.team != unit.team


static func _has_effect(combat: Combat, skill_id: String, effect_type: String) -> bool:
	for effect in combat.data.skill(skill_id).get("effects", []):
		if str(effect["type"]) == effect_type:
			return true
	return false


static func _threshold(combat: Combat, key: String, fallback: float) -> float:
	return float(combat.data.postures.get("thresholds", {}).get(key, fallback))


static func _decision(unit: CombatUnit, skill_id: String, target: CombatUnit, rule: String) -> Dictionary:
	return {"action": CombatAction.make(unit.id, skill_id, target.id), "rule": rule, "held_forte": false}


## Filet de sécurité : si aucune règle n'a trouvé d'action (cas impossible en pratique), l'action par défaut.
static func _complete(combat: Combat, unit: CombatUnit, decision: Dictionary) -> Dictionary:
	if decision.is_empty() or decision.get("action") == null:
		return {"action": combat.default_action(unit), "rule": "basique", "held_forte": false}
	if not decision.has("held_forte"):
		decision["held_forte"] = false
	return decision


static func _find(actions: Array, unit_id: String) -> CombatAction:
	for action in actions:
		if action != null and action.actor_id == unit_id:
			return action
	return null


## La première Intention offensive d'un allié (pour concentrer la même cible).
static func _first_hostile(combat: Combat, actions: Array, team: int, except_id: String = "") -> CombatAction:
	for action in actions:
		if action == null or action.actor_id == except_id:
			continue
		var actor := combat.get_unit(action.actor_id)
		if actor != null and actor.team == team and combat.is_hostile(action.skill_id):
			return action
	return null
