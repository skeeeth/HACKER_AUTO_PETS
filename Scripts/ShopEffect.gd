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
signal resolved

var shop_manager:ShopEffectManager
var data:EffectData
var holder:CombatUnitControl
var targets : Array[CombatUnitControl]

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

func set_targets():
	var unit_stack = shop_manager.shop_main.get_unit_stack()
	var my_index = unit_stack.find(holder)
	for t in data.targets:
		
		var x_spacing = 150 #shop_manager.shop_main.unit_holder.theme.get_constant("separation")
		#x_spacing = holder.size.x
		var absolute_index = Effect.get_index_from_target(t,true,my_index,holder.shift)
		var indicator = Indicator.create(data.effect_type,absolute_index,
				x_spacing,holder.size.x,+x_spacing)
		
		shop_manager.add_child(indicator)
		
		var i = 5 - absolute_index
		if i < 0 or i >= 5:
			continue
		
		if i >= unit_stack.size():
			continue
		
		targets.append(unit_stack[i])

func resolve():
	#var indicator = Indicator.create(self,)
	#shop_manager.add_child()
	set_targets()
	for target in targets:
		#var target = get_target(t)
		#if !target:
			#continue
		match data.effect_type:
			##ok im pretty sure these are the only 2 things that need to happen in shop
			## everything else is TODO to be implemented
			## but also just fix the inheritance at that point
			
			EffectData.EffectTypes.GIVE:
				target.attack += data.magnitude
				target.health += data.magnitude + data.mag_mod
			EffectData.EffectTypes.SHIFT:
				target.shift += data.magnitude #modifer???
			EffectData.EffectTypes.STOCK:
				pass
				
	resolved.emit()
