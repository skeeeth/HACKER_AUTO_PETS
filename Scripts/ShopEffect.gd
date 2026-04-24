##The fact that this script is so similar to SimEffect is evidence that
## the inheritance structure of the project should probably be changed
## but this was quick and dirty
## having this inherit simeffect doesn't work right now unless
## CombatUnitControl inherited from CombatUnit and
## ShopEffectManager inherited from CombatManager
## (or had common anscestors is probably better)
extends Node
class_name ShopEffect

signal triggered

var shop_manager:ShopEffectManager
var data:EffectData
var holder:CombatUnitControl

func subscribe(manager:ShopEffectManager):
	shop_manager = manager
	match data.trigger_state:
		EffectData.TriggerStates.SHOP_START:
			shop_manager.shop_entered.connect(trigger)
		
		EffectData.TriggerStates.SHOP_END:
			shop_manager.shop_ending.connect(trigger)

	if data.subresource:
		if data.sub_type == EffectData.SUBEFFECT_TYPES.EXTRA_EFFECT:
			var new_effect = ShopEffect.new()
			new_effect.holder = holder
			new_effect.data = data.subresource
			new_effect.shop_manager = shop_manager
			triggered.connect(new_effect.trigger) #syncs
			add_sibling(new_effect)

func trigger():
	shop_manager.effect_stack.append(self)
	triggered.emit()

func resolve():
	for t in data.targets:
		var target = get_target(t)
		if !target:
			continue
		match data.effect_type:
			##ok im pretty sure these are the only 2 things that need to happen in shop
			## everything else is TODO to be implemented
			## but also just fix the inheritance at that point
			
			EffectData.EffectTypes.GIVE:
				target.attack += data.magnitude
				target.health += data.magnitude + data.mag_mod
			EffectData.EffectTypes.SHIFT:
				target.shift += data.magnitude #modifer???

func get_target(t:Target) -> CombatUnitControl:
	var unit_stack = shop_manager.shop_main.get_unit_stack()
	var my_index = unit_stack.find(holder)
	assert(my_index != -1, "Effect called outside the club?")
	var target_index:int = 0
	match t.type:
		Target.TargetCodes.O:
			#technically this should be supported in engine, like target O with -shift
			# could hit team, but i dont have any SHOP effects with target O
			# so im pretty sure this isn't even going to be called, and null is fine
			# if it does get called
			return null
		Target.TargetCodes.STRICT_SELF:
			return holder
		Target.TargetCodes.S:
			target_index = my_index - t.value + holder.shift
		Target.TargetCodes.A:
			target_index = t.value + holder.shift
	target_index -= 5
	if target_index < 0 or target_index >= 5:
		return null
	
	if target_index >= unit_stack.size():
		return null
	return unit_stack[target_index]
