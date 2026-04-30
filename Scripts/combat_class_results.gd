extends Control
class_name CombatUnitResults

signal sell_unit
signal moved_unit(this : CombatUnitControl, direction : int)

@export var damage_label: Label
@export var health_label: Label
@export var name_label : Label
@export var shift_label : Label
@export var sprite : TextureRect

@export var object_index : int
var shop_manager : ShopManager

var moved_position : bool
var effect : EffectData
var unit_data : UnitData

var shift : int = 0:
	set(v):
		shift = v
		shift_label.text = "%+d" % shift
		if unit_data:
			unit_data.shift = shift

## This variable has a set function that changes the attack text
var attack : int:
	set(v):
		attack = v
		damage_label.text = str(attack)
		if unit_data:
			unit_data.attack = attack

## This variable has a set function that changes the health text
var health : int:
	set(v):
		health = v
		health_label.text = str(health)
		if unit_data:
			unit_data.health = health


## This sets up the unit data for the unit
func dress(data : UnitData, index : int = 0):
	unit_data = data
	attack = data.attack
	health = data.health
	name_label.text = data.unit_name
	effect = data.effect
	sprite.texture = data.effect.sprite
	object_index = index
	shift = unit_data.shift


func _mouse_entered():
	var info : InfoDisplay = InfoDisplay.create(unit_data)
	add_child(info)
	info.position.y = -100
	mouse_exited.connect(info.queue_free)
