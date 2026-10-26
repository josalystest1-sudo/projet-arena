## Lanceur de tests : godot --headless --path . --script res://tests/run_tests.gd
## Exécute toutes les méthodes test_* des fichiers res://tests/test_*.gd. Code de sortie 1 si un test échoue.
extends SceneTree

const TESTS_DIR := "res://tests/"


func _initialize() -> void:
	var total := 0
	var failed := 0
	var files := _test_files()
	files.sort()
	for path in files:
		var script: GDScript = load(path)
		if script == null or not script.can_instantiate():
			total += 1
			failed += 1
			print("  ÉCHEC %s : le fichier de test ne se charge pas" % path.get_file())
			continue
		var case = script.new()
		for method in case.get_method_list():
			var method_name: String = method["name"]
			if not method_name.begins_with("test_"):
				continue
			total += 1
			case.failures.clear()
			case.setup()
			case.call(method_name)
			if case.failures.is_empty():
				print("  OK   %s::%s" % [path.get_file(), method_name])
			else:
				failed += 1
				print("  ÉCHEC %s::%s" % [path.get_file(), method_name])
				for failure in case.failures:
					print("        - " + failure)
	print("")
	print("%d tests, %d échecs" % [total, failed])
	quit(1 if failed > 0 else 0)


func _test_files() -> Array[String]:
	var result: Array[String] = []
	var dir := DirAccess.open(TESTS_DIR)
	if dir == null:
		push_error("Dossier de tests introuvable : " + TESTS_DIR)
		return result
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.begins_with("test_") and file_name.ends_with(".gd") and file_name != "test_case.gd":
			result.append(TESTS_DIR + file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	return result
