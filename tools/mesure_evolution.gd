## Mesure du garde-fou des évolutions (décision de Gautier du 30 octobre : « un évolué à roue vide est plus fort qu'un
## niveau 29 ») : chaque évolution à roue vide (niveau 30, zéro point) contre sa classe de base au niveau 29 (29 points),
## en 1 contre 1 et en trio (les Échos des deux camps sont des classes de base), dans les deux ordres, par classe, pour
## un saut de puissance donné (sans toucher à data/rules.json). Pour la phase 9.
##   godot --headless --path . --script res://tools/mesure_evolution.gd -- <puissance_pv> <puissance_valeurs> <graines>
extends SceneTree


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var d := Donnees.defaut()
	d.regles["evolution"]["puissance_pv"] = float(args[0])
	d.regles["evolution"]["puissance_valeurs"] = float(args[1])
	var nb := int(args[2])
	print("puissance PV %s, valeurs %s, %d graines" % [args[0], args[1], nb])
	var tot_solo := [0, 0]
	var tot_trio := [0, 0]
	var tot_tours := 0
	for classe in d.ordre_classes:
		var evo := Evolution.evolutions_de(classe, d)[0]
		var solo := [0, 0]
		var trio := [0, 0]
		for graine in range(1, nb + 1):
			for premier in [true, false]:
				var a := Generateur.generer(evo, graine, 30, Generateur.PAR_DEFAUT, d)
				var b := Generateur.generer(classe, graine + 1000, 29, Generateur.PAR_DEFAUT, d)
				var r := _duel([a], [b], premier, d)
				solo[0] += 1 if r["gagne"] else 0
				solo[1] += 1
				var r2 := _duel(Trio.camp(a, 30, d), Trio.camp(b, 29, d), premier, d)
				trio[0] += 1 if r2["gagne"] else 0
				trio[1] += 1
				tot_tours += int(r2["tours"])
		print("  %-16s solo %3d %%   trio %3d %%" % [evo, roundi(100.0 * solo[0] / solo[1]), roundi(100.0 * trio[0] / trio[1])])
		tot_solo[0] += solo[0]
		tot_solo[1] += solo[1]
		tot_trio[0] += trio[0]
		tot_trio[1] += trio[1]
	print("TOTAL solo %d %%  trio %d %%  (tours moyens en trio : %.1f)" % [roundi(100.0 * tot_solo[0] / tot_solo[1]), roundi(100.0 * tot_trio[0] / tot_trio[1]), float(tot_tours) / float(tot_trio[1])])
	quit(0)


func _duel(camp_evo: Array, camp_base: Array, evo_en_premier: bool, d: Donnees) -> Dictionary:
	var e := Regles.nouveau_combat(camp_evo if evo_en_premier else camp_base, camp_base if evo_en_premier else camp_evo, 30, "pvp", d)
	while not e.fini and e.tour <= 100:
		e = Regles.resoudre_tour(e, IA.declarer(e, []))
	return {"gagne": e.fini and e.vainqueur == ("a" if evo_en_premier else "b"), "tours": e.tour}
