## Lecteur de bruitages : quelques lecteurs en parallèle, son coupable par le joueur.
class_name Sfx
extends Node

const SOUNDS := {
	"clic": preload("res://assets/sfx/clic.wav"),
	"tic": preload("res://assets/sfx/tic.wav"),
	"coup": preload("res://assets/sfx/coup.wav"),
	"gros_coup": preload("res://assets/sfx/gros_coup.wav"),
	"soin": preload("res://assets/sfx/soin.wav"),
	"bloque": preload("res://assets/sfx/bloque.wav"),
	"ko": preload("res://assets/sfx/ko.wav"),
	"synergie": preload("res://assets/sfx/synergie.wav"),
	"forte": preload("res://assets/sfx/forte.wav"),
	"tour": preload("res://assets/sfx/tour.wav"),
	"releve": preload("res://assets/sfx/releve.wav"),
	"victoire": preload("res://assets/sfx/victoire.wav"),
	"defaite": preload("res://assets/sfx/defaite.wav"),
}
const VOICES := 6

var muted: bool = false
var _players: Array[AudioStreamPlayer] = []
var _next: int = 0


func _ready() -> void:
	for i in range(VOICES):
		var player := AudioStreamPlayer.new()
		add_child(player)
		_players.append(player)


func play(sound: String, pitch: float = 1.0, volume_db: float = 0.0) -> void:
	if muted or not SOUNDS.has(sound):
		return
	var player := _players[_next]
	_next = (_next + 1) % VOICES
	player.stream = SOUNDS[sound]
	player.pitch_scale = pitch
	player.volume_db = volume_db
	player.play()
