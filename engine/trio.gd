## Le trio (docs/GDD_V2.md, § 4.3 et § 5 ; docs/PLAN.md, PR 1.1) : un camp est toujours un Front, un Dégâts et un
## Soutien, par rôle principal (le rôle de la classe dans data/classes). Le joueur occupe la case de son rôle ; les deux
## autres sont des Échos, des personnages pilotés par l'IA, à qui le joueur ne donne jamais d'ordre. Avant le serveur,
## les Échos sont générés : pour chaque rôle manquant, une classe de ce rôle tirée avec la graine du joueur, puis une
## roue entière (5 voies) au niveau du joueur, allumage par défaut (Generateur.echo). Dans le camp, le joueur d'abord,
## puis ses Échos dans l'ordre Front, Dégâts, Soutien : c'est aussi l'ordre de leurs annonces (IA.declarer).
## Module pur : le hasard vient de la graine fournie.
class_name Trio
extends RefCounted

const ROLES := ["front", "degats", "soutien"]
## La graine d'un Écho : celle du joueur, mêlée au rang de son rôle (comme l'acolyte, section 4 de la spécification).
const XOR_ECHO := 0x3C6EF372


## Les classes d'un rôle, dans l'ordre des données : les classes de base (rang 0) ou les évolutions (rang 1).
static func classes_du_role(role: String, donnees: Donnees = null, rang: int = 0) -> Array[String]:
	var d := donnees if donnees != null else Donnees.defaut()
	if rang >= 1:
		return Evolution.du_role(role, d)
	var out: Array[String] = []
	for c in d.ordre_classes:
		if str(d.classe(c)["role"]) == role:
			out.append(c)
	return out


## Les rôles des deux Échos d'un joueur de cette classe : les deux autres, dans l'ordre Front, Dégâts, Soutien.
static func roles_des_echos(classe_joueur: String, donnees: Donnees = null) -> Array[String]:
	var d := donnees if donnees != null else Donnees.defaut()
	var role_joueur := str(d.classe(classe_joueur)["role"])
	var out: Array[String] = []
	for role in ROLES:
		if role != role_joueur:
			out.append(role)
	return out


## La graine de l'Écho d'un rôle.
static func graine_echo(graine_joueur: int, role: String) -> int:
	return graine_joueur ^ (XOR_ECHO * (ROLES.find(role) + 1))


## Les deux Échos générés d'un joueur : la classe de chaque rôle manquant tirée avec la graine de l'Écho, sa roue au
## niveau du joueur.
static func echos(classe_joueur: String, graine_joueur: int, niveau: int, donnees: Donnees = null) -> Array[Destin]:
	var d := donnees if donnees != null else Donnees.defaut()
	var out: Array[Destin] = []
	for role in roles_des_echos(classe_joueur, d):
		out.append(echo(role, graine_echo(graine_joueur, role), niveau, d))
	return out


## Un Écho généré d'un rôle : une classe de ce rôle tirée avec sa graine (une évolution au-delà du niveau 30 :
## engine/evolution.gd), sa roue au niveau donné.
static func echo(role: String, graine: int, niveau: int, donnees: Donnees = null) -> Destin:
	var d := donnees if donnees != null else Donnees.defaut()
	var classes := classes_du_role(role, d, Evolution.rang_du_niveau(niveau, d))
	var rng := RandomNumberGenerator.new()
	rng.seed = graine
	return Generateur.echo(classes[rng.randi_range(0, classes.size() - 1)], graine, niveau, d)


## Le camp d'un joueur : lui, puis ses deux Échos générés.
static func camp(joueur: Destin, niveau: int, donnees: Donnees = null) -> Array[Destin]:
	var out: Array[Destin] = [joueur]
	out.append_array(echos(joueur.classe_id, joueur.graine, niveau, donnees))
	return out
