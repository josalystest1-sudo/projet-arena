## Vérifie le budget de chaque nœud des dix classes et de leurs évolutions (docs/SPEC-COMBAT-V2.md, section 7.4) : son coût, calculé avec
## la grille 7.2, doit tomber dans ±6 % du budget de son rang (ou de son budget_override). Lancé par la CI.
##   godot --headless --path . --script res://tools/budget.gd [-- --tout]
## Code de sortie 1, avec la liste des nœuds fautifs, si un seul nœud sort de son budget ou si une donnée est inconnue.
## Avec --tout : le coût de chaque nœud.
extends SceneTree


func _initialize() -> void:
	var donnees := Donnees.charger()
	for erreur in donnees.erreurs:
		print("  DONNÉE   " + erreur)
	if "--tout" in OS.get_cmdline_user_args():
		for id in donnees.ordre_classes + donnees.ordre_evolutions:
			var cls: Dictionary = donnees.classes[id]
			print("%s (moyeu %s : %.2f)" % [cls["nom"], cls["moyeu"]["nom"], Budget.cout(donnees.regles, cls["moyeu"])])
			for voie in cls["voies"]:
				var cases: Array[String] = []
				for n in voie["noeuds"]:
					cases.append("%s %.2f/%d" % [n["nom"], Budget.cout(donnees.regles, n), roundi(Budget.budget(donnees.regles, n))])
				print("  %-22s %s" % [voie["nom"], " · ".join(cases)])
	var fautes := Budget.fautes(donnees)
	var total := 0
	for id in donnees.ordre_classes + donnees.ordre_evolutions:
		total += 1
		for voie in donnees.classes[id].get("voies", []):
			total += voie.get("noeuds", []).size()
	for f in fautes:
		print("  FAUTE    %s · %s · rang %d · %s : %s" % [f["classe"], f["voie"], f["rang"], f["nom"], f["faute"]])
	print("%d nœuds vérifiés, %d hors budget, %d erreurs de données" % [total, fautes.size(), donnees.erreurs.size()])
	quit(1 if not fautes.is_empty() or not donnees.erreurs.is_empty() else 0)
