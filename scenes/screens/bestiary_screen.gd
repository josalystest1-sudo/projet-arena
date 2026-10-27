## Le bestiaire de la Tour : ses monstres, famille par famille, avec leurs compétences et leur passif.
## Au prototype, tous les monstres sont visibles ; ceux que tu n'as pas encore croisés sont marqués.
extends Control

const RANK_ORDER := ["sbire", "soldat", "elite", "gardien"]

var app: ArenaApp


func setup(p_app: ArenaApp, _options: Dictionary) -> void:
	app = p_app
	var column := UiKit.scroll_column(self, 12)
	column.add_child(UiKit.label("Bestiaire", 36, UiKit.GOLD))
	column.add_child(UiKit.label("Monstres croisés : %d sur %d" % [app.profile.monsters_seen.size(), app.data.monsters.size()], 18, UiKit.SOFT))
	column.add_child(UiKit.label("Chaque étage réunit de 1 à 4 monstres d'une même famille ; aux étages 5 et 10, un Gardien. Leur force grandit d'étage en étage.", 16, UiKit.SOFT))
	var families: Array = app.data.monster_families.keys()
	families.sort()
	for family in families:
		column.add_child(UiKit.spacer(4))
		column.add_child(UiKit.label(str(app.data.monster_families[family]), 26, UiKit.GOLD))
		for monster_id in _by_rank(family):
			_monster_card(column, monster_id)
	column.add_child(UiKit.button("Retour à la Tour", func(): app.show_screen("tower"), 56))


## Les monstres d'une famille, du sbire au Gardien.
func _by_rank(family: String) -> Array[String]:
	var list := app.data.monsters_of(family)
	list.sort_custom(func(a, b): return RANK_ORDER.find(app.data.monsters[a]["rank"]) < RANK_ORDER.find(app.data.monsters[b]["rank"]))
	return list


func _monster_card(parent: Node, monster_id: String) -> void:
	var monster: Dictionary = app.data.monsters[monster_id]
	var card := UiKit.card(parent, 4)
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	card.add_child(header)
	header.add_child(PortraitView.make(monster_id, "", "", 5.0, true))
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(info)
	var guardian := str(monster["rank"]) == "gardien"
	info.add_child(UiKit.label(str(monster["name"]), 24, Color("ffa94d") if guardian else Color.WHITE, false))
	info.add_child(UiKit.label("%s · %s" % [app.data.monster_rank_name(monster_id), UiKit.ROLE_LABELS.get(str(monster["role"]), "")], 16, UiKit.SOFT, false))
	var stats: Dictionary = monster["stats"]
	info.add_child(UiKit.label("PV %d · vitesse %d · puissance %d" % [int(stats["max_hp"]), int(stats["speed"]), int(stats["power"])], 15, UiKit.SOFT, false))
	if not app.profile.monsters_seen.has(monster_id):
		info.add_child(UiKit.label("Pas encore croisé", 15, Color("ff8787"), false))
	card.add_child(UiKit.label(str(monster.get("description", "")), 16, Color.WHITE, false))
	for tier in CombatUnit.TIERS:
		UiKit.skill_block(card, app.data, str(monster["skills"][tier]), Color("ff8787"))
	if str(monster.get("passive", "")) != "":
		UiKit.passive_block(card, app.data, str(monster["passive"]))
