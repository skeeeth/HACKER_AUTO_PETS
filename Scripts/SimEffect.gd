extends Node2D
class_name Effect

#signal triggered
signal resolved

var data : EffectData
var shift : int = 0
var modifier : int = 0 #modify-er? hardly even know her!
var manager : CombatSimManager
var holder : SimUnit

#var elbow_one:Vector2 = Vector2.ZERO
#var elbow_two:Vector2 = Vector2.ZERO
#const DRAW_DROP:float = 50
#const LINE_WIDTH:float = 5
#
#func _draw() -> void:
	#var drop_vector = Vector2(0,DRAW_DROP)
	#draw_line(elbow_one,elbow_two,Color.BLACK,LINE_WIDTH)
	#draw_line(elbow_one,elbow_one+drop_vector,Color.BLACK,LINE_WIDTH)
	#draw_line(elbow_two,elbow_two+drop_vector,Color.BLACK,LINE_WIDTH)

##Connect to the appropriate triggers
@warning_ignore("unused_parameter")
func subscribe(units:Array[SimUnit]):
	if data.subresource:
		if data.sub_type == EffectData.SUBEFFECT_TYPES.EXTRA_EFFECT:
			##instance and sync
			pass
	 
	match data.trigger_state:
		EffectData.TriggerStates.BATTLE_START:
			manager.combat_start.connect(trigger)
		
		EffectData.TriggerStates.HURT:
			holder.hurt.connect(trigger)
		
		EffectData.TriggerStates.B_ATTACK:
			holder.attack_queued.connect(trigger)
		
		EffectData.TriggerStates.TURN_START:
			manager.turn_start.connect(trigger)
		

func trigger():
	visible = true
	manager.trigger_effect(self)
	print(data.name + " Triggered")
	#TEMP, replace with more sophisticated art later
	holder.position.y -= 40 #bump unit up to show its active

func resolve():
	var animation = self.create_tween()
	animation.set_parallel()
	
	var fizzled = true ##true until proven otherwise
	
	for t in data.targets:
		var target = _get_target_unit(t)
		if !target: continue #fails if target not found
		
		#if target found even once, not fizzled
		fizzled = false
		
		var indicator_:Indicator = Indicator.create(self,target)
		target.add_child(indicator_)
		animation.tween_property(indicator_,"position:y",0,0.1).set_ease(Tween.EASE_IN_OUT)
		
		match data.effect_type:
			EffectData.EffectTypes.GIVE:
				resolve_give(target)
				
			EffectData.EffectTypes.DAMAGE:
				target.take_damage(get_magnitude())
				
			EffectData.EffectTypes.APPLY:
				assert(data.subresource) #ASSIGN A SUBRESOURCE
				add_effect(target,data.subresource)
	
	if fizzled:
		animation.set_parallel(false)
		var start = holder.position.x
		var wiggle_size:float = 20
		var wiggle_direction:int = -1
		var wiggle_scale:float = 1.0
		for i in range(0,5):
			var wiggle = wiggle_size*wiggle_direction*wiggle_scale
			wiggle_direction *= -1
			animation.tween_property(holder,"position:x",
			start + wiggle,0.06*wiggle_scale)
			wiggle_scale *= 0.75
		
		animation.tween_property(holder,"position:x",start,0.06)
	
	await animation.finished
	#animation.tween_callback(resolved.emit)
	print("Resolved " + data.name)
	resolved.emit()
	holder.position.y += 40 #reset
	#visible = false


func _get_target_unit(t:Target) -> SimUnit:
	var is_player_side : bool = manager.player_queue.has(holder)
	var ally_queue:Array
	@warning_ignore("unused_variable")
	var opp_queue:Array
	if is_player_side:
		ally_queue = manager.player_queue
		opp_queue = manager.enemy_queue
	else:
		ally_queue = manager.enemy_queue
		opp_queue = manager.player_queue
		
	var my_index = ally_queue.find(holder)
	var target_index:int = my_index #- t.value - shift
	var target_queue:Array
	match t.type:
		Target.TargetCodes.S:
			if is_player_side:
				target_index = 5 - my_index
				target_index += t.value + shift
			else:
				target_index = 6 + my_index
				target_index -= t.value + shift
		Target.TargetCodes.O:
			if is_player_side:
				target_index = 6 + my_index
				target_index += t.value + shift
			else:
				target_index = 5 - my_index
				target_index -= t.value + shift
		Target.TargetCodes.A:
			target_index = t.value + shift
	
	if target_index <= 5:
		target_index = 5 - target_index
		target_queue = manager.player_queue
	else:
		target_index = target_index - 6
		target_queue = manager.enemy_queue

	if target_index >= target_queue.size():
		#fails if target is too far
		#print(data.name + str(target_index))
		return null
		
	var target_unit:SimUnit = target_queue[target_index]
	#elbow_one = holder.position + Vector2(0,-100)
	#elbow_two = target_unit.position + Vector2(0,-100)
	#queue_redraw()
	return target_unit

	#if target_index < 0: #if reaching other side
		##flip to opp context
		#target_index *= -1 
		#target_index -= 1 #1st opp is its index 0
		#
		#if target_queue == opp_queue:
			#target_queue = ally_queue
		#else:
			#target_queue = ally_queue

func resolve_give(target:SimUnit):
	target.attack += get_magnitude()
	target.health += get_magnitude() + data.mag_mod


func get_magnitude() -> int:
	match data.magnitude_type:
		EffectData.MagnitudeTypes.RAW:
			return data.magnitude + modifier
		EffectData.MagnitudeTypes.ATTACK:
			return holder.attack #could use mag_mod as a coeffecient here 
		EffectData.MagnitudeTypes.HEALTH:
			return holder.health
		EffectData.MagnitudeTypes.CUSTOM:
			##hmmmmmm idk about this
			## if it comes up will have to be its own switch
			return 0 #0 for now
		_: ##default
			##this shouldn't come up, but it is necessary
			## to appease compiler
			return 67
			
func add_effect(target:SimUnit,effect_data_:EffectData):
	var new_effect = Effect.new()
	new_effect.holder = target
	new_effect.data = effect_data_
	new_effect.manager = manager
	target.add_child(new_effect)
	
	#smelly copy-pasted code hmmm :/ idk should work and be fine
	var all_units:Array[SimUnit] = manager.player_queue.duplicate()
	all_units.append_array(manager.enemy_queue)
	
	new_effect.subscribe(all_units)
