extends Node
class_name ShopEffectManager


signal shop_entered
signal shop_ending

@export var shop_main:ShopManager

var effect_stack : Array[ShopEffect]

#func _ready() -> void:
	#shop_entered.emit()
#
	#resolve_effects()

func resolve_effects():
	for e in effect_stack:
		e.resolve()
	
func lock():
	for b in shop_main.purchase_buttons:
		b.disabled = true
	
	for u in shop_main.get_unit_stack():
		u.mouse_filter = Control.MOUSE_FILTER_IGNORE

func unlock():
	for b in shop_main.purchase_buttons:
		b.disabled = false
	
	for u in shop_main.get_unit_stack():
		u.mouse_filter = Control.MOUSE_FILTER_STOP
	
