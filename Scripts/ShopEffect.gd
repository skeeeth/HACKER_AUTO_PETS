extends Node
class_name ShopEffect

var shop_manager:ShopEffectManager
var data:EffectData

func subscribe():
	match  data.TriggerStates:
		EffectData.TriggerStates.SHOP_START:
			shop_manager.shop_entered.connect(trigger)
		
		EffectData.TriggerStates.SHOP_END:
			shop_manager.shop_ending.connect(trigger)

func trigger():
	pass

func get_target(t:Target):
	pass
