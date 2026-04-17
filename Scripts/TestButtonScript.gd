extends Button

@export var transition_scene_file_path : String

func _on_pressed() -> void:
	if PlayerUnitsContainer.ally_unit_list.size() != 0:
		get_tree().change_scene_to_file(transition_scene_file_path)
