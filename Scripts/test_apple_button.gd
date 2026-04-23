extends Button

@export var shop : ShopManager

func _on_pressed() -> void:
	var target_unit:CombatUnitControl = shop.unit_holder.get_children().front()
	target_unit.unit_data.attack += 1
	target_unit.unit_data.health += 1
	target_unit.dress(target_unit.unit_data)
	
	
	pass # Replace with function body.
