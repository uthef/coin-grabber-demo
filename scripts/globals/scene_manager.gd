# узел управление сценами
extends Node


func change_current_scene(res_path: String, parameters: Dictionary = {}) -> Node:
	var new_scene: PackedScene = load(res_path)
	var new_scene_instance = new_scene.instantiate()

	for key in parameters.keys():
		new_scene_instance[key] = parameters[key]

	get_tree().root.add_child(new_scene_instance)

	get_tree().current_scene.queue_free()
	get_tree().current_scene = new_scene_instance

	return new_scene_instance

