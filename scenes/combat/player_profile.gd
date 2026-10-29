## Ce que le jeu retient entre deux combats, sur l'appareil du joueur : victoires, série, record, son,
## le duo (son perso et son acolyte) et les records de la Tour.
## (En attendant les comptes de l'étape 5, tout reste en local.)
class_name PlayerProfile
extends RefCounted

const PATH := "user://profil.cfg"
## Où le profil est gardé : PATH, sauf pour les outils de capture (tools/capture.gd), qui gardent le leur à part.
static var chemin := PATH

var wins: int = 0
var losses: int = 0
var streak: int = 0
var best_streak: int = 0
var muted: bool = false
## Le duo (combat V2) : {version: 2, classe, graine, allumage, acolyte_nom} (vide tant qu'aucun duo n'est créé).
var duo: Dictionary = {}
## Record à la Tour par classe : étage atteint (GDD : le record est classé par classe).
var tower_records: Dictionary = {}
## Par classe : l'étage d'où la prochaine montée peut reprendre (après le dernier Gardien franchi), tous ses PV.
var tower_paliers: Dictionary = {}
## Par classe : les Faveurs de la Tour acquises (identifiant -> nombre de cumuls), une par Gardien vaincu pour la
## première fois ; elles ne valent que dans la Tour.
var tower_faveurs: Dictionary = {}
## Les monstres déjà croisés à la Tour (identifiant -> true), pour le bestiaire.
var monsters_seen: Dictionary = {}
## Les bulles d'aide du combat déjà lues (identifiant -> true) : chacune ne s'affiche qu'une fois.
var tips_seen: Dictionary = {}
## Le niveau (1 à 30 : un point de Destin par niveau) et l'XP vers le niveau suivant (au prototype, une courbe rapide).
var level: int = 1
var xp: int = 0
const MAX_LEVEL := 30


static func load_profile() -> PlayerProfile:
	var profile := PlayerProfile.new()
	var cfg := ConfigFile.new()
	if cfg.load(chemin) == OK:
		profile.wins = int(cfg.get_value("stats", "wins", 0))
		profile.losses = int(cfg.get_value("stats", "losses", 0))
		profile.streak = int(cfg.get_value("stats", "streak", 0))
		profile.best_streak = int(cfg.get_value("stats", "best_streak", 0))
		profile.muted = bool(cfg.get_value("options", "muted", false))
		profile.duo = cfg.get_value("duo", "duo", {})
		profile.tower_records = cfg.get_value("tour", "records", {})
		profile.tower_paliers = cfg.get_value("tour", "paliers", {})
		profile.tower_faveurs = cfg.get_value("tour", "faveurs", {})
		profile.monsters_seen = cfg.get_value("tour", "monstres", {})
		profile.tips_seen = cfg.get_value("aide", "vues", {})
		profile.level = int(cfg.get_value("progression", "niveau", 1))
		profile.xp = int(cfg.get_value("progression", "xp", 0))
	return profile


func save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("stats", "wins", wins)
	cfg.set_value("stats", "losses", losses)
	cfg.set_value("stats", "streak", streak)
	cfg.set_value("stats", "best_streak", best_streak)
	cfg.set_value("options", "muted", muted)
	cfg.set_value("duo", "duo", duo)
	cfg.set_value("tour", "records", tower_records)
	cfg.set_value("tour", "paliers", tower_paliers)
	cfg.set_value("tour", "faveurs", tower_faveurs)
	cfg.set_value("tour", "monstres", monsters_seen)
	cfg.set_value("aide", "vues", tips_seen)
	cfg.set_value("progression", "niveau", level)
	cfg.set_value("progression", "xp", xp)
	cfg.save(chemin)


## L'XP qu'il faut pour passer du niveau donné au suivant (prototype : rapide, pour tester l'arbre ; le GDD vise
## 20 à 60 minutes par niveau au début).
static func xp_to_next(from_level: int) -> int:
	return 150 + 50 * from_level


## Ajoute de l'XP ; renvoie {levels: niveaux gagnés, level: le niveau atteint}.
func gain_xp(amount: int) -> Dictionary:
	var gained := 0
	if level < MAX_LEVEL:
		xp += amount
		while level < MAX_LEVEL and xp >= xp_to_next(level):
			xp -= xp_to_next(level)
			level += 1
			gained += 1
		if level >= MAX_LEVEL:
			xp = 0
	return {"levels": gained, "level": level}


## Enregistre un résultat. Renvoie {previous_streak, new_record}.
func record_result(won: bool) -> Dictionary:
	var previous := streak
	var new_record := false
	if won:
		wins += 1
		streak += 1
		if streak > best_streak:
			best_streak = streak
			new_record = streak > 1
	else:
		losses += 1
		streak = 0
	save()
	return {"previous_streak": previous, "new_record": new_record}


## Note un monstre croisé à la Tour (enregistré à la première rencontre).
func see_monster(monster_id: String) -> void:
	if not monsters_seen.has(monster_id):
		monsters_seen[monster_id] = true
		save()
