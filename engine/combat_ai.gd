## L'IA unique du jeu : l'acolyte, le joueur IA d'en face, et plus tard les Échos, les ennemis de la Tour
## et le simulateur. « Prévisible plutôt que brillante » (GDD) : quelques règles courtes, toujours essayées
## dans le même ordre ; la première qui s'applique décide. Un joueur qui connaît le rôle de l'acolyte devine son coup.
## Module pur et déterministe : mêmes entrées, même choix.
##
## L'acolyte joue seul, comme un second joueur (GDD, décision du 27 octobre : plus de postures). Ses règles sont fixes,
## propres à son rôle :
## - commune : un allié KO est relevé dès que possible (le joueur d'abord) ;
## - Front   : il protège le joueur dès que celui-ci a perdu des PV (sa protection prête), sinon sa forte, sinon il frappe
##             l'ennemi le plus bas ;
## - Dégâts  : il frappe l'ennemi le plus bas (forte, moyenne, basique) et ne secourt qu'un allié sous 50 % ;
## - Soutien : il soigne le plus blessé sous 50 %, sinon retire un état négatif, sinon joue sa forte, sinon frappe.
## Une seule règle pour les Synergies : si sa forte est prête et fait Synergie avec une compétence que le joueur n'a pas
## ce tour-ci mais aura au tour suivant, il garde sa forte un tour (il joue ses autres règles), jamais deux tours de suite ;
## le tour d'après, il la joue (après une relève, seule règle qui passe avant).
## Il annonce toujours son coup en premier : son annonce ne dépend jamais du choix du joueur.
class_name CombatAI
extends RefCounted

## L'IA regarde toujours ses compétences de la plus forte à la plus faible.
const STRONG_FIRST := ["forte", "moyenne", "basique"]


# ---------------------------------------------------------------------------
# L'acolyte
# ---------------------------------------------------------------------------

## L'annonce de l'acolyte. Renvoie {action, rule, waiting} : rule dit quelle règle a décidé (pour l'afficher) ;
## waiting, quand il garde sa forte pour une Synergie au tour suivant : {synergy, skill_id} (la compétence du joueur).
## allow_wait = false : sans la règle d'attente (pour mesurer ce qu'elle apporte, au simulateur).
static func decide_acolyte(combat: Combat, unit: CombatUnit, allow_wait: bool = true) -> Dictionary:
	var decision := _rule_revive(combat, unit)
	if decision.is_empty():
		decision = _rule_after_wait(combat, unit)
	if decision.is_empty():
		var waiting := synergy_wait(combat, unit) if allow_wait else {}
		decision = _libre(combat, unit, null, not waiting.is_empty())
		if not waiting.is_empty():
			decision["waiting"] = waiting
			var action: CombatAction = decision.get("action")
			if action != null:
				action.waits_for_synergy = true
	return _complete(combat, unit, decision)


## La règle d'attente : {synergy, skill_id} si l'acolyte doit garder sa forte ce tour-ci, sinon {}.
## Sa forte est prête (et ce n'est pas une relève), il n'a pas déjà attendu au tour précédent, et l'une des compétences
## du joueur n'est pas jouable ce tour-ci mais le sera au tour suivant et fait Synergie avec sa forte.
static func synergy_wait(combat: Combat, unit: CombatUnit) -> Dictionary:
	var leader := combat.leader_of(unit.team)
	if leader == null or leader == unit or not leader.is_alive() or not combat.can_use(unit, "forte"):
		return {}
	var strong: String = unit.skills["forte"]
	if skill_kind(combat.data, strong) == "releve" or int(unit.flags.get("waited_for_synergy", -10)) == combat.turn - 1:
		return {}
	for tier in CombatUnit.TIERS:
		var partner: String = leader.skills[tier]
		var synergy := combat.data.find_synergy(partner, strong)
		if synergy.is_empty() or combat.can_use(leader, tier) or combat.cooldown_remaining(leader, tier) != 1:
			continue
		if bool(combat.data.skill(partner).get("once_per_combat", false)) and leader.flags.get("used_" + partner, false):
			continue
		return {"synergy": synergy, "skill_id": partner}
	return {}


## Le tour d'après l'attente : il joue la forte qu'il gardait, dès que la compétence du joueur qui fait Synergie
## avec elle est revenue (le joueur n'a plus qu'à la jouer avec elle).
static func _rule_after_wait(combat: Combat, unit: CombatUnit) -> Dictionary:
	if int(unit.flags.get("waited_for_synergy", -10)) != combat.turn - 1 or not combat.can_use(unit, "forte"):
		return {}
	var leader := combat.leader_of(unit.team)
	if leader == null or leader == unit or not leader.is_alive():
		return {}
	var strong: String = unit.skills["forte"]
	for tier in CombatUnit.TIERS:
		if combat.can_use(leader, tier) and not combat.data.find_synergy(leader.skills[tier], strong).is_empty():
			var target := _target_for(combat, unit, strong, _lowest_ally(combat, unit), _lowest_enemy(combat, unit))
			if target != null:
				return _decision(unit, strong, target, "avec_toi")
	return {}


# ---------------------------------------------------------------------------
# Le joueur IA (duo adverse, Échos) et les ennemis sans acolyte (Tour)
# ---------------------------------------------------------------------------

## Le choix d'un personnage principal piloté par l'IA. Comme un humain, il connaît l'annonce de son acolyte :
## il relève et soigne l'urgence d'abord, puis cherche la Synergie avec elle, puis joue son rôle en frappant la même cible.
static func decide_leader(combat: Combat, unit: CombatUnit, partner_action: CombatAction) -> Dictionary:
	var decision := _rule_revive(combat, unit)
	var hurt := _lowest_ally(combat, unit)
	if decision.is_empty() and Duo.main_role(combat.data, unit.class_id) == "soutien" \
			and hurt != null and hurt.hp_ratio() < _threshold(combat, "heal_below", 0.5):
		decision = _pick_heal(combat, unit, STRONG_FIRST, hurt, "soin")
	if decision.is_empty() and partner_action != null:
		decision = _synergy_with(combat, unit, partner_action)
	if decision.is_empty():
		var focus: CombatUnit = null
		if partner_action != null and combat.is_hostile(partner_action.skill_id):
			focus = combat.get_unit(partner_action.target_id)
		decision = _libre(combat, unit, focus, false)
	return _complete(combat, unit, decision)


## Les Intentions de tout un camp, dans l'ordre d'un vrai tour : l'acolyte annonce, puis le joueur choisit en le sachant.
## fixed_actions : Intentions déjà connues (celle du joueur humain).
static func choose_team(combat: Combat, team: int, fixed_actions: Array = []) -> Array:
	var actions: Array = fixed_actions.duplicate()
	var leader := combat.leader_of(team)
	var acolyte := combat.acolyte_of(team)
	if leader != null and acolyte != null:
		var announce: CombatAction = _find(actions, acolyte.id)
		if acolyte.is_alive() and announce == null:
			announce = decide_acolyte(combat, acolyte)["action"]
			actions.append(announce)
		if leader.is_alive() and _find(actions, leader.id) == null:
			actions.append(decide_leader(combat, leader, announce)["action"])
	# Les autres (ennemis de la Tour) : chacun joue son rôle et concentre la cible de ceux qui ont choisi avant lui.
	for unit in combat.team_units(team, true):
		if _find(actions, unit.id) == null:
			actions.append(decide_leader(combat, unit, _first_hostile(combat, actions, team))["action"])
	return actions


## Le choix d'une unité seule, sachant les Intentions de ses alliés (acolyte : ses règles, sinon joueur IA).
static func choose(combat: Combat, unit: CombatUnit, ally_actions: Array = []) -> CombatAction:
	if unit.is_acolyte:
		return decide_acolyte(combat, unit)["action"]
	var partner_action := _first_hostile(combat, ally_actions, unit.team, unit.id)
	if partner_action == null:
		for action in ally_actions:
			if action != null and action.actor_id != unit.id:
				partner_action = action
				break
	return decide_leader(combat, unit, partner_action)["action"]


# ---------------------------------------------------------------------------
# Pour l'écran : les Synergies que le joueur peut construire avec son acolyte
# ---------------------------------------------------------------------------

## Pour chaque compétence jouable du joueur, la Synergie qu'elle déclencherait avec l'annonce de l'acolyte.
## Renvoie [{tier, skill_id, synergy, acolyte_skill, targets}] ; targets liste les cibles du joueur qui déclenchent la
## Synergie (toutes, sauf pour une Synergie « même cible »).
static func synergy_options(combat: Combat, leader: CombatUnit, acolyte: CombatUnit) -> Array:
	var result: Array = []
	if leader == null or acolyte == null or not leader.is_alive() or not acolyte.is_alive():
		return result
	var answer: CombatAction = decide_acolyte(combat, acolyte)["action"]
	if answer == null:
		return result
	for tier in CombatUnit.TIERS:
		if not combat.can_use(leader, tier):
			continue
		var skill_id: String = leader.skills[tier]
		var synergy := combat.data.find_synergy(skill_id, answer.skill_id)
		if synergy.is_empty():
			continue
		var targets: Array = []
		for target in combat.valid_targets(leader, skill_id):
			if not bool(synergy.get("same_target", false)) or answer.target_id == target.id:
				targets.append(target.id)
		if not targets.is_empty():
			result.append({"tier": tier, "skill_id": skill_id, "synergy": synergy, "acolyte_skill": answer.skill_id, "targets": targets})
	return result


## Ce que fait une compétence, vu par l'IA : degats, soin, protection, renfort ou releve. Une compétence qui ne pose
## qu'un état suit ce que l'état dit de lui (« kind » dans data/statuses.json : Voile et Piège protègent, Vif renforce).
static func skill_kind(data: CombatData, skill_id: String) -> String:
	var types: Array = []
	var status_kinds: Array = []
	for effect in data.skill(skill_id).get("effects", []):
		types.append(str(effect["type"]))
		if str(effect["type"]) == "status":
			status_kinds.append(data.status_kind(str(effect["id"])))
	if types.has("revive"):
		return "releve"
	if types.has("summon"):
		# Un Golem protège, un Spectre attaque : la compétence le dit (« role »).
		for effect in data.skill(skill_id).get("effects", []):
			if str(effect["type"]) == "summon":
				return str(effect.get("role", "protection"))
	if types.has("order") or types.has("sacrifice"):
		return "degats"
	if types.has("heal") or types.has("cleanse"):
		return "soin"
	if types.has("barrier") or types.has("absorb_next_hit") or types.has("taunt"):
		return "protection"
	if types.has("damage"):
		return "degats"
	if status_kinds.has("protection"):
		return "protection"
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


## Les règles de son rôle. focus : la cible à frapper si on en impose une (sinon l'ennemi le plus bas).
## hold_forte : la forte est gardée (règle d'attente pour une Synergie).
static func _libre(combat: Combat, unit: CombatUnit, focus: CombatUnit, hold_forte: bool) -> Dictionary:
	var enemy := focus if _is_enemy(unit, focus) else _lowest_enemy(combat, unit)
	var hurt := _lowest_ally(combat, unit)
	var role := Duo.main_role(combat.data, unit.class_id)
	# Un Soutien soigne sous son seuil ; un Dégâts ne secourt que sous le sien.
	var below := _threshold(combat, "heal_below", 0.5) if role == "soutien" else _threshold(combat, "rescue_below", 0.5)
	var hurt_badly := hurt != null and hurt.hp_ratio() < below
	var forte: Array = [] if hold_forte else ["forte"]
	var any_tier: Array = forte + ["moyenne", "basique"]
	var decision := {}
	match role:
		"front":
			# Il protège l'allié le plus fragile (en duo : le joueur) dès que celui-ci a perdu des PV et que sa protection est prête ;
			# une protection qu'il ne peut poser que sur lui-même (Garde haute) sert dès qu'il a lui-même perdu des PV.
			var guarded := _guarded_ally(combat, unit)
			if guarded.hp < guarded.max_hp:
				decision = _pick(combat, unit, any_tier, ["protection"], guarded, enemy, "protege")
			if decision.is_empty() and unit.hp < unit.max_hp:
				decision = _pick(combat, unit, any_tier, ["protection"], unit, enemy, "protege", true)
			if decision.is_empty():
				decision = _pick(combat, unit, forte, ["degats", "renfort", "protection"], hurt, enemy, "forte")
		"soutien":
			if hurt_badly:
				decision = _pick_heal(combat, unit, any_tier, hurt, "soin")
			if decision.is_empty():
				decision = _pick_cleanse(combat, unit, any_tier, combat.allies_of(unit, true))
			if decision.is_empty():
				decision = _pick(combat, unit, forte, ["protection", "degats", "renfort"], hurt, enemy, "forte")
			# Une protection (Fumigène, Trêve) sur l'allié dès qu'il a perdu des PV.
			if decision.is_empty() and hurt != null and hurt != unit and hurt.hp < hurt.max_hp:
				decision = _pick(combat, unit, ["moyenne"], ["protection"], hurt, enemy, "protege")
			if decision.is_empty():
				decision = _pick(combat, unit, ["moyenne"], ["renfort"], hurt, enemy, "moyenne")
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


## Un personnage principal cherche la Synergie avec l'annonce de son partenaire.
static func _synergy_with(combat: Combat, unit: CombatUnit, partner_action: CombatAction) -> Dictionary:
	for tier in STRONG_FIRST:
		var skill_id: String = unit.skills[tier]
		if not combat.can_use(unit, tier):
			continue
		var synergy := combat.data.find_synergy(skill_id, partner_action.skill_id)
		if synergy.is_empty():
			continue
		# Une protection ou un soin ne se joue pour une Synergie que s'il servirait de toute façon (quelqu'un a perdu des
		# PV, pas de créature déjà là) : l'Invocateur relançait son Golem à chaque Prière annoncée, même sans besoin, et
		# perdait ses tours d'attaque (le duo Golem + Prière gagnait 9 points de moins avec sa Synergie que sans).
		var kind := skill_kind(combat.data, skill_id)
		if kind in ["protection", "soin"]:
			var hurt := _lowest_ally(combat, unit)
			if hurt == null or hurt.hp_ratio() >= 1.0:
				continue
			if unit.has_creature() and _has_effect(combat, skill_id, "summon"):
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
## Une compétence qui ne vise que soi (Voile, Garde haute) ne sert à secourir ou protéger que si l'allié à secourir est
## soi-même ; self_only : seules ces compétences sont considérées.
static func _pick(combat: Combat, unit: CombatUnit, tiers: Array, kinds: Array, ally: CombatUnit, enemy: CombatUnit, rule: String, self_only: bool = false) -> Dictionary:
	for tier in tiers:
		if not combat.can_use(unit, tier):
			continue
		var skill_id: String = unit.skills[tier]
		if not kinds.has(skill_kind(combat.data, skill_id)):
			continue
		# Une invocation se lance sur soi mais protège tout le duo : elle sert à protéger n'importe quel allié.
		var targets_self := str(combat.data.skill(skill_id).get("target", "enemy")) == "self" and not _has_effect(combat, skill_id, "summon")
		if (self_only and not targets_self) or (targets_self and rule in ["protege", "secours", "soin"] and ally != unit):
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
			# Un renfort (Encouragement, Refrain) va à l'autre membre du duo plutôt qu'à soi.
			if skill_kind(combat.data, skill_id) == "renfort":
				var partner := combat.partner_of(unit)
				if partner != null and valid.has(partner):
					return partner
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
	var only_statuses := true
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
				if bool(effect.get("overflow_barrier", false)):
					# Un soin qui déborde en barrière n'est inutile que si la cible a déjà une barrière au moins aussi grosse.
					return target.hp >= target.max_hp and target.barrier_amount() >= int(effect["power"])
				return target.hp >= target.max_hp and not _has_effect(combat, skill_id, "cleanse")
			"reset_cooldowns":
				# Catalyseur : inutile si l'allié n'a rien en recharge.
				var pending := 0
				for tier in ["moyenne", "forte"]:
					pending += combat.cooldown_remaining(target, tier)
				return pending == 0
			"summon":
				# Inutile si la même créature est là pour encore au moins deux tours.
				return unit.has_creature() and str(unit.creature.get("kind", "")) == str(effect.get("creature", "")) and int(unit.creature.get("turns", 0)) >= 2
			"sacrifice":
				# Sans créature, le Sacrifice ne vaut pas une forte.
				return not unit.has_creature()
			"status":
				# Un Lien sans créature ne protège rien.
				if str(effect.get("id", "")) == "lien" and not unit.has_creature():
					return true
			_:
				only_statuses = false
	# Une compétence qui ne pose que des états (Piège, Voile, Totem) est inutile si tous sont déjà posés pour au moins
	# aussi longtemps sur toute sa cible.
	if only_statuses and not skill.get("effects", []).is_empty():
		for member in group:
			for effect in skill.get("effects", []):
				var existing := member.get_status(str(effect["id"]))
				if existing.is_empty() or int(existing.get("turns", 0)) < int(effect.get("turns", 1)) or int(existing.get("value", 0)) < int(effect.get("value", 0)):
					return false
		return true
	return false


# ---------------------------------------------------------------------------
# Utilitaires
# ---------------------------------------------------------------------------

## L'ennemi le plus bas en pourcentage de PV (à égalité : le moins de PV, puis l'ordre des places), parmi ceux
## qu'on peut viser (un ennemi sous Voile ou dans la fumée ne compte pas, sauf s'il n'y a que lui).
static func _lowest_enemy(combat: Combat, unit: CombatUnit) -> CombatUnit:
	var targetable: Array[CombatUnit] = []
	for enemy in combat.enemies_of(unit, true):
		if not combat.is_untargetable(enemy):
			targetable.append(enemy)
	return _lowest(targetable if not targetable.is_empty() else combat.enemies_of(unit, true))


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


static func _is_enemy(unit: CombatUnit, other: CombatUnit) -> bool:
	return other != null and other.is_alive() and other.team != unit.team


static func _has_effect(combat: Combat, skill_id: String, effect_type: String) -> bool:
	for effect in combat.data.skill(skill_id).get("effects", []):
		if str(effect["type"]) == effect_type:
			return true
	return false


static func _threshold(combat: Combat, key: String, fallback: float) -> float:
	return float(combat.data.ai.get("thresholds", {}).get(key, fallback))


static func _decision(unit: CombatUnit, skill_id: String, target: CombatUnit, rule: String) -> Dictionary:
	return {"action": CombatAction.make(unit.id, skill_id, target.id), "rule": rule}


## Filet de sécurité : si aucune règle n'a trouvé d'action (cas impossible en pratique), l'action par défaut.
static func _complete(combat: Combat, unit: CombatUnit, decision: Dictionary) -> Dictionary:
	if decision.is_empty() or decision.get("action") == null:
		return {"action": combat.default_action(unit), "rule": "basique"}
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
