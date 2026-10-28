## Le moteur de règles du combat, tour par tour simultané. Les camps sont de taille variable :
## 2 contre 2 en PvP (un joueur et son acolyte de chaque côté), 2 contre 1 à 4 monstres à la Tour.
## Module pur : aucune dépendance aux nœuds de scène, aucun affichage, aucun hasard.
## Il est réutilisé tel quel par le client, le serveur, l'IA des Échos et le simulateur.
##
## Utilisation :
##   var combat := Combat.create(data, team_a, team_b)
##   ... chaque tour : collecter une CombatAction par unité vivante, puis
##   var events := combat.resolve_turn(actions)   # liste d'événements pour l'affichage
##
## Tout ce qui est chiffré vit dans les données : les effets des compétences (data/skills.json), les paramètres des
## passifs (data/passives.json, lus par clé : un passif « reduction » réduit les dégâts subis, quel que soit son nom),
## les états (data/statuses.json : négatif, contrôle, dégâts sur la durée, intouchable) et les Synergies
## (data/synergies.json : un type d'effet et ses chiffres). Les nœuds de Destin ajoutent leurs modificateurs sur
## l'unité (CombatUnit.mods) avec les mêmes clés que les passifs.
class_name Combat
extends RefCounted

const ACT_LAST_PENALTY := 1000
## Célérité (Voile, Hymne…) : l'unité agit avant tout le monde, les vitesses normales restant sous 100.
const ACT_FIRST_BONUS := 100
## Les types de dégâts du GDD, par famille (pour les réductions physiques ou élémentaires).
const PHYSICAL := ["tranchant", "contondant", "perforant"]
const ELEMENTAL := ["feu", "givre", "foudre", "ombre", "lumiere"]

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
## La Tour n'a pas de mort subite (GDD) : seulement une limite de tours au bout de laquelle un camp désigné gagne.
var sudden_death_enabled: bool = true
## Camp vainqueur à la fin forcée, s'il est imposé (-1 : le plus de PV totaux, comme en PvP).
var forced_end_winner: int = -1
## Épuisement (la Tour) : à partir de ce tour, ce camp ne soigne plus et ne pose plus de barrières (-1 : jamais).
var exhausted_team: int = -1
var exhaustion_turn: int = 0

# --- État interne d'un tour en cours de résolution ---
var _events: Array[Dictionary] = []
var _actions: Dictionary = {}          # unit_id -> CombatAction
var _acted: Dictionary = {}            # unit_id -> true une fois son tour passé (ou perdu)
var _resolved: Dictionary = {}         # unit_id -> true si l'action a bien été exécutée
var _resolved_targets: Dictionary = {} # unit_id -> identifiants des cibles réellement touchées par son action
var _queue: Array[CombatUnit] = []     # file d'attente du tour : qui agit ensuite
var _damage_dealt: Dictionary = {}     # actor_id -> {target_id: dégâts infligés ce tour}
var _hits_taken: Dictionary = {}       # target_id -> nombre de coups directs reçus ce tour
var _synergy_pairs: Array[Dictionary] = []
var _current_hits: Dictionary = {}     # cibles distinctes touchées par l'action en cours
var _team_first: Dictionary = {}       # camp -> true si l'un de ses membres joue une compétence « tout le duo agit en premier »


# ---------------------------------------------------------------------------
# Construction
# ---------------------------------------------------------------------------

## team_a et team_b : listes de dictionnaires {class_id, picks, name, is_player, is_acolyte} (seuls class_id et picks sont obligatoires).
## Un camp peut compter autant de membres qu'on veut : 2 en PvP (le joueur puis son acolyte), 1 à 4 monstres à la Tour.
## Un membre peut aussi porter : mods et skill_mods (les nœuds de son Destin), et pour la Tour max_hp_mult et power_mult
## (ennemis plus ou moins forts), heal_mult (soins plus faibles des ennemis de la Tour), hp (PV de départ, gardés
## d'un étage à l'autre) et cooldowns ({palier: tours restants}, recharges conservées).
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
			var unit: CombatUnit
			if member.has("monster_id"):
				unit = CombatUnit.from_monster(p_data, member["monster_id"], unit_id, team, slot)
				if member.has("name"):
					unit.display_name = str(member["name"])
			else:
				# En duo, le budget du Destin dépend aussi de la classe du partenaire.
				var partner_class := str(members[1 - slot].get("class_id", "")) if members.size() == 2 else ""
				unit = CombatUnit.from_class(p_data, member["class_id"], picks, unit_id, team, slot, partner_class, bool(member.get("is_acolyte", false)))
			unit.is_player = bool(member.get("is_player", false))
			if member.has("mods") or member.has("skill_mods"):
				unit.apply_mods(p_data, member.get("mods", {}), member.get("skill_mods", {}))
			if member.has("max_hp_mult"):
				unit.max_hp = maxi(1, int(round(float(unit.max_hp) * float(member["max_hp_mult"]))))
				unit.hp = unit.max_hp
			if member.has("power_mult"):
				unit.power = maxi(1, int(round(float(unit.power) * float(member["power_mult"]))))
			unit.heal_mult = float(member.get("heal_mult", 1.0))
			if member.has("hp"):
				unit.hp = clampi(int(member["hp"]), 1, unit.max_hp)
			var carried: Dictionary = member.get("cooldowns", {})
			for tier in carried:
				if int(carried[tier]) > 0:
					unit.cooldown_until[tier] = 1 + int(carried[tier])
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


## L'autre membre du duo (null s'il n'y en a pas ou s'il est KO).
func partner_of(unit: CombatUnit) -> CombatUnit:
	for ally in allies_of(unit, true):
		if ally != unit:
			return ally
	return null


func team_total_hp(team: int) -> int:
	var total := 0
	for unit in team_units(team, true):
		total += unit.hp
	return total


func priority_team_for_turn(p_turn: int) -> int:
	return priority_team if p_turn % 2 == 1 else 1 - priority_team


func is_sudden_death() -> bool:
	return sudden_death_enabled and turn >= sudden_death_turn


## Épuisement des ennemis de la Tour : ils ne soignent plus et ne protègent plus.
func is_exhausted(unit: CombatUnit) -> bool:
	return unit.team == exhausted_team and turn >= exhaustion_turn


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
	# Chantage : la forte est interdite tant que l'état dure.
	if tier == "forte" and unit.has_status("chantage"):
		return false
	var skill_id: String = unit.skills.get(tier, "")
	if bool(data.skill(skill_id).get("once_per_combat", false)) and unit.flags.get("used_" + skill_id, false):
		return false
	return true


func is_hostile(skill_id: String) -> bool:
	return str(data.skill(skill_id).get("target", "enemy")) in ["enemy", "enemies_2", "enemies_all"]


## Un ennemi qu'on ne peut pas viser ce tour-ci (Voile, Fumigène).
func is_untargetable(unit: CombatUnit) -> bool:
	for status_id in unit.status_ids():
		if data.status_flag(status_id, "untargetable"):
			return true
	return false


## Les cibles qu'un joueur peut choisir pour cette compétence.
func valid_targets(unit: CombatUnit, skill_id: String) -> Array[CombatUnit]:
	var target_type := str(data.skill(skill_id).get("target", "enemy"))
	match target_type:
		"enemy", "enemies_2", "enemies_all":
			var result: Array[CombatUnit] = []
			for enemy in enemies_of(unit, true):
				if not is_untargetable(enemy):
					result.append(enemy)
			return result
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
				var hits := int(effect.get("hits", 1))
				result["damage"] = int(result["damage"]) + hits * _damage_amount(actor, target, _effect_power(actor, skill_id, effect), _effect_mult(actor, target, effect, skill_id), single, str(skill.get("element", "")))
			"heal":
				result["heal"] = int(result["heal"]) + mini(_heal_amount(actor, target, _effect_power(actor, skill_id, effect)), target.max_hp - target.hp)
			"revive":
				result["revive"] = not target.is_alive()
	if int(result["damage"]) > 0:
		result["blocked"] = target.has_status("rempart") or _would_dodge(actor, target)
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
	_hits_taken = {}
	_synergy_pairs = []
	_team_first = {}

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
			var action: CombatAction = _actions[unit.id]
			if action != null:
				# L'acolyte qui garde sa forte pour une Synergie : retenu, pour qu'il n'attende jamais deux tours de suite.
				if action.waits_for_synergy:
					unit.flags["waited_for_synergy"] = turn
				# Hymne : tout le camp agit avant les ennemis ce tour.
				if _has_effect(action.skill_id, "team_first"):
					_team_first[unit.team] = true
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
			_emit({"type": "action_lost", "actor": actor.id, "skill": action.skill_id, "reason": "ko"})
			continue
		if actor.has_status("etourdi"):
			# Étourdi (Berceuse, Piège…) : son action est perdue, sa compétence n'est pas dépensée.
			_emit({"type": "action_lost", "actor": actor.id, "skill": action.skill_id, "reason": "etourdi"})
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


## Vitesse utilisée pour trier la file en début de tour : stat, bonus de la compétence, passifs et modificateurs,
## états (Vif, Célérité, Gelé), Hymne du camp, « agit en dernier » (Calme).
func effective_speed(unit: CombatUnit) -> int:
	var speed := unit.base_speed + int(round(_pv(unit, "speed_bonus")))
	var action: CombatAction = _actions.get(unit.id)
	if action != null:
		speed += int(data.skill(action.skill_id).get("speed_bonus", 0))
	if _pv(unit, "ko_speed") > 0.0 and _ko_mult(unit) > 1.0:
		speed += int(_pv(unit, "ko_speed"))
	# Cardio : +1 vitesse par tour sans être touché (jusqu'à un plafond), remis à zéro au premier coup.
	if _pv(unit, "speed_per_quiet_turn") > 0.0:
		speed += mini(int(unit.flags.get("quiet_turns", 0)), int(_pv(unit, "quiet_turns_max", 4))) * int(_pv(unit, "speed_per_quiet_turn"))
	# Réseau : +vitesse par ennemi sous un de ses états.
	if _pv(unit, "speed_per_marked_enemy") > 0.0:
		for enemy in enemies_of(unit, true):
			for status in enemy.statuses:
				if str(status.get("source", "")) == unit.id:
					speed += int(_pv(unit, "speed_per_marked_enemy"))
					break
	if unit.has_status("vif"):
		speed += int(unit.get_status("vif")["value"])
	if unit.has_status("celerite") or _team_first.get(unit.team, false):
		speed += ACT_FIRST_BONUS
	if _pv(unit, "act_last") > 0.0:
		speed -= ACT_FIRST_BONUS
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
		_apply_effect(actor, effect, _effect_targets(actor, effect, targets), skill, context)

	# Résonance : toucher plusieurs cibles rend un tour de recharge de la forte.
	if _pv(actor, "multi_hit_forte_minus") > 0.0 and _current_hits.size() >= 2:
		_reduce_cooldown(actor, "forte", int(_pv(actor, "multi_hit_forte_minus")), "resonance")
	# Enchaîneur : les coups consécutifs sur la même cible se renforcent ; changer de cible remet le compte à zéro.
	if _pv(actor, "combo_bonus") > 0.0 and is_hostile(action.skill_id):
		var first_target: String = targets[0].id
		if _current_hits.has(first_target) and actor.flags.get("combo_target", "") == first_target:
			actor.flags["combo"] = mini(int(actor.flags.get("combo", 0)) + 1, int(_pv(actor, "combo_max", 3)))
		else:
			actor.flags["combo"] = 1 if _current_hits.has(first_target) else 0
		actor.flags["combo_target"] = first_target
	# Jab, puis Crochet : le moteur retient à quel tour chaque compétence a touché.
	if not _current_hits.is_empty():
		actor.flags["hit_turn_" + action.skill_id] = turn


## Un effet peut viser autre chose que la cible de la compétence : « on: allies » (tout le duo), « on: self »,
## « on: partner » (l'autre membre du duo). Ex. Cri de guerre : il frappe un ennemi, et le bonus de dégâts va à tout le duo.
func _effect_targets(actor: CombatUnit, effect: Dictionary, targets: Array[CombatUnit]) -> Array[CombatUnit]:
	match str(effect.get("on", "")):
		"allies":
			return allies_of(actor, true)
		"self":
			var only_self: Array[CombatUnit] = [actor]
			return only_self
		"partner":
			var partner := partner_of(actor)
			var only_partner: Array[CombatUnit] = []
			if partner != null:
				only_partner.append(partner)
			return only_partner
	return targets


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
			elif chosen == null or not chosen.is_alive() or chosen.team == actor.team or is_untargetable(chosen):
				chosen = _first_targetable(enemies_of(actor, true))
			if chosen != null:
				chosen = _charisma_redirect(actor, chosen, target_type == "enemy")
				result.append(chosen)
			if target_type == "enemies_2":
				for enemy in enemies_of(actor, true):
					if enemy != chosen and result.size() < 2 and not is_untargetable(enemy):
						result.append(enemy)
		"enemies_all":
			for enemy in enemies_of(actor, true):
				if not is_untargetable(enemy):
					result.append(enemy)
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


## Charisme : un coup sur N visant son allié vise le Diplomate à la place (compte tenu par ennemi).
func _charisma_redirect(actor: CombatUnit, chosen: CombatUnit, single: bool) -> CombatUnit:
	if not single:
		return chosen
	for ally in allies_of(chosen, true):
		if ally == chosen or _pv(ally, "redirect_every") <= 0.0 or is_untargetable(ally):
			continue
		var count := int(actor.flags.get("charisme_" + ally.id, 0)) + 1
		actor.flags["charisme_" + ally.id] = count
		if count % int(_pv(ally, "redirect_every")) == 0:
			_emit({"type": "redirected", "actor": actor.id, "from": chosen.id, "to": ally.id, "by": "charisme"})
			return ally
	return chosen


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
	var skill_id := str(context["skill_id"])
	match str(effect["type"]):
		"damage":
			var hits := int(effect.get("hits", 1))
			for target in targets:
				for hit in range(hits):
					var mult := _effect_mult(actor, target, effect, skill_id)
					for synergy_id in context["synergies"]:
						mult += _synergy_amplify(synergy_id, skill_id, target)
					var dealt := _deal_damage(actor, target, _effect_power(actor, skill_id, effect), element, mult, bool(context["single_target"]), skill_id)
					if dealt > 0:
						_current_hits[target.id] = true
					# Vol de vie (Dévorer, Drain d'âme) : une part des dégâts infligés soigne l'attaquant.
					if dealt > 0 and effect.has("lifesteal"):
						_self_heal(actor, int(round(float(dealt) * float(effect["lifesteal"]))), skill_id)
					# Brasier : chaque coup de feu brûle la cible.
					if _pv(actor, "burn_value") > 0.0 and element == "feu" and target.is_alive():
						_add_status(target, {"id": "brulure", "turns": int(_pv(actor, "burn_turns", 1)), "value": int(_pv(actor, "burn_value")), "source": actor.id})
		"heal":
			for target in targets:
				if bool(effect.get("overflow_barrier", false)):
					_heal_with_overflow(actor, target, _effect_power(actor, skill_id, effect), skill_id, float(effect.get("overflow", 1.0)))
				else:
					_heal(actor, target, _effect_power(actor, skill_id, effect), skill_id)
		"status":
			for target in targets:
				if target.is_alive():
					_add_status(target, {"id": effect["id"], "turns": int(effect["turns"]) + int(actor.skill_mod(skill_id, "turns_bonus")), "value": int(effect.get("value", 0)), "source": actor.id})
		"barrier":
			for target in targets:
				_add_status(target, {"id": "barriere", "turns": int(effect.get("turns", 3)), "value": _barrier_amount(actor, _effect_power(actor, skill_id, effect)), "source": actor.id})
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
				_act_last(actor, target)
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
		"delay_cooldown":
			# Sabotage : la compétence du palier donné repart en recharge, comme si la cible venait de la jouer.
			for target in targets:
				_delay_cooldown(actor, target, str(effect.get("tier", "forte")))
		"reset_cooldowns":
			# Catalyseur : toutes les recharges d'un allié sont remises à zéro.
			for target in targets:
				if target.is_alive():
					target.cooldown_until = {}
					_emit({"type": "cooldowns_reset", "source": actor.id, "target": target.id})
		"team_first":
			pass  # Pris en compte au tri de la file (voir resolve_turn).


## Multiplicateur propre à un effet de dégâts : doublé si la cible n'a pas encore agi (Coup bas), si une autre
## compétence a touché au tour précédent (Crochet après Jab), plus fort à chaque tour écoulé (Crescendo).
func _effect_mult(actor: CombatUnit, target: CombatUnit, effect: Dictionary, skill_id: String) -> float:
	var mult := 1.0
	if effect.has("bonus_if_not_acted") and (not _acted.get(target.id, false) or _condition_forced(actor, skill_id)):
		mult += float(effect["bonus_if_not_acted"])
	if effect.has("bonus_after"):
		var previous := str(effect["bonus_after"])
		if int(actor.flags.get("hit_turn_" + previous, -10)) == turn - 1:
			mult += float(effect.get("bonus_after_value", 1.0))
	if effect.has("per_turn"):
		mult += float(effect["per_turn"]) * float(turn - 1)
	return mult


## Puissance d'un effet, avec l'évolution de compétence du Destin (power_bonus : +10 % = 0,1).
func _effect_power(actor: CombatUnit, skill_id: String, effect: Dictionary) -> int:
	var power := int(effect.get("power", 0))
	var bonus := actor.skill_mod(skill_id, "power_bonus")
	if bonus != 0.0:
		power = int(round(float(power) * (1.0 + bonus)))
	return power


# --- Dégâts et soins -------------------------------------------------------

## Montant des dégâts d'une compétence, avant Martyr, Rempart et barrière. Dans l'ordre : la puissance de l'attaquant,
## ses états et passifs (Galvanisé, Colère, Focalisation, Vétéran, Meute, Affaibli, bonus de situation), la mort subite,
## puis ce que subit la cible (Peau de fer, Mâchoire d'acier, Peau de mercure, Marque).
func _damage_amount(source: CombatUnit, target: CombatUnit, base_power: int, mult: float, single_target: bool, element: String = "") -> int:
	var amount := float(base_power) * float(source.power) / 100.0 * mult
	if source.has_status("galvanise"):
		amount *= 1.0 + float(source.get_status("galvanise")["value"]) / 100.0
	if _pv(source, "per_quarter") > 0.0:
		var missing_quarters := int(floor((1.0 - source.hp_ratio()) * 4.0))
		amount *= 1.0 + _pv(source, "per_quarter") * float(missing_quarters)
	if single_target and _pv(source, "single_target_bonus") > 0.0:
		amount *= 1.0 + _pv(source, "single_target_bonus")
	if _pv(source, "damage_bonus") > 0.0:
		amount *= 1.0 + _pv(source, "damage_bonus") * _ko_mult(source)
	if _pv(source, "per_ally_bonus") > 0.0:
		amount *= 1.0 + _pv(source, "per_ally_bonus") * float(allies_of(source, true).size() - 1)
	if element != "" and _pv(source, element + "_bonus") > 0.0:
		amount *= 1.0 + _pv(source, element + "_bonus")
	amount *= _situation_mult(source, target)
	if source.has_status("affaibli"):
		amount *= maxf(0.0, 1.0 - float(source.get_status("affaibli")["value"]) / 100.0)
	amount *= sudden_death_damage_mult()
	if _pv(target, "reduction") > 0.0:
		amount *= 1.0 - _pv(target, "reduction")
	if element in PHYSICAL and _pv(target, "physical_reduction") > 0.0:
		amount *= 1.0 - _pv(target, "physical_reduction")
	if element in ELEMENTAL and _pv(target, "elemental_reduction") > 0.0:
		amount *= 1.0 - _pv(target, "elemental_reduction")
	if target.has_status("marque"):
		amount *= 1.0 + float(target.get_status("marque")["value"]) / 100.0
	if target.has_status("garde"):
		amount *= maxf(0.0, 1.0 - float(target.get_status("garde")["value"]) / 100.0)
	return int(round(amount))


## Les bonus de situation de l'attaquant : cible déjà touchée ce tour (Opportuniste), cible sous un seuil (Mise à mort),
## cible qui saigne ou s'empoisonne (Traqueur), cible marquée (Œil de faucon), coups consécutifs (Enchaîneur), Calme.
func _situation_mult(source: CombatUnit, target: CombatUnit) -> float:
	var mult := 1.0
	if _pv(source, "hit_target_bonus") > 0.0 and int(_hits_taken.get(target.id, 0)) > 0:
		mult *= 1.0 + _pv(source, "hit_target_bonus")
	if _pv(source, "execute_bonus") > 0.0 and target.hp_ratio() < _pv(source, "execute_threshold", 0.35):
		mult *= 1.0 + _pv(source, "execute_bonus")
	if _pv(source, "dot_target_bonus") > 0.0 and _has_dot(target):
		mult *= 1.0 + _pv(source, "dot_target_bonus")
	if _pv(source, "marked_target_bonus") > 0.0 and target.has_status("marque"):
		mult *= 1.0 + _pv(source, "marked_target_bonus")
	if _pv(source, "combo_bonus") > 0.0 and str(source.flags.get("combo_target", "")) == target.id:
		mult *= 1.0 + _pv(source, "combo_bonus") * float(int(source.flags.get("combo", 0)))
	if _pv(source, "act_last_bonus") > 0.0:
		mult *= 1.0 + _pv(source, "act_last_bonus")
	return mult


## Montant d'un soin de compétence (avant plafond des PV max).
func _heal_amount(source: CombatUnit, target: CombatUnit, base_power: int) -> int:
	var amount := float(base_power) * float(source.power) / 100.0
	if _pv(source, "foi_bonus") > 0.0 and target.hp_ratio() < _pv(source, "foi_threshold", 0.4):
		amount *= 1.0 + _pv(source, "foi_bonus")
	if _pv(source, "heal_bonus") > 0.0:
		amount *= 1.0 + _pv(source, "heal_bonus")
	amount *= source.heal_mult * sudden_death_heal_mult()
	if is_exhausted(source):
		amount = 0.0
	return int(round(amount))


## Valeur d'une barrière posée par une unité.
func _barrier_amount(source: CombatUnit, base_power: int) -> int:
	if is_exhausted(source):
		return 0
	var amount := float(base_power) * float(source.power) / 100.0
	if _pv(source, "barrier_bonus") > 0.0:
		amount *= 1.0 + _pv(source, "barrier_bonus")
	return int(round(amount))


## Calcule et inflige des dégâts d'une compétence. Renvoie les PV réellement perdus par la cible.
func _deal_damage(source: CombatUnit, target: CombatUnit, base_power: int, element: String, mult: float, single_target: bool, skill_id: String = "") -> int:
	if not target.is_alive():
		return 0
	var total := _damage_amount(source, target, base_power, mult, single_target, element)

	# Esquive, Fuite : la première attaque du combat est annulée.
	if _would_dodge(source, target):
		target.flags["dodges"] = int(target.flags.get("dodges", 0)) + 1
		_emit({"type": "dodged", "source": source.id, "target": target.id, "amount": total})
		return 0

	# Martyr : un allié de la cible encaisse une part des dégâts.
	for ally in allies_of(target, true):
		if ally != target and _pv(ally, "martyr_share") > 0.0:
			var share := int(round(float(total) * _pv(ally, "martyr_share")))
			if share > 0:
				total -= share
				_apply_damage(source, ally, share, element, "martyr")
			break
	var dealt := _apply_damage(source, target, total, element, "hit")
	_after_hit(source, target, dealt, element, skill_id)
	return dealt


## Esquive, Fuite : une attaque ennemie directe est annulée tant qu'il reste des esquives (une par combat, et une de
## plus à partir d'un tour donné pour certains passifs).
func _would_dodge(source: CombatUnit, target: CombatUnit) -> bool:
	if source == null or source.team == target.team or _pv(target, "dodges") <= 0.0:
		return false
	var allowed := int(_pv(target, "dodges"))
	if _pv(target, "dodge_again_from_turn") > 0.0 and turn >= int(_pv(target, "dodge_again_from_turn")):
		allowed += 1
	return int(target.flags.get("dodges", 0)) < allowed


## Après un coup direct d'un ennemi : ripostes (Garde haute, Ultimatum, Sang acide), piège, compteurs de situation.
func _after_hit(source: CombatUnit, target: CombatUnit, dealt: int, element: String, skill_id: String) -> void:
	if source == null or source.team == target.team:
		return
	_hits_taken[target.id] = int(_hits_taken.get(target.id, 0)) + 1
	target.flags["quiet_turns"] = 0
	target.flags["hit_this_turn"] = turn
	var contact := data.is_contact(skill_id)
	# Garde haute : la cible contre-attaque celui qui la frappe (au contact).
	var garde := target.get_status("garde")
	if not garde.is_empty() and contact and source.is_alive():
		_riposte(target, source, int(garde.get("counter", 0)), "garde")
	# Ultimatum : celui qui a été forcé d'attaquer le Diplomate le paie.
	var ultimatum := source.get_status("ultimatum")
	if not ultimatum.is_empty() and str(ultimatum.get("source", "")) == target.id and source.is_alive():
		_riposte(target, source, int(ultimatum.get("value", 0)), "ultimatum")
		var extra := get_unit(str(ultimatum.get("extra_counter", "")))
		if extra != null and extra.is_alive() and source.is_alive():
			var extra_garde := extra.get_status("garde")
			_riposte(extra, source, int(extra_garde.get("counter", 0)), "garde")
	# Sang acide : les attaquants au contact subissent des dégâts.
	if _pv(target, "contact_riposte") > 0.0 and contact and source.is_alive():
		_riposte(target, source, int(_pv(target, "contact_riposte")), "sang_acide")
	# Piège : le premier ennemi qui agit sur l'allié piégé est étourdi au tour suivant.
	if target.has_status("piege") and source.is_alive():
		target.remove_status("piege")
		_emit({"type": "trapped", "source": target.id, "target": source.id})
		_add_status(source, {"id": "etourdi", "turns": 2, "value": 0, "source": target.id})


## Une riposte : des dégâts proportionnels à la puissance de celui qui riposte, sans riposte en retour.
func _riposte(defender: CombatUnit, attacker: CombatUnit, power: int, kind: String) -> void:
	if power <= 0:
		return
	var amount := int(round(float(power) * float(defender.power) / 100.0 * sudden_death_damage_mult()))
	_apply_damage(defender, attacker, amount, "", kind)


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
		# Vibrato : une part des dégâts passe à travers la barrière.
		var pierced := int(round(float(amount) * _pv(source, "barrier_pierce"))) if source != null else 0
		var absorbed := mini(int(barrier["value"]), amount - pierced)
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
	if source != null and source.team != target.team and kind != "dot":
		target.last_hit_by = source.id
	if source != null:
		damage_by_team[source.team] = int(damage_by_team[source.team]) + amount
		if not _damage_dealt.has(source.id):
			_damage_dealt[source.id] = {}
		_damage_dealt[source.id][target.id] = int(_damage_dealt[source.id].get(target.id, 0)) + amount
	if target.hp <= 0:
		target.statuses.clear()
		_emit({"type": "ko", "target": target.id})
	elif _pv(target, "souffle_heal") > 0.0 and not target.flags.get("second_souffle", false) and target.hp_ratio() < _pv(target, "souffle_threshold", 0.3):
		target.flags["second_souffle"] = true
		_heal(target, target, int(round(float(target.max_hp) * _pv(target, "souffle_heal"))), "second_souffle", true)
	return amount


func _heal(source: CombatUnit, target: CombatUnit, base_power: int, kind: String, raw: bool = false) -> int:
	if not target.is_alive():
		return 0
	var amount := _heal_amount(source, target, base_power) if not raw else int(round(float(base_power) * sudden_death_heal_mult()))
	var healed := mini(amount, target.max_hp - target.hp)
	target.hp += healed
	_emit({"type": "heal", "source": source.id, "target": target.id, "amount": healed, "kind": kind, "hp": target.hp})
	return healed


## Un soin qu'une unité se donne par ses propres effets (vol de vie, Régénération) : comme ses autres soins, il suit
## son multiplicateur de soins et s'arrête quand son camp est épuisé (ennemis de la Tour).
func _self_heal(unit: CombatUnit, amount: int, kind: String) -> int:
	if is_exhausted(unit):
		return 0
	return _heal(unit, unit, int(round(float(amount) * unit.heal_mult)), kind, true)


## Prière : une part (ratio) du soin qui dépasse les PV max devient une barrière (un petit soin n'est jamais perdu).
func _heal_with_overflow(source: CombatUnit, target: CombatUnit, base_power: int, kind: String, ratio: float) -> void:
	if not target.is_alive():
		return
	var expected := _heal_amount(source, target, base_power)
	var healed := _heal(source, target, base_power, kind)
	var barrier := int(round(float(expected - healed) * ratio))
	if barrier > 0:
		_add_status(target, {"id": "barriere", "turns": 2, "value": barrier, "source": source.id})


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
	var applied: Array[CombatUnit] = []
	for enemy in provoked:
		if _add_status(enemy, {"id": "provoque", "turns": 1, "value": 0, "source": actor.id}):
			applied.append(enemy)
	_emit({"type": "taunt", "actor": actor.id, "targets": _ids(applied)})


## Repousse l'Intention de la cible d'un cran : elle passe juste derrière l'unité qui la suivait.
func _push_back(target: CombatUnit) -> void:
	if target.is_immune("push_back"):
		_emit({"type": "immune", "target": target.id, "status": "push_back"})
		return
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


## Trait de givre, Engloutir : la cible passe en fin de file ; si elle a déjà agi, elle agira en dernier au tour suivant.
func _act_last(actor: CombatUnit, target: CombatUnit) -> void:
	if not target.is_alive():
		return
	if target.is_immune("gele"):
		_emit({"type": "immune", "target": target.id, "status": "gele"})
		return
	if _acted.get(target.id, false):
		_add_status(target, {"id": "gele", "turns": 2, "value": 0, "source": actor.id})
	else:
		_queue.erase(target)
		_queue.append(target)
		_add_status(target, {"id": "gele", "turns": 1, "value": 0, "source": actor.id})


## Pose un état, sauf immunité (Impassible, Sang-froid) ; les états posés par une unité « dont les états durent un tour
## de plus » (Distillation, Virtuose) sont prolongés. Renvoie vrai si l'état a été posé.
func _add_status(target: CombatUnit, status: Dictionary) -> bool:
	var status_id := str(status["id"])
	if target.is_immune(status_id):
		_emit({"type": "immune", "target": target.id, "status": status_id})
		return false
	var source := get_unit(str(status.get("source", "")))
	if source != null and source != target and _pv(source, "status_turns_bonus") > 0.0 and int(status.get("turns", 0)) > 0:
		status = status.duplicate()
		status["turns"] = int(status["turns"]) + int(_pv(source, "status_turns_bonus"))
	target.add_status(status)
	_emit({"type": "status", "target": target.id, "status": status_id, "turns": status.get("turns", 0), "value": status.get("value", 0)})
	return true


# --- Recharges ---------------------------------------------------------------

func _start_cooldown(unit: CombatUnit, tier: String) -> void:
	var cooldown := int(cooldown_by_tier.get(tier, 0))
	if cooldown <= 0:
		return
	# Météorologue, Rythme, Doigts agiles, nœuds de Destin : une recharge plus courte.
	cooldown -= int(_pv(unit, tier + "_minus")) + int(unit.skill_mod(unit.skills[tier], "cooldown_minus"))
	unit.cooldown_until[tier] = turn + maxi(cooldown, 1) + 1


func _reduce_cooldown(unit: CombatUnit, tier: String, amount: int, reason: String) -> void:
	var until := int(unit.cooldown_until.get(tier, 0))
	if until <= turn + 1:
		return
	unit.cooldown_until[tier] = until - amount
	_emit({"type": "cooldown_reduced", "target": unit.id, "tier": tier, "amount": amount, "reason": reason})


## Sabotage : la compétence du palier repart en recharge complète (au plus tard de sa recharge actuelle).
func _delay_cooldown(actor: CombatUnit, target: CombatUnit, tier: String) -> void:
	if not target.is_alive():
		return
	var until := turn + int(cooldown_by_tier.get(tier, 0)) + 1
	if until > int(target.cooldown_until.get(tier, 0)):
		target.cooldown_until[tier] = until
	_emit({"type": "cooldown_delayed", "source": actor.id, "target": target.id, "tier": tier, "remaining": cooldown_remaining(target, tier)})


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


func _synergy_pair(synergy_id: String) -> Dictionary:
	for pair in _synergy_pairs:
		if pair["synergy"]["id"] == synergy_id:
			return pair
	return {}


## Le bonus de dégâts d'une Synergie « amplify » déjà active (sa première compétence s'est résolue) sur la compétence
## qui s'exécute : +bonus, éventuellement seulement sur les cibles portant un état (Piège de feu : les provoqués).
func _synergy_amplify(synergy_id: String, skill_id: String, target: CombatUnit) -> float:
	var synergy := data.synergy_by_id(synergy_id)
	var effect: Dictionary = synergy.get("effect", {})
	if str(effect.get("type", "")) != "amplify" or str(effect.get("skill", "")) != skill_id:
		return 0.0
	var vs_status := str(effect.get("vs_status", ""))
	if vs_status != "" and not target.has_status(vs_status):
		return 0.0
	return _sp(synergy_id, "bonus", 0.5)


## Marque + Coup bas : la condition du Coup bas est tenue pour vraie quand la Synergie est active.
func _condition_forced(actor: CombatUnit, skill_id: String) -> bool:
	for synergy_id in _active_synergy_ids(actor):
		var effect: Dictionary = data.synergy_by_id(synergy_id).get("effect", {})
		if str(effect.get("type", "")) == "force_condition" and str(effect.get("skill", "")) == skill_id:
			return true
	return false


## La seconde compétence du couple vient de se résoudre : la Synergie se déclenche. Son effet est décrit dans les
## données (type et chiffres), le moteur n'a qu'une poignée de types génériques.
func _fire_synergies(actor: CombatUnit) -> void:
	for pair in _synergy_pairs:
		var partner_id := _partner_in(pair, actor)
		if partner_id == "" or not _resolved.get(partner_id, false) or pair.get("fired", false):
			continue
		pair["fired"] = true
		var synergy: Dictionary = pair["synergy"]
		var partner := get_unit(partner_id)
		_emit({"type": "synergy", "id": synergy["id"], "name": synergy["name"], "actors": pair["actors"]})
		_apply_synergy(synergy, actor, partner)
		# Inspiration : chaque Synergie du duo galvanise l'équipe.
		for ally in allies_of(actor, true):
			if _pv(ally, "synergy_team_bonus") > 0.0:
				for member in allies_of(actor, true):
					_add_status(member, {"id": "galvanise", "turns": 2, "value": int(round(_pv(ally, "synergy_team_bonus") * 100.0)), "source": ally.id})


## second : celui qui vient d'agir ; first : son partenaire, qui a agi avant. « actor_of(skill) » retrouve lequel des
## deux joue telle compétence du couple.
func _apply_synergy(synergy: Dictionary, second: CombatUnit, first: CombatUnit) -> void:
	var id := str(synergy["id"])
	var effect: Dictionary = synergy.get("effect", {})
	var skill_id := str(effect.get("skill", ""))
	var owner := _actor_of(skill_id, second, first)
	var other := first if owner == second else second
	var target := get_unit(_actions[second.id].target_id)
	match str(effect.get("type", "")):
		"amplify":
			# Si la compétence amplifiée s'est résolue avant l'autre, le bonus s'applique maintenant sur ce qu'elle a fait.
			if owner == first:
				var dealt: Dictionary = _damage_dealt.get(first.id, {})
				var vs_status := str(effect.get("vs_status", ""))
				for enemy in enemies_of(second, true):
					if dealt.has(enemy.id) and (vs_status == "" or enemy.has_status(vs_status)):
						_apply_damage(first, enemy, int(round(float(dealt[enemy.id]) * _sp(id, "bonus", 0.5))), str(data.skill(skill_id).get("element", "")), "synergie")
		"force_condition":
			# Coup bas résolu avant la Marque : le double s'applique après coup.
			if owner == first:
				var dealt: Dictionary = _damage_dealt.get(first.id, {})
				var bonus := float(_skill_effect(skill_id, "damage").get("bonus_if_not_acted", 1.0))
				for enemy in enemies_of(second, true):
					if dealt.has(enemy.id) and _acted.get(enemy.id, false) and enemy.id == _actions[first.id].target_id:
						_apply_damage(first, enemy, int(round(float(dealt[enemy.id]) * bonus)), str(data.skill(skill_id).get("element", "")), "synergie")
		"extra_damage":
			# Des dégâts fixes d'un élément sur la cible (de la seconde compétence, ou de la compétence nommée).
			if skill_id != "":
				target = get_unit(_actions[owner.id].target_id)
			if target != null and target.is_alive() and target.team != second.team:
				_apply_damage(owner if skill_id != "" else second, target, int(round(_sp(id, "damage", 30) * sudden_death_damage_mult())), str(effect.get("element", "")), "synergie")
		"extend_status":
			# Un état de la cible dure plus longtemps et frappe plus fort (Plaie brûlante : le saignement).
			if target == null or not target.is_alive():
				return
			var status := target.get_status(str(effect.get("status", "")))
			if not status.is_empty():
				status["turns"] = int(status["turns"]) + int(_sp(id, "extra_turns", 2))
				status["value"] = int(round(float(status["value"]) * (1.0 + _sp(id, "bonus", 0.0))))
				_emit({"type": "status", "target": target.id, "status": status["id"], "turns": status["turns"], "value": status["value"]})
		"add_status":
			# Un état posé : sur la cible de la compétence nommée (« to: skill_target »), sur tout le duo ou sur tous les
			# ennemis. « stack » : un Rempart déjà posé gagne une protection de plus au lieu d'être remplacé.
			var status := {"id": str(effect.get("status", "")), "turns": int(_sp(id, "turns", float(effect.get("turns", 2)))), "value": int(_sp(id, "value", float(effect.get("value", 0)))), "source": owner.id}
			for unit in _synergy_targets(str(effect.get("to", "skill_target")), owner, second):
				if not unit.is_alive():
					continue
				var existing := unit.get_status(status["id"])
				if bool(effect.get("stack", false)) and not existing.is_empty():
					existing["value"] = int(existing["value"]) + maxi(int(status["value"]), 1)
					_emit({"type": "status", "target": unit.id, "status": status["id"], "turns": existing.get("turns", 0), "value": existing["value"]})
				else:
					_add_status(unit, status)
		"spread_to_duo":
			# La barrière, le soin ou le renfort de la compétence nommée se pose aussi sur les autres membres du duo.
			var skill_effect := _first_effect(skill_id, ["barrier", "heal", "status"])
			var already: Array = _resolved_targets.get(owner.id, [])
			var share := _sp(id, "share", _sp(id, "mult", 1.0))
			for ally in allies_of(owner, true):
				if already.has(ally.id):
					continue
				match str(skill_effect.get("type", "")):
					"barrier":
						_add_status(ally, {"id": "barriere", "turns": int(skill_effect.get("turns", 3)), "value": int(round(float(_barrier_amount(owner, int(skill_effect.get("power", 0)))) * share)), "source": owner.id})
					"heal":
						_heal_with_overflow(owner, ally, int(round(float(skill_effect.get("power", 0)) * share)), "synergie", float(skill_effect.get("overflow", 1.0)))
					"status":
						_add_status(ally, {"id": skill_effect["id"], "turns": int(skill_effect["turns"]), "value": int(round(float(skill_effect.get("value", 0)) * share)), "source": owner.id})
		"spread_to_enemies":
			# Les dégâts de la compétence nommée touchent aussi les autres ennemis (ceux sous l'état posé par le partenaire).
			var power := int(_skill_effect(skill_id, "damage").get("power", 0))
			var already: Array = _resolved_targets.get(owner.id, [])
			var vs_status := str(effect.get("vs_status", ""))
			for enemy in enemies_of(owner, true):
				if already.has(enemy.id) or is_untargetable(enemy):
					continue
				if vs_status != "":
					var marked := enemy.get_status(vs_status)
					if marked.is_empty() or str(marked.get("source", "")) != other.id:
						continue
				_apply_damage(owner, enemy, _damage_amount(owner, enemy, power, _sp(id, "mult", 1.0), true, str(data.skill(skill_id).get("element", ""))), str(data.skill(skill_id).get("element", "")), "synergie")
		"cooldown_minus":
			# Une recharge du partenaire (ou des deux) revient plus tôt (Hymne + une forte).
			var tier := str(effect.get("tier", "forte"))
			for unit in ([first, second] if str(effect.get("who", "owner")) == "both" else [owner]):
				_reduce_cooldown(unit, tier, int(_sp(id, "amount", 1)), "synergie")
		"heal_duo":
			for ally in allies_of(second, true):
				_heal(second, ally, int(_sp(id, "power", 30)), "synergie")
		"barrier_duo":
			for ally in allies_of(second, true):
				_add_status(ally, {"id": "barriere", "turns": int(effect.get("turns", 2)), "value": _barrier_amount(second, int(_sp(id, "power", 30))), "source": second.id})
		"cleanse_duo":
			for ally in allies_of(second, true):
				for status_id in ally.status_ids():
					if data.is_negative_status(status_id):
						ally.remove_status(status_id)
						_emit({"type": "status_removed", "target": ally.id, "status": status_id})
		"lifesteal":
			# Les dégâts du couple ce tour soignent le duo (le plus blessé d'abord).
			var total := 0
			for unit in [first, second]:
				for amount in _damage_dealt.get(unit.id, {}).values():
					total += int(amount)
			var healed := _lowest_hp(allies_of(second, true))
			if healed != null and total > 0:
				_heal(second, healed, int(round(float(total) * _sp(id, "share", 0.3))), "synergie", true)
		"extra_counter":
			# Ultimatum + Garde haute : l'ennemi forcé d'attaquer subit aussi la contre-attaque du partenaire.
			var guard := _actor_of(str(effect.get("guard", "")), second, first)
			var forced := get_unit(_actions[_actor_of(skill_id, second, first).id].target_id)
			if forced != null and forced.has_status("ultimatum"):
				forced.get_status("ultimatum")["extra_counter"] = guard.id


## Les unités visées par un état de Synergie : « skill_target » (la cible de la compétence nommée), « duo », « enemies ».
func _synergy_targets(to: String, owner: CombatUnit, second: CombatUnit) -> Array[CombatUnit]:
	var result: Array[CombatUnit] = []
	match to:
		"duo":
			return allies_of(second, true)
		"enemies":
			for enemy in enemies_of(second, true):
				if not is_untargetable(enemy):
					result.append(enemy)
			return result
	var target := get_unit(_actions[owner.id].target_id)
	if target != null:
		result.append(target)
	return result


## Lequel des deux membres du couple joue cette compétence (le second par défaut).
func _actor_of(skill_id: String, second: CombatUnit, first: CombatUnit) -> CombatUnit:
	if skill_id != "" and _actions[first.id].skill_id == skill_id:
		return first
	return second


## Le premier effet d'un type donné dans une compétence (ex. la barrière du Bouclier de mana).
func _skill_effect(skill_id: String, effect_type: String) -> Dictionary:
	return _first_effect(skill_id, [effect_type])


func _first_effect(skill_id: String, types: Array) -> Dictionary:
	for effect in data.skill(skill_id).get("effects", []):
		if str(effect["type"]) in types:
			return effect
	return {}


func _has_effect(skill_id: String, effect_type: String) -> bool:
	return not _skill_effect(skill_id, effect_type).is_empty()


# ---------------------------------------------------------------------------
# Fin de tour
# ---------------------------------------------------------------------------

func _end_of_turn() -> void:
	# Effets sur la durée (saignement, brûlure, poison : les états marqués « dot » dans les données).
	for unit in units:
		if not unit.is_alive():
			continue
		for status_id in data.dot_statuses():
			var status := unit.get_status(status_id)
			if not status.is_empty() and unit.is_alive():
				var source := get_unit(str(status.get("source", "")))
				var amount := int(round(float(status["value"]) * sudden_death_damage_mult()))
				_apply_damage(source, unit, amount, status_id, "dot")
		# Régénérations : Lumière intérieure, Régénération ; Baume soigne l'allié le plus blessé.
		if unit.is_alive() and _pv(unit, "regen") > 0.0 and unit.hp < unit.max_hp:
			_self_heal(unit, int(round(float(unit.max_hp) * _pv(unit, "regen"))), "regeneration")
		if unit.is_alive() and _pv(unit, "ally_regen") > 0.0:
			var hurt := _lowest_hp(allies_of(unit, true))
			if hurt != null and hurt.hp < hurt.max_hp:
				_heal(unit, hurt, int(round(float(hurt.max_hp) * _pv(unit, "ally_regen"))), "baume", true)
		# Protocole : un état de contrôle de l'allié est retiré en fin de tour.
		if unit.is_alive() and _pv(unit, "cleanse_ally_control") > 0.0:
			for ally in allies_of(unit, true):
				if ally == unit:
					continue
				for status_id in ally.status_ids():
					if data.status_flag(status_id, "control"):
						ally.remove_status(status_id)
						_emit({"type": "status_removed", "target": ally.id, "status": status_id})
						break
		# Cardio : un tour sans être touché.
		if unit.is_alive() and int(unit.flags.get("hit_this_turn", 0)) != turn:
			unit.flags["quiet_turns"] = int(unit.flags.get("quiet_turns", 0)) + 1

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
		end_reason = "mort_subite" if sudden_death_enabled else "limite_de_tours"
		var hp_a := team_total_hp(0)
		var hp_b := team_total_hp(1)
		if forced_end_winner >= 0:
			winner = forced_end_winner
		elif hp_a != hp_b:
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

## Un chiffre d'une unité : le paramètre de son passif (data/passives.json) plus ses modificateurs (nœuds de Destin),
## sous la même clé. 0 (ou fallback) si rien ne le définit.
func _pv(unit: CombatUnit, key: String, fallback: float = 0.0) -> float:
	if unit.mods.has(key):
		return data.passive_param(unit.passive, key, 0.0) + float(unit.mods[key])
	return data.passive_param(unit.passive, key, fallback)


func _sp(synergy_id: String, key: String, fallback: float) -> float:
	return data.synergy_param(synergy_id, key, fallback)


## Vétéran : ses bonus sont multipliés quand son allié est KO.
func _ko_mult(unit: CombatUnit) -> float:
	if _pv(unit, "ko_mult") <= 0.0:
		return 1.0
	for ally in allies_of(unit):
		if ally != unit and not ally.is_alive():
			return _pv(unit, "ko_mult")
	return 1.0


func _has_dot(unit: CombatUnit) -> bool:
	for status_id in unit.status_ids():
		if data.status_flag(status_id, "dot"):
			return true
	return false


func _emit(event: Dictionary) -> void:
	_events.append(event)


func _ids(list: Array[CombatUnit]) -> Array:
	var ids: Array = []
	for unit in list:
		ids.append(unit.id)
	return ids


func _first_targetable(list: Array[CombatUnit]) -> CombatUnit:
	for unit in list:
		if unit.is_alive() and not is_untargetable(unit):
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
