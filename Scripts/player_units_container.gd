extends Node

var ally_unit_list : Array[UnitData]
const ARRAY_MAX_SIZE : int = 5

func add_unit_to_list(unit : UnitData) -> void:
	ally_unit_list.append(unit)

func remove_unit_from_list(unit : UnitData) -> void:
	ally_unit_list.erase(unit)
