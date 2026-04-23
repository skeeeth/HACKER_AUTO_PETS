## Bit of a HACK job, these actually shouldn't have an inheritance
## relationship, I just didnt want to rewrite the Effect class to have
## different manager types
extends Node ##REALLY WRONG WAY TO GO ABOUT THIS
class_name ShopEffectManager

signal shop_entered
signal shop_ending


func _ready() -> void: #OVERWRITE super's ready
	pass
