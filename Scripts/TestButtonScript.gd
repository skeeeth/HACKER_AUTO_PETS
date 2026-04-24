extends Button

@export var transition_scene_file_path : String
var current_scene : String

func _ready() -> void:
	current_scene = get_tree().current_scene.name

func _on_pressed() -> void:
	if current_scene == "ShopScene":
		if PlayerUnitsContainer.ally_unit_list.size() != 0:
			get_tree().change_scene_to_file(transition_scene_file_path)
	else:
		get_tree().change_scene_to_file(transition_scene_file_path)
