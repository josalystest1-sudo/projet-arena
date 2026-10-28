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
	"multi_cible", "tolerance_budget", "budgets", "couts", "couts_multi"]
const CLES_BUDGETS := ["moyeu", "1", "2", "3", "4"]
const CLES_COUTS := ["degats", "soin", "barriere", "dot", "gardien", "renfort", "affaiblissement", "etourdi", "gele",
	"aveugle", "desarme", "egare", "silencie", "provoque", "enracine", "purge", "dissipe"]
const CLES_ETAT := ["nom", "type", "texte", "pictogramme", "couleur", "negatif", "dissipable", "purgeable"]
const TYPES_ETAT := ["controle", "affaiblissement", "deplacement", "dot", "hot", "protection", "renfort"]
const CLES_TEXTES := ["formes", "ligne", "phrase", "fiche"]
const FORMES := ["diffuse", "concentree", "persistante", "vive"]
const CLES_CLASSE := ["id", "nom", "genre", "role", "pv", "k", "acolyte", "moyeu", "voies"]
const CLES_VOIE := ["id", "nom", "acolyte", "noeuds"]
const CLES_NOEUD := ["rang", "nom", "genre", "effets", "budget_override"]

var regles: Dictionary = {}
var etats: Dictionary = {}
var textes: Dictionary = {}
## Les classes par identifiant, et leur ordre (data/classes.json : celui de la section 9, et des écrans).
var classes: Dictionary = {}
var ordre_classes: Array[String] = []
## Ce qui ne va pas dans les données : une ligne par problème (vide si tout est connu et cohérent).
var erreurs: Array[String] = []

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


## Les erreurs d'un fichier de classe (vide s'il est conforme à la section 13.1).
static func valider_classe(cls: Dictionary, id: String = "?") -> Array[String]:
	var out: Array[String] = []
	_cles_dans(cls, CLES_CLASSE, CLES_CLASSE, "classe " + id, out)
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
