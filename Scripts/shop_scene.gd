extends Node2D
class_name ShopManager

const UNIT_CONTROL_SCENE = preload("uid://cuol4iet7e1w2")

@export var combat_scene_file_path : String

@export var purchasable_units : Array[UnitData]
@export var purchase_buttons : Array[PurchaseButton]
@export var coins : int = 10
@export var unit_cost : int = 3
@export var coin_text_node : Label
@export var unit_holder : HBoxContainer

var base_coin_text : String

var player_stack : Array[CombatUnitControl]

var list_index : int = 0

func _ready() -> void:
	base_coin_text = coin_text_node.text
	_set_coin_text()
	
	if PlayerUnitsContainer.ally_unit_list.size() != 0:
		_add_all_to_stack()
	
	_set_buttons()


## This function adds the unit data to the shop player stack
func _add_to_stack(data : UnitData) -> void:
	var unit : CombatUnitControl = _create_unit(data)
	player_stack.append(unit)

## This function calls the _add_to_stack function 
## for each unit in the PlayerUnitsContainer class
func _add_all_to_stack() -> void:
	for data in PlayerUnitsContainer.ally_unit_list:
		var new_unit : CombatUnitControl
		new_unit = UNIT_CONTROL_SCENE.instantiate()
		new_unit.dress(data, list_index)
		unit_holder.add_child(new_unit)
		player_stack.append(new_unit)
		list_index += 1
	list_index = 0

## This function creates a new CombatUnit scene 
## and spawns it into the level. Then, it sets the data perameter
## into the new CombatUnit scene and adds it to the Unit Holder Node
func _create_unit(data:UnitData) -> CombatUnitControl:
	var new_unit : CombatUnitControl
	new_unit = UNIT_CONTROL_SCENE.instantiate()
	new_unit.dress(data, PlayerUnitsContainer.ally_unit_list.size() - 1)
	unit_holder.add_child(new_unit)
	unit_holder.move_child(new_unit, 0)
	return new_unit


func _set_coin_text() -> void:
	coin_text_node.text = base_coin_text + str(coins)

## This function adds a unit to the Player Unit Container class 
## based on the button pressed. 
## If there are not enough coins or space, the unit is not purchased.
func purchase_unit(unit:UnitData) -> void:
	
	if PlayerUnitsContainer.ally_unit_list.size() != PlayerUnitsContainer.ARRAY_MAX_SIZE:
		if coins >= unit_cost:
			PlayerUnitsContainer.add_unit_to_list(unit)
			_add_to_stack(unit)
			reduce_coin(unit_cost)
			
	else:
		print("Size full")


func sell() -> void:
	increase_coin(1)
	
func reduce_coin(price : int) -> void:
	coins -= price
	_set_coin_text()

func increase_coin(sell_price : int) -> void:
	coins += sell_price
	_set_coin_text()

func _go_to_combat_scene() -> void:
	if PlayerUnitsContainer.ally_unit_list.size() != 0:
		get_tree().change_scene_to_file(combat_scene_file_path)
	elif PlayerUnitsContainer.ally_unit_list.size() == 0 and coins < 3:
		print("No units and no coins? Here is some money.")
		coins = unit_cost
		_set_coin_text()
		pass
		
func _reroll() -> void:
	if coins != 0:
		reduce_coin(1)
		_set_buttons()

func _set_buttons() -> void:
	for button in purchase_buttons:
		var random_unit_num : int = randi_range(0, purchasable_units.size() - 1)
		button.add_unit_to_button(purchasable_units[random_unit_num])


func move_unit(unit : CombatUnitControl, direction : int) -> void:
	print(unit.name_label.text, ": ", unit.object_index - 1)
	if direction == -1:
		unit_holder.move_child(unit, unit.get_index() - 1)
		print(unit.name_label.text, ": ", unit.object_index)
	else:
		unit_holder.move_child(unit, unit.get_index() + 1)
		print(unit.name_label.text, ": ", unit.object_index)
