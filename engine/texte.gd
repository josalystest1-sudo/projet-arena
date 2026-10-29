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
				n = "-%d %%" % Regles.plancher(float(ef["pourcent"]) * pourcents)
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


## La fiche d'un nœud en combat (section 12.4), vue par un perso (point_de_vue, ex. « a1 ») : nom, classe · voie ·
## rang, pictogrammes, ligne chiffrée (niveau, multiplicateur de classe, éclats), phrase, détail des états, l'échéance ;
## pour un nœud ennemi, « Pour l'empêcher » (les réponses que le joueur ou son acolyte a en main ce tour-ci) ; pour un
## nœud à soi, « Après » et l'éclat de la Clé. rang 0 : le moyeu.
static func fiche(e: EtatCombat, id: String, voie: int, rang: int, point_de_vue: String, donnees: Donnees = null) -> Dictionary:
	var d := donnees if donnees != null else Donnees.defaut()
	var txt: Dictionary = d.textes["fiche"]
	var statique := e.fiche(id)
	var noeud := e.noeud(id, voie, rang)
	var bonus := 0.0 if rang == 0 else float(statique["bonus"][voie][rang - 1])
	var valeurs := Regles.multiplicateur_niveau(e) * float(statique["k"]) * (1.0 + bonus)
	var classe := d.classe(str(statique["classe"]))
	var sous_titre := str(txt["moyeu"])
	if rang > 0:
		sous_titre = str(txt["cle"] if rang == 4 else txt["rang"]).format({"voie": statique["voies"][voie]["nom"], "rang": rang})
	var out := {"nom": nom(noeud, d), "sous_titre": "%s · %s" % [classe.get("nom", statique["nom"]), sous_titre],
		"pictos": pictos(noeud, valeurs, 1.0 + bonus, d), "ligne": ligne(noeud, valeurs, 1.0 + bonus, d), "phrase": phrase(noeud, d),
		"etats": _details_etats(noeud, d), "apres": "", "eclat": "", "echeance": ""}
	var a_soi := e.camp(id) == e.camp(point_de_vue)
	out["echeance"] = echeance_texte(e, id, voie, rang, a_soi, d)
	if a_soi:
		if rang == 4:
			out["apres"] = str(txt["cle_remet"])
			var eclat := float(statique["bonus"][voie][3]) - float(statique["bonus"][voie][2])
			if eclat > 0.0001:
				out["eclat"] = str(txt["eclat_cle"]).format({"pourcent": roundi(eclat * 100.0)})
		elif rang > 0:
			out["apres"] = "%s : %s" % [txt["apres"], nom(e.noeud(id, voie, rang + 1), d)]
	else:
		out["pour_l_empecher"] = pour_l_empecher(e, id, voie, rang, point_de_vue)
	return out


## « Jouable maintenant » (à soi, légal ce tour-ci), « Peut le jouer ce tour-ci » (un ennemi, légal ce tour-ci),
## « Jouable au prochain tour », « Jouable dans 2 tours »,
## « Éteint encore 2 tours », ou, pour un nœud que le jalon a déjà dépassé, « Déjà joué : la voie est plus loin ».
static func echeance_texte(e: EtatCombat, id: String, voie: int, rang: int, a_soi: bool, d: Donnees) -> String:
	var txt: Dictionary = d.textes["fiche"]
	if rang == 0:
		return str(txt["jouable_maintenant"] if a_soi else txt["jouable_ce_tour"])
	var p := e.perso(id)
	if rang <= int(p["jalons"][voie]):
		return str(txt["depasse"])
	for a in Regles.actions_legales(e, id):
		if a["source"] == "voie" and int(a["voie"]) == voie and int(a["rang"]) == rang:
			return str(txt["jouable_maintenant"] if a_soi else txt["jouable_ce_tour"])
	var restant := int(p["spent_until"][voie][rang - 1]) - e.tour
	if restant > 0 and restant >= rang - int(p["jalons"][voie]):
		return str(txt["eteint_encore_1"]) if restant == 1 else str(txt["eteint_encore"]).format({"n": restant})
	var ech := Regles.echeance(e, id, voie, rang)
	return str(txt["jouable_prochain_tour"]) if ech <= 1 else str(txt["jouable_dans"]).format({"n": ech})


## « Pour l'empêcher » (section 12.4) : les nœuds légaux ce tour-ci du perso qui regarde et de son acolyte qui
## annuleraient ou retarderaient ce nœud ennemi : Étourdi ; Gelé (sauf contre le moyeu) ; Silencié (contre une Clé) ;
## Égaré (sauf contre le moyeu) ; Enraciné (si le nœud n'est pas sur la dernière voie de l'ennemi) ; une barrière ou un
## soin s'il fait des dégâts. Chacun : {nom, pictogramme, couleur}, sans doublon.
static func pour_l_empecher(e: EtatCombat, id: String, voie: int, rang: int, point_de_vue: String) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var vus := {}
	var noeud := e.noeud(id, voie, rang)
	var blesse := false
	for ef in noeud["effets"]:
		blesse = blesse or ef["type"] in ["degats", "dot"]
	var derniere := int(e.perso(id)["last_voie"])
	for m in e.allies_vivants(point_de_vue):
		for a in Regles.actions_legales(e, m):
			var n := Regles.noeud_de(e, a)
			var reponse := {}
			for ef in n["effets"]:
				var touche_ennemi: bool = ef["cible"] in ["un_ennemi", "tous_les_ennemis"]
				var ok := false
				match str(ef["type"]):
					"etat":
						match str(ef["nom"]):
							"etourdi":
								ok = touche_ennemi
							"gele":
								ok = touche_ennemi and rang > 0
							"silencie":
								ok = touche_ennemi and rang == 4
							"enracine":
								ok = touche_ennemi and rang > 0 and (derniere < 0 or voie != derniere)
					"egare":
						ok = touche_ennemi and rang > 0
					"barriere", "soin":
						ok = blesse
				if ok:
					reponse = picto(ef)
					break
			var nom_reponse := nom(n)
			if not reponse.is_empty() and not vus.has(nom_reponse):
				vus[nom_reponse] = true
				reponse["nom"] = nom_reponse
				out.append(reponse)
	return out


## Une Synergie en clair (section 8) : { nom, regle, effet } ; « dégâts ×1,25 », avec les chiffres des règles.
static func synergie(nom_synergie: String, donnees: Donnees = null) -> Dictionary:
	var d := donnees if donnees != null else Donnees.defaut()
	var gab: Dictionary = d.textes["synergies"].get(nom_synergie, {"regle": "", "effet": ""})
	var chiffres := {"Brisure": Regles.BRISURE_DEGATS, "Bastion": Regles.BASTION_BARRIERE, "Embrasement": Regles.EMBRASEMENT_TOURS,
		"Harmonie": Regles.HARMONIE_TOURS}
	var x := str(chiffres.get(nom_synergie, 1)).replace(".", ",")
	return {"nom": nom_synergie, "regle": str(gab["regle"]), "effet": str(gab["effet"]).format({"x": x, "n": x})}


## La fiche d'un état posé sur un perso : { nom, pictogramme, couleur, sous_titre (« Sur Mage · encore 2 tours »),
## valeur (« 12 par tour », « +25 % », ou ""), texte (ce qu'il fait), source (« Posé par Cèdre », ou "") }.
## noms : les noms affichés des persos (sinon ceux de leur fiche).
static func fiche_etat(e: EtatCombat, id: String, nom_etat: String, noms: Dictionary = {}, donnees: Donnees = null) -> Dictionary:
	var d := donnees if donnees != null else Donnees.defaut()
	var gab: Dictionary = d.textes["etat_fiche"]
	var def: Dictionary = d.etats[nom_etat]
	var s: Dictionary = e.perso(id)["etats"][nom_etat]
	var n := e.tours_restants(id, nom_etat)
	var valeur := ""
	if str(def["type"]) in ["dot", "hot"]:
		valeur = str(gab["par_tour"]).format({"n": int(s["valeur"])})
	elif nom_etat in ["renfort", "affaiblissement"]:
		valeur = str(gab["pourcent"]).format({"signe": "+" if nom_etat == "renfort" else "-", "n": roundi(float(s["valeur"]) * 100.0)})
	var source := str(s.get("source", ""))
	return {"nom": str(def["nom"]), "pictogramme": str(def["pictogramme"]), "couleur": str(def["couleur"]),
		"sous_titre": str(gab["sur"]).format({"nom": noms.get(id, e.fiche(id)["nom"]), "n": n, "s": "s" if n > 1 else ""}),
		"valeur": valeur, "texte": str(def["texte"]).substr(0, 1).to_upper() + str(def["texte"]).substr(1) + ".",
		"source": str(gab["pose_par"]).format({"nom": noms.get(source, e.fiche(source)["nom"])}) if e.statique.has(source) else ""}


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
