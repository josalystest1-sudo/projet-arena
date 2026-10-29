## Composer son trio (docs/GDD_V2.md, § 5 et § 11) : un seul écran pour tous les modes. Ta case, puis tes deux Échos
## (un de chacun des deux autres rôles), proposés par le jeu à ton niveau : leur fiche (classe, niveau, voies, comment
## ils jouent, les Synergies possibles avec toi) et « Un autre Écho ». Amis et guilde viendront avec le serveur.
## options : « mode » = « duel » (amical), « classe » (un combat classé de l'Arène) ou « tour » : le bouton du bas lance
## ce mode ; sans mode, les deux.
extends Control

var app: ArenaApp
var mode := ""
## À la Tour : l'étage de départ choisi (0 : le palier).
var depart := 0


func setup(p_app: ArenaApp, options: Dictionary) -> void:
	app = p_app
	mode = str(options.get("mode", ""))
	depart = int(options.get("depart", 0))
	_construire()


func _construire() -> void:
	for enfant in get_children():
		enfant.queue_free()
	var column := UiKit.scroll_column(self, 10)
	column.add_child(UiKit.label("Ton trio", 30, UiKit.GOLD))
	column.add_child(UiKit.label("Toujours un Front, un Dégâts et un Soutien. Tes deux Échos sont pilotés par l'IA : ils annoncent leur coup avant toi, et tu ne leur donnes jamais d'ordre.", 15, UiKit.SOFT))
	_carte(column, app.destin, "Toi", UiKit.GOLD, "")
	var roles := Trio.roles_des_echos(app.player_class, app.data)
	for i in range(roles.size()):
		_carte(column, app.echos[i], str(app.echos_choisis[roles[i]]["nom"]), UiKit.ACOLYTE_BLUE, roles[i])
	var plus := UiKit.card(column, 2)
	plus.add_child(UiKit.label("Amis et guilde", 18, UiKit.SOFT, false))
	plus.add_child(UiKit.label("Ton compte existe (voir ton profil) : à la prochaine étape, les personnages des autres joueurs pourront compléter ton trio, à leur vrai niveau, trois aides par jour.", 14, UiKit.SOFT, false))
	column.add_child(UiKit.spacer(4))
	if mode in ["", "duel", "classe"]:
		var classe := mode == "classe"
		column.add_child(UiKit.main_button("Chercher un adversaire classé" if classe else "Chercher un adversaire (amical)", func():
			app.sfx.play("clic")
			app.show_screen("versus", {"classe": classe})))
	if mode in ["", "tour"]:
		var monter := func():
			app.sfx.play("clic")
			app.show_screen("combat", app.commencer_tour(depart))
		var etage := depart if depart >= 1 else app.palier()
		var texte := "Monter la Tour" if etage <= 1 else "Monter la Tour (étage %d)" % etage
		column.add_child(UiKit.main_button(texte, monter) if mode == "tour" else UiKit.button(texte, monter, 64))
	if mode != "":
		column.add_child(UiKit.button("Retour", func(): app.show_screen("arene" if mode in ["duel", "classe"] else "tower"), 52))


## La fiche d'un membre du trio. role : celui d'un Écho (« » pour le joueur), pour en proposer un autre.
func _carte(parent: VBoxContainer, d: Destin, nom: String, couleur: Color, role: String) -> void:
	var carte := UiKit.card(parent, 4)
	var ligne := HBoxContainer.new()
	ligne.add_theme_constant_override("separation", 10)
	carte.add_child(ligne)
	ligne.add_child(PortraitView.make(d.classe_id, "", "", 5.0))
	var texte := VBoxContainer.new()
	texte.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ligne.add_child(texte)
	texte.add_child(UiKit.label(nom, 22, couleur, false))
	texte.add_child(UiKit.label("%s · niveau %d%s" % [app.class_label(d.classe_id), app.profile.level, "" if role == "" else " · proposé par le jeu"], 15, UiKit.SOFT, false))
	var voies: Array[String] = []
	for v in d.voies:
		voies.append(str(v["nom"]).trim_prefix("Voie ").trim_prefix("du ").trim_prefix("de la ").trim_prefix("de l'").trim_prefix("des "))
	texte.add_child(UiKit.label("Moyeu : %s · voies : %s" % [Texte.nom(d.moyeu), ", ".join(voies)], 14, Color.WHITE, false))
	if role == "":
		return
	var syn := synergies_possibles(app.destin, d)
	carte.add_child(UiKit.label("Avec toi : " + (", ".join(syn) if not syn.is_empty() else "pas de Synergie possible"), 15, UiKit.GOLD if not syn.is_empty() else UiKit.SOFT, false))
	carte.add_child(UiKit.button("Un autre Écho %s" % UiKit.ROLE_LABELS[role], func():
		app.sfx.play("clic")
		app.changer_echo(role)
		_construire(), 48, 16))


## Les Synergies (section 8 de la spécification du combat) que deux roues peuvent faire ensemble, d'après les effets de
## leurs nœuds allumés et de leurs moyeux : Brisure (un contrôle et des dégâts), Embrasement (deux DoT), Bastion (une
## barrière et un soin), Harmonie (un Renfort et des dégâts).
static func synergies_possibles(a: Destin, b: Destin) -> Array[String]:
	var ea := _effets(a)
	var eb := _effets(b)
	var out: Array[String] = []
	if (ea.has("controle") and eb.has("coup")) or (eb.has("controle") and ea.has("coup")):
		out.append("Brisure")
	if ea.has("dot") and eb.has("dot"):
		out.append("Embrasement")
	if (ea.has("barriere") and eb.has("soin")) or (eb.has("barriere") and ea.has("soin")):
		out.append("Bastion")
	if (ea.has("renfort") and eb.has("degats")) or (eb.has("renfort") and ea.has("degats")):
		out.append("Harmonie")
	return out


## Ce que savent faire les nœuds allumés d'une roue (et son moyeu) : { « degats » (sur un ou tous les ennemis), « coup »
## (sur un seul), « dot », « controle », « barriere », « soin », « renfort » -> true }.
static func _effets(d: Destin) -> Dictionary:
	var out := {}
	var noeuds: Array = [d.moyeu]
	for v in d.voies:
		for n in v["noeuds"]:
			if bool(n["allume"]):
				noeuds.append(n)
	for n in noeuds:
		for ef in n["effets"]:
			var t := str(ef["type"])
			if t == "degats" and ef["cible"] in ["un_ennemi", "tous_les_ennemis"]:
				out["degats"] = true
				if ef["cible"] == "un_ennemi":
					out["coup"] = true
			elif t == "etat" and str(ef["nom"]) in Regles.CONTROLES_BRISURE:
				out["controle"] = true
			elif t in ["dot", "barriere", "soin", "renfort"]:
				out[t] = true
	return out
