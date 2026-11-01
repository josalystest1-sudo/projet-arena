## Paramètres (GDD) : le son, et les outils du prototype (nouveaux tirages, nouveau personnage, effacer ses données).
extends Control

var app: ArenaApp
var sound_button: Button
var erase_button: Button
var raz_button: Button
var lendemain_label: Label
var _raz_armed := false
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
	proto.add_child(UiKit.label("Dans le vrai jeu, ton Destin ne change jamais. Ici, pour essayer d'autres roues, tu peux tirer à nouveau.", 15, UiKit.SOFT, false))
	proto.add_child(UiKit.button("Autre Destin (même classe)", _reroll_player, 52))
	proto.add_child(UiKit.button("Gagner un niveau (pour allumer un nœud)", _level_up, 52))
	var niveaux := HBoxContainer.new()
	niveaux.add_theme_constant_override("separation", 8)
	proto.add_child(niveaux)
	for n: int in [5, 10, 30]:
		var b := UiKit.button("+%d niveaux" % n, func():
			app.sfx.play("clic")
			app.monter_niveaux(n)
			app.show_screen("destin"), 52)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		niveaux.add_child(b)
	proto.add_child(UiKit.label("Le niveau s'arrête au plafond de ta classe (30 avant d'évoluer). Les points gagnés sont à placer sur la roue.", 15, UiKit.SOFT, false))
	proto.add_child(UiKit.button("Passer au lendemain (guerres, objectifs, Arène, Marché)", func():
		app.sfx.play("clic")
		app.passer_au_lendemain()
		app.show_screen("ville"), 52))
	lendemain_label = UiKit.label("", 15, UiKit.SOFT, false)
	proto.add_child(lendemain_label)
	_refresh_lendemain()
	raz_button = UiKit.button("Remettre mon personnage à zéro (niveau 1, roue neuve)", _raz, 52)
	proto.add_child(raz_button)
	proto.add_child(UiKit.button("Vieillir le compte de 7 jours (pour le Marché)", func():
		app.sfx.play("clic")
		app.vieillir_compte(7)
		app.show_screen("marche"), 52))
	proto.add_child(UiKit.button("Nouveau personnage (autre classe)", func(): app.show_screen("creation"), 52))
	erase_button = UiKit.button("Effacer toutes mes données", _erase, 52)
	proto.add_child(erase_button)
	column.add_child(UiKit.button("Retour à la ville", func(): app.show_screen("ville"), 56))


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
	app.show_screen("destin")


func _refresh_lendemain() -> void:
	var n := app.profile.jours_avance
	if n == 0:
		lendemain_label.text = "Le jeu est à la date d'aujourd'hui."
	else:
		lendemain_label.text = "Le jeu se croit %d jour%s plus tard qu'aujourd'hui (le %s)." % [n, "s" if n > 1 else "", app.profile.aujourd_hui()]


## La remise à zéro du perso demande une confirmation : un second appui.
func _raz() -> void:
	if not _raz_armed:
		_raz_armed = true
		raz_button.text = "Sûr ? Touche encore : niveau 1, roue neuve"
		raz_button.modulate = Color(1, 0.6, 0.6)
		return
	app.sfx.play("clic")
	app.remettre_perso_a_zero()
	app.show_screen("destin")


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
	app.destin = null
	app.echos.clear()
	app.echos_choisis = {}
	app.show_screen("creation")
