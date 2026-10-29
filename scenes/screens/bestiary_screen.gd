## Le bestiaire de la Tour : les 14 monstres par famille, du sbire au Gardien. Chacun est une classe, une ou deux de ses
## voies et un multiplicateur de PV (docs/SPEC-COMBAT-V2.md, section 10.4) : aucune mécanique propre.
extends Control

var app: ArenaApp


func setup(p_app: ArenaApp, _options: Dictionary) -> void:
	app = p_app
	var column := UiKit.scroll_column(self, 10)
	column.add_child(UiKit.label("Le bestiaire", 32, UiKit.GOLD))
	var bestiaire: Dictionary = app.data.bestiaire
	for famille in bestiaire["familles"]:
		column.add_child(UiKit.label(str(bestiaire["familles"][famille]), 22, UiKit.GOLD, false))
		for id in bestiaire["monstres"]:
			var m: Dictionary = bestiaire["monstres"][id]
			if m["famille"] != famille:
				continue
			var carte := UiKit.card(column, 4)
			var rangee := HBoxContainer.new()
			rangee.add_theme_constant_override("separation", 10)
			carte.add_child(rangee)
			rangee.add_child(PortraitView.make(id, "", "", 5.0, true))
			var texte := VBoxContainer.new()
			texte.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			rangee.add_child(texte)
			texte.add_child(UiKit.label(str(m["nom"]), 20, Color.WHITE, false))
			var cls := app.data.classe(str(m["classe"]))
			var voies: Array[String] = []
			for v in m["voies"]:
				for voie in cls["voies"]:
					if voie["id"] == v:
						voies.append(str(voie["nom"]))
			texte.add_child(UiKit.label("%s · %s · PV ×%s" % [bestiaire["rangs"][m["rang"]], cls["nom"], str(m["pv_mult"]).replace(".", ",")], 14, UiKit.SOFT, false))
			texte.add_child(UiKit.label(", ".join(voies), 14, UiKit.SOFT, false))
			texte.add_child(UiKit.label(str(m["description"]), 15, Color.WHITE, false))
	column.add_child(UiKit.button("Retour à la Tour", func(): app.show_screen("tower"), 52))
