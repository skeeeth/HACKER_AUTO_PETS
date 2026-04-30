extends Node
class_name ShopEffectManager


signal shop_entered
signal shop_ending
signal effects_finsihed
signal ending_resolved

@export var shop_main:ShopManager

var effect_stack : Array[ShopEffect]

#func _ready() -> void:
	#shop_entered.emit()
#
	#resolve_effects()

func resolve_effects():
	if effect_stack.size() >= 1:
		var current = effect_stack.pop_back()
		current.resolve()
		await current.resolved
		resolve_effects()
	else:
		effects_finsihed.emit()

	
func lock():
	for b in shop_main.purchase_buttons:
		b.disabled = true
	
	for u in shop_main.get_unit_stack():
		u.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	shop_main.combat_scene_button.disabled = true

func unlock():
	for b in shop_main.purchase_buttons:
		b.disabled = false
	
	for u in shop_main.get_unit_stack():
		u.mouse_filter = Control.MOUSE_FILTER_STOP
		
	shop_main.combat_scene_button.disabled = false

func end_combat():
	shop_ending.emit()
	lock()
	resolve_effects()
	if effect_stack.size() >= 1:
		await effects_finsihed
	var transition = create_tween()
	transition.tween_callback(ending_resolved.emit).set_delay(0.5)
	
