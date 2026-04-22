extends Button

@export var shop : ShopManager

func _on_pressed() -> void:
	var target_unit:CombatUnitControl = shop.unit_holder.get_children().front()
	target_unit.attack += 1
	target_unit.health += 1
	
	
	pass # Replace with function body.
