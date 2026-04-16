extends Node2D
class_name ShopManager


const UNIT_CONTROL_SCENE = preload("uid://cuol4iet7e1w2")

@export var purchasable_units : Array[UnitData]

var player_stack : Array[CombatUnitControl]

func _ready() -> void:
	if PlayerUnitsContainer.ally_unit_list.size() != 0:
		add_all_to_hbox()


func add_to_hbox(data : UnitData) -> void:
	var unit : CombatUnitControl = _create_unit(data)
	player_stack.append(unit)
	

func add_all_to_hbox() -> void:
	for data in PlayerUnitsContainer.ally_unit_list:
		add_to_hbox(data)


func _create_unit(data:UnitData) -> CombatUnitControl:
	var new_unit : CombatUnitControl
	new_unit = UNIT_CONTROL_SCENE.instantiate()
	new_unit.dress(data)
	get_tree().get_root().get_node("ShopScene/HBoxContainer").add_child(new_unit)
	return new_unit


func _purchase_unit_button_pressed(unitNum : int) -> void:
	
	if PlayerUnitsContainer.ally_unit_list.size() != PlayerUnitsContainer.ARRAY_MAX_SIZE:
		PlayerUnitsContainer.add_unit_to_list(purchasable_units[unitNum - 1])
		add_to_hbox(purchasable_units[unitNum - 1])
	else:
		print("Size full")
