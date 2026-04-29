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
signal holder_changed(to:CombatUnitControl)

var shop_manager:ShopEffectManager
var data:EffectData
var holder:CombatUnitControl:
	set(v):
		holder = v
		holder_changed.emit(holder)

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
			var follow_holder = func fh(h:CombatUnitControl):
				new_effect.holder = h
			holder_changed.connect(follow_holder)
			resolved.connect(new_effect.trigger) #syncs
			add_child(new_effect) #move with parent

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
		var indicator = Indicator.create(data, absolute_index,
				x_spacing, holder.sprite.size.x, x_spacing)
		
		shop_manager.shop_main.add_child.call_deferred(indicator)
		indicator.drop()
		indicator.tree_exiting.connect(resolved.emit)
		
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
				resolve_stock()
				
	#resolved.emit()

func resolve_stock():
	assert(data.subresource)
	var new_food_data = FoodData.new()
	match data.subresource.effect_type:
		EffectData.EffectTypes.SHIFT:
			new_food_data.type = FoodData.food_types.SHIFT
			new_food_data.magnitude = data.subresource.magnitude
			new_food_data.display_string = ">>"
			
		##TODO GIVE, though nothing does that right now
	
	new_food_data.price = data.subresource.mag_mod
	
	shop_manager.shop_main.create_food(new_food_data)
