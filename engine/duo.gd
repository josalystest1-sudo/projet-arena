## Composition d'un duo : le personnage du joueur et son acolyte (GDD, « L'acolyte »).
## Module pur : le hasard vient d'un générateur fourni par l'appelant (même graine, même duo).
class_name Duo
extends RefCounted


## Rôle principal d'une classe : front, degats ou soutien.
static func main_role(data: CombatData, class_id: String) -> String:
	return data.role_of(class_id)


## Les classes qui peuvent servir d'acolyte : celles dont le rôle principal complète celui du joueur.
## Un Soutien reçoit un Front ou un Dégâts, un Dégâts un Front ou un Soutien, un Front un Dégâts ou un Soutien.
static func acolyte_classes(data: CombatData, player_class: String) -> Array[String]:
	var role := main_role(data, player_class)
	var result: Array[String] = []
	for class_id in data.classes:
		if main_role(data, class_id) != role:
			result.append(str(class_id))
	result.sort()
	return result


## Toutes les combinaisons de kit d'une classe : une active par palier et un passif.
static func all_picks(data: CombatData, class_id: String) -> Array[Dictionary]:
	var cls: Dictionary = data.classes[class_id]
	var result: Array[Dictionary] = []
	for basique in range(cls["skills"]["basique"].size()):
		for moyenne in range(cls["skills"]["moyenne"].size()):
			for forte in range(cls["skills"]["forte"].size()):
				for passive in range(cls["passives"].size()):
					result.append({"basique": basique, "moyenne": moyenne, "forte": forte, "passive": passive})
	return result


## Les 3 compétences actives d'un kit.
static func kit_skills(data: CombatData, class_id: String, picks: Dictionary) -> Array[String]:
	var cls: Dictionary = data.classes[class_id]
	var result: Array[String] = []
	for tier in CombatUnit.TIERS:
		var pool: Array = cls["skills"][tier]
		result.append(str(pool[int(picks.get(tier, 0)) % pool.size()]))
	return result


## Les Synergies que deux kits peuvent déclencher ensemble.
static func kit_synergies(data: CombatData, class_a: String, picks_a: Dictionary, class_b: String, picks_b: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for skill_a in kit_skills(data, class_a, picks_a):
		for skill_b in kit_skills(data, class_b, picks_b):
			var synergy := data.find_synergy(skill_a, skill_b)
			if not synergy.is_empty():
				result.append(synergy)
	return result


## Tire l'acolyte d'un joueur : une classe complémentaire au hasard, puis un kit au hasard parmi ceux
## qui ont au moins une Synergie avec le kit du joueur (aucun duo sans Synergie).
static func draw_acolyte(data: CombatData, player_class: String, player_picks: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var classes := acolyte_classes(data, player_class)
	var class_id: String = classes[rng.randi_range(0, classes.size() - 1)]
	var candidates: Array[Dictionary] = []
	for picks in all_picks(data, class_id):
		if not kit_synergies(data, player_class, player_picks, class_id, picks).is_empty():
			candidates.append(picks)
	if candidates.is_empty():
		candidates = all_picks(data, class_id)
	return {"class_id": class_id, "picks": candidates[rng.randi_range(0, candidates.size() - 1)]}


## Un duo complet pour Combat.create : le personnage principal puis son acolyte.
static func members(leader_class: String, leader_picks: Dictionary, acolyte: Dictionary) -> Array:
	return [
		{"class_id": leader_class, "picks": leader_picks},
		{"class_id": acolyte["class_id"], "picks": acolyte["picks"], "is_acolyte": true},
	]


## Un duo tiré entièrement au hasard (adversaires, simulateur). Classe imposée si class_id n'est pas vide.
static func random_duo(data: CombatData, rng: RandomNumberGenerator, class_id: String = "") -> Array:
	var leader_class := class_id
	if leader_class == "":
		var classes: Array = data.classes.keys()
		classes.sort()
		leader_class = classes[rng.randi_range(0, classes.size() - 1)]
	var leader_picks := CombatUnit.random_picks(rng)
	return members(leader_class, leader_picks, draw_acolyte(data, leader_class, leader_picks, rng))
