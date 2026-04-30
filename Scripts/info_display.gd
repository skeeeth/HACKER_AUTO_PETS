extends Control
class_name InfoDisplay

@export var sprite:TextureRect
@export var title_label:Label
@export var description:RichTextLabel
@export var health_label:Label
@export var attack_label:Label

const self_scene = preload("uid://caqo5o73bgt5u")
static func create(data:UnitData) -> InfoDisplay:
	var new_info : InfoDisplay = self_scene.instantiate()
	new_info.set_info(data)
	return new_info
	
func set_info(data:UnitData):
	sprite.texture = data.effect.sprite
	title_label.text = data.unit_name
	#this is not the correct way to use a richtext label
	description.text = "[font_size=24]" + data.effect.effect_description
	health_label.text = str(data.health)
	attack_label.text = str(data.attack)
