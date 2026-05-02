extends Control
class_name CombatUnitControl

signal clicked(data)
signal sell_unit
signal moved_unit(this : CombatUnitControl, direction : int)

@export var damage_label: Label
@export var health_label: Label
@export var name_label : Label
@export var shift_label : Label
@export var sprite : TextureRect

@export var object_index : int
@export var effect_node : ShopEffect
var shop_manager : ShopManager

var moved_position : bool
var effect : EffectData
var unit_data : UnitData

var dropable:bool = true

var shift : int = 0:
	set(v):
		shift = v
		shift_label.text = "Shift: %+d" % shift
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

func _ready() -> void:
	#shop_manager = get_tree().get_root().get_node("ShopScene")
	sell_unit.connect(shop_manager.sell)
	moved_unit.connect(shop_manager.move_unit)


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
	effect_node.data = data.effect
	effect_node.holder = self



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

func _mouse_entered():
	for i in effect_node.set_targets(false):
		mouse_exited.connect(i.queue_free)
	#Indicator.create(unit_data,)
	#var info : InfoDisplay = InfoDisplay.create(unit_data)
	#add_child(info)
	#info.position.y = -100
	#mouse_exited.connect(info.queue_free)


func _can_drop_data(_position, data):
	return typeof(data) == TYPE_DICTIONARY and data.has("source") and dropable

#func save_stats_to_data():
	#unit_data.attack = attack
	#unit_data.health = health
	#unit_data.shift = shift

func _get_drag_data(_at_position: Vector2) -> Variant:
	if !dropable: return
	var preview_sprite = TextureRect.new()
	preview_sprite.texture = sprite.texture
	preview_sprite.size = sprite.size
	set_drag_preview(preview_sprite)
	
	var drop_data:Dictionary = {
		"data" = unit_data,
		"source" = self
	}
	return drop_data

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var source_object = data["source"]
	if source_object is CombatUnitControl:
		effect_node.reparent(source_object)
		source_object.effect_node.reparent(self)
		
		var original_node = effect_node
		effect_node = source_object.effect_node
		source_object.effect_node = original_node
		
		source_object.dress(unit_data)
		dress(data["data"]) #data["data"] is fucked up naming what am i doing
						#	^ok but the issue is data being plural and singluar
		
	elif source_object is Food:
		if source_object.try_purchase():
			accept_food(data["data"])

func accept_food(food_data:FoodData):
	match food_data.type:
		FoodData.food_types.SHIFT:
			shift += food_data.magnitude
		FoodData.food_types.GIVE:
			attack += food_data.magnitude
			health += food_data.magnitude #+ food mod

func _gui_input(event: InputEvent) -> void:
	if event.is_action("lmb"):
		clicked.emit(unit_data)
