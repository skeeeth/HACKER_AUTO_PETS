extends Control

@export var title_scene_path : String

func change_to_title() -> void:
	get_tree().change_scene_to_file(title_scene_path)
