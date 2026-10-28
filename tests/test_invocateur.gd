## L'Invocateur et sa créature : Golem, Spectre, Ordre, Sacrifice, Lien, ses passifs, ses Synergies et l'IA.
extends "res://tests/test_case.gd"

const GM := ["guerrier", "mage"]
const IM := ["invocateur", "mage"]


func hits_of(events: Array, actor: String) -> Array:
	for event in events_of_type(events, "action"):
		if event["actor"] == actor:
			return event["targets"]
	return []


## L'Invocateur est lent (vitesse 7) : pour tester ce qui suit son invocation dans le même tour, il agit en premier.
func first(combat: Combat, unit_id: String) -> void:
	combat.get_unit(unit_id).add_status({"id": "celerite", "turns": 1})


## Un Invocateur sans Symbiose (qui grossit la créature), avec Pacte.
func plain(enemies: Array = GM, picks: Dictionary = {}) -> Combat:
	var mine := {"invocateur": {"passive": 2}}
	mine.merge(picks, true)
	return duo_combat(IM, enemies, mine)


func test_le_golem_encaisse_les_coups_du_duo() -> void:
	var combat := plain()
	first(combat, "a1")
	var events := combat.resolve_turn([action("a1", "golem", "a1"), action("b1", "taillade", "a2"), action("b2", "boule_de_feu", "a1")])
	var summoned := events_of_type(events, "creature_summoned")
	assert_eq(summoned.size(), 1, "un Golem est invoqué")
	var golem_hp := int(round(combat.get_unit("a1").max_hp * float(data.skill("golem")["effects"][0]["hp"])))
	assert_eq(int(summoned[0]["max_hp"]), golem_hp, "ses PV : une part de ceux de l'Invocateur")
	assert_eq(events_of_type(events, "creature_hit").size(), 2, "il prend les deux coups (celui sur le Mage et celui sur l'Invocateur)")
	assert_eq(damage_from(events, "b1", "a2") + damage_from(events, "b2", "a1"), 0, "personne n'est touché")
	var taken := int(round(skill_power("taillade") * class_power("guerrier"))) + int(round(skill_power("boule_de_feu") * class_power("mage")))
	assert_eq(int(combat.get_unit("a1").creature["hp"]), golem_hp - taken, "le Golem a perdu les PV correspondants")
	# Ce qui dépasse ses PV passe à la cible, et le Golem meurt.
	combat.get_unit("a1").creature["hp"] = 10
	heal_all(combat)
	var overflow := combat.resolve_turn([action("b1", "taillade", "a2")])
	assert_eq(events_of_type(overflow, "creature_died").size(), 1, "le Golem est détruit")
	assert_eq(damage_from(overflow, "b1", "a2"), int(round(skill_power("taillade") * class_power("guerrier"))) - 10, "le Mage prend le reste")
	assert_false(combat.get_unit("a1").has_creature(), "plus de créature")
	assert_true(combat.can_use(combat.get_unit("a1"), "moyenne"), "Pacte : la moyenne est de nouveau prête")


func test_le_spectre_frappe_seul_en_fin_de_tour() -> void:
	var combat := plain(GM, {"invocateur": {"moyenne": 1}})
	combat.get_unit("b2").hp = 100
	var events := combat.resolve_turn([action("a1", "spectre", "a1"), action("b1", "taillade", "a2"), action("b2", "boule_de_feu", "a2")])
	assert_eq(events_of_type(events, "creature_attack").size(), 1, "le Spectre frappe une fois")
	var spectre: Dictionary = combat.get_unit("a1").creature
	var expected := int(round(float(data.skill("spectre")["effects"][0]["strike"]) * float(spectre["power"]) / 100.0))
	assert_eq(damage_from(events, "a1", "b2", "creature"), expected, "sur l'ennemi le plus bas, avec sa propre puissance")
	assert_eq(events_of_type(events, "creature_hit").size(), 0, "un Spectre n'encaisse pas les coups du duo")
	heal_all(combat)
	var next := combat.resolve_turn([action("a1", "fouet_d_ombre", "b1")])
	assert_true(damage_from(next, "a1", "b1", "creature") > 0, "au tour suivant, il suit la cible de son maître")


func test_ordre_avec_et_sans_creature() -> void:
	var combat := plain(GM, {"invocateur": {"basique": 1}})
	var alone := combat.resolve_turn([action("a1", "ordre", "b2")])
	assert_eq(damage_from(alone, "a1", "b2", "hit"), int(round(float(data.skill("ordre")["effects"][0]["fallback"]) * class_power("invocateur"))), "sans créature : un coup faible de l'Invocateur")
	heal_all(combat)
	combat.resolve_turn([action("a1", "golem", "a1")])
	heal_all(combat)
	var ordered := combat.resolve_turn([action("a1", "ordre", "b2")])
	var golem: Dictionary = combat.get_unit("a1").creature
	assert_eq(damage_from(ordered, "a1", "b2", "creature"), int(round(float(data.skill("ordre")["effects"][0]["power"]) * float(golem["power"]) / 100.0)), "avec le Golem : c'est lui qui frappe")
	assert_eq(combat.preview(combat.get_unit("a1"), "ordre", combat.get_unit("b2"))["damage"], damage_from(ordered, "a1", "b2", "creature"), "la prévision le sait")


func test_sacrifice_fait_exploser_la_creature() -> void:
	var combat := plain()
	combat.resolve_turn([action("a1", "golem", "a1")])
	heal_all(combat)
	jump_to_turn(combat, 3)
	first(combat, "a1")
	var golem_hp: int = combat.get_unit("a1").creature["hp"]
	var effect: Dictionary = data.skill("sacrifice")["effects"][0]
	var events := combat.resolve_turn([action("a1", "sacrifice", "b1")])
	var blast := int(round(golem_hp * float(effect["hp_share"])))
	assert_eq(damage_from(events, "a1", "b2", "sacrifice"), blast, "la moitié des PV du Golem en dégâts sur le Mage")
	assert_eq(damage_from(events, "a1", "b2", "hit"), int(round(skill_power("sacrifice", "sacrifice") * class_power("invocateur"))), "plus les dégâts du Sacrifice")
	assert_true(damage_from(events, "a1", "b1", "sacrifice") > 0, "sur tous les ennemis")
	assert_eq(events_of_type(events, "creature_died").size(), 1, "le Golem est détruit")
	assert_true(combat.can_use(combat.get_unit("a1"), "moyenne"), "Pacte : la moyenne revient")
	var empty := plain()
	jump_to_turn(empty, 3)
	var weak := empty.resolve_turn([action("a1", "sacrifice", "b1")])
	assert_eq(damage_from(weak, "a1", "b2", "hit"), int(round(round(skill_power("sacrifice", "sacrifice") * float(effect["fallback"])) * class_power("invocateur"))), "sans créature : la moitié des dégâts, rien de plus")
	assert_eq(damage_from(weak, "a1", "b2", "sacrifice"), 0, "et pas d'explosion")


func test_lien_envoie_les_coups_d_un_allie_a_la_creature() -> void:
	var combat := plain(GM, {"invocateur": {"moyenne": 1, "forte": 1}})
	combat.resolve_turn([action("a1", "spectre", "a1")])
	heal_all(combat)
	jump_to_turn(combat, 3)
	first(combat, "a1")
	var events := combat.resolve_turn([action("a1", "lien", "a2"), action("b1", "taillade", "a2"), action("b2", "boule_de_feu", "a1")])
	assert_eq(damage_from(events, "b1", "a2"), 0, "le coup sur le Mage lié va au Spectre")
	assert_eq(events_of_type(events, "creature_hit").size(), 1, "le Spectre l'encaisse")
	assert_true(damage_from(events, "b2", "a1") > 0, "l'Invocateur, lui, n'est pas lié : il prend son coup")


func test_la_creature_dure_trois_tours_et_une_seule_a_la_fois() -> void:
	# Invoqué au tour 1 (le tour de l'invocation ne compte pas), le Golem tient les tours 2, 3 et 4.
	var combat := plain()
	combat.resolve_turn([action("a1", "golem", "a1")])
	for i in range(2):
		heal_all(combat)
		combat.get_unit("a1").creature["hp"] = combat.get_unit("a1").creature["max_hp"]
		combat.resolve_turn([])
		assert_true(combat.get_unit("a1").has_creature(), "encore là après le tour %d" % (i + 2))
	heal_all(combat)
	combat.get_unit("a1").creature["hp"] = combat.get_unit("a1").creature["max_hp"]
	var gone := combat.resolve_turn([])
	assert_eq(events_of_type(gone, "creature_gone").size(), 1, "elle s'efface à la fin du tour 4 (sans mourir : pas de Pacte)")
	assert_false(combat.get_unit("a1").has_creature(), "plus de créature")
	var swap := plain(GM, {"invocateur": {"moyenne": 1}})
	swap.resolve_turn([action("a1", "spectre", "a1")])
	heal_all(swap)
	swap.get_unit("a1").cooldown_until = {}
	swap.get_unit("a1").skills["moyenne"] = "golem"
	var replaced := swap.resolve_turn([action("a1", "golem", "a1")])
	assert_eq(events_of_type(replaced, "creature_gone").size(), 1, "le Spectre s'efface")
	assert_eq(str(swap.get_unit("a1").creature["kind"]), "golem", "le Golem le remplace")


func test_symbiose_essaim_nourrice_et_la_mort_du_maitre() -> void:
	# Symbiose : une créature plus grosse.
	var combat := duo_combat(IM, GM)
	combat.resolve_turn([action("a1", "golem", "a1")])
	var effect: Dictionary = data.skill("golem")["effects"][0]
	assert_eq(int(combat.get_unit("a1").creature["max_hp"]), int(round(combat.get_unit("a1").max_hp * float(effect["hp"]) * (1.0 + pp("symbiose", "creature_bonus")))), "Symbiose : plus de PV")
	# Essaim : deux frappes aux tours pairs.
	var swarm := duo_combat(IM, GM, {"invocateur": {"passive": 1, "moyenne": 1}})
	swarm.resolve_turn([action("a1", "spectre", "a1")])
	heal_all(swarm)
	var even := swarm.resolve_turn([action("a1", "fouet_d_ombre", "b2")])
	assert_eq(events_of_type(even, "creature_attack").size(), 2, "tour 2 : le Spectre frappe deux fois")
	# Nourrice : la créature se soigne en fin de tour.
	var nurse := duo_combat(IM, GM, {"invocateur": {"passive": 3}})
	nurse.resolve_turn([action("a1", "golem", "a1")])
	heal_all(nurse)
	var max_hp: int = nurse.get_unit("a1").creature["max_hp"]
	nurse.get_unit("a1").creature["hp"] = max_hp - 5
	var healed := nurse.resolve_turn([])
	var got := 0
	for event in events_of_type(healed, "creature_heal"):
		got += int(event["amount"])
	assert_true(got > 0, "le Golem, entamé par les coups du tour, récupère des PV en fin de tour")
	assert_eq(got, mini(int(round(float(max_hp) * pp("nourrice", "creature_regen"))), max_hp - (int(nurse.get_unit("a1").creature["hp"]) - got)), "une part de ses PV max, sans dépasser le maximum")
	# La créature disparaît avec son maître.
	var master := plain()
	master.resolve_turn([action("a1", "golem", "a1")])
	master.get_unit("a1").hp = 1
	master.get_unit("a1").creature["hp"] = 1
	var fall := master.resolve_turn([action("b1", "taillade", "a1"), action("b2", "boule_de_feu", "a1")])
	assert_false(master.get_unit("a1").is_alive(), "l'Invocateur tombe")
	assert_true(events_of_type(fall, "creature_gone").size() + events_of_type(fall, "creature_died").size() >= 1, "sa créature n'est plus là")
	assert_false(master.get_unit("a1").has_creature(), "plus de créature")


func test_synergies_de_la_creature() -> void:
	# Pacte sacré (GDD : Égide + Lien) : la créature récupère tout ce qu'elle a encaissé ce tour.
	var combat := duo_combat(["invocateur", "pretre"], GM, {"invocateur": {"passive": 2, "forte": 1}})
	combat.resolve_turn([action("a1", "golem", "a1")])
	heal_all(combat)
	jump_to_turn(combat, 3)
	var golem_hp: int = combat.get_unit("a1").creature["hp"]
	first(combat, "a1")
	var events := combat.resolve_turn([action("a1", "lien", "a2"), action("a2", "egide", "a2"), action("b1", "taillade", "a1"), action("b2", "boule_de_feu", "a2")])
	assert_eq(events_of_type(events, "synergy").size(), 1, "Pacte sacré")
	assert_true(events_of_type(events, "creature_hit").size() >= 1, "le Golem a encaissé")
	assert_eq(int(combat.get_unit("a1").creature["hp"]), golem_hp, "et a tout récupéré")
	# Cœur de pierre : le Bouclier de mana soigne le Golem.
	var stone := duo_combat(IM, GM, {"invocateur": {"passive": 2}, "mage": {"forte": 1}})
	stone.resolve_turn([action("a1", "golem", "a1")])
	heal_all(stone)
	jump_to_turn(stone, 3)
	stone.get_unit("a1").cooldown_until = {}
	first(stone, "a1")
	stone.get_unit("a1").creature["hp"] = 20
	var heal := stone.resolve_turn([action("a1", "golem", "a1"), action("a2", "bouclier_de_mana", "a1")])
	assert_eq(events_of_type(heal, "synergy").size(), 1, "Cœur de pierre")
	var kinds := []
	for event in events_of_type(heal, "creature_heal"):
		kinds.append(event.get("kind", ""))
	assert_true(kinds.has("synergie"), "le Golem tout neuf est soigné (de ce que les coups du tour lui ont pris)")


func test_l_ia_de_l_invocateur() -> void:
	var combat := duo_combat(["mage", "invocateur"], GM, {"invocateur": {"basique": 1, "passive": 2}})
	assert_eq(CombatAI.decide_acolyte(combat, combat.get_unit("a2"))["action"].skill_id, "ordre", "à fond : il frappe (Ordre, sans créature : lui-même)")
	combat.get_unit("a1").hp = 150
	var decision := CombatAI.decide_acolyte(combat, combat.get_unit("a2"))
	assert_eq(decision["action"].skill_id, "golem", "tu as perdu des PV : il invoque le Golem pour te couvrir")
	assert_eq(decision["rule"], "protege", "règle : il te protège")
	combat.resolve_turn([decision["action"]])
	heal_all(combat)
	combat.get_unit("a1").hp = 150
	combat.get_unit("a2").cooldown_until = {}
	assert_eq(CombatAI.decide_acolyte(combat, combat.get_unit("a2"))["action"].skill_id, "ordre", "le Golem est là : pas de nouvelle invocation, il attaque")
	jump_to_turn(combat, 3)
	combat.get_unit("a2").cooldown_until = {"moyenne": 5}
	assert_eq(CombatAI.decide_acolyte(combat, combat.get_unit("a2"))["action"].skill_id, "sacrifice", "sa forte est prête et il a une créature : Sacrifice")
	combat.get_unit("a2").creature = {}
	assert_eq(CombatAI.decide_acolyte(combat, combat.get_unit("a2"))["action"].skill_id, "ordre", "sans créature, pas de Sacrifice")
	var link := duo_combat(["mage", "invocateur"], GM, {"invocateur": {"forte": 1, "passive": 2}})
	jump_to_turn(link, 3)
	link.get_unit("a2").cooldown_until = {"moyenne": 5}
	assert_ne(CombatAI.decide_acolyte(link, link.get_unit("a2"))["action"].skill_id, "lien", "sans créature, pas de Lien")
