## L'IA simple qui pilote les personnages sans joueur (et, plus tard, les Échos et le simulateur).
## Elle lit les Intentions de ses alliés, concentre les attaques et cherche les Synergies.
## Volontairement un cran en dessous d'un bon joueur : elle joue ses fortes dès qu'elles sont prêtes.
## Module pur et déterministe : mêmes entrées, même choix.
class_name CombatAI
extends RefCounted

const TIER_BONUS := {"basique": 0.0, "moyenne": 10.0, "forte": 25.0}
const FOCUS_BONUS := 30.0
const KILL_BONUS := 40.0
const SYNERGY_BONUS := 20.0


## Choisit l'action d'une unité. ally_actions : les Intentions déjà connues de ses alliés.
static func choose(combat: Combat, unit: CombatUnit, ally_actions: Array = []) -> CombatAction:
	var best: CombatAction = null
	var best_score := -INF
	for tier in CombatUnit.TIERS:
		if not combat.can_use(unit, tier):
			continue
		var skill_id: String = unit.skills[tier]
		for target in combat.valid_targets(unit, skill_id):
			var score := _score(combat, unit, skill_id, tier, target, ally_actions)
			if score > best_score:
				best_score = score
				best = CombatAction.make(unit.id, skill_id, target.id)
	if best == null:
		return combat.default_action(unit)
	return best


## Choisit les actions de toute une équipe, chacune voyant les Intentions des précédentes.
static func choose_team(combat: Combat, team: int, fixed_actions: Array = []) -> Array:
	var actions: Array = fixed_actions.duplicate()
	for unit in combat.team_units(team, true):
		var already := false
		for action in actions:
			if action != null and action.actor_id == unit.id:
				already = true
		if already:
			continue
		actions.append(choose(combat, unit, actions))
	return actions


static func _score(combat: Combat, unit: CombatUnit, skill_id: String, tier: String, target: CombatUnit, ally_actions: Array) -> float:
	var skill := combat.data.skill(skill_id)
	var score: float = TIER_BONUS[tier]
	var focus := _focus_target(combat, unit, ally_actions)
	var enemies := combat.enemies_of(unit, true)
	var allies := combat.allies_of(unit, true)

	if combat.is_hostile(skill_id):
		var damage := _expected_damage(unit, skill)
		var hit_count := 1
		match str(skill.get("target")):
			"enemies_all":
				hit_count = enemies.size()
			"enemies_2":
				hit_count = mini(2, enemies.size())
		score += damage * float(hit_count) * 0.8
		if target == focus:
			score += FOCUS_BONUS
		if damage >= target.hp + target.barrier_amount():
			score += KILL_BONUS
		if hit_count > 1 and enemies.size() < 2:
			score -= 30.0
		score -= target.barrier_amount() * 0.3
		if target.has_status("rempart"):
			score -= 25.0

	match skill_id:
		"provocation":
			var hurt_ally := _lowest_ratio(allies, unit)
			score += 40.0 if hurt_ally < 0.5 else 12.0
			if _ally_intends(ally_actions, "nova"):
				score += SYNERGY_BONUS + 10.0
		"rempart":
			if target == unit:
				score -= 20.0
			score += (1.0 - target.hp_ratio()) * 70.0
			if target.has_status("rempart"):
				score -= 60.0
		"cri_de_guerre":
			score += 20.0 + 15.0 * float(allies.size() - 1)
		"fendoir":
			if _ally_intends(ally_actions, "boule_de_feu", target.id):
				score += SYNERGY_BONUS
		"boule_de_feu":
			if _ally_intends(ally_actions, "fendoir", target.id):
				score += SYNERGY_BONUS
		"trait_de_givre":
			if target == _fastest(enemies):
				score += 12.0
			if _ally_intends(ally_actions, "chatiment", target.id):
				score += SYNERGY_BONUS
		"chatiment":
			if _ally_intends(ally_actions, "trait_de_givre", target.id):
				score += SYNERGY_BONUS
		"nova":
			if _ally_intends(ally_actions, "provocation"):
				score += SYNERGY_BONUS
		"bouclier_de_mana":
			score += (1.0 - target.hp_ratio()) * 90.0 - target.barrier_amount() * 0.5
			if target.hp_ratio() > 0.7:
				score -= 30.0
		"priere":
			score += _heal_value(target, 0.8, 70.0)
			if _ally_intends(ally_actions, "rempart"):
				score += SYNERGY_BONUS * 0.5
		"restauration":
			score += _heal_value(target, 0.65, 120.0)
		"purification":
			var has_bad := false
			for status_id in target.status_ids():
				if combat.data.is_negative_status(status_id):
					has_bad = true
			score += (45.0 if has_bad else -20.0) + _heal_value(target, 0.7, 40.0)
		"egide":
			var missing := 0.0
			for ally in allies:
				missing += 1.0 - ally.hp_ratio()
			score += 15.0 + missing * 40.0
			if combat.turn >= 3 and missing < 0.3:
				score -= 10.0
		"resurrection":
			score += 200.0
	return score


static func _expected_damage(unit: CombatUnit, skill: Dictionary) -> float:
	var total := 0.0
	for effect in skill.get("effects", []):
		if effect["type"] == "damage":
			total += float(effect["power"]) * float(unit.power) / 100.0
		elif effect["type"] == "status" and effect.get("id") == "saignement":
			total += float(effect.get("value", 0)) * float(effect.get("turns", 1)) * 0.5
	return total


## Soin : utile seulement sous un seuil de PV, d'autant plus que l'allié est bas.
static func _heal_value(target: CombatUnit, threshold: float, weight: float) -> float:
	if target.hp_ratio() >= threshold:
		return -50.0
	return (1.0 - target.hp_ratio()) * weight


## La cible que l'équipe concentre : celle visée par le plus d'alliés, sinon l'ennemi le plus bas.
static func _focus_target(combat: Combat, unit: CombatUnit, ally_actions: Array) -> CombatUnit:
	var votes := {}
	for action in ally_actions:
		if action == null or action.actor_id == unit.id or not combat.is_hostile(action.skill_id):
			continue
		votes[action.target_id] = int(votes.get(action.target_id, 0)) + 1
	var best: CombatUnit = null
	var best_votes := 0
	for enemy in combat.enemies_of(unit, true):
		var count := int(votes.get(enemy.id, 0))
		if best == null or count > best_votes or (count == best_votes and enemy.hp < best.hp):
			best = enemy
			best_votes = count
	return best


static func _ally_intends(ally_actions: Array, skill_id: String, target_id: String = "") -> bool:
	for action in ally_actions:
		if action != null and action.skill_id == skill_id and (target_id == "" or action.target_id == target_id):
			return true
	return false


static func _lowest_ratio(allies: Array[CombatUnit], except: CombatUnit) -> float:
	var lowest := 1.0
	for ally in allies:
		if ally != except:
			lowest = minf(lowest, ally.hp_ratio())
	return lowest


static func _fastest(list: Array[CombatUnit]) -> CombatUnit:
	var best: CombatUnit = null
	for unit in list:
		if best == null or unit.base_speed > best.base_speed:
			best = unit
	return best
