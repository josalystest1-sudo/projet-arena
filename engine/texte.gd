## Les textes générés depuis les données (docs/SPEC-COMBAT-V2.md, section 12.6) : le nom d'un nœud avec le suffixe
## de sa forme, sa ligne chiffrée, sa phrase (10 mots au plus, sans chiffre). Les gabarits sont dans data/textes.json :
## rien n'est écrit à la main nœud par nœud. Module pur.
class_name Texte
extends RefCounted


## « Boule de feu diffuse », « Acide vif », « Lianes diffuses » : le nom de base et le suffixe de la forme, accordé.
static func nom(noeud: Dictionary, donnees: Donnees = null) -> String:
	var d := donnees if donnees != null else Donnees.defaut()
	var forme := str(noeud.get("forme", "base"))
	if forme == "base" or not d.textes["formes"].has(forme):
		return str(noeud["nom"])
	return "%s %s" % [noeud["nom"], d.textes["formes"][forme][str(noeud.get("genre", "m"))]]


## « 45 à un ennemi + 12×3 Saignement » : chaque effet avec ses chiffres. Les valeurs numériques sont multipliées par
## `valeurs` (M(niveau) × k × éclats), les pourcentages par `pourcents` (éclats), puis arrondies à l'inférieur.
static func ligne(noeud: Dictionary, valeurs: float = 1.0, pourcents: float = 1.0, donnees: Donnees = null) -> String:
	var d := donnees if donnees != null else Donnees.defaut()
	var gabarits: Dictionary = d.textes["ligne"]["effets"]
	var cibles_a: Dictionary = d.textes["ligne"]["cibles_a"]
	var cibles_sur: Dictionary = d.textes["ligne"]["cibles_sur"]
	var parts: Array[String] = []
	for ef in noeud["effets"]:
		var type := str(ef["type"])
		var champs := {"a_cible": cibles_a.get(str(ef["cible"]), ""), "sur_cible": cibles_sur.get(str(ef["cible"]), ""), "etat": _nom_etat(d, ef)}
		if ef.has("valeur"):
			champs["valeur"] = Regles.plancher(float(ef["valeur"]) * valeurs)
		if ef.has("par_tour"):
			champs["par_tour"] = Regles.plancher(float(ef["par_tour"]) * valeurs)
		if ef.has("pourcent"):
			champs["pourcent"] = Regles.plancher(float(ef["pourcent"]) * pourcents)
		if ef.has("tours"):
			champs["tours"] = int(ef["tours"])
		parts.append(str(gabarits[type]).format(champs))
	return str(d.textes["ligne"]["separateur"]).join(parts)


## La ligne d'un nœud d'un perso en combat : avec son niveau, son multiplicateur de classe et ses éclats.
static func ligne_en_combat(e: EtatCombat, id: String, voie: int, rang: int) -> String:
	var fiche := e.fiche(id)
	var bonus := 0.0 if rang == 0 else float(fiche["bonus"][voie][rang - 1])
	return ligne(e.noeud(id, voie, rang), Regles.multiplicateur_niveau(e) * float(fiche["k"]) * (1.0 + bonus), 1.0 + bonus)


static func _nom_etat(d: Donnees, ef: Dictionary) -> String:
	match str(ef["type"]):
		"dot":
			return str(d.etats[str(ef["sous_type"])]["nom"])
		"etat":
			return str(d.etats[str(ef["nom"])]["nom"])
		"gardien", "renfort", "affaiblissement", "egare":
			return str(d.etats[str(ef["type"])]["nom"])
	return ""


## « Frappe, lacère et désarme un ennemi. » : un verbe par effet ; les effets qui se suivent sur la même cible
## partagent leur complément ; un effet sur soi prend sa forme pronominale (« se protège »).
static func phrase(noeud: Dictionary, donnees: Donnees = null) -> String:
	var d := donnees if donnees != null else Donnees.defaut()
	var gab: Dictionary = d.textes["phrase"]
	var groupes: Array = []
	for ef in noeud["effets"]:
		var cle := str(ef["type"])
		if cle == "dot":
			cle = str(ef["sous_type"])
		elif cle == "etat":
			cle = str(ef["nom"])
		var cible := str(ef["cible"])
		if cible == "soi":
			groupes.append({"cible": "soi", "verbes": [str(gab["soi"].get(cle, gab["verbes"][cle]))]})
			continue
		var verbe := str(gab["verbes"][cle])
		if not groupes.is_empty() and groupes[-1]["cible"] == cible:
			if not verbe in groupes[-1]["verbes"]:
				groupes[-1]["verbes"].append(verbe)
		else:
			groupes.append({"cible": cible, "verbes": [verbe]})
	var propositions: Array[String] = []
	for g in groupes:
		var p := _enumerer(g["verbes"], gab)
		if g["cible"] != "soi":
			p += " " + str(gab["cibles"][g["cible"]])
		propositions.append(p)
	var texte := ""
	var deja_et := false
	for p in propositions:
		if p.contains(str(gab["et"])):
			deja_et = true
	if deja_et:
		texte = str(gab["virgule"]).join(propositions)
	else:
		texte = _enumerer(propositions, gab)
	return texte.substr(0, 1).to_upper() + texte.substr(1) + str(gab["fin"])


## Le pictogramme et la couleur d'un effet (table 7.1) : ceux de l'état qu'il pose, ou ceux de l'effet.
static func picto(ef: Dictionary, donnees: Donnees = null) -> Dictionary:
	var d := donnees if donnees != null else Donnees.defaut()
	var etat := ""
	match str(ef["type"]):
		"dot":
			etat = str(ef["sous_type"])
		"etat":
			etat = str(ef["nom"])
		"gardien", "renfort", "affaiblissement", "egare", "barriere":
			etat = str(ef["type"])
	if etat != "":
		return {"pictogramme": str(d.etats[etat]["pictogramme"]), "couleur": str(d.etats[etat]["couleur"])}
	return d.textes["pictos"]["effets"][str(ef["type"])].duplicate()


## La rangée de pictogrammes d'un nœud (section 12.1) : pour chaque effet, son pictogramme, sa couleur, le glyphe de
## sa cible et son nombre (« 60 », « 30×3 », « +25 % », « 1 » pour un état d'un tour).
static func pictos(noeud: Dictionary, valeurs: float = 1.0, pourcents: float = 1.0, donnees: Donnees = null) -> Array[Dictionary]:
	var d := donnees if donnees != null else Donnees.defaut()
	var out: Array[Dictionary] = []
	for ef in noeud["effets"]:
		var p := picto(ef, d)
		p["cible"] = str(d.textes["pictos"]["cibles"][str(ef["cible"])])
		var n := ""
		match str(ef["type"]):
			"degats", "soin", "barriere":
				n = str(Regles.plancher(float(ef["valeur"]) * valeurs))
			"dot", "gardien":
				n = "%d×%d" % [Regles.plancher(float(ef["par_tour"]) * valeurs), int(ef["tours"])]
			"renfort":
				n = "+%d %%" % Regles.plancher(float(ef["pourcent"]) * pourcents)
			"affaiblissement":
				n = "−%d %%" % Regles.plancher(float(ef["pourcent"]) * pourcents)
			"etat":
				n = str(int(ef["tours"]))
		p["texte"] = n
		out.append(p)
	return out


## La fiche d'un nœud hors combat (section 12.4 ; écran du Destin) : nom, classe · voie · rang, pictogrammes, ligne,
## phrase, détail des états, « Après ». Les valeurs comptent le niveau, le multiplicateur de classe et les éclats
## allumés. rang 0 : le moyeu.
static func fiche_destin(destin: Destin, voie: int, rang: int, niveau: int, donnees: Donnees = null) -> Dictionary:
	var d := donnees if donnees != null else Donnees.defaut()
	var fiche_txt: Dictionary = d.textes["fiche"]
	var noeud: Dictionary = destin.moyeu if rang == 0 else destin.voies[voie]["noeuds"][rang - 1]
	var bonus := destin.bonus_valeurs(voie, rang)
	var m := 1.0 + float(d.regles["niveau_pente"]) * float(maxi(1, niveau) - 1)
	var valeurs := m * destin.k * (1.0 + bonus)
	var sous_titre := str(fiche_txt["moyeu"])
	if rang > 0:
		var gabarit := str(fiche_txt["cle"] if rang == 4 else fiche_txt["rang"])
		sous_titre = gabarit.format({"voie": destin.voies[voie]["nom"], "rang": rang})
	var out := {"nom": nom(noeud, d), "sous_titre": "%s · %s" % [destin.nom, sous_titre], "pictos": pictos(noeud, valeurs, 1.0 + bonus, d),
		"ligne": ligne(noeud, valeurs, 1.0 + bonus, d), "phrase": phrase(noeud, d), "etats": _details_etats(noeud, d),
		"apres": "", "eclat": "", "allume": bool(noeud.get("allume", true))}
	if rang > 0:
		if rang == 4:
			out["apres"] = str(fiche_txt["cle_remet"])
			var eclat5: float = Destin.ECLAT_VALEURS_CLE[4] if destin.voies[voie]["eclats"][4] else 0.0
			if eclat5 > 0.0:
				out["eclat"] = str(fiche_txt["eclat_cle"]).format({"pourcent": roundi(eclat5 * 100.0)})
		else:
			var suivant: Dictionary = destin.voies[voie]["noeuds"][rang]
			out["apres"] = "%s : %s" % [fiche_txt["apres"], nom(suivant, d)]
	return out


## Pour chaque état qu'un nœud pose, sa ligne fixe : « Enraciné : ne peut pas changer de voie ».
static func _details_etats(noeud: Dictionary, d: Donnees) -> Array[String]:
	var out: Array[String] = []
	for ef in noeud["effets"]:
		var etat := ""
		match str(ef["type"]):
			"dot":
				etat = str(ef["sous_type"])
			"etat":
				etat = str(ef["nom"])
			"gardien", "renfort", "affaiblissement", "egare":
				etat = str(ef["type"])
		if etat == "":
			continue
		var l := str(d.textes["fiche"]["etat"]).format({"etat": d.etats[etat]["nom"], "texte": d.etats[etat]["texte"]})
		if not l in out:
			out.append(l)
	return out


static func _enumerer(mots: Array, gab: Dictionary) -> String:
	if mots.size() == 1:
		return str(mots[0])
	var debut: Array[String] = []
	for i in range(mots.size() - 1):
		debut.append(str(mots[i]))
	return str(gab["virgule"]).join(debut) + str(gab["et"]) + str(mots[-1])
