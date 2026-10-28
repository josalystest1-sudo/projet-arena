## Paramètres (GDD) : le son, et les outils du prototype (nouveaux tirages, nouveau personnage, effacer ses données).
extends Control

var app: ArenaApp
var sound_button: Button
var erase_button: Button
var _erase_armed := false


func setup(p_app: ArenaApp, _options: Dictionary) -> void:
	app = p_app
	var column := UiKit.scroll_column(self, 12)
	column.add_child(UiKit.label("Paramètres", 30, UiKit.GOLD))
	sound_button = UiKit.button("", _toggle_sound, 56)
	column.add_child(sound_button)
	_refresh_sound()
	var proto := UiKit.card(column, 8)
	proto.add_child(UiKit.label("Outils du prototype", 20, UiKit.GOLD, false))
	proto.add_child(UiKit.label("Dans le vrai jeu, ton Destin et ton acolyte ne changent jamais. Ici, pour essayer tous les kits, tu peux tirer à nouveau.", 15, UiKit.SOFT, false))
	proto.add_child(UiKit.button("Autre tirage pour toi", _reroll_player, 52))
	proto.add_child(UiKit.button("Autre acolyte", _reroll_acolyte, 52))
	proto.add_child(UiKit.button("Gagner un niveau (pour tester l'arbre du Destin)", _level_up, 52))
	proto.add_child(UiKit.button("Nouveau personnage (autre classe)", func(): app.show_screen("creation"), 52))
	erase_button = UiKit.button("Effacer toutes mes données", _erase, 52)
	proto.add_child(erase_button)
	column.add_child(UiKit.button("Retour à l'accueil", func(): app.show_screen("home"), 56))


func _toggle_sound() -> void:
	app.sfx.muted = not app.sfx.muted
	app.profile.muted = app.sfx.muted
	app.profile.save()
	_refresh_sound()
	app.sfx.play("clic")


func _refresh_sound() -> void:
	sound_button.text = "Son : coupé" if app.sfx.muted else "Son : activé"


func _level_up() -> void:
	app.sfx.play("clic")
	app.gain_xp(PlayerProfile.xp_to_next(app.profile.level) - app.profile.xp)
	app.show_screen("destin")


func _reroll_player() -> void:
	app.sfx.play("clic")
	app.reroll_player()
	app.show_screen("skills")


func _reroll_acolyte() -> void:
	app.sfx.play("clic")
	app.reroll_acolyte()
	app.show_screen("meet")


## Effacer demande une confirmation : un second appui.
func _erase() -> void:
	if not _erase_armed:
		_erase_armed = true
		erase_button.text = "Sûr ? Touche encore pour tout effacer"
		erase_button.modulate = Color(1, 0.6, 0.6)
		return
	app.profile = PlayerProfile.new()
	app.profile.save()
	app.player_class = ""
	app.acolyte = {}
	app.show_screen("creation")
