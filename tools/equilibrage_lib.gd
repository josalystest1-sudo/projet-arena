## Le simulateur d'équilibrage du combat V2 (docs/SPEC-COMBAT-V2.md, section 11) : des combats IA contre IA au niveau
## 30, allumage par défaut, Destins tirés avec des graines successives. Trois mesures :
## - la matrice des classes : chaque classe (et son acolyte) contre chaque classe, les camps en alternance ;
## - les trois routes : le joueur d'une classe joue Ruée, Éventail ou Réactive (l'IA standard) contre l'IA standard
##   de chaque classe ;
## - l'usage (voies jouées, Clés, longueur des combats) ; et la Tour, montée par l'IA standard.
## Puis les six critères de la section 11.2 et le rapport en français. Utilisé par tools/equilibrage.gd (travailleurs
## et rapport), tools/regleur.py (les passes de réglage) et les tests. Aucune règle ici : tout passe par res://engine.
extends RefCounted

const NIVEAU := 30
## Les graines du camp B : décalées, pour qu'un miroir (une classe contre elle-même) n'oppose pas deux Destins identiques.
const DECALAGE_B := 500000
## Au-delà, un combat est compté « non fini » (le test 50 exige qu'il n'y en ait aucun).
const TOURS_MAX := 100
## La Tour : les montées s'arrêtent à l'étage 21 (on sait alors que l'étage 20 est atteint).
const ETAGE_MAX := 21
const ROUTES := ["ruee", "eventail", "reactive"]
const NOMS_ROUTES := {"ruee": "Ruée", "eventail": "Éventail", "reactive": "Réactive"}


# --- Les Destins, gardés en mémoire (un même Destin sert dans plusieurs cases) ---------------

static func destins(d: Donnees, classe: String, graine: int, memoire: Dictionary) -> Array:
	var cle := "%s|%d" % [classe, graine]
	if not memoire.has(cle):
		memoire[cle] = [Generateur.generer(classe, graine, NIVEAU, Generateur.PAR_DEFAUT, d), Generateur.acolyte(classe, graine, NIVEAU, d)]
		if memoire.size() > 4000:
			memoire.clear()
			memoire[cle] = [Generateur.generer(classe, graine, NIVEAU, Generateur.PAR_DEFAUT, d), Generateur.acolyte(classe, graine, NIVEAU, d)]
	return memoire[cle]


# --- Un duel ----------------------------------------------------------------------------

## Un duel : la classe A (avec son acolyte) contre la classe B, A dans le camp « a » si a_en_premier. route : ce que
## joue le joueur de A (« reactive » : l'IA standard). Rend le vainqueur, la longueur et l'usage des deux joueurs.
static func duel(d: Donnees, classe_a: String, classe_b: String, graine: int, a_en_premier: bool, route: String, memoire: Dictionary) -> Dictionary:
	var da := destins(d, classe_a, graine, memoire)
	var db := destins(d, classe_b, graine + DECALAGE_B, memoire)
	var e := Regles.nouveau_combat(da if a_en_premier else db, db if a_en_premier else da, NIVEAU, "pvp", d)
	var joueur_a := "a1" if a_en_premier else "b1"
	var joueur_b := "b1" if a_en_premier else "a1"
	var voies_a := [false, false, false, false, false]
	var voies_b := [false, false, false, false, false]
	var cle_a := false
	var cle_b := false
	var etat_route := {"derniere": -1}
	while not e.fini and e.tour <= TOURS_MAX:
		var humains: Array = [] if route == "reactive" else [joueur_a]
		var decl := IA.declarer(e, humains)
		if route != "reactive":
			var a := action_route(e, joueur_a, route, etat_route)
			if not a.is_empty():
				decl[joueur_a] = a
		e = Regles.resoudre_tour(e, decl)
		for paire in [[joueur_a, voies_a, true], [joueur_b, voies_b, false]]:
			var a: Dictionary = e.actions_jouees.get(paire[0], {})
			if not a.is_empty() and a["source"] == "voie":
				paire[1][int(a["voie"])] = true
				if int(a["rang"]) == 4:
					if paire[2]:
						cle_a = true
					else:
						cle_b = true
	var camp_a := "a" if a_en_premier else "b"
	return {"gagne_a": e.fini and e.vainqueur == camp_a, "fini": e.fini, "tours": e.tour, "voies_a": voies_a,
		"voies_b": voies_b, "cle_a": cle_a, "cle_b": cle_b}


## Les joueurs scriptés (section 11.1). Ruée : continuer la voie la plus avancée vers sa Clé (jalon le plus haut ; à
## égalité, la Clé au plus gros budget, puis la voie dont la Clé a été jouée il y a le plus longtemps), le moyeu sinon. Éventail : N1 puis N2 de chaque voie à
## tour de rôle, jamais un N3 ni une Clé sauf s'il n'y a rien d'autre.
static func action_route(e: EtatCombat, id: String, route: String, etat_route: Dictionary) -> Dictionary:
	var legales := Regles.actions_legales(e, id)
	if legales.is_empty():
		return {}
	var choisie: Dictionary = legales[0]
	if route == "ruee":
		var derniere: Dictionary = etat_route.get("derniere_cle", {})
		var meilleur := [-1, -1.0, 0]
		for a in legales:
			if a["source"] != "voie":
				continue
			var v := int(a["voie"])
			var cle := e.noeud(id, v, 4)
			# À égalité de jalon et de budget, la voie dont la Clé a été jouée il y a le plus longtemps (à tour de rôle).
			var valeur := [int(e.perso(id)["jalons"][v]), Budget.budget(e.regles, cle) if bool(cle["allume"]) else 0.0, -int(derniere.get(v, -1))]
			if valeur[0] > meilleur[0] or (valeur[0] == meilleur[0] and (valeur[1] > meilleur[1] or (valeur[1] == meilleur[1] and valeur[2] > meilleur[2]))):
				meilleur = valeur
				choisie = a
		if choisie["source"] == "voie" and int(choisie["rang"]) == 4:
			derniere[int(choisie["voie"])] = e.tour
			etat_route["derniere_cle"] = derniere
	elif route == "eventail":
		var nb := e.nb_voies(id)
		var trouvee := false
		for decalage in range(1, nb + 1):
			var v := (int(etat_route["derniere"]) + decalage) % nb
			for a in legales:
				if a["source"] == "voie" and int(a["voie"]) == v and int(a["rang"]) <= 2:
					choisie = a
					trouvee = true
					break
			if trouvee:
				break
		if not trouvee:
			for a in legales:
				if a["source"] == "voie":
					choisie = a
					break
		if choisie["source"] == "voie":
			etat_route["derniere"] = int(choisie["voie"])
	var out := choisie.duplicate()
	out["cible_ennemie"] = IA.cible_ennemie(e, id)
	out["cible_alliee"] = IA.cible_alliee(e, id)
	return out


# --- Une montée de la Tour ---------------------------------------------------------------

## L'étage atteint par l'IA standard (s'arrête à ETAGE_MAX).
static func montee(d: Donnees, classe: String, graine: int, memoire: Dictionary) -> int:
	var duo := destins(d, classe, graine, memoire)
	var t := Tour.commencer(duo[0], duo[1], NIVEAU, graine, d)
	while not t.fini and t.etage < ETAGE_MAX:
		var e := t.combat()
		while not e.fini and not t.abandonne(e) and e.tour <= TOURS_MAX:
			e = Regles.resoudre_tour(e, IA.declarer(e))
		if not e.fini and not t.abandonne(e):
			e.fini = true
			e.vainqueur = "b"
		t.terminer(e)
	return t.etage if not t.fini else t.atteint


# --- Les mesures (une part du travail, pour un processus) ------------------------------------

## Une part d'une mesure : « matrice », « routes » ou « tour ». n : combats par case (ou montées par classe) ;
## graine0 : la première graine. Rend des comptes à additionner (fusionner).
static func simuler(d: Donnees, mesure: String, part: int, parts: int, n: int, graine0: int) -> Dictionary:
	var classes := d.ordre_classes
	var nc := classes.size()
	var memoire := {}
	var out := vide(nc)
	var index := -1
	match mesure:
		"matrice":
			for k in range(n):
				for i in range(nc):
					for j in range(nc):
						index += 1
						if index % parts != part:
							continue
						var r := duel(d, classes[i], classes[j], graine0 + k, k % 2 == 0, "reactive", memoire)
						_compter_duel(out, i, j, r)
		"routes":
			for k in range(n):
				for i in range(nc):
					for route in ["ruee", "eventail"]:
						for j in range(nc):
							index += 1
							if index % parts != part:
								continue
							var r := duel(d, classes[i], classes[j], graine0 + k, k % 2 == 0, route, memoire)
							var cle := "%d|%s" % [i, route]
							out["routes"][cle] = _ajouter(out["routes"].get(cle, [0, 0]), [1 if r["gagne_a"] else 0, 1])
		"tour":
			for k in range(n):
				for i in range(nc):
					index += 1
					if index % parts != part:
						continue
					var etage := montee(d, classes[i], graine0 + k, memoire)
					var cle := "%d|%d" % [i, etage]
					out["tour"][cle] = int(out["tour"].get(cle, 0)) + 1
	return out


static func vide(nc: int) -> Dictionary:
	var gains: Array = []
	var parties: Array = []
	for i in range(nc):
		var ligne_g: Array = []
		var ligne_p: Array = []
		for j in range(nc):
			ligne_g.append(0)
			ligne_p.append(0)
		gains.append(ligne_g)
		parties.append(ligne_p)
	var usage: Array = []
	for i in range(nc):
		usage.append({"combats": 0, "voies": [0, 0, 0, 0, 0], "cle": 0})
	return {"gains": gains, "parties": parties, "longueurs": {}, "non_finis": 0, "usage": usage, "routes": {}, "tour": {}}


static func _compter_duel(out: Dictionary, i: int, j: int, r: Dictionary) -> void:
	out["gains"][i][j] = int(out["gains"][i][j]) + (1 if r["gagne_a"] else 0)
	out["parties"][i][j] = int(out["parties"][i][j]) + 1
	var t := str(r["tours"])
	out["longueurs"][t] = int(out["longueurs"].get(t, 0)) + 1
	if not r["fini"]:
		out["non_finis"] = int(out["non_finis"]) + 1
	# L'usage d'une classe : ses combats comme classe A (chaque case compte une fois chaque classe en A).
	var u: Dictionary = out["usage"][i]
	u["combats"] = int(u["combats"]) + 1
	for v in range(5):
		if r["voies_a"][v]:
			u["voies"][v] = int(u["voies"][v]) + 1
	if r["cle_a"]:
		u["cle"] = int(u["cle"]) + 1


static func _ajouter(a: Array, b: Array) -> Array:
	return [int(a[0]) + int(b[0]), int(a[1]) + int(b[1])]


## Additionne des parts (relues depuis du JSON : des nombres à virgule, remis en entiers).
static func fusionner(parts: Array, nc: int) -> Dictionary:
	var out := vide(nc)
	for p in parts:
		for i in range(nc):
			for j in range(nc):
				out["gains"][i][j] += int(p["gains"][i][j])
				out["parties"][i][j] += int(p["parties"][i][j])
			out["usage"][i]["combats"] += int(p["usage"][i]["combats"])
			out["usage"][i]["cle"] += int(p["usage"][i]["cle"])
			for v in range(5):
				out["usage"][i]["voies"][v] += int(p["usage"][i]["voies"][v])
		for t in p["longueurs"]:
			out["longueurs"][str(t)] = int(out["longueurs"].get(str(t), 0)) + int(p["longueurs"][t])
		out["non_finis"] += int(p["non_finis"])
		for cle in p["routes"]:
			out["routes"][cle] = _ajouter(out["routes"].get(cle, [0, 0]), p["routes"][cle])
		for cle in p["tour"]:
			out["tour"][cle] = int(out["tour"].get(cle, 0)) + int(p["tour"][cle])
	return out


# --- Les chiffres et les six critères (section 11.2) ----------------------------------------

## Tout ce que dit une mesure, par classe : taux de victoire (moyenne de sa ligne), cases, routes, voies, Clés, Tour.
static func resumer(d: Donnees, m: Dictionary) -> Dictionary:
	var classes := d.ordre_classes
	var nc := classes.size()
	var par_classe := {}
	var cases: Array = []
	for i in range(nc):
		var somme := 0.0
		var cases_i := 0
		for j in range(nc):
			var p := int(m["parties"][i][j])
			if p == 0:
				continue
			var taux := float(m["gains"][i][j]) / float(p)
			somme += taux
			cases_i += 1
			cases.append({"a": classes[i], "b": classes[j], "taux": taux, "parties": p})
		var u: Dictionary = m["usage"][i]
		var combats := maxi(1, int(u["combats"]))
		var voies: Array = []
		for v in range(5):
			voies.append(float(u["voies"][v]) / float(combats))
		var routes := {"reactive": somme / float(maxi(1, cases_i))}
		for route in ["ruee", "eventail"]:
			var r: Array = m["routes"].get("%d|%s" % [i, route], [0, 0])
			if int(r[1]) > 0:
				routes[route] = float(r[0]) / float(r[1])
		var montees := 0
		var etage10 := 0
		var etage20 := 0
		var etages := 0
		for cle in m["tour"]:
			var parties_cle := str(cle).split("|")
			if int(parties_cle[0]) != i:
				continue
			var nb := int(m["tour"][cle])
			var etage := int(parties_cle[1])
			montees += nb
			etages += etage * nb
			if etage >= 10:
				etage10 += nb
			if etage >= 20:
				etage20 += nb
		par_classe[classes[i]] = {"taux": somme / float(maxi(1, cases_i)), "voies": voies, "cle": float(u["cle"]) / float(combats),
			"combats": int(u["combats"]), "routes": routes, "montees": montees,
			"etage10": float(etage10) / float(maxi(1, montees)), "etage20": float(etage20) / float(maxi(1, montees)),
			"etage_moyen": float(etages) / float(maxi(1, montees))}
	var longueurs: Array = []
	var total := 0
	for t in m["longueurs"]:
		longueurs.append([int(t), int(m["longueurs"][t])])
		total += int(m["longueurs"][t])
	longueurs.sort_custom(func(x, y): return x[0] < y[0])
	var mediane := 0
	var avant_20 := 0
	var cumul := 0
	for l in longueurs:
		cumul += int(l[1])
		if mediane == 0 and cumul * 2 >= total:
			mediane = int(l[0])
		if int(l[0]) < 20:
			avant_20 += int(l[1])
	return {"classes": par_classe, "cases": cases, "mediane": mediane, "avant_20": float(avant_20) / float(maxi(1, total)),
		"combats": total, "non_finis": int(m["non_finis"])}


## Les six critères (section 11.2) : { titre, ok, ecarts : [ce qui sort, en clair] }.
static func criteres(r: Dictionary) -> Array:
	var out: Array = []
	var classes: Dictionary = r["classes"]
	var c1: Array = []
	for c in classes:
		var taux: float = classes[c]["taux"]
		if taux < 0.47 or taux > 0.53:
			c1.append("%s %s" % [c, _pc(taux)])
	out.append({"titre": "1. Chaque classe entre 47 % et 53 % de victoires", "ok": c1.is_empty(), "ecarts": c1})
	var c2: Array = []
	for cas in r["cases"]:
		if cas["taux"] < 0.40 or cas["taux"] > 0.60:
			c2.append("%s contre %s %s" % [cas["a"], cas["b"], _pc(cas["taux"])])
	out.append({"titre": "2. Aucune case de la matrice hors de 40 % – 60 %", "ok": c2.is_empty(), "ecarts": c2})
	# Décisions de Gautier du 28 octobre : Ruée et Éventail sont des repères, affichés sans seuil ; le critère porte
	# sur la route Réactive (l'IA standard).
	var c3: Array = []
	for c in classes:
		var taux: float = classes[c]["routes"]["reactive"]
		if taux > 0.55 or taux < 0.40:
			c3.append("%s Réactive %s" % [c, _pc(taux)])
	out.append({"titre": "3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)", "ok": c3.is_empty(), "ecarts": c3})
	var c4: Array = []
	for c in classes:
		for v in range(5):
			if classes[c]["voies"][v] < 0.15:
				c4.append("%s voie %d %s" % [c, v + 1, _pc(classes[c]["voies"][v])])
		if classes[c]["cle"] < 0.60:
			c4.append("%s : Clé jouée dans %s des combats" % [c, _pc(classes[c]["cle"])])
	out.append({"titre": "4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %", "ok": c4.is_empty(), "ecarts": c4})
	var c5: Array = []
	if r["mediane"] < 6 or r["mediane"] > 10:
		c5.append("médiane %d tours" % r["mediane"])
	if r["avant_20"] < 0.95:
		c5.append("%s des combats finis avant le tour 20" % _pc(r["avant_20"]))
	if int(r["non_finis"]) > 0:
		c5.append("%d combats non finis" % r["non_finis"])
	out.append({"titre": "5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20", "ok": c5.is_empty(), "ecarts": c5})
	var c6: Array = []
	var e10: Array = []
	var e20: Array = []
	for c in classes:
		if int(classes[c]["montees"]) == 0:
			c6.append("%s : pas de montée mesurée" % c)
			continue
		e10.append(classes[c]["etage10"])
		e20.append(classes[c]["etage20"])
		if classes[c]["etage10"] < 0.40 or classes[c]["etage10"] > 0.60:
			c6.append("%s étage 10 %s" % [c, _pc(classes[c]["etage10"])])
		if classes[c]["etage20"] < 0.05 or classes[c]["etage20"] > 0.10:
			c6.append("%s étage 20 %s" % [c, _pc(classes[c]["etage20"])])
	if not e10.is_empty() and (e10.max() - e10.min() > 0.05 or e20.max() - e20.min() > 0.05):
		c6.append("écart entre classes : étage 10 de %s à %s, étage 20 de %s à %s" % [_pc(e10.min()), _pc(e10.max()), _pc(e20.min()), _pc(e20.max())])
	out.append({"titre": "6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes", "ok": c6.is_empty(), "ecarts": c6})
	return out


static func _pc(x: float) -> String:
	return ("%.1f %%" % (100.0 * x)).replace(".", ",")


# --- Le rapport (section 11.3 : un rapport en français par passe) -----------------------------

static func rapport(d: Donnees, r: Dictionary, titre: String, boutons: Array) -> String:
	var classes := d.ordre_classes
	var lignes: Array[String] = []
	lignes.append("## " + titre)
	lignes.append("")
	var crit := criteres(r)
	var tenus := 0
	for c in crit:
		tenus += 1 if c["ok"] else 0
	lignes.append("**%d critères tenus sur 6.** %d combats de duel (médiane %d tours), %d combats non finis." % [tenus, r["combats"], r["mediane"], r["non_finis"]])
	lignes.append("")
	lignes.append("### Les six critères (section 11.2)")
	lignes.append("")
	for c in crit:
		lignes.append("- %s **%s**%s" % ["✅" if c["ok"] else "❌", c["titre"], "" if c["ok"] else " : " + ", ".join(c["ecarts"])])
	lignes.append("")
	lignes.append("### La matrice des classes (taux de victoire de la ligne contre la colonne)")
	lignes.append("")
	var tete := "| | " + " | ".join(classes.map(func(c): return d.classe(c)["nom"].substr(0, 4))) + " | **Moyenne** |"
	lignes.append(tete)
	lignes.append("|" + " --- |".repeat(classes.size() + 2))
	var taux_cases := {}
	for cas in r["cases"]:
		taux_cases["%s|%s" % [cas["a"], cas["b"]]] = cas["taux"]
	for a in classes:
		var cellules: Array[String] = []
		for b in classes:
			cellules.append(str(roundi(100.0 * float(taux_cases.get("%s|%s" % [a, b], 0.0)))))
		lignes.append("| %s | %s | **%s** |" % [d.classe(a)["nom"], " | ".join(cellules), _pc(r["classes"][a]["taux"])])
	lignes.append("")
	lignes.append("### Les trois routes, l'usage des voies et la Tour, par classe")
	lignes.append("")
	lignes.append("| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |")
	lignes.append("| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |")
	for c in classes:
		var s: Dictionary = r["classes"][c]
		var cases_l: Array[String] = [d.classe(c)["nom"]]
		for route in ROUTES:
			cases_l.append(_pc(s["routes"][route]) if s["routes"].has(route) else "—")
		for v in range(5):
			cases_l.append(_pc(s["voies"][v]))
		cases_l.append(_pc(s["cle"]))
		if int(s["montees"]) > 0:
			cases_l.append_array([_pc(s["etage10"]), _pc(s["etage20"]), ("%.1f" % s["etage_moyen"]).replace(".", ",")])
		else:
			cases_l.append_array(["—", "—", "—"])
		lignes.append("| " + " | ".join(cases_l) + " |")
	lignes.append("")
	lignes.append("### Boutons touchés, et pourquoi")
	lignes.append("")
	if boutons.is_empty():
		lignes.append("Aucun (mesure seule).")
	for b in boutons:
		lignes.append("- " + str(b))
	lignes.append("")
	return "\n".join(lignes)
