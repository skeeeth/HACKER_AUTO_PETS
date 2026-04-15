extends Button

@export var transition_scene_file_path : String

func _on_pressed() -> void:
	get_tree().change_scene_to_file(transition_scene_file_path)
