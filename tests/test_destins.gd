## Le budget de puissance du Destin, par côté : un même kit n'a pas la même force joué par le joueur et par l'acolyte.
extends "res://tests/test_case.gd"


func test_la_cle_d_un_kit() -> void:
	assert_eq(CombatData.kit_key("pretre", ["priere", "restauration", "egide"], "foi"), "pretre:priere+restauration+egide+foi", "classe, puis basique, moyenne, forte et passif")


func test_un_kit_est_ajuste_selon_le_cote_ou_il_est_joue() -> void:
	var key := CombatData.kit_key("pretre", ["priere", "restauration", "egide"], "foi")
	data.destins = {"kits": {"joueur": {key: -0.04}, "acolyte": {key: 0.03}}}
	var picks := {"basique": 1, "moyenne": 0, "forte": 0, "passive": 0}
	var stats: Dictionary = data.classes["pretre"]["stats"]
	var as_player := CombatUnit.from_class(data, "pretre", picks, "a1", 0, 0, "mage", false)
	assert_eq(as_player.skills["basique"], "priere", "kit tiré")
	assert_eq(as_player.max_hp, int(round(float(stats["max_hp"]) * 0.96)), "joué par le joueur : -4 %")
	assert_eq(as_player.power, int(round(float(stats["power"]) * 0.96)), "et -4 % de puissance")
	var as_acolyte := CombatUnit.from_class(data, "pretre", picks, "a2", 0, 1, "mage", true)
	assert_eq(as_acolyte.max_hp, int(round(float(stats["max_hp"]) * 1.03)), "le même kit joué par l'acolyte : +3 %")
	picks["passive"] = 1
	var other := CombatUnit.from_class(data, "pretre", picks, "a1", 0, 0, "mage", false)
	assert_eq(other.max_hp, int(stats["max_hp"]), "un autre kit : rien")
	data.destins = {"kit_pairs": {}}


func test_l_ajustement_total_d_un_kit_est_plafonne() -> void:
	# Plusieurs ajustements qui s'additionnent (élément, composition, acolyte, kit) ne dépassent jamais ±25 % en tout.
	var key := CombatData.kit_key("pretre", ["priere", "restauration", "egide"], "foi")
	data.destins = {"kit_items": {"priere": 0.15, "foi": 0.15}, "duo_classes": {"mage+pretre": 0.15}, "acolyte_classes": {"pretre": 0.15},
		"kits": {"acolyte": {key: 0.15}}}
	var bonus := data.kit_bonus(["priere", "restauration", "egide"], "foi", "pretre", "mage", true)
	assert_eq(bonus, CombatData.MAX_KIT_BONUS, "0,75 en tout, plafonné à 0,25")
	data.destins = {"kit_items": {"priere": -0.15, "foi": -0.15}, "kits": {"joueur": {key: -0.15}}}
	assert_eq(data.kit_bonus(["priere", "restauration", "egide"], "foi", "pretre", "mage", false), -CombatData.MAX_KIT_BONUS, "et vers le bas")
	data.destins = {"kit_items": {"priere": 0.05}}
	assert_eq(data.kit_bonus(["priere", "restauration", "egide"], "foi", "pretre", "mage", false), 0.05, "sous le plafond : inchangé")
	data.destins = {"kit_pairs": {}}


func test_les_ajustements_des_donnees_restent_petits() -> void:
	# Le budget du Destin corrige à la marge : aucun ajustement ne dépasse 15 % (au-delà, c'est l'effet qu'il faut revoir).
	var real := CombatData.load_default()
	for section in real.destins:
		_check_values(real.destins[section], section)


func _check_values(values: Variant, path: String) -> void:
	if values is Dictionary:
		for key in values:
			_check_values(values[key], path + "/" + str(key))
	else:
		assert_between(absf(float(values)), 0.0, 0.15, path)
