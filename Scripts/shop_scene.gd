extends Node2D
class_name ShopManager


const UNIT_CONTROL_SCENE = preload("uid://cuol4iet7e1w2")

@export var purchasable_units : Array[UnitData]
@export var coins : int = 10
@export var coin_text_node : Label

var base_coin_text : String

var player_stack : Array[CombatUnitControl]

func _ready() -> void:
	base_coin_text = coin_text_node.text
	_set_coin_text()
	
	if PlayerUnitsContainer.ally_unit_list.size() != 0:
		_add_all_to_hbox()


func _add_to_hbox(data : UnitData) -> void:
	var unit : CombatUnitControl = _create_unit(data)
	player_stack.append(unit)
	

func _add_all_to_hbox() -> void:
	for data in PlayerUnitsContainer.ally_unit_list:
		_add_to_hbox(data)


func _create_unit(data:UnitData) -> CombatUnitControl:
	var new_unit : CombatUnitControl
	new_unit = UNIT_CONTROL_SCENE.instantiate()
	new_unit.dress(data)
	get_tree().get_root().get_node("ShopScene/UnitHolder").add_child(new_unit)
	return new_unit


func _set_coin_text() -> void:
	coin_text_node.text = base_coin_text + str(coins)

func _purchase_unit_button_pressed(unitNum : int) -> void:
	
	if PlayerUnitsContainer.ally_unit_list.size() != PlayerUnitsContainer.ARRAY_MAX_SIZE:
		if coins >= 3:
			PlayerUnitsContainer.add_unit_to_list(purchasable_units[unitNum - 1])
			_add_to_hbox(purchasable_units[unitNum - 1])
			coins -= 3
			_set_coin_text()
	else:
		print("Size full")
