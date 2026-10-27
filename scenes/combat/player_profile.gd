## Ce que le jeu retient entre deux combats, sur l'appareil du joueur : victoires, série, record, son,
## le duo (son perso et son acolyte, avec la dernière posture donnée) et les records de la Tour.
## (En attendant les comptes de l'étape 5, tout reste en local.)
class_name PlayerProfile
extends RefCounted

const PATH := "user://profil.cfg"

var wins: int = 0
var losses: int = 0
var streak: int = 0
var best_streak: int = 0
var muted: bool = false
## Le duo : {player_class, player_picks, acolyte_class, acolyte_picks, acolyte_name} (vide tant qu'aucun duo n'est créé).
var duo: Dictionary = {}
var posture: String = "libre"
## Record à la Tour par classe : étage atteint (GDD : le record est classé par classe).
var tower_records: Dictionary = {}


static func load_profile() -> PlayerProfile:
	var profile := PlayerProfile.new()
	var cfg := ConfigFile.new()
	if cfg.load(PATH) == OK:
		profile.wins = int(cfg.get_value("stats", "wins", 0))
		profile.losses = int(cfg.get_value("stats", "losses", 0))
		profile.streak = int(cfg.get_value("stats", "streak", 0))
		profile.best_streak = int(cfg.get_value("stats", "best_streak", 0))
		profile.muted = bool(cfg.get_value("options", "muted", false))
		profile.duo = cfg.get_value("duo", "duo", {})
		profile.posture = str(cfg.get_value("duo", "posture", "libre"))
		profile.tower_records = cfg.get_value("tour", "records", {})
	return profile


func save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("stats", "wins", wins)
	cfg.set_value("stats", "losses", losses)
	cfg.set_value("stats", "streak", streak)
	cfg.set_value("stats", "best_streak", best_streak)
	cfg.set_value("options", "muted", muted)
	cfg.set_value("duo", "duo", duo)
	cfg.set_value("duo", "posture", posture)
	cfg.set_value("tour", "records", tower_records)
	cfg.save(PATH)


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
