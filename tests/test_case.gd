## Classe de base des tests du moteur de règles. Pas de dépendance à une bibliothèque externe.
extends RefCounted

var failures: Array = []
var data: CombatData


func setup() -> void:
	data = CombatData.load_default()


func assert_true(condition: bool, message: String = "") -> void:
	if not condition:
		failures.append(message if message != "" else "condition fausse")


func assert_false(condition: bool, message: String = "") -> void:
	assert_true(not condition, message)


func assert_eq(actual: Variant, expected: Variant, message: String = "") -> void:
	if actual != expected:
		failures.append("%s : attendu %s, obtenu %s" % [message, str(expected), str(actual)])


func assert_ne(actual: Variant, unexpected: Variant, message: String = "") -> void:
	if actual == unexpected:
		failures.append("%s : ne devait pas valoir %s" % [message, str(unexpected)])


func assert_between(actual: float, low: float, high: float, message: String = "") -> void:
	if actual < low or actual > high:
		failures.append("%s : %s hors de [%s, %s]" % [message, str(actual), str(low), str(high)])


# --- Aides pour construire des combats ---------------------------------------

## Kit par défaut : première compétence de chaque palier, premier passif.
func member(class_id: String, picks: Dictionary = {}) -> Dictionary:
	return {"class_id": class_id, "picks": picks}


## Équipe standard Guerrier / Mage / Prêtre.
func standard_team(picks_by_class: Dictionary = {}) -> Array:
	return [
		member("guerrier", picks_by_class.get("guerrier", {})),
		member("mage", picks_by_class.get("mage", {})),
		member("pretre", picks_by_class.get("pretre", {})),
	]


func standard_combat(picks_a: Dictionary = {}, picks_b: Dictionary = {}) -> Combat:
	return Combat.create(data, standard_team(picks_a), standard_team(picks_b))


func action(actor: String, skill: String, target: String) -> CombatAction:
	return CombatAction.make(actor, skill, target)


## Fait passer des tours « vides » (tout le monde joue sa basique) jusqu'au tour demandé.
func advance_to_turn(combat: Combat, target_turn: int) -> void:
	while combat.turn < target_turn and not combat.finished:
		combat.resolve_turn([])


## Saute directement au tour demandé, sans jouer les tours intermédiaires (PV et états intacts).
func jump_to_turn(combat: Combat, target_turn: int) -> void:
	combat.turn = target_turn


## Dégâts infligés par une source précise à une cible (tous types confondus, ou un type donné).
func damage_from(events: Array, source_id: String, target_id: String, kind: String = "") -> int:
	var total := 0
	for event in events_of_type(events, "damage"):
		if event["source"] == source_id and event["target"] == target_id and (kind == "" or event["kind"] == kind):
			total += int(event["amount"])
	return total


func events_of_type(events: Array, type: String) -> Array:
	var result := []
	for event in events:
		if event["type"] == type:
			result.append(event)
	return result


func damage_to(events: Array, target_id: String) -> int:
	var total := 0
	for event in events_of_type(events, "damage"):
		if event["target"] == target_id:
			total += int(event["amount"])
	return total


func action_order(events: Array) -> Array:
	var order := []
	for event in events_of_type(events, "action"):
		order.append(event["actor"])
	return order
