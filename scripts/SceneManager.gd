extends Node

var target_spawn: String = "player_spawn"

func change_to_scene(scene_path: String, spawn_name: String = "player_spawn"):
	print("Cambiando a escena: ", scene_path)
	print("Spawn point: ", spawn_name)
	target_spawn = spawn_name
	get_tree().change_scene_to_file(scene_path)
