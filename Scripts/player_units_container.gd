extends Node

var ally_unit_list : Array[UnitData]


const ARRAY_MAX_SIZE : int = 5

func add_unit_to_list(unit : UnitData) -> void:
	ally_unit_list.append(unit)

func remove_unit_from_list(unit : UnitData) -> void:
	ally_unit_list.erase(unit)

func move_unit_in_list(index : int, direction : int) -> bool:
	var moving_unit = ally_unit_list[index]
	
	if direction == -1:
		if index != 0:
			ally_unit_list[index] = ally_unit_list[index - 1]
			ally_unit_list[index - 1] = moving_unit
			return true
		else:
			return false
	else:
		if index != ally_unit_list.size() - 1:
			ally_unit_list[index] = ally_unit_list[index + 1]
			ally_unit_list[index + 1] = moving_unit
			return true
		else:
			return false

func clear_list():
	ally_unit_list.clear()
