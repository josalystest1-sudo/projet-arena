## Chargement et validation des données du combat V2 (docs/SPEC-COMBAT-V2.md, section 13.1) : règles, états,
## textes et les dix classes. Toute clé inconnue est une erreur : elle est notée dans `erreurs` (les tests et
## tools/budget.gd échouent alors). Module pur : aucune dépendance aux nœuds de scène.
class_name Donnees
extends RefCounted

const DOSSIER := "res://data/"

const CIBLES := ["un_ennemi", "tous_les_ennemis", "soi", "un_allie", "duo"]
## Les cibles multiples : leur coût est multiplié par 1,3 (section 7.2).
const CIBLES_MULTI := ["tous_les_ennemis", "duo"]
const ROLES := ["front", "degats", "soutien"]
## Le genre d'un nom (pour accorder le suffixe de forme) : masculin, féminin, et leurs pluriels.
const GENRES := ["m", "f", "mp", "fp"]
## Les états que pose un effet « etat » (section 7.1).
const ETATS_EFFET := ["etourdi", "gele", "silencie", "enracine", "aveugle", "desarme", "provoque"]
## Les types de dégâts sur la durée (effet « dot »).
const DOTS := ["saignement", "brulure", "poison", "familier"]
## Les seize états de la table 6.
const ETATS := ["etourdi", "gele", "silencie", "enracine", "aveugle", "desarme", "provoque", "egare", "saignement",
	"brulure", "poison", "familier", "gardien", "barriere", "renfort", "affaiblissement"]
## Les clés de chaque effet, selon son type (section 7.1).
const CLES_EFFETS := {
	"degats": ["type", "valeur", "cible"],
	"soin": ["type", "valeur", "cible"],
	"barriere": ["type", "valeur", "cible"],
	"dot": ["type", "sous_type", "par_tour", "tours", "cible"],
	"gardien": ["type", "par_tour", "tours", "cible"],
	"etat": ["type", "nom", "tours", "cible"],
	"egare": ["type", "cible"],
	"renfort": ["type", "pourcent", "tours", "cible"],
	"affaiblissement": ["type", "pourcent", "tours", "cible"],
	"purge": ["type", "cible"],
	"dissipe": ["type", "cible"],
}
const CLES_REGLES := ["extinction", "refroidissement", "mort_subite_tour", "mort_subite_pas", "chrono_s", "niveau_pente",
	"multi_cible", "tolerance_budget", "budgets", "couts", "couts_multi", "tour_soins_usure", "evolution"]
## Les évolutions (data/rules.json, GDD V2 § 3) : le nombre de niveaux d'un rang, le saut de puissance (PV et valeurs).
const CLES_EVOLUTION_REGLES := ["niveau", "puissance_pv", "puissance_valeurs", "rang_max"]
const CLES_BUDGETS := ["moyeu", "1", "2", "3", "4"]
const CLES_COUTS := ["degats", "soin", "barriere", "dot", "gardien", "renfort", "affaiblissement", "etourdi", "gele",
	"aveugle", "desarme", "egare", "silencie", "provoque", "enracine", "purge", "dissipe"]
const CLES_ETAT := ["nom", "type", "texte", "pictogramme", "couleur", "negatif", "dissipable", "purgeable"]
const TYPES_ETAT := ["controle", "affaiblissement", "deplacement", "dot", "hot", "protection", "renfort"]
const CLES_TEXTES := ["formes", "ligne", "phrase", "fiche", "pictos", "synergies", "etat_fiche"]
const FORMES := ["diffuse", "concentree", "persistante", "vive"]
const CLES_CLASSE := ["id", "nom", "genre", "role", "pv", "k", "acolyte", "moyeu", "voies"]
## Une évolution (data/evolutions/<id>.json) : une classe, avec sa classe de base, son rang et une description.
const CLES_EVOLUTION := ["id", "nom", "genre", "role", "pv", "k", "base", "rang", "description", "moyeu", "voies"]
const CLES_VOIE := ["id", "nom", "acolyte", "noeuds"]
const CLES_NOEUD := ["rang", "nom", "genre", "effets", "budget_override"]
const CLES_BESTIAIRE := ["familles", "rangs", "monstres"]
const CLES_MONSTRE := ["nom", "famille", "rang", "classe", "voies", "pv_mult", "description"]
const CLES_TOUR := ["pv_entre_etages", "monstres_max", "somme_depart", "somme_pente", "somme_largeur", "somme_max",
	"niveau_par_etage", "tirages", "gardien_tous_les", "revenu"]
## Le revenu passif de la Tour (data/tour.json, GDD V2 § 6) : des Éclats et un peu d'XP par jour selon le record, plafonnés.
const CLES_REVENU := ["eclats_par_etage", "xp_par_etage", "eclats_max", "xp_max"]
## Une Faveur de la Tour (data/faveurs.json) : son nom, son texte (« {v} » : la valeur cumulée, en %), sa valeur par
## cumul (une fraction), et son plafond (facultatif).
const CLES_FAVEUR := ["nom", "texte", "valeur", "max"]
const CLES_FAVEUR_OBLIGATOIRES := ["nom", "texte", "valeur"]
## Les six Faveurs que le moteur sait appliquer (engine/tour.gd et scenes/app/app.gd).
const FAVEURS := ["vigueur", "puissance", "repit", "egide", "effroi", "savoir"]
## L'équipement (data/items.json, engine/equipement.gd) : les emplacements, les huit lignes que le moteur sait
## appliquer, les raretés, l'échelle du niveau, les bases, le butin par source, la reforge.
const CLES_OBJETS := ["emplacements", "lignes", "raretes", "niveau", "bases", "butin", "reforge", "recyclage", "eclats"]
## Les Éclats (la monnaie liée, GDD V2 § 10.2) gagnés en duel et par étage de la Tour (data/items.json).
## La ville (data/ville.json, GDD V2 § 11) : ses bâtiments (nom, sous-titre, écran ouvert et ses options, position sur
## la carte en fractions, disponible ou non, forme du dessin provisoire).
const CLES_VILLE := ["batiments"]
## Les objectifs du jour (data/objectifs.json, GDD V2 § 10.3) : combien par jour, et la réserve (texte, compteur du jeu,
## cible, récompense en XP et en Éclats). Les compteurs connus sont ceux d'engine/objectifs.gd.
const CLES_OBJECTIFS := ["par_jour", "reserve"]
## L'Arène classée (data/arene.json, GDD V2 § 7) : combats par jour, points, saison, coffre, adversaires, ligues, noms.
const CLES_ARENE := ["combats_par_jour", "points_gagne", "points_perdu", "saison", "coffre", "adversaire", "ligues", "noms"]
const CLES_ARENE_SAISON := ["debut", "jours"]
const CLES_ARENE_COFFRE := ["commun", "rare", "epique"]
const CLES_ARENE_ADVERSAIRE := ["niveau_ecart", "equipement"]
const CLES_ARENE_LIGUES := ["aspirants", "elus", "ascendants"]
## Les donjons (data/donjons.json, GDD V2 § 8) : portes par embranchement, profondeur, PV rendus entre les vagues,
## force de l'élite et du boss, récompenses, et chaque donjon (famille, tranche de niveau, niveau, entrée, boss).
const CLES_DONJONS := ["portes", "profondeur", "pv_entre_vagues", "elite_mult", "boss_mult", "recompenses", "donjons"]
const CLES_DONJON := ["id", "nom", "famille", "niveau_min", "niveau_max", "niveau", "entree", "boss", "description"]
const CLES_RECOMPENSE_DONJON := ["rarete", "fragments", "eclats"]
## Le Comptoir (data/comptoir.json, GDD V2 § 10.2) : prix plancher par rareté, pente du niveau, base de qualité, multiples
## du Marché, l'étal du jour (raretés vendues et leur prix en Éclats).
const CLES_COMPTOIR := ["plancher", "niveau_pente", "qualite_base", "marche", "etal"]
const CLES_ETAL := ["raretes", "prix"]
## Le boss à paliers (data/boss.json, GDD V2 § 8.5) : la limite de tours, les solutions connues (identifiant -> texte), et
## par boss ses paliers (fraction de PV, solution, texte du verrou, ce qui a manqué).
const CLES_BOSS := ["tours_max", "solutions", "boss"]
## Le serveur (data/serveur.json, phase 5) : l'adresse et la clé publique du projet (vides : serveur simulé), la table
## des fiches, les mots des pseudos par défaut, le monde simulé (nombre de joueurs, graine, niveau le plus haut).
const CLES_SERVEUR := ["url", "cle_publique", "table", "pseudos", "simule"]
## Le Marché (data/marche.json, GDD V2 § 10.2) : seuils d'ouverture, taxe, annonces par joueur, monde simulé.
const CLES_MARCHE := ["niveau_min", "jours_min", "taxe", "annonces_max", "simule"]
const CLES_MARCHE_SIMULE := ["annonces", "raretes", "vente_par_jour"]
const CLES_SIMULE := ["joueurs", "graine", "niveau_max"]
const CLES_PALIER := ["pv", "solution", "texte", "manque"]
const CLES_OBJECTIF := ["id", "texte", "compteur", "cible", "xp", "eclats"]
const CLES_BATIMENT := ["id", "nom", "texte", "ecran", "options", "x", "y", "dispo", "forme"]
const CLES_BATIMENT_OBLIGATOIRES := ["id", "nom", "texte", "ecran", "x", "y", "dispo"]
const CLES_ECLATS := ["duel_gagne", "duel_perdu", "etage_base", "etage_pente", "rejoue"]
const CLES_EMPLACEMENT := ["nom"]
const LIGNES := ["pv", "force", "degats", "soins", "barrieres", "dot", "cle", "ouverture"]
const CLES_LIGNE := ["nom", "texte", "fourchette", "plafond"]
const CLES_RARETE := ["nom", "rang", "lignes", "echelle"]
const CLES_NIVEAU := ["plancher", "plein"]
const CLES_BASE := ["nom", "genre", "emplacement", "lignes"]
const CLES_BUTIN := ["etage", "gardien", "rejoue"]
const CLES_REFORGE := ["cout", "pente"]

var regles: Dictionary = {}
var etats: Dictionary = {}
## Le serveur (data/serveur.json) : adresse, clé publique, table, pseudos, monde simulé.
var serveur: Dictionary = {}
## Le Marché (data/marche.json) : seuils, taxe, annonces par joueur, monde simulé.
var marche: Dictionary = {}
var textes: Dictionary = {}
## Les classes par identifiant (les dix classes de base et leurs évolutions), et l'ordre des classes de base
## (data/classes.json : celui de la section 9, et des écrans).
var classes: Dictionary = {}
var ordre_classes: Array[String] = []
## L'ordre des évolutions (data/evolutions.json : le rang 1 puis le rang 2) ; chacune est aussi dans `classes`, avec
## `base` (son parent) et `rang`.
var ordre_evolutions: Array[String] = []
## Le bestiaire de la Tour (section 10.4) : familles, rangs, monstres (une classe, des voies, un multiplicateur de PV).
var bestiaire: Dictionary = {}
## Les règles de la Tour (data/tour.json) : PV rendus entre deux étages, tirage des monstres, Gardiens, abandon.
var tour: Dictionary = {}
## Les Faveurs de la Tour (data/faveurs.json, GDD V2 § 6) : identifiant -> {nom, texte, valeur, max}.
var faveurs: Dictionary = {}
## L'équipement (data/items.json, GDD V2 § 10.1) : emplacements, lignes, raretés, niveau, bases, butin, reforge.
var objets: Dictionary = {}
## La ville (data/ville.json, GDD V2 § 11) : la liste de ses bâtiments.
var ville: Dictionary = {}
## Les objectifs du jour (data/objectifs.json, GDD V2 § 10.3).
var objectifs: Dictionary = {}
## L'Arène classée (data/arene.json, GDD V2 § 7).
var objets_arene: Dictionary = {}
## Les donjons (data/donjons.json, GDD V2 § 8).
var donjons: Dictionary = {}
## Le Comptoir (data/comptoir.json, GDD V2 § 10.2).
var comptoir: Dictionary = {}
## Le boss à paliers (data/boss.json, GDD V2 § 8.5).
var boss: Dictionary = {}
## Ce qui ne va pas dans les données : une ligne par problème (vide si tout est connu et cohérent).
var erreurs: Array[String] = []
## Une mémoire de calculs qui ne dépendent que des données (les formes de chaque nœud, pour le générateur).
var memoire: Dictionary = {}

static var _defaut: Donnees = null


## Les données de res://data/, chargées une seule fois.
static func defaut() -> Donnees:
	if _defaut == null:
		_defaut = charger()
	return _defaut


static func charger(dossier: String = DOSSIER) -> Donnees:
	var donnees := Donnees.new()
	donnees.regles = _lire(dossier + "rules.json", donnees.erreurs)
	donnees.etats = _lire(dossier + "etats.json", donnees.erreurs)
	donnees.textes = _lire(dossier + "textes.json", donnees.erreurs)
	var ordre: Variant = _lire(dossier + "classes.json", donnees.erreurs, [])
	for id in ordre:
		donnees.ordre_classes.append(str(id))
		donnees.classes[str(id)] = _lire(dossier + "classes/" + str(id) + ".json", donnees.erreurs)
	var ordre_evo: Variant = _lire(dossier + "evolutions.json", donnees.erreurs, [])
	for id in ordre_evo:
		if donnees.classes.has(str(id)):
			donnees.erreurs.append("evolutions.json : « %s » est déjà une classe" % str(id))
			continue
		donnees.ordre_evolutions.append(str(id))
		donnees.classes[str(id)] = _lire(dossier + "evolutions/" + str(id) + ".json", donnees.erreurs)
	donnees.bestiaire = _lire(dossier + "bestiaire.json", donnees.erreurs)
	donnees.tour = _lire(dossier + "tour.json", donnees.erreurs)
	donnees.faveurs = _lire(dossier + "faveurs.json", donnees.erreurs)
	donnees.objets = _lire(dossier + "items.json", donnees.erreurs)
	donnees.ville = _lire(dossier + "ville.json", donnees.erreurs)
	donnees.objectifs = _lire(dossier + "objectifs.json", donnees.erreurs)
	donnees.objets_arene = _lire(dossier + "arene.json", donnees.erreurs)
	donnees.donjons = _lire(dossier + "donjons.json", donnees.erreurs)
	donnees.comptoir = _lire(dossier + "comptoir.json", donnees.erreurs)
	donnees.boss = _lire(dossier + "boss.json", donnees.erreurs)
	donnees.serveur = _lire(dossier + "serveur.json", donnees.erreurs)
	donnees.marche = _lire(dossier + "marche.json", donnees.erreurs)
	donnees.valider()
	return donnees


static func _lire(chemin: String, erreurs: Array[String], defaut: Variant = {}) -> Variant:
	if not FileAccess.file_exists(chemin):
		erreurs.append("fichier introuvable : " + chemin)
		return defaut
	var lu: Variant = JSON.parse_string(FileAccess.get_file_as_string(chemin))
	if lu == null:
		erreurs.append("JSON invalide : " + chemin)
		return defaut
	return lu


func classe(id: String) -> Dictionary:
	return classes.get(id, {})


## Le nœud d'une classe : rang 0 pour le moyeu, sinon la voie (0 à 4) et le rang (1 à 4).
func noeud(classe_id: String, voie: int, rang: int) -> Dictionary:
	var cls := classe(classe_id)
	if rang == 0:
		return cls.get("moyeu", {})
	return cls["voies"][voie]["noeuds"][rang - 1]


# --- Validation ----------------------------------------------------------------

func valider() -> void:
	_cles(regles, CLES_REGLES, CLES_REGLES, "rules.json")
	_cles(regles.get("budgets", {}), CLES_BUDGETS, CLES_BUDGETS, "rules.json budgets")
	_cles(regles.get("couts", {}), CLES_COUTS, CLES_COUTS, "rules.json couts")
	_cles(regles.get("couts_multi", {}), CLES_COUTS, [], "rules.json couts_multi")
	_cles(etats, ETATS, ETATS, "etats.json")
	for id in etats:
		_cles(etats[id], CLES_ETAT, CLES_ETAT, "etats.json " + str(id))
		if not str(etats[id].get("type", "")) in TYPES_ETAT:
			erreurs.append("etats.json %s : type inconnu « %s »" % [id, etats[id].get("type", "")])
	_cles(textes, CLES_TEXTES, CLES_TEXTES, "textes.json")
	_cles(textes.get("formes", {}), FORMES, FORMES, "textes.json formes")
	for forme in textes.get("formes", {}):
		_cles(textes["formes"][forme], GENRES, GENRES, "textes.json formes " + str(forme))
	for id in ordre_classes:
		erreurs.append_array(valider_classe(classes[id], id))
	_cles(regles.get("evolution", {}), CLES_EVOLUTION_REGLES, CLES_EVOLUTION_REGLES, "rules.json evolution")
	for id in ordre_evolutions:
		erreurs.append_array(valider_classe(classes[id], id))
		var ev: Dictionary = classes[id]
		var rang := int(ev.get("rang", 0))
		var parent: Dictionary = classes.get(str(ev.get("base", "")), {})
		if parent.is_empty():
			erreurs.append("évolution %s : parent inconnu « %s »" % [id, ev.get("base", "")])
		elif rang < 1 or rang > 2:
			erreurs.append("évolution %s : rang %d (1 ou 2 attendu)" % [id, rang])
		elif int(parent.get("rang", 0)) != rang - 1:
			erreurs.append("évolution %s : son parent « %s » devrait être de rang %d" % [id, ev.get("base", ""), rang - 1])
		if str(ev.get("description", "")) == "":
			erreurs.append("évolution %s : description vide" % id)
	_cles(tour, CLES_TOUR, CLES_TOUR, "tour.json")
	_cles(tour.get("revenu", {}), CLES_REVENU, CLES_REVENU, "tour.json revenu")
	_cles(faveurs, FAVEURS, FAVEURS, "faveurs.json")
	for id in faveurs:
		var ou := "faveurs.json " + str(id)
		_cles(faveurs[id], CLES_FAVEUR, CLES_FAVEUR_OBLIGATOIRES, ou)
		if not faveurs[id] is Dictionary:
			continue
		if float(faveurs[id].get("valeur", 0.0)) <= 0.0:
			erreurs.append(ou + " : valeur nulle ou négative")
		if faveurs[id].has("max") and float(faveurs[id]["max"]) < float(faveurs[id].get("valeur", 0.0)):
			erreurs.append(ou + " : plafond plus bas que la valeur d'un cumul")
		if not "{v}" in str(faveurs[id].get("texte", "")):
			erreurs.append(ou + " : le texte doit contenir « {v} »")
	_valider_objets()
	_valider_ville()
	_valider_objectifs()
	_valider_arene()
	_cles(bestiaire, CLES_BESTIAIRE, CLES_BESTIAIRE, "bestiaire.json")
	for id in bestiaire.get("monstres", {}):
		var m: Dictionary = bestiaire["monstres"][id]
		var ou := "bestiaire.json " + str(id)
		_cles(m, CLES_MONSTRE, CLES_MONSTRE, ou)
		if not classes.has(str(m.get("classe", ""))):
			erreurs.append(ou + " : classe inconnue")
			continue
		var ids: Array = []
		for voie in classes[str(m["classe"])]["voies"]:
			ids.append(voie["id"])
		for v in m.get("voies", []):
			if not v in ids:
				erreurs.append("%s : voie inconnue « %s »" % [ou, v])
		if m.get("voies", []).is_empty():
			erreurs.append(ou + " : aucune voie")
		if not bestiaire.get("familles", {}).has(str(m.get("famille", ""))) or not bestiaire.get("rangs", {}).has(str(m.get("rang", ""))):
			erreurs.append(ou + " : famille ou rang inconnu")
		if float(m.get("pv_mult", 0.0)) < 0.5 or float(m.get("pv_mult", 0.0)) > 1.5:
			erreurs.append(ou + " : pv_mult hors de 0,5 à 1,5")
	_valider_donjons()
	_valider_comptoir()
	_valider_boss()
	_cles(serveur, CLES_SERVEUR, CLES_SERVEUR, "serveur.json")
	_cles(marche, CLES_MARCHE, CLES_MARCHE, "marche.json")
	_cles(marche.get("simule", {}), CLES_MARCHE_SIMULE, CLES_MARCHE_SIMULE, "marche.json simule")
	if float(marche.get("taxe", 1.0)) < 0.0 or float(marche.get("taxe", 1.0)) >= 1.0:
		erreurs.append("marche.json : une taxe entre 0 et 1 attendue")
	for r in marche.get("simule", {}).get("raretes", {}):
		if not objets.get("raretes", {}).has(str(r)):
			erreurs.append("marche.json : rareté inconnue « %s »" % str(r))
	_cles(serveur.get("simule", {}), CLES_SIMULE, CLES_SIMULE, "serveur.json simule")
	if serveur.get("pseudos", []).is_empty():
		erreurs.append("serveur.json : aucun mot de pseudo")
	if int(serveur.get("simule", {}).get("joueurs", 0)) < 3:
		erreurs.append("serveur.json : au moins trois joueurs simulés")


## Le boss à paliers (data/boss.json) : clés connues, une limite de tours, chaque boss un Gardien du bestiaire, des
## paliers décroissants entre 0 et 1 avec une solution connue.
func _valider_boss() -> void:
	_cles(boss, CLES_BOSS, CLES_BOSS, "boss.json")
	if not boss is Dictionary or not boss.get("boss") is Dictionary:
		return
	if int(boss.get("tours_max", 0)) < 10:
		erreurs.append("boss.json : une limite d'au moins 10 tours attendue")
	var monstres: Dictionary = bestiaire.get("monstres", {})
	for id in boss["boss"]:
		var ou := "boss.json " + str(id)
		if not monstres.has(str(id)) or str(monstres[str(id)].get("rang", "")) != "gardien":
			erreurs.append(ou + " : pas un Gardien du bestiaire")
		_cles(boss["boss"][id], ["paliers"], ["paliers"], ou)
		var precedent := 1.0
		for p in boss["boss"][id].get("paliers", []):
			_cles(p, CLES_PALIER, CLES_PALIER, ou + " palier")
			if not p is Dictionary:
				continue
			if float(p.get("pv", 0.0)) <= 0.0 or float(p.get("pv", 0.0)) >= precedent:
				erreurs.append(ou + " : paliers attendus décroissants, entre 0 et 1")
			precedent = float(p.get("pv", 0.0))
			if not boss.get("solutions", {}).has(str(p.get("solution", ""))):
				erreurs.append(ou + " : solution inconnue « %s »" % p.get("solution", ""))


## Le Comptoir (data/comptoir.json) : clés connues, un plancher et un multiple de Marché par rareté connue, une pente et
## une base de qualité cohérentes, un étal sur des raretés connues avec leur prix.
func _valider_comptoir() -> void:
	_cles(comptoir, CLES_COMPTOIR, CLES_COMPTOIR, "comptoir.json")
	if not comptoir is Dictionary or not comptoir.has("etal"):
		return
	var raretes: Array = objets.get("raretes", {}).keys()
	_cles(comptoir.get("plancher", {}), raretes, raretes, "comptoir.json plancher")
	_cles(comptoir.get("marche", {}), raretes, raretes, "comptoir.json marche")
	if float(comptoir.get("niveau_pente", -1.0)) < 0.0 or float(comptoir.get("qualite_base", -1.0)) < 0.0 or float(comptoir.get("qualite_base", 2.0)) > 1.0:
		erreurs.append("comptoir.json : pente du niveau positive et base de qualité entre 0 et 1 attendues")
	_cles(comptoir["etal"], CLES_ETAL, CLES_ETAL, "comptoir.json etal")
	if comptoir["etal"] is Dictionary:
		for r in comptoir["etal"].get("raretes", []):
			if not raretes.has(str(r)) or not comptoir["etal"].get("prix", {}).has(str(r)):
				erreurs.append("comptoir.json etal : rareté inconnue ou sans prix « %s »" % r)


## L'équipement (data/items.json) : toutes les clés connues ; chaque base sur un emplacement connu, avec des lignes
## connues, toutes différentes, assez nombreuses pour la rareté la plus riche ; chaque fourchette croissante et sous
## son plafond ; le butin sur des raretés connues.
func _valider_objets() -> void:
	_cles(objets, CLES_OBJETS, CLES_OBJETS, "items.json")
	if not objets is Dictionary or not objets.has("lignes"):
		return
	for id in objets.get("emplacements", {}):
		_cles(objets["emplacements"][id], CLES_EMPLACEMENT, CLES_EMPLACEMENT, "items.json emplacement " + str(id))
	_cles(objets["lignes"], LIGNES, LIGNES, "items.json lignes")
	for id in objets["lignes"]:
		var ou := "items.json ligne " + str(id)
		var l: Variant = objets["lignes"][id]
		_cles(l, CLES_LIGNE, CLES_LIGNE, ou)
		if not l is Dictionary:
			continue
		var f: Variant = l.get("fourchette", [])
		if not f is Array or f.size() != 2 or float(f[0]) <= 0.0 or float(f[1]) <= float(f[0]):
			erreurs.append(ou + " : fourchette attendue [min, max] avec 0 < min < max")
		elif float(l.get("plafond", 0.0)) < float(f[1]):
			erreurs.append(ou + " : plafond plus bas que le haut de la fourchette")
		if not "{v}" in str(l.get("texte", "")):
			erreurs.append(ou + " : le texte doit contenir « {v} »")
	var lignes_max := 0
	for id in objets.get("raretes", {}):
		var ou := "items.json rareté " + str(id)
		_cles(objets["raretes"][id], CLES_RARETE, CLES_RARETE, ou)
		if objets["raretes"][id] is Dictionary:
			_cles(objets["raretes"][id].get("nom", {}), ["m", "f"], ["m", "f"], ou + " nom")
			lignes_max = maxi(lignes_max, int(objets["raretes"][id].get("lignes", 0)))
			if float(objets["raretes"][id].get("echelle", 0.0)) <= 0.0 or int(objets["raretes"][id].get("lignes", 0)) <= 0:
				erreurs.append(ou + " : échelle et nombre de lignes positifs attendus")
	_cles(objets.get("niveau", {}), CLES_NIVEAU, CLES_NIVEAU, "items.json niveau")
	if objets.get("niveau", {}) is Dictionary:
		var p := float(objets["niveau"].get("plancher", 0.0))
		if p <= 0.0 or p > 1.0 or float(objets["niveau"].get("plein", 0.0)) < 1.0:
			erreurs.append("items.json niveau : plancher entre 0 et 1, plein d'au moins 1")
	for id in objets.get("bases", {}):
		var ou := "items.json base " + str(id)
		var b: Variant = objets["bases"][id]
		_cles(b, CLES_BASE, CLES_BASE, ou)
		if not b is Dictionary:
			continue
		if not objets.get("emplacements", {}).has(str(b.get("emplacement", ""))):
			erreurs.append(ou + " : emplacement inconnu")
		if not str(b.get("genre", "")) in ["m", "f"]:
			erreurs.append(ou + " : genre inconnu")
		var vues: Array = []
		for l in b.get("lignes", []):
			if not objets["lignes"].has(str(l)):
				erreurs.append("%s : ligne inconnue « %s »" % [ou, l])
			elif vues.has(l):
				erreurs.append("%s : ligne en double « %s »" % [ou, l])
			vues.append(l)
		if vues.size() < lignes_max:
			erreurs.append("%s : %d lignes, il en faut %d pour la rareté la plus riche" % [ou, vues.size(), lignes_max])
	_cles(objets.get("butin", {}), CLES_BUTIN, CLES_BUTIN, "items.json butin")
	if objets.get("butin", {}) is Dictionary:
		for source in ["etage", "gardien"]:
			var poids: Variant = objets["butin"].get(source, {})
			if not poids is Dictionary or poids.is_empty():
				erreurs.append("items.json butin %s : des poids par rareté attendus" % source)
				continue
			for r in poids:
				if not objets.get("raretes", {}).has(str(r)) or float(poids[r]) <= 0.0:
					erreurs.append("items.json butin %s : rareté inconnue ou poids nul « %s »" % [source, r])
		var rejoue := float(objets["butin"].get("rejoue", -1.0))
		if rejoue < 0.0 or rejoue > 1.0:
			erreurs.append("items.json butin : rejoue entre 0 et 1 attendu")
	_cles(objets.get("reforge", {}), CLES_REFORGE, CLES_REFORGE, "items.json reforge")
	var raretes: Array = objets.get("raretes", {}).keys()
	_cles(objets.get("recyclage", {}), raretes, raretes, "items.json recyclage")
	if objets.get("recyclage", {}) is Dictionary:
		for r in objets["recyclage"]:
			if int(objets["recyclage"][r]) < 0:
				erreurs.append("items.json recyclage %s : valeur négative" % r)
	_cles(objets.get("eclats", {}), CLES_ECLATS, CLES_ECLATS, "items.json eclats")


## La ville (data/ville.json) : des bâtiments aux clés connues, aux identifiants uniques, placés sur la carte (0 à 1) ;
## un bâtiment disponible ouvre un écran.
func _valider_ville() -> void:
	_cles(ville, CLES_VILLE, CLES_VILLE, "ville.json")
	if not ville is Dictionary or not ville.get("batiments") is Array:
		return
	var ids: Array = []
	for b in ville["batiments"]:
		var ou := "ville.json bâtiment %s" % (b.get("id", "?") if b is Dictionary else "?")
		_cles(b, CLES_BATIMENT, CLES_BATIMENT_OBLIGATOIRES, ou)
		if not b is Dictionary:
			continue
		if ids.has(b.get("id", "")):
			erreurs.append(ou + " : identifiant en double")
		ids.append(b.get("id", ""))
		for axe in ["x", "y"]:
			if float(b.get(axe, -1.0)) < 0.0 or float(b.get(axe, -1.0)) > 1.0:
				erreurs.append(ou + " : %s hors de la carte (0 à 1)" % axe)
		if bool(b.get("dispo", false)) and str(b.get("ecran", "")) == "":
			erreurs.append(ou + " : disponible mais sans écran")
		if b.has("options") and not b["options"] is Dictionary:
			erreurs.append(ou + " : options attendues en objet")


## Les objectifs du jour (data/objectifs.json) : clés connues, identifiants uniques, compteurs connus, cibles et
## récompenses positives, une réserve assez grande pour un jour.
func _valider_objectifs() -> void:
	_cles(objectifs, CLES_OBJECTIFS, CLES_OBJECTIFS, "objectifs.json")
	if not objectifs is Dictionary or not objectifs.get("reserve") is Array:
		return
	var ids: Array = []
	for o in objectifs["reserve"]:
		var ou := "objectifs.json objectif %s" % (o.get("id", "?") if o is Dictionary else "?")
		_cles(o, CLES_OBJECTIF, CLES_OBJECTIF, ou)
		if not o is Dictionary:
			continue
		if ids.has(o.get("id", "")):
			erreurs.append(ou + " : identifiant en double")
		ids.append(o.get("id", ""))
		if not str(o.get("compteur", "")) in Objectifs.COMPTEURS:
			erreurs.append(ou + " : compteur inconnu « %s »" % o.get("compteur", ""))
		if int(o.get("cible", 0)) <= 0 or int(o.get("xp", -1)) < 0 or int(o.get("eclats", -1)) < 0:
			erreurs.append(ou + " : cible positive, XP et Éclats non négatifs attendus")
	if int(objectifs.get("par_jour", 0)) <= 0 or int(objectifs.get("par_jour", 0)) > ids.size():
		erreurs.append("objectifs.json : par_jour entre 1 et la taille de la réserve")


## L'Arène (data/arene.json) : clés connues, chiffres positifs, une saison datée, des poids d'équipement sur des raretés
## connues (ou vide : sans équipement), des noms.
func _valider_arene() -> void:
	_cles(objets_arene, CLES_ARENE, CLES_ARENE, "arene.json")
	if not objets_arene is Dictionary or not objets_arene.has("saison"):
		return
	if int(objets_arene.get("combats_par_jour", 0)) <= 0 or int(objets_arene.get("points_gagne", 0)) <= 0 or int(objets_arene.get("points_perdu", -1)) < 0:
		erreurs.append("arene.json : combats par jour et points positifs attendus")
	_cles(objets_arene["saison"], CLES_ARENE_SAISON, CLES_ARENE_SAISON, "arene.json saison")
	if objets_arene["saison"] is Dictionary and (str(objets_arene["saison"].get("debut", "")).length() != 10 or int(objets_arene["saison"].get("jours", 0)) <= 0):
		erreurs.append("arene.json saison : un début « AAAA-MM-JJ » et une durée en jours attendus")
	_cles(objets_arene.get("coffre", {}), CLES_ARENE_COFFRE, CLES_ARENE_COFFRE, "arene.json coffre")
	_cles(objets_arene.get("adversaire", {}), CLES_ARENE_ADVERSAIRE, CLES_ARENE_ADVERSAIRE, "arene.json adversaire")
	if objets_arene.get("adversaire", {}) is Dictionary:
		for r in objets_arene["adversaire"].get("equipement", {}):
			if str(r) != "" and not objets.get("raretes", {}).has(str(r)):
				erreurs.append("arene.json adversaire : rareté inconnue « %s »" % r)
	_cles(objets_arene.get("ligues", {}), CLES_ARENE_LIGUES, CLES_ARENE_LIGUES, "arene.json ligues")
	if not objets_arene.get("noms") is Array or objets_arene["noms"].is_empty():
		erreurs.append("arene.json : des noms d'adversaires attendus")


## Les donjons (data/donjons.json) : clés connues, chiffres cohérents, chaque donjon sur une famille du bestiaire avec un
## Gardien du bestiaire pour boss et une tranche de niveau ; les récompenses sur des raretés connues. (Appelée après le
## bestiaire et l'équipement.)
func _valider_donjons() -> void:
	_cles(donjons, CLES_DONJONS, CLES_DONJONS, "donjons.json")
	if not donjons is Dictionary or not donjons.get("donjons") is Array:
		return
	if int(donjons.get("portes", 0)) < 2 or int(donjons.get("profondeur", 0)) < 1:
		erreurs.append("donjons.json : au moins deux portes et une profondeur de 1")
	for quoi in ["elite", "boss"]:
		var r: Variant = donjons.get("recompenses", {}).get(quoi, {})
		_cles(r, CLES_RECOMPENSE_DONJON, CLES_RECOMPENSE_DONJON, "donjons.json récompense " + quoi)
		if r is Dictionary and not objets.get("raretes", {}).has(str(r.get("rarete", ""))):
			erreurs.append("donjons.json récompense %s : rareté inconnue" % quoi)
	var ids: Array = []
	var monstres: Dictionary = bestiaire.get("monstres", {})
	for dj in donjons["donjons"]:
		var ou := "donjons.json donjon %s" % (dj.get("id", "?") if dj is Dictionary else "?")
		_cles(dj, CLES_DONJON, CLES_DONJON, ou)
		if not dj is Dictionary:
			continue
		if ids.has(dj.get("id", "")):
			erreurs.append(ou + " : identifiant en double")
		ids.append(dj.get("id", ""))
		if not bestiaire.get("familles", {}).has(str(dj.get("famille", ""))):
			erreurs.append(ou + " : famille inconnue")
		if not monstres.has(str(dj.get("boss", ""))) or str(monstres[str(dj.get("boss", ""))].get("rang", "")) != "gardien":
			erreurs.append(ou + " : le boss doit être un Gardien du bestiaire")
		if int(dj.get("niveau_min", 0)) < 1 or int(dj.get("niveau_max", 0)) < int(dj.get("niveau_min", 0)) or int(dj.get("niveau", 0)) < 1 or int(dj.get("entree", -1)) < 0:
			erreurs.append(ou + " : niveaux et entrée incohérents")


## Les erreurs d'un fichier de classe (vide s'il est conforme à la section 13.1) ; une évolution (clés `base` et
## `rang`) a ses propres clés.
static func valider_classe(cls: Dictionary, id: String = "?") -> Array[String]:
	var out: Array[String] = []
	var cles := CLES_EVOLUTION if cls.has("base") or cls.has("rang") else CLES_CLASSE
	_cles_dans(cls, cles, cles, "classe " + id, out)
	if str(cls.get("id", "")) != id:
		out.append("classe %s : identifiant « %s » différent du nom du fichier" % [id, cls.get("id", "")])
	if not str(cls.get("role", "")) in ROLES:
		out.append("classe %s : rôle inconnu « %s »" % [id, cls.get("role", "")])
	if not str(cls.get("genre", "")) in GENRES:
		out.append("classe %s : genre inconnu" % id)
	if cls.get("moyeu") is Dictionary:
		_valider_noeud(cls["moyeu"], "%s moyeu" % id, false, out)
	if cls.get("voies") is Array:
		for v in range(cls["voies"].size()):
			var voie: Dictionary = cls["voies"][v]
			var ou := "%s voie %d (%s)" % [id, v + 1, voie.get("id", "?")]
			_cles_dans(voie, CLES_VOIE, CLES_VOIE, ou, out)
			for noeud in voie.get("noeuds", []):
				_valider_noeud(noeud, "%s rang %s" % [ou, noeud.get("rang", "?")], true, out)
	return out


static func _valider_noeud(noeud: Dictionary, ou: String, avec_rang: bool, out: Array[String]) -> void:
	var obligatoires := ["nom", "genre", "effets"]
	if avec_rang:
		obligatoires.append("rang")
	var permises := CLES_NOEUD if avec_rang else CLES_NOEUD.filter(func(c): return c != "rang")
	_cles_dans(noeud, permises, obligatoires, ou, out)
	if not str(noeud.get("genre", "")) in GENRES:
		out.append(ou + " : genre inconnu")
	var effets: Variant = noeud.get("effets", [])
	if not effets is Array or effets.is_empty():
		out.append(ou + " : aucun effet")
		return
	for effet in effets:
		var type := str(effet.get("type", ""))
		if not CLES_EFFETS.has(type):
			out.append("%s : type d'effet inconnu « %s »" % [ou, type])
			continue
		_cles_dans(effet, CLES_EFFETS[type], CLES_EFFETS[type], "%s effet %s" % [ou, type], out)
		if not str(effet.get("cible", "")) in CIBLES:
			out.append("%s : cible inconnue « %s »" % [ou, effet.get("cible", "")])
		if type == "etat" and not str(effet.get("nom", "")) in ETATS_EFFET:
			out.append("%s : état inconnu « %s »" % [ou, effet.get("nom", "")])
		if type == "dot" and not str(effet.get("sous_type", "")) in DOTS:
			out.append("%s : type de DoT inconnu « %s »" % [ou, effet.get("sous_type", "")])


func _cles(dico: Variant, permises: Array, obligatoires: Array, ou: String) -> void:
	_cles_dans(dico, permises, obligatoires, ou, erreurs)


static func _cles_dans(dico: Variant, permises: Array, obligatoires: Array, ou: String, out: Array[String]) -> void:
	if not dico is Dictionary:
		out.append(ou + " : objet attendu")
		return
	for cle in dico:
		if not str(cle) in permises:
			out.append("%s : clé inconnue « %s »" % [ou, cle])
	for cle in obligatoires:
		if not dico.has(cle):
			out.append("%s : clé manquante « %s »" % [ou, cle])
