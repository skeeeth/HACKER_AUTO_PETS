extends Control
class_name InfoDisplay

@export var sprite:TextureRect
@export var title_label:Label
@export var description:RichTextLabel

const self_scene = preload("uid://caqo5o73bgt5u")
static func create(data:UnitData) -> InfoDisplay:
	var new_info : InfoDisplay = self_scene.instantiate()
	new_info.sprite.texture = data.effect.sprite
	new_info.title_label.text = data.unit_name
	new_info.description.add_text(data.effect.effect_description)
	return new_info
	
