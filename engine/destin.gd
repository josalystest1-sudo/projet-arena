## Le Destin d'un personnage (docs/SPEC-COMBAT-V2.md, sections 2 à 4) : sa roue. Le moyeu, puis les voies (5 pour
## le joueur, 3 pour l'acolyte, de 1 à 5 pour un monstre de la Tour), chacune avec ses 4 nœuds actifs (leur forme,
## allumés ou non) et ses 5 éclats. C'est ce que reçoit le combat ; le générateur (engine/generateur.gd) le fabrique.
## Module pur.
class_name Destin
extends RefCounted

## Les éclats d'une voie (règle fixe de la section 3.1, hors des données) : É1 et É2 accrochés à N1, É3 à N2,
## É4 à N3, É5 à la Clé. É1 et É3 : +5 % sur les valeurs de la voie ; É2 et É4 : +3 % de PV max ; É5 : +10 % sur
## les valeurs de la Clé.
const ECLAT_NOEUD := [1, 1, 2, 3, 4]
const ECLAT_VALEURS_VOIE := [0.05, 0.0, 0.05, 0.0, 0.0]
const ECLAT_PV := [0.0, 0.03, 0.0, 0.03, 0.0]
const ECLAT_VALEURS_CLE := [0.0, 0.0, 0.0, 0.0, 0.10]

var classe_id := ""
## Le nom affiché : celui de la classe, ou d'un monstre de la Tour.
var nom := ""
var role := ""
var graine := 0
var acolyte := false
var pv_base := 0
## Multiplicateur de PV d'un monstre de la Tour (section 10.4) ; 1 sinon.
var pv_mult := 1.0
## Multiplicateur de classe (section 7.3) : il multiplie les valeurs numériques des nœuds.
var k := 1.0
var moyeu: Dictionary = {}
## Les voies : { id, nom, noeuds: [4 nœuds { rang, nom, genre, effets, forme, allume, ... }], eclats: [5 booléens] }.
var voies: Array = []


## Le Destin « de base » d'une classe : chaque nœud dans sa forme Base, tel qu'écrit dans la section 9, sans éclat.
## nb_voies : les premières voies seulement (3 pour l'acolyte). tout_allume : les 4 nœuds de chaque voie allumés ;
## sinon seulement les N1 (un personnage qui vient d'être créé).
static func de_base(donnees: Donnees, p_classe_id: String, nb_voies: int = 5, tout_allume: bool = true) -> Destin:
	var cls := donnees.classe(p_classe_id)
	var d := Destin.new()
	d.classe_id = p_classe_id
	d.nom = str(cls["nom"])
	d.role = str(cls["role"])
	d.pv_base = int(cls["pv"])
	d.k = float(cls["k"])
	d.acolyte = nb_voies == 3
	d.moyeu = cls["moyeu"].duplicate(true)
	d.moyeu["rang"] = 0
	d.moyeu["forme"] = "base"
	d.moyeu["allume"] = true
	for v in range(mini(nb_voies, cls["voies"].size())):
		var voie: Dictionary = cls["voies"][v]
		var noeuds: Array = []
		for n in voie["noeuds"]:
			var copie: Dictionary = n.duplicate(true)
			copie["forme"] = "base"
			copie["allume"] = tout_allume or int(n["rang"]) == 1
			noeuds.append(copie)
		d.voies.append({"id": voie["id"], "nom": voie["nom"], "noeuds": noeuds, "eclats": [false, false, false, false, false]})
	return d


## Le bonus des éclats sur les valeurs d'un nœud (rang 0 : le moyeu, qui n'en a pas) : É1 + É3, et É5 pour la Clé.
func bonus_valeurs(voie: int, rang: int) -> float:
	if rang == 0 or voie < 0 or voie >= voies.size():
		return 0.0
	var eclats: Array = voies[voie]["eclats"]
	var bonus := 0.0
	for i in range(eclats.size()):
		if eclats[i]:
			bonus += ECLAT_VALEURS_VOIE[i]
			if rang == 4:
				bonus += ECLAT_VALEURS_CLE[i]
	return bonus


## Le bonus des éclats sur les PV max : +3 % par É2 et par É4 allumé, toutes voies confondues.
func bonus_pv() -> float:
	var bonus := 0.0
	for voie in voies:
		for i in range(voie["eclats"].size()):
			if voie["eclats"][i]:
				bonus += ECLAT_PV[i]
	return bonus


func vers_dict() -> Dictionary:
	return {"classe_id": classe_id, "nom": nom, "role": role, "graine": graine, "acolyte": acolyte, "pv_base": pv_base,
		"pv_mult": pv_mult, "k": k, "moyeu": moyeu.duplicate(true), "voies": voies.duplicate(true)}


static func depuis_dict(dico: Dictionary) -> Destin:
	var d := Destin.new()
	d.classe_id = str(dico["classe_id"])
	d.nom = str(dico["nom"])
	d.role = str(dico["role"])
	d.graine = int(dico["graine"])
	d.acolyte = bool(dico["acolyte"])
	d.pv_base = int(dico["pv_base"])
	d.pv_mult = float(dico["pv_mult"])
	d.k = float(dico["k"])
	d.moyeu = dico["moyeu"].duplicate(true)
	d.voies = dico["voies"].duplicate(true)
	return d
