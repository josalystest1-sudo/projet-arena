## L'IA unique du jeu : l'acolyte, le joueur IA d'en face, et plus tard les Échos, les ennemis de la Tour
## et le simulateur. « Prévisible plutôt que brillante » (GDD) : quelques règles courtes, toujours essayées
## dans le même ordre ; la première qui s'applique décide. Un joueur qui connaît la posture devine le coup.
## Module pur et déterministe : mêmes entrées, même choix.
##
## Une posture change l'ordre de ses priorités, jamais sa classe : les postures dépendent du rôle de l'acolyte (GDD,
## liste par rôle dans data/postures.json). Règle commune : un allié KO est relevé dès que possible (le joueur d'abord).
## Libre (tous)            : il joue son rôle (Front protège dès que le joueur a perdu des PV, Dégâts frappe le plus bas,
##                           Soutien soigne sous 50 %).
## Garde ta forte (tous)   : comme Libre, mais la forte ne part que le tour où le joueur joue la sienne (ou une Synergie avec elle).
## Front   Tiens la ligne  : provocations et protections sur le joueur dès qu'elles sont prêtes, sinon il frappe celui
##                           qui a fait le plus mal au joueur.
##         Cogne           : ses coups (forte, moyenne, basique) avant ses protections ; il ne protège qu'en urgence.
## Dégâts  Même cible      : comme Libre, mais sur la cible du joueur.
##         Achève          : toujours l'ennemi le plus proche du KO (le moins de PV restants), sans secourir personne.
## Soutien Soigne d'abord  : soigne le joueur dès 70 % de PV, puis comme Libre.
##         Affaiblis-les   : ses affaiblissements et contrôles sur la cible du joueur, sinon ses coups ; il ne soigne
##                           qu'en urgence.
class_name CombatAI
extends RefCounted

const LIBRE := "libre"
const GARDE_TA_FORTE := "garde_ta_forte"
const TIENS_LA_LIGNE := "tiens_la_ligne"
const COGNE := "cogne"
const MEME_CIBLE := "meme_cible"
const ACHEVE := "acheve"
const SOIGNE_D_ABORD := "soigne_d_abord"
const AFFAIBLIS := "affaiblis"
## Les effets qui affaiblissent ou contrôlent un ennemi (posture Affaiblis-les).
const WEAKENING_EFFECTS := ["push_back", "act_last"]
## L'IA regarde toujours ses compétences de la plus forte à la plus faible.
const STRONG_FIRST := ["forte", "moyenne", "basique"]


# ---------------------------------------------------------------------------
# L'acolyte
# ---------------------------------------------------------------------------

## L'annonce de l'acolyte selon sa posture. leader_action : l'Intention actuelle du joueur (null tant qu'il n'a rien choisi).
## Renvoie {action, rule, held_forte} : rule dit quelle règle a décidé (pour l'afficher), held_forte qu'il garde une forte prête.
## Une posture qui n'est pas celle de son rôle compte comme Libre.
static func decide_acolyte(combat: Combat, unit: CombatUnit, posture: String, leader_action: CombatAction) -> Dictionary:
	var leader := combat.leader_of(unit.team)
	if not postures_for(combat.data, unit.class_id).has(posture):
		posture = LIBRE
	var decision := _rule_revive(combat, unit)
	if decision.is_empty():
		var leader_up := leader != null and leader.is_alive() and leader != unit
		match posture:
			TIENS_LA_LIGNE:
				decision = _hold_the_line(combat, unit, leader) if leader_up else _libre(combat, unit, null, false)
			COGNE:
				decision = _cogne(combat, unit)
			MEME_CIBLE:
				decision = _same_target(combat, unit, leader, leader_action)
			ACHEVE:
				decision = _finish(combat, unit)
			SOIGNE_D_ABORD:
				decision = _heal_first(combat, unit, leader) if leader_up else _libre(combat, unit, null, false)
			AFFAIBLIS:
				decision = _weaken(combat, unit, leader, leader_action)
			GARDE_TA_FORTE:
				decision = _keep_strong(combat, unit, leader, leader_action) if leader_up else _libre(combat, unit, null, false)
			_:
				decision = _libre(combat, unit, null, false)
	return _complete(combat, unit, decision)


## Les postures d'un acolyte de cette classe, dans l'ordre du sélecteur : Libre, les deux de son rôle, Garde ta forte.
static func postures_for(data: CombatData, class_id: String) -> Array:
	var by_role: Dictionary = data.postures.get("by_role", {})
	return by_role.get(Duo.main_role(data, class_id), [LIBRE, GARDE_TA_FORTE])


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
	var allowed := postures_for(combat.data, acolyte.class_id)
	# Il est en danger : la posture qui le protège (Tiens la ligne, Soigne d'abord ; un Dégâts n'en a pas).
	if leader.hp_ratio() < _threshold(combat, "ai_leader_protect_below", 0.4):
		for posture in [TIENS_LA_LIGNE, SOIGNE_D_ABORD]:
			if allowed.has(posture):
				return posture
	# Un adversaire est presque KO : la posture offensive (Cogne, Achève, Affaiblis-les).
	for enemy in combat.team_units(1 - team, true):
		if enemy.hp_ratio() < _threshold(combat, "ai_leader_finish_below", 0.35):
			for posture in [COGNE, ACHEVE, AFFAIBLIS]:
				if allowed.has(posture):
					return posture
	# Sa forte revient au tour suivant et celle de l'acolyte fait Synergie avec l'une de ses compétences : l'acolyte garde
	# la sienne pour la jouer avec lui (sans Synergie à construire, la garder ne fait que la retarder).
	if combat.can_use(acolyte, "forte") and skill_kind(combat.data, acolyte.skills["forte"]) != "releve" \
			and combat.cooldown_remaining(leader, "forte") == 1 and _forte_has_synergy(combat, leader, acolyte):
		return GARDE_TA_FORTE
	return LIBRE


## Les Intentions de tout un camp, dans l'ordre d'un vrai tour : posture, annonce de l'acolyte, choix du joueur,
## puis l'acolyte révise son annonce s'il doit réagir (Même cible et Affaiblis-les suivent la cible, Garde ta forte attend
## la forte).
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
	var role := Duo.main_role(combat.data, unit.class_id)
	# Un Soutien soigne sous son seuil ; un Dégâts ne secourt que sous le sien.
	var below := _threshold(combat, "libre_heal_below", 0.5) if role == "soutien" else _threshold(combat, "libre_rescue_below", 0.5)
	var hurt_badly := hurt != null and hurt.hp_ratio() < below
	var forte: Array = [] if hold_forte else ["forte"]
	var any_tier: Array = forte + ["moyenne", "basique"]
	var decision := {}
	match role:
		"front":
			# Il protège l'allié le plus fragile (en duo : le joueur) dès que celui-ci a perdu des PV et que sa protection est prête.
			var guarded := _guarded_ally(combat, unit)
			if guarded.hp < guarded.max_hp:
				decision = _pick(combat, unit, any_tier, ["protection"], guarded, enemy, "protege")
			if decision.is_empty():
				decision = _pick(combat, unit, forte, ["degats", "renfort", "protection"], hurt, enemy, "forte")
		"soutien":
			# Il soigne le joueur d'abord dès qu'il passe sous le seuil, sinon le plus blessé (lui compris).
			var leader := combat.leader_of(unit.team)
			if leader != null and leader != unit and leader.is_alive() and leader.hp_ratio() < below:
				decision = _pick_heal(combat, unit, any_tier, leader, "soin")
			elif hurt_badly:
				decision = _pick_heal(combat, unit, any_tier, hurt, "soin")
			if decision.is_empty():
				decision = _pick_cleanse(combat, unit, any_tier, combat.allies_of(unit, true))
			# Sa forte : une protection seulement si l'un de vous a déjà perdu des PV (une Égide à fond de PV est gâchée).
			if decision.is_empty():
				var kinds: Array = ["protection", "degats", "renfort"] if _someone_hurt(combat, unit) else ["degats", "renfort"]
				decision = _pick(combat, unit, forte, kinds, hurt, enemy, "forte")
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


## Tiens la ligne (Front) : provocations et protections sur le joueur dès qu'elles sont prêtes, même à fond de PV ;
## sinon il frappe celui qui a fait le plus mal au joueur.
static func _hold_the_line(combat: Combat, unit: CombatUnit, leader: CombatUnit) -> Dictionary:
	var attacker := _worst_attacker(combat, unit, leader)
	var decision := _pick(combat, unit, STRONG_FIRST, ["protection"], leader, attacker, "tiens")
	if decision.is_empty():
		decision = _pick(combat, unit, ["forte"], ["degats", "renfort"], leader, attacker, "riposte")
	if decision.is_empty():
		decision = _pick(combat, unit, ["moyenne", "basique"], ["degats"], leader, attacker, "riposte")
	if decision.is_empty():
		decision = _libre(combat, unit, attacker, false)
	return decision


## Cogne (Front) : ses coups (forte, moyenne, basique : toute compétence qui frappe) sur l'ennemi le plus bas ;
## il ne protège qu'en urgence (le joueur sous 30 % de PV).
static func _cogne(combat: Combat, unit: CombatUnit) -> Dictionary:
	var enemy := _lowest_enemy(combat, unit)
	var guarded := _guarded_ally(combat, unit)
	var decision := {}
	if guarded.hp_ratio() < _threshold(combat, "cogne_protect_below", 0.3):
		decision = _pick(combat, unit, STRONG_FIRST, ["protection"], guarded, enemy, "urgence")
	# Ses coups : toute compétence qui frappe, même une provocation (elle frappe sa cible).
	for tier in STRONG_FIRST:
		if not decision.is_empty():
			break
		var skill_id: String = unit.skills[tier]
		if combat.can_use(unit, tier) and (_has_effect(combat, skill_id, "damage") or skill_kind(combat.data, skill_id) == "renfort"):
			var target := _target_for(combat, unit, skill_id, unit, enemy)
			if target != null:
				decision = _decision(unit, skill_id, target, "cogne")
	if decision.is_empty():
		decision = _libre(combat, unit, enemy, false)
	return decision


## Même cible que moi (Dégâts) : les règles de Libre, mais sur la cible du joueur.
static func _same_target(combat: Combat, unit: CombatUnit, leader: CombatUnit, leader_action: CombatAction) -> Dictionary:
	var target := _leader_target(combat, unit, leader, leader_action)
	var decision := _libre(combat, unit, target, false)
	var chosen: CombatAction = decision.get("action")
	if chosen != null and chosen.target_id == target.id and combat.is_hostile(chosen.skill_id):
		decision["rule"] = "meme_cible"
	return decision


## Achève (Dégâts) : forte, moyenne puis basique de dégâts, toujours sur l'ennemi le plus proche du KO, même si ce n'est
## pas la cible du joueur. Il ne secourt personne.
static func _finish(combat: Combat, unit: CombatUnit) -> Dictionary:
	var target := _closest_to_ko(combat, unit)
	var decision := _pick(combat, unit, ["forte"], ["degats", "renfort"], unit, target, "acheve")
	if decision.is_empty():
		decision = _pick(combat, unit, ["moyenne", "basique"], ["degats"], unit, target, "acheve")
	if decision.is_empty():
		decision = _libre(combat, unit, target, false)
	return decision


## Soigne d'abord (Soutien) : son plus gros soin sur le joueur dès qu'il passe sous 70 % de PV, puis il lui retire un
## état négatif ; sinon comme Libre.
static func _heal_first(combat: Combat, unit: CombatUnit, leader: CombatUnit) -> Dictionary:
	var decision := {}
	if leader.hp_ratio() < _threshold(combat, "heal_first_below", 0.7):
		decision = _pick_heal(combat, unit, STRONG_FIRST, leader, "soin_toi")
	if decision.is_empty():
		decision = _pick_cleanse(combat, unit, STRONG_FIRST, [leader])
	if decision.is_empty():
		decision = _libre(combat, unit, null, false)
	return decision


## Affaiblis-les (Soutien) : ses affaiblissements et contrôles sur la cible du joueur, sinon ses coups (forte d'abord) ;
## il ne soigne qu'en urgence (un allié sous 30 % de PV). Sans aucune attaque, il joue comme en Libre, et le dit.
static func _weaken(combat: Combat, unit: CombatUnit, leader: CombatUnit, leader_action: CombatAction) -> Dictionary:
	var target := _leader_target(combat, unit, leader, leader_action)
	var hurt := _lowest_ally(combat, unit)
	var decision := {}
	if hurt != null and hurt.hp_ratio() < _threshold(combat, "urgent_below", 0.3):
		decision = _pick_heal(combat, unit, STRONG_FIRST, hurt, "urgence")
	if decision.is_empty():
		decision = _pick_weakening(combat, unit, target)
	if decision.is_empty():
		decision = _pick(combat, unit, STRONG_FIRST, ["degats"], hurt, target, "affaiblit_coups")
	if decision.is_empty():
		decision = _libre(combat, unit, target, false)
		decision["rule"] = "sans_attaque"
	return decision


## Une compétence prête qui affaiblit ou contrôle un ennemi (la plus forte d'abord), sur la cible donnée.
static func _pick_weakening(combat: Combat, unit: CombatUnit, target: CombatUnit) -> Dictionary:
	for tier in STRONG_FIRST:
		var skill_id: String = unit.skills[tier]
		if not combat.can_use(unit, tier) or not weakens(combat.data, skill_id):
			continue
		var chosen := _target_for(combat, unit, skill_id, null, target)
		if chosen != null and chosen.team != unit.team:
			return _decision(unit, skill_id, chosen, "affaiblit")
	return {}


## Une compétence qui affaiblit ou contrôle un ennemi : repousse, fait agir en dernier, ou pose un état négatif.
static func weakens(data: CombatData, skill_id: String) -> bool:
	for effect in data.skill(skill_id).get("effects", []):
		var type := str(effect["type"])
		if WEAKENING_EFFECTS.has(type):
			return true
		if type == "status" and data.is_negative_status(str(effect.get("id", ""))) and str(effect.get("on", "")) == "":
			return true
	return false


## L'ennemi le plus proche du KO : le moins de PV restants, barrière comprise (à égalité : le plus bas en %).
static func _closest_to_ko(combat: Combat, unit: CombatUnit) -> CombatUnit:
	var best: CombatUnit = null
	for enemy in combat.enemies_of(unit, true):
		var left := enemy.hp + enemy.barrier_amount()
		if best == null or left < best.hp + best.barrier_amount() \
				or (left == best.hp + best.barrier_amount() and enemy.hp_ratio() < best.hp_ratio()):
			best = enemy
	return best


## Celui qui a fait le plus de dégâts au joueur depuis le début du combat (encore debout). Une cible stable : en duo,
## les deux ennemis frappent chacun leur tour, et riposter sur le dernier qui a frappé dispersait les coups.
## Personne ne l'a encore frappé : l'ennemi le plus bas.
static func _worst_attacker(combat: Combat, unit: CombatUnit, leader: CombatUnit) -> CombatUnit:
	var worst: CombatUnit = null
	var most := 0
	for enemy in combat.enemies_of(unit, true):
		var dealt := int(leader.damage_taken_from.get(enemy.id, 0))
		if dealt > most:
			worst = enemy
			most = dealt
	return worst if worst != null else _lowest_enemy(combat, unit)


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
				if bool(effect.get("overflow_barrier", false)):
					# Un soin qui déborde en barrière n'est inutile que si la cible a déjà une barrière au moins aussi grosse.
					return target.hp >= target.max_hp and target.barrier_amount() >= int(effect["power"])
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


## La forte de l'acolyte fait Synergie avec l'une des compétences du joueur.
static func _forte_has_synergy(combat: Combat, leader: CombatUnit, acolyte: CombatUnit) -> bool:
	for tier in CombatUnit.TIERS:
		if not combat.data.find_synergy(leader.skills[tier], acolyte.skills["forte"]).is_empty():
			return true
	return false


## L'un des alliés a déjà perdu des PV.
static func _someone_hurt(combat: Combat, unit: CombatUnit) -> bool:
	for ally in combat.allies_of(unit, true):
		if ally.hp < ally.max_hp:
			return true
	return false


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
