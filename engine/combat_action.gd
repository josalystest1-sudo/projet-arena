## Une Intention : un personnage, une compétence, une cible.
class_name CombatAction
extends RefCounted

var actor_id: String
var skill_id: String
var target_id: String


static func make(p_actor_id: String, p_skill_id: String, p_target_id: String) -> CombatAction:
	var action := CombatAction.new()
	action.actor_id = p_actor_id
	action.skill_id = p_skill_id
	action.target_id = p_target_id
	return action


func to_dict() -> Dictionary:
	return {"actor": actor_id, "skill": skill_id, "target": target_id}
