extends Control
class_name CombatUnitControl

signal sell_unit
signal moved_unit(this : CombatUnitControl, direction : int)

@export var damage_label: Label
@export var health_label: Label
@export var name_label : Label
@export var sprite : TextureRect

@export var object_index : int
var shop_manager : ShopManager

var moved_position : bool
var effect : EffectData
var unit_data : UnitData


## This variable has a set function that changes the attack text
var attack : int:
	set(v):
		attack = v
		damage_label.text = str(attack)

## This variable has a set function that changes the health text
var health : int:
	set(v):
		health = v
		health_label.text = str(health)

func _ready() -> void:
	shop_manager = get_tree().get_root().get_node("ShopScene")
	sell_unit.connect(shop_manager.sell)
	moved_unit.connect(shop_manager.move_unit)


## This sets up the unit data for the unit
func dress(data : UnitData, index : int):
	attack = data.attack
	health = data.health
	name_label.text = data.unit_name
	effect = data.effect
	sprite.texture = data.effect.sprite
	unit_data = data
	object_index = index


func _on_sell_button_pressed() -> void:
	PlayerUnitsContainer.remove_unit_from_list(unit_data)
	sell_unit.emit()
	queue_free()


func _on_move_up_pressed() -> void:
	moved_position = PlayerUnitsContainer.move_unit_in_list(object_index, -1)
	
	if moved_position == true:
		object_index -= 1
		moved_unit.emit(self, 1)
	
	

func _on_move_back_pressed() -> void:
	moved_position = PlayerUnitsContainer.move_unit_in_list(object_index, 1)
	
	if moved_position == true:
		object_index += 1
		moved_unit.emit(self, -1)
	
