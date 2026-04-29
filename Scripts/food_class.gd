extends PanelContainer
class_name Food

@export var food_data:FoodData
@export var display_label:Label
var shop:ShopManager

static var self_scene = preload("uid://ct3bbwrecsopt")

static func create(from_data:FoodData) -> Food:
	var new_food:Food = self_scene.instantiate()
	new_food.food_data = from_data
	new_food.display_label.text = "[" + from_data.display_string + "]"
	return new_food

func _get_drag_data(_at_position: Vector2) -> Variant:
	var preview_sprite = create(food_data)
	#preview_sprite.texture = sprite.texture
	#preview_sprite.size = sprite.size
	set_drag_preview(preview_sprite)
	
	var drop_data:Dictionary = {
		"data" = food_data,
		"source" = self
	}
	
	return drop_data


func try_purchase():
	if shop.coins >= food_data.price:
		shop.reduce_coin(food_data.price)
		queue_free()
		return true
	else:
		return false
