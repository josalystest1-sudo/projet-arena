## Le moteur de règles du combat, tour par tour simultané. Les camps sont de taille variable :
## 2 contre 2 en PvP (un joueur et son acolyte de chaque côté), 2 contre 2 ou 3 à la Tour.
## Module pur : aucune dépendance aux nœuds de scène, aucun affichage, aucun hasard.
## Il est réutilisé tel quel par le client, le serveur, l'IA des Échos et le simulateur.
##
## Utilisation :
##   var combat := Combat.create(data, team_a, team_b)
##   ... chaque tour : collecter une CombatAction par unité vivante, puis
##   var events := combat.resolve_turn(actions)   # liste d'événements pour l'affichage
class_name Combat
extends RefCounted

## Valeurs des passifs et effets (chiffres de départ du prototype).
const PEAU_DE_FER_REDUCTION := 0.15
const SECOND_SOUFFLE_THRESHOLD := 0.30
const SECOND_SOUFFLE_HEAL := 0.10
const COLERE_PER_QUARTER := 0.10
const FOCALISATION_BONUS := 0.20
const BRASIER_BURN := {"turns": 1, "value": 8}
const FOI_THRESHOLD := 0.40
const FOI_BONUS := 0.20
const MARTYR_SHARE := 0.20
const LUMIERE_INTERIEURE_HEAL := 0.05
const SANCTUAIRE_BONUS := 0.25
const SYNERGY_NOVA_BONUS := 0.50
const SYNERGY_ECLAT_DAMAGE := 40
const SYNERGY_PLAIE_EXTRA_TURNS := 2
const ACT_LAST_PENALTY := 1000

var data: CombatData
var units: Array[CombatUnit] = []
var turn: int = 1
var finished: bool = false
var winner: int = -1
var end_reason: String = ""
## Historique complet des événements depuis le début du combat.
var history: Array[Dictionary] = []
## Dégâts totaux infligés par équipe (départage en cas d'égalité).
var damage_by_team: Dictionary = {0: 0, 1: 0}
## Équipe prioritaire à vitesse égale au tour 1 ; la priorité alterne ensuite à chaque tour.
## Tirée à pile ou face par l'appelant (l'écran, le serveur, le simulateur) : le moteur reste déterministe.
var priority_team: int = 0

# --- Règles chiffrées, lues dans data/rules.json à la création du combat ---
## Tour à partir duquel la mort subite s'applique (soins réduits, dégâts en hausse à chaque tour).
var sudden_death_turn: int = 10
## Dernier tour joué : à la fin de ce tour, l'équipe avec le plus de PV gagne.
var forced_end_turn: int = 15
var sudden_death_damage_step: float = 0.25
var sudden_death_heal: float = 0.5
## Recharges (en tours d'indisponibilité) et tour de déblocage de la forte.
var cooldown_by_tier: Dictionary = {"basique": 0, "moyenne": 2, "forte": 4}
var strong_available_from_turn: int = 3

# --- État interne d'un tour en cours de résolution ---
var _events: Array[Dictionary] = []
var _actions: Dictionary = {}          # unit_id -> CombatAction
var _acted: Dictionary = {}            # unit_id -> true une fois son tour passé (ou perdu)
var _resolved: Dictionary = {}         # unit_id -> true si l'action a bien été exécutée
var _resolved_targets: Dictionary = {} # unit_id -> identifiants des cibles réellement touchées par son action
var _queue: Array[CombatUnit] = []     # file d'attente du tour : qui agit ensuite
var _damage_dealt: Dictionary = {}     # actor_id -> {target_id: dégâts infligés ce tour}
var _synergy_pairs: Array[Dictionary] = []
var _current_hits: Dictionary = {}     # cibles distinctes touchées par l'action en cours


# ---------------------------------------------------------------------------
# Construction
# ---------------------------------------------------------------------------

## team_a et team_b : listes de dictionnaires {class_id, picks, name, is_player, is_acolyte} (seuls class_id et picks sont obligatoires).
## Un camp peut compter autant de membres qu'on veut : 2 en PvP (le joueur puis son acolyte), 2 ou 3 à la Tour.
## p_priority_team : équipe qui agit en premier à vitesse égale au tour 1 (0 ou 1).
static func create(p_data: CombatData, team_a: Array, team_b: Array, p_priority_team: int = 0) -> Combat:
	var combat := Combat.new()
	combat.data = p_data
	combat.priority_team = p_priority_team
	var rules: Dictionary = p_data.rules
	combat.sudden_death_turn = int(rules.get("sudden_death_turn", combat.sudden_death_turn))
	combat.forced_end_turn = int(rules.get("forced_end_turn", combat.forced_end_turn))
	combat.sudden_death_damage_step = float(rules.get("sudden_death_damage_step", combat.sudden_death_damage_step))
	combat.sudden_death_heal = float(rules.get("sudden_death_heal_mult", combat.sudden_death_heal))
	combat.cooldown_by_tier = rules.get("cooldowns", combat.cooldown_by_tier)
	combat.strong_available_from_turn = int(rules.get("strong_available_from_turn", combat.strong_available_from_turn))
	for team in [0, 1]:
		var members: Array = team_a if team == 0 else team_b
		for slot in range(members.size()):
			var member: Dictionary = members[slot]
			var unit_id := "%s%d" % ["a" if team == 0 else "b", slot + 1]
			var picks: Dictionary = member.get("picks", {})
			if member.has("name"):
				picks = picks.duplicate()
				picks["name"] = member["name"]
			var unit := CombatUnit.from_class(p_data, member["class_id"], picks, unit_id, team, slot)
			unit.is_player = bool(member.get("is_player", false))
			unit.is_acolyte = bool(member.get("is_acolyte", false))
			combat.units.append(unit)
	return combat


# ---------------------------------------------------------------------------
# Lecture de l'état
# ---------------------------------------------------------------------------

func get_unit(unit_id: String) -> CombatUnit:
	for unit in units:
		if unit.id == unit_id:
			return unit
	return null


func team_units(team: int, alive_only: bool = false) -> Array[CombatUnit]:
	var result: Array[CombatUnit] = []
	for unit in units:
		if unit.team == team and (not alive_only or unit.is_alive()):
			result.append(unit)
	return result


## Le personnage principal d'un camp (le joueur, ou le joueur IA d'en face) : celui que l'acolyte accompagne.
func leader_of(team: int) -> CombatUnit:
	for unit in team_units(team):
		if not unit.is_acolyte:
			return unit
	return null


## L'acolyte d'un camp (null s'il n'y en a pas, par exemple un groupe d'ennemis de la Tour).
func acolyte_of(team: int) -> CombatUnit:
	for unit in team_units(team):
		if unit.is_acolyte:
			return unit
	return null


func allies_of(unit: CombatUnit, alive_only: bool = false) -> Array[CombatUnit]:
	return team_units(unit.team, alive_only)


func enemies_of(unit: CombatUnit, alive_only: bool = false) -> Array[CombatUnit]:
	return team_units(1 - unit.team, alive_only)


func team_total_hp(team: int) -> int:
	var total := 0
	for unit in team_units(team, true):
		total += unit.hp
	return total


func priority_team_for_turn(p_turn: int) -> int:
	return priority_team if p_turn % 2 == 1 else 1 - priority_team


func is_sudden_death() -> bool:
	return turn >= sudden_death_turn


func sudden_death_damage_mult() -> float:
	if not is_sudden_death():
		return 1.0
	return 1.0 + sudden_death_damage_step * float(turn - sudden_death_turn + 1)


func sudden_death_heal_mult() -> float:
	return sudden_death_heal if is_sudden_death() else 1.0


## Nombre de tours avant qu'une compétence soit de nouveau disponible (0 = disponible).
func cooldown_remaining(unit: CombatUnit, tier: String) -> int:
	var until := int(unit.cooldown_until.get(tier, 0))
	var remaining := until - turn
	if tier == "forte":
		remaining = maxi(remaining, strong_available_from_turn - turn)
	return maxi(remaining, 0)


func can_use(unit: CombatUnit, tier: String) -> bool:
	if not unit.is_alive():
		return false
	if cooldown_remaining(unit, tier) > 0:
		return false
	var skill_id: String = unit.skills.get(tier, "")
	if bool(data.skill(skill_id).get("once_per_combat", false)) and unit.flags.get("used_" + skill_id, false):
		return false
	return true


func is_hostile(skill_id: String) -> bool:
	return str(data.skill(skill_id).get("target", "enemy")) in ["enemy", "enemies_2", "enemies_all"]


## Les cibles qu'un joueur peut choisir pour cette compétence.
func valid_targets(unit: CombatUnit, skill_id: String) -> Array[CombatUnit]:
	var target_type := str(data.skill(skill_id).get("target", "enemy"))
	match target_type:
		"enemy", "enemies_2", "enemies_all":
			return enemies_of(unit, true)
		"ally", "allies_all":
			return allies_of(unit, true)
		"self":
			var only_self: Array[CombatUnit] = [unit]
			return only_self
		"ally_ko":
			var result: Array[CombatUnit] = []
			for ally in allies_of(unit):
				if not ally.is_alive() and not ally.flags.get("revived", false):
					result.append(ally)
			return result
	return []


## L'action par défaut quand le joueur n'a rien choisi : la basique sur la cible du tour précédent.
func default_action(unit: CombatUnit) -> CombatAction:
	var skill_id: String = unit.skills["basique"]
	var targets := valid_targets(unit, skill_id)
	if targets.is_empty():
		return null
	var target: CombatUnit = targets[0]
	var previous := get_unit(unit.last_target)
	if previous != null and targets.has(previous):
		target = previous
	elif not is_hostile(skill_id):
		for candidate in targets:
			if candidate.hp_ratio() < target.hp_ratio():
				target = candidate
	return CombatAction.make(unit.id, skill_id, target.id)


## Vérifie une action ; renvoie l'action par défaut si elle est invalide.
func validate_action(unit: CombatUnit, action: CombatAction) -> CombatAction:
	if action == null:
		return default_action(unit)
	var tier := unit.tier_of(action.skill_id)
	if tier == "" or not can_use(unit, tier):
		return default_action(unit)
	var target := get_unit(action.target_id)
	if target == null or not valid_targets(unit, action.skill_id).has(target):
		return default_action(unit)
	return action


## Les Synergies prêtes à se déclencher parmi une liste d'Intentions (alliés entre eux).
func find_synergies(actions: Array) -> Array[Dictionary]:
	var pairs: Array[Dictionary] = []
	for i in range(actions.size()):
		for j in range(i + 1, actions.size()):
			var a: CombatAction = actions[i]
			var b: CombatAction = actions[j]
			if a == null or b == null:
				continue
			var unit_a := get_unit(a.actor_id)
			var unit_b := get_unit(b.actor_id)
			if unit_a == null or unit_b == null or unit_a.team != unit_b.team:
				continue
			var synergy := data.find_synergy(a.skill_id, b.skill_id)
			if synergy.is_empty():
				continue
			if bool(synergy.get("same_target", false)) and a.target_id != b.target_id:
				continue
			pairs.append({"synergy": synergy, "actors": [a.actor_id, b.actor_id]})
	return pairs


## Prévision pour l'affichage : ce que ferait cette compétence sur cette cible si elle partait maintenant.
## Ne modifie rien. Ne tient pas compte de ce que les autres feront avant (le tour est simultané).
## Renvoie {damage, heal, blocked, lethal, revive}.
func preview(actor: CombatUnit, skill_id: String, target: CombatUnit) -> Dictionary:
	var result := {"damage": 0, "heal": 0, "blocked": false, "lethal": false, "revive": false}
	var skill := data.skill(skill_id)
	if skill.is_empty() or target == null:
		return result
	var single := str(skill.get("target")) in ["enemy", "ally", "self"]
	for effect in skill.get("effects", []):
		match str(effect["type"]):
			"damage":
				result["damage"] = int(result["damage"]) + _damage_amount(actor, target, int(effect["power"]), 1.0, single)
			"heal":
				result["heal"] = int(result["heal"]) + mini(_heal_amount(actor, target, int(effect["power"])), target.max_hp - target.hp)
			"revive":
				result["revive"] = not target.is_alive()
	if int(result["damage"]) > 0:
		result["blocked"] = target.has_status("rempart")
		result["lethal"] = not result["blocked"] and int(result["damage"]) >= target.hp + target.barrier_amount()
	return result


## Pour chaque palier d'une unité : les alliés vivants qui possèdent la compétence partenaire d'une Synergie.
## Renvoie {palier: [{ally_id, skill_id, name, available}]}. « available » : l'allié peut la jouer ce tour.
func synergy_partners(unit: CombatUnit) -> Dictionary:
	var result := {}
	for tier in CombatUnit.TIERS:
		var skill_id: String = unit.skills.get(tier, "")
		var partners: Array = []
		for ally in allies_of(unit, true):
			if ally == unit:
				continue
			for ally_tier in CombatUnit.TIERS:
				var ally_skill: String = ally.skills.get(ally_tier, "")
				var synergy := data.find_synergy(skill_id, ally_skill)
				if not synergy.is_empty():
					partners.append({"ally_id": ally.id, "skill_id": ally_skill, "name": synergy["name"], "available": can_use(ally, ally_tier)})
		result[tier] = partners
	return result


# ---------------------------------------------------------------------------
# Résolution d'un tour
# ---------------------------------------------------------------------------

## Résout un tour complet et renvoie les événements produits, dans l'ordre.
func resolve_turn(actions: Array) -> Array[Dictionary]:
	assert(not finished, "Le combat est terminé.")
	_events = []
	_actions = {}
	_acted = {}
	_resolved = {}
	_resolved_targets = {}
	_queue = []
	_damage_dealt = {}
	_synergy_pairs = []

	_emit({"type": "turn_start", "turn": turn, "sudden_death": is_sudden_death()})

	# 1. Intentions : chaque unité vivante a exactement une action valide.
	for action in actions:
		if action is CombatAction:
			var unit := get_unit(action.actor_id)
			if unit != null and unit.is_alive():
				_actions[unit.id] = validate_action(unit, action)
	for unit in units:
		if unit.is_alive():
			if not _actions.has(unit.id):
				_actions[unit.id] = default_action(unit)
			_queue.append(unit)
		else:
			_acted[unit.id] = true
	_queue.sort_custom(_compare_speed)

	# 2. Révélation.
	var revealed: Array = []
	for unit in units:
		if _actions.has(unit.id) and _actions[unit.id] != null:
			revealed.append(_actions[unit.id].to_dict())
	_emit({"type": "reveal", "actions": revealed})
	_synergy_pairs = find_synergies(_actions.values())
	for pair in _synergy_pairs:
		_emit({"type": "synergy_ready", "id": pair["synergy"]["id"], "name": pair["synergy"]["name"], "actors": pair["actors"]})

	# 3. Résolution dans l'ordre de la file (vitesse, puis effets qui déplacent les Intentions).
	_emit({"type": "order", "order": _ids(_queue)})
	while not _queue.is_empty():
		var actor: CombatUnit = _queue.pop_front()
		_acted[actor.id] = true
		var action: CombatAction = _actions.get(actor.id)
		if action == null:
			continue
		if not actor.is_alive():
			_emit({"type": "action_lost", "actor": actor.id, "skill": action.skill_id})
			continue
		_execute_action(actor, action)
		_resolved[actor.id] = true
		_fire_synergies(actor)
		if team_units(0, true).is_empty() or team_units(1, true).is_empty():
			break

	# 4. Fin de tour : effets sur la durée, recharges, conditions de fin.
	_end_of_turn()
	for event in _events:
		history.append(event)
	return _events


## Les unités qui n'ont pas encore agi ce tour, dans l'ordre où elles vont agir.
func remaining_order() -> Array[CombatUnit]:
	return _queue.duplicate()


## Vitesse utilisée pour trier la file en début de tour : stat, bonus de la compétence,
## passifs, et malus « agit en dernier » pour une unité gelée.
func effective_speed(unit: CombatUnit) -> int:
	var speed := unit.base_speed
	var action: CombatAction = _actions.get(unit.id)
	if action != null:
		speed += int(data.skill(action.skill_id).get("speed_bonus", 0))
	if unit.passive == "veteran":
		for ally in allies_of(unit):
			if ally != unit and not ally.is_alive():
				speed += 1
	if unit.has_status("gele"):
		speed -= ACT_LAST_PENALTY
	return speed


func _compare_speed(a: CombatUnit, b: CombatUnit) -> bool:
	var speed_a := effective_speed(a)
	var speed_b := effective_speed(b)
	if speed_a != speed_b:
		return speed_a > speed_b
	if a.team != b.team:
		# À vitesse égale, la priorité alterne d'un tour à l'autre.
		return a.team == priority_team_for_turn(turn)
	return a.slot < b.slot


# ---------------------------------------------------------------------------
# Exécution d'une action
# ---------------------------------------------------------------------------

func _execute_action(actor: CombatUnit, action: CombatAction) -> void:
	var skill := data.skill(action.skill_id)
	var tier := actor.tier_of(action.skill_id)
	_start_cooldown(actor, tier)
	if bool(skill.get("once_per_combat", false)):
		actor.flags["used_" + action.skill_id] = true
	actor.last_target = action.target_id

	var targets := _resolve_targets(actor, action)
	_resolved_targets[actor.id] = _ids(targets)
	_emit({"type": "action", "actor": actor.id, "skill": action.skill_id, "tier": tier,
		"targets": _ids(targets), "redirected": bool(_is_redirected(actor, action, targets))})
	if targets.is_empty():
		_emit({"type": "no_target", "actor": actor.id, "skill": action.skill_id})
		return

	var context := {
		"skill_id": action.skill_id,
		"single_target": targets.size() == 1 and str(skill.get("target")) in ["enemy", "ally", "self"],
		"synergies": _active_synergy_ids(actor),
	}
	_current_hits = {}
	for effect in skill.get("effects", []):
		_apply_effect(actor, effect, targets, skill, context)

	if actor.passive == "resonance" and _current_hits.size() >= 2:
		_reduce_cooldown(actor, "forte", 1, "resonance")


func _resolve_targets(actor: CombatUnit, action: CombatAction) -> Array[CombatUnit]:
	var skill := data.skill(action.skill_id)
	var target_type := str(skill.get("target", "enemy"))
	var chosen := get_unit(action.target_id)
	var result: Array[CombatUnit] = []
	match target_type:
		"enemy", "enemies_2":
			var provoker := _provoker_of(actor)
			if provoker != null:
				chosen = provoker
			elif chosen == null or not chosen.is_alive() or chosen.team == actor.team:
				chosen = _first_alive(enemies_of(actor, true))
			if chosen != null:
				result.append(chosen)
			if target_type == "enemies_2":
				for enemy in enemies_of(actor, true):
					if enemy != chosen and result.size() < 2:
						result.append(enemy)
		"enemies_all":
			result = enemies_of(actor, true)
		"ally":
			if chosen == null or not chosen.is_alive() or chosen.team != actor.team:
				chosen = _lowest_hp(allies_of(actor, true))
			if chosen != null:
				result.append(chosen)
		"allies_all":
			result = allies_of(actor, true)
		"self":
			result.append(actor)
		"ally_ko":
			if chosen != null and chosen.team == actor.team and not chosen.is_alive():
				result.append(chosen)
	return result


func _is_redirected(actor: CombatUnit, action: CombatAction, targets: Array[CombatUnit]) -> bool:
	return is_hostile(action.skill_id) and not targets.is_empty() and targets[0].id != action.target_id and _provoker_of(actor) != null


func _provoker_of(unit: CombatUnit) -> CombatUnit:
	var status := unit.get_status("provoque")
	if status.is_empty():
		return null
	var provoker := get_unit(str(status.get("source", "")))
	if provoker == null or not provoker.is_alive() or provoker.team == unit.team:
		return null
	return provoker


func _apply_effect(actor: CombatUnit, effect: Dictionary, targets: Array[CombatUnit], skill: Dictionary, context: Dictionary) -> void:
	var element := str(skill.get("element", ""))
	match str(effect["type"]):
		"damage":
			for target in targets:
				var mult := 1.0
				if "provocation_nova" in context["synergies"] and skill.get("tier") == "forte" and target.has_status("provoque"):
					mult += SYNERGY_NOVA_BONUS
				var dealt := _deal_damage(actor, target, int(effect["power"]), element, mult, bool(context["single_target"]))
				if dealt > 0:
					_current_hits[target.id] = true
				if actor.passive == "brasier" and element == "feu" and target.is_alive():
					_add_status(target, {"id": "brulure", "turns": BRASIER_BURN["turns"], "value": BRASIER_BURN["value"], "source": actor.id})
		"heal":
			for target in targets:
				_heal(actor, target, int(effect["power"]), str(context["skill_id"]))
		"status":
			for target in targets:
				if target.is_alive():
					_add_status(target, {"id": effect["id"], "turns": int(effect["turns"]), "value": int(effect.get("value", 0)), "source": actor.id})
		"barrier":
			for target in targets:
				_add_status(target, {"id": "barriere", "turns": int(effect.get("turns", 3)), "value": _barrier_amount(actor, int(effect["power"])), "source": actor.id})
		"absorb_next_hit":
			for target in targets:
				_add_status(target, {"id": "rempart", "turns": int(effect.get("turns", 2)), "value": 1, "source": actor.id})
		"taunt":
			_apply_taunt(actor, targets, int(effect.get("count", 2)))
		"push_back":
			for target in targets:
				_push_back(target)
		"act_last":
			for target in targets:
				if not target.is_alive():
					continue
				if _acted.get(target.id, false):
					# Elle a déjà agi : elle agira en dernier au tour suivant.
					_add_status(target, {"id": "gele", "turns": 2, "value": 0, "source": actor.id})
				else:
					_queue.erase(target)
					_queue.append(target)
					_add_status(target, {"id": "gele", "turns": 1, "value": 0, "source": actor.id})
		"cleanse":
			for target in targets:
				for status_id in target.status_ids():
					if data.is_negative_status(status_id):
						target.remove_status(status_id)
						_emit({"type": "status_removed", "target": target.id, "status": status_id})
						break
		"revive":
			for target in targets:
				_revive(actor, target, int(effect.get("percent", 30)))


# --- Dégâts et soins -------------------------------------------------------

## Montant des dégâts d'une compétence, avant Martyr, Rempart et barrière.
func _damage_amount(source: CombatUnit, target: CombatUnit, base_power: int, mult: float, single_target: bool) -> int:
	var amount := float(base_power) * float(source.power) / 100.0 * mult
	if source.has_status("cri_de_guerre"):
		amount *= 1.0 + float(source.get_status("cri_de_guerre")["value"]) / 100.0
	if source.passive == "colere":
		var missing_quarters := int(floor((1.0 - source.hp_ratio()) * 4.0))
		amount *= 1.0 + COLERE_PER_QUARTER * float(missing_quarters)
	if source.passive == "focalisation" and single_target:
		amount *= 1.0 + FOCALISATION_BONUS
	amount *= sudden_death_damage_mult()
	if target.passive == "peau_de_fer":
		amount *= 1.0 - PEAU_DE_FER_REDUCTION
	return int(round(amount))


## Montant d'un soin de compétence (avant plafond des PV max).
func _heal_amount(source: CombatUnit, target: CombatUnit, base_power: int) -> int:
	var amount := float(base_power) * float(source.power) / 100.0
	if source.passive == "foi" and target.hp_ratio() < FOI_THRESHOLD:
		amount *= 1.0 + FOI_BONUS
	amount *= sudden_death_heal_mult()
	return int(round(amount))


## Valeur d'une barrière posée par une unité.
func _barrier_amount(source: CombatUnit, base_power: int) -> int:
	var amount := float(base_power) * float(source.power) / 100.0
	if source.passive == "sanctuaire":
		amount *= 1.0 + SANCTUAIRE_BONUS
	return int(round(amount))


## Calcule et inflige des dégâts d'une compétence. Renvoie les PV réellement perdus par la cible.
func _deal_damage(source: CombatUnit, target: CombatUnit, base_power: int, element: String, mult: float, single_target: bool) -> int:
	if not target.is_alive():
		return 0
	var total := _damage_amount(source, target, base_power, mult, single_target)

	# Martyr : un Prêtre allié de la cible encaisse une part des dégâts.
	for ally in allies_of(target, true):
		if ally != target and ally.passive == "martyr":
			var share := int(round(float(total) * MARTYR_SHARE))
			if share > 0:
				total -= share
				_apply_damage(source, ally, share, element, "martyr")
			break
	return _apply_damage(source, target, total, element, "hit")


## Applique des dégâts bruts (après multiplicateurs) : Rempart, barrière, PV, KO, Second souffle.
func _apply_damage(source: CombatUnit, target: CombatUnit, amount: int, element: String, kind: String) -> int:
	if not target.is_alive() or amount <= 0:
		return 0
	var rempart := target.get_status("rempart")
	if not rempart.is_empty() and kind != "dot":
		rempart["value"] = int(rempart["value"]) - 1
		if int(rempart["value"]) <= 0:
			target.remove_status("rempart")
		_emit({"type": "absorbed", "target": target.id, "amount": amount, "by": "rempart"})
		return 0
	var barrier := target.get_status("barriere")
	if not barrier.is_empty():
		var absorbed := mini(int(barrier["value"]), amount)
		barrier["value"] = int(barrier["value"]) - absorbed
		amount -= absorbed
		if int(barrier["value"]) <= 0:
			target.remove_status("barriere")
		_emit({"type": "absorbed", "target": target.id, "amount": absorbed, "by": "barriere", "left": int(barrier.get("value", 0))})
		if amount <= 0:
			return 0
	target.hp = maxi(target.hp - amount, 0)
	var source_id := source.id if source != null else ""
	_emit({"type": "damage", "source": source_id, "target": target.id, "amount": amount, "element": element, "kind": kind, "hp": target.hp})
	if source != null:
		damage_by_team[source.team] = int(damage_by_team[source.team]) + amount
		if not _damage_dealt.has(source.id):
			_damage_dealt[source.id] = {}
		_damage_dealt[source.id][target.id] = int(_damage_dealt[source.id].get(target.id, 0)) + amount
	if target.hp <= 0:
		target.statuses.clear()
		_emit({"type": "ko", "target": target.id})
	elif target.passive == "second_souffle" and not target.flags.get("second_souffle", false) and target.hp_ratio() < SECOND_SOUFFLE_THRESHOLD:
		target.flags["second_souffle"] = true
		_heal(target, target, int(round(float(target.max_hp) * SECOND_SOUFFLE_HEAL)), "second_souffle", true)
	return amount


func _heal(source: CombatUnit, target: CombatUnit, base_power: int, kind: String, raw: bool = false) -> int:
	if not target.is_alive():
		return 0
	var amount := _heal_amount(source, target, base_power) if not raw else int(round(float(base_power) * sudden_death_heal_mult()))
	var healed := mini(amount, target.max_hp - target.hp)
	target.hp += healed
	_emit({"type": "heal", "source": source.id, "target": target.id, "amount": healed, "kind": kind, "hp": target.hp})
	return healed


func _revive(actor: CombatUnit, target: CombatUnit, percent: int) -> void:
	if target.is_alive() or target.flags.get("revived", false):
		_emit({"type": "fizzle", "actor": actor.id, "target": target.id, "reason": "deja_releve"})
		return
	target.flags["revived"] = true
	target.hp = maxi(int(round(float(target.max_hp) * float(percent) / 100.0)), 1)
	target.statuses.clear()
	target.cooldown_until = {}
	_emit({"type": "revive", "source": actor.id, "target": target.id, "hp": target.hp})


# --- Contrôles ---------------------------------------------------------------

func _apply_taunt(actor: CombatUnit, targets: Array[CombatUnit], count: int) -> void:
	var provoked: Array[CombatUnit] = []
	var candidates := enemies_of(actor, true)
	for target in targets:
		if candidates.has(target):
			provoked.append(target)
	# Complète avec les ennemis qui n'ont pas encore agi, dans l'ordre où ils vont agir.
	for enemy in _queue:
		if provoked.size() >= count:
			break
		if enemy.team != actor.team and not provoked.has(enemy):
			provoked.append(enemy)
	for enemy in candidates:
		if provoked.size() >= count:
			break
		if not provoked.has(enemy):
			provoked.append(enemy)
	for enemy in provoked:
		_add_status(enemy, {"id": "provoque", "turns": 1, "value": 0, "source": actor.id})
	_emit({"type": "taunt", "actor": actor.id, "targets": _ids(provoked)})


## Repousse l'Intention de la cible d'un cran : elle passe juste derrière l'unité qui la suivait.
func _push_back(target: CombatUnit) -> void:
	if _acted.get(target.id, false) or not target.is_alive():
		_emit({"type": "push_back", "target": target.id, "effect": false})
		return
	var index := _queue.find(target)
	if index < 0 or index >= _queue.size() - 1:
		_emit({"type": "push_back", "target": target.id, "effect": false})
		return
	var follower: CombatUnit = _queue[index + 1]
	_queue[index] = follower
	_queue[index + 1] = target
	_emit({"type": "push_back", "target": target.id, "effect": true, "behind": follower.id})


func _add_status(target: CombatUnit, status: Dictionary) -> void:
	target.add_status(status)
	_emit({"type": "status", "target": target.id, "status": status["id"], "turns": status.get("turns", 0), "value": status.get("value", 0)})


# --- Recharges ---------------------------------------------------------------

func _start_cooldown(unit: CombatUnit, tier: String) -> void:
	var cooldown := int(cooldown_by_tier.get(tier, 0))
	if cooldown <= 0:
		return
	if tier == "forte" and unit.passive == "meteorologue":
		cooldown -= 1
	unit.cooldown_until[tier] = turn + cooldown + 1


func _reduce_cooldown(unit: CombatUnit, tier: String, amount: int, reason: String) -> void:
	var until := int(unit.cooldown_until.get(tier, 0))
	if until <= turn + 1:
		return
	unit.cooldown_until[tier] = until - amount
	_emit({"type": "cooldown_reduced", "target": unit.id, "tier": tier, "amount": amount, "reason": reason})


# --- Synergies ---------------------------------------------------------------

func _active_synergy_ids(actor: CombatUnit) -> Array:
	var ids: Array = []
	for pair in _synergy_pairs:
		var partner := _partner_in(pair, actor)
		if partner != "" and _resolved.get(partner, false):
			ids.append(pair["synergy"]["id"])
	return ids


func _partner_in(pair: Dictionary, actor: CombatUnit) -> String:
	var actors: Array = pair["actors"]
	if actors[0] == actor.id:
		return actors[1]
	if actors[1] == actor.id:
		return actors[0]
	return ""


## La seconde compétence du couple vient de se résoudre : la Synergie se déclenche.
func _fire_synergies(actor: CombatUnit) -> void:
	for pair in _synergy_pairs:
		var partner_id := _partner_in(pair, actor)
		if partner_id == "" or not _resolved.get(partner_id, false) or pair.get("fired", false):
			continue
		pair["fired"] = true
		var synergy: Dictionary = pair["synergy"]
		var partner := get_unit(partner_id)
		_emit({"type": "synergy", "id": synergy["id"], "name": synergy["name"], "actors": pair["actors"]})
		match str(synergy["id"]):
			"provocation_nova":
				_synergy_provocation_nova(actor, partner)
			"rempart_priere":
				_synergy_rempart_priere(actor, partner)
			"trait_de_givre_chatiment":
				_synergy_eclat(actor, partner)
			"fendoir_boule_de_feu":
				_synergy_plaie_brulante(actor)
			"cri_de_guerre_bouclier_de_mana":
				_synergy_forteresse(actor, partner)
			"provocation_chatiment":
				_synergy_jugement(actor, partner)
			"arc_de_foudre_priere":
				_synergy_courant_de_vie(actor, partner)


func _synergy_provocation_nova(second: CombatUnit, first: CombatUnit) -> void:
	# Si la Nova s'est résolue avant la Provocation, le bonus est appliqué maintenant.
	if _actions[second.id].skill_id != "provocation":
		return
	var mage := first
	var dealt: Dictionary = _damage_dealt.get(mage.id, {})
	for enemy in enemies_of(second, true):
		if enemy.has_status("provoque") and dealt.has(enemy.id):
			var bonus := int(round(float(dealt[enemy.id]) * SYNERGY_NOVA_BONUS))
			_apply_damage(mage, enemy, bonus, "feu", "synergie")


## Bastion : le Rempart se reforme, avec une protection de plus (même s'il avait déjà servi).
func _synergy_rempart_priere(second: CombatUnit, first: CombatUnit) -> void:
	var guerrier := second if _actions[second.id].skill_id == "rempart" else first
	var protected := get_unit(_actions[guerrier.id].target_id)
	if protected == null or not protected.is_alive():
		return
	var rempart := protected.get_status("rempart")
	if rempart.is_empty():
		_add_status(protected, {"id": "rempart", "turns": 2, "value": 1, "source": guerrier.id})
	else:
		rempart["value"] = int(rempart["value"]) + 1
		_emit({"type": "status", "target": protected.id, "status": "rempart", "turns": rempart.get("turns", 0), "value": rempart["value"]})


func _synergy_eclat(second: CombatUnit, first: CombatUnit) -> void:
	var pretre := second if _actions[second.id].skill_id == "chatiment" else first
	var target := get_unit(_actions[second.id].target_id)
	if target != null and target.is_alive() and target.team != pretre.team:
		var amount := int(round(float(SYNERGY_ECLAT_DAMAGE) * sudden_death_damage_mult()))
		_apply_damage(pretre, target, amount, "lumiere", "synergie")


func _synergy_plaie_brulante(second: CombatUnit) -> void:
	var target := get_unit(_actions[second.id].target_id)
	if target == null or not target.is_alive():
		return
	var bleed := target.get_status("saignement")
	if not bleed.is_empty():
		bleed["turns"] = int(bleed["turns"]) + SYNERGY_PLAIE_EXTRA_TURNS
		_emit({"type": "status", "target": target.id, "status": "saignement", "turns": bleed["turns"], "value": bleed["value"]})


## Forteresse : le Bouclier de mana se pose aussi sur les autres membres du duo.
func _synergy_forteresse(second: CombatUnit, first: CombatUnit) -> void:
	var mage := second if _actions[second.id].skill_id == "bouclier_de_mana" else first
	var effect := _skill_effect("bouclier_de_mana", "barrier")
	var already: Array = _resolved_targets.get(mage.id, [])
	for ally in allies_of(mage, true):
		if not already.has(ally.id):
			_add_status(ally, {"id": "barriere", "turns": int(effect.get("turns", 3)), "value": _barrier_amount(mage, int(effect.get("power", 0))), "source": mage.id})


## Jugement : le Châtiment frappe aussi chaque autre ennemi provoqué par le Guerrier.
func _synergy_jugement(second: CombatUnit, first: CombatUnit) -> void:
	var guerrier := second if _actions[second.id].skill_id == "provocation" else first
	var pretre := first if guerrier == second else second
	var power := int(_skill_effect("chatiment", "damage").get("power", 0))
	var already: Array = _resolved_targets.get(pretre.id, [])
	for enemy in enemies_of(pretre, true):
		var provoked := enemy.get_status("provoque")
		if provoked.is_empty() or str(provoked.get("source", "")) != guerrier.id or already.has(enemy.id):
			continue
		_apply_damage(pretre, enemy, _damage_amount(pretre, enemy, power, 1.0, true), "lumiere", "synergie")


## Courant de vie : la Prière soigne aussi les autres membres du duo.
func _synergy_courant_de_vie(second: CombatUnit, first: CombatUnit) -> void:
	var pretre := second if _actions[second.id].skill_id == "priere" else first
	var power := int(_skill_effect("priere", "heal").get("power", 0))
	var already: Array = _resolved_targets.get(pretre.id, [])
	for ally in allies_of(pretre, true):
		if not already.has(ally.id):
			_heal(pretre, ally, power, "synergie")


## Le premier effet d'un type donné dans une compétence (ex. la barrière du Bouclier de mana).
func _skill_effect(skill_id: String, effect_type: String) -> Dictionary:
	for effect in data.skill(skill_id).get("effects", []):
		if str(effect["type"]) == effect_type:
			return effect
	return {}


# ---------------------------------------------------------------------------
# Fin de tour
# ---------------------------------------------------------------------------

func _end_of_turn() -> void:
	# Effets sur la durée.
	for unit in units:
		if not unit.is_alive():
			continue
		for status_id in ["saignement", "brulure"]:
			var status := unit.get_status(status_id)
			if not status.is_empty() and unit.is_alive():
				var source := get_unit(str(status.get("source", "")))
				var amount := int(round(float(status["value"]) * sudden_death_damage_mult()))
				_apply_damage(source, unit, amount, status_id, "dot")
		if unit.is_alive() and unit.passive == "lumiere_interieure" and unit.hp < unit.max_hp:
			_heal(unit, unit, int(round(float(unit.max_hp) * LUMIERE_INTERIEURE_HEAL)), "lumiere_interieure", true)

	# Les états avancent d'un tour.
	for unit in units:
		for i in range(unit.statuses.size() - 1, -1, -1):
			var status: Dictionary = unit.statuses[i]
			status["turns"] = int(status.get("turns", 1)) - 1
			if int(status["turns"]) <= 0:
				unit.statuses.remove_at(i)
				_emit({"type": "status_expired", "target": unit.id, "status": status["id"]})

	_emit({"type": "turn_end", "turn": turn, "hp": _hp_snapshot()})
	_check_end()
	if not finished:
		turn += 1


func _check_end() -> void:
	var alive_a := team_units(0, true).size()
	var alive_b := team_units(1, true).size()
	if alive_a == 0 or alive_b == 0:
		finished = true
		end_reason = "ko"
		if alive_a != alive_b:
			winner = 0 if alive_a > alive_b else 1
		else:
			winner = _tie_break()
	elif turn >= forced_end_turn:
		finished = true
		end_reason = "mort_subite"
		var hp_a := team_total_hp(0)
		var hp_b := team_total_hp(1)
		if hp_a != hp_b:
			winner = 0 if hp_a > hp_b else 1
		else:
			winner = _tie_break()
	if finished:
		_emit({"type": "end", "winner": winner, "reason": end_reason})


## Jamais de match nul : l'équipe qui a infligé le plus de dégâts gagne, sinon l'équipe prioritaire du combat.
func _tie_break() -> int:
	if int(damage_by_team[0]) != int(damage_by_team[1]):
		return 0 if int(damage_by_team[0]) > int(damage_by_team[1]) else 1
	return priority_team


# ---------------------------------------------------------------------------
# Utilitaires
# ---------------------------------------------------------------------------

func _emit(event: Dictionary) -> void:
	_events.append(event)


func _ids(list: Array[CombatUnit]) -> Array:
	var ids: Array = []
	for unit in list:
		ids.append(unit.id)
	return ids


func _first_alive(list: Array[CombatUnit]) -> CombatUnit:
	for unit in list:
		if unit.is_alive():
			return unit
	return null


func _lowest_hp(list: Array[CombatUnit]) -> CombatUnit:
	var best: CombatUnit = null
	for unit in list:
		if unit.is_alive() and (best == null or unit.hp_ratio() < best.hp_ratio()):
			best = unit
	return best


func _hp_snapshot() -> Dictionary:
	var snapshot := {}
	for unit in units:
		snapshot[unit.id] = unit.hp
	return snapshot
