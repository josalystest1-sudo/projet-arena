## Règle d'architecture n°1 : le moteur de règles est un module pur, sans affichage ni nœud de scène.
extends "res://tests/test_case.gd"

const ENGINE_DIR := "res://engine/"
const FORBIDDEN := ["extends Node", "extends Control", "extends Node2D", "extends CanvasItem", "get_tree(", "get_node(", "$", "preload(\"res://scenes", "load(\"res://scenes", "Input.", "await ", "randf(", "randi(", "randomize("]


func test_moteur_sans_dependance_a_l_affichage() -> void:
	var dir := DirAccess.open(ENGINE_DIR)
	assert_true(dir != null, "dossier du moteur")
	if dir == null:
		return
	var count := 0
	for file_name in dir.get_files():
		if not file_name.ends_with(".gd"):
			continue
		count += 1
		var text := FileAccess.get_file_as_string(ENGINE_DIR + file_name)
		assert_true(text.contains("extends RefCounted"), file_name + " doit hériter de RefCounted")
		for line in text.split("\n"):
			var code := line.strip_edges()
			if code.begins_with("#"):
				continue
			for word in FORBIDDEN:
				if code.contains(word):
					failures.append("%s : « %s » interdit dans le moteur (%s)" % [file_name, word, code])
	assert_true(count >= 5, "les fichiers du moteur ont été trouvés")
