extends Node2D
class_name Effect

#signal triggered
signal resolved
signal shifted

var data : EffectData
var shift : int = 0:
	set(v):
		shift = v
		shifted.emit()
var modifier : int = 0 #modify-er? hardly even know her!
var manager : CombatSimManager
var holder : SimUnit
var sound_effect : AudioStream

var target_units:Array[SimUnit]
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
func subscribe():
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
		
		EffectData.TriggerStates.FAINT:
			holder.died.connect(trigger.unbind(1))
			
		EffectData.TriggerStates.TURN_END:
			manager.turn_end.connect(trigger)
			
		EffectData.TriggerStates.SHOP_START:
			assert(manager)
		
		EffectData.TriggerStates.SHOP_END:
			assert(manager)

func trigger():
	visible = true
	manager.trigger_effect(self)
	#set_targets()
	print(data.name + " Triggered")
	#TEMP, replace with more sophisticated art later
	holder.position.y -= 40 #bump unit up to show its active

func resolve():
	
	#Play sound effect
	SoundManager.play_sound(sound_effect)
	
	var animation = self.create_tween()
	animation.set_parallel()
	
	var fizzled = true ##true until proven otherwise
	
	set_targets()
	for target in target_units:
		#var target = _get_target_unit(t)
		#if !target: continue #fails if target not found
		
		#if target found even once, not fizzled
		fizzled = false
		animation.tween_property(self,"position:y",40,0.1).set_ease(Tween.EASE_IN_OUT)
		animation.tween_property(self,"position:y",-20,0.1).set_ease(Tween.EASE_IN_OUT)
		animation.tween_property(self,"position:y",0,0.1).set_ease(Tween.EASE_IN_OUT)
		
		match data.effect_type:
			EffectData.EffectTypes.GIVE:
				resolve_give(target)
				
			EffectData.EffectTypes.DAMAGE:
				target.take_damage(get_magnitude())
				
			EffectData.EffectTypes.APPLY:
				assert(data.subresource) #ASSIGN A SUBRESOURCE
				add_effect(target,data.subresource)
				
			EffectData.EffectTypes.SHIFT:
				target.effect.shift += get_magnitude()
				
			EffectData.EffectTypes.SUMMON:
				resolve_summon()
			
			EffectData.EffectTypes.SIGNAL:
				##literally just do  the thing for now its chill
				manager.turn_start.emit()
				## not a great solution, but whatever it handles
				## this edge case, maybe if this were a more common
				## effect I would make a huge signal enum or something
				#assert(data.magnitude_type == EffectData.MagnitudeTypes.CUSTOM)
				#get_magnitude()
	
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
	
	#if data.trigger_state == EffectData.TriggerStates.FAINT:
		#manager.cleanup()

	#animation.tween_callback(resolved.emit)
	print("Resolved " + data.name)
	resolved.emit()
	holder.position.y += 40 #reset
	#visible = false


func set_targets():
	target_units.clear()
	var is_player_side : bool = manager.player_queue.has(holder)
	var ally_queue:Array
	if is_player_side:
		ally_queue = manager.player_queue
	else:
		ally_queue = manager.enemy_queue
		
	var my_index = ally_queue.find(holder)
	for t in data.targets:
		var i = get_index_from_target(t,is_player_side,my_index,shift)
		try_target_index(i)


##returns an int equal to the absolute index to be gotten from a Target resource
#should maybe be part of Target class if anything, but adapted from an old Effect func
static func get_index_from_target(t:Target,is_player_side:bool,my_index:int,with_shift:int) -> int:
	var target_index : int = my_index
	match t.type:
		Target.TargetCodes.S:
			if is_player_side:
				target_index = 5 - my_index
				target_index += t.value + with_shift
			else:
				target_index = 6 + my_index
				target_index -= t.value + with_shift
		Target.TargetCodes.O:
			if is_player_side:
				target_index = 6 + my_index
				target_index += t.value + with_shift
			else:
				target_index = 5 - my_index
				target_index -= t.value + with_shift
		Target.TargetCodes.A:
			target_index = t.value + with_shift
		Target.TargetCodes.STRICT_SELF:
			if is_player_side:
				target_index = 5 - my_index
			else:
				target_index = 6 + my_index
	
	print(target_index)
	return target_index

##sets target_units_array
func try_target_index(target_index:int) ->  void:
	
	var indicator_:Indicator = Indicator.create(data, target_index,
			manager.step_size, holder.sprite.size.x)
	
	resolved.connect(indicator_.drop)
	manager.add_child(indicator_)
	
	var target_queue:Array
	if target_index <= 5:
		target_index = 5 - target_index
		target_queue = manager.player_queue
	else:
		target_index = target_index - 6
		target_queue = manager.enemy_queue


	
	if target_index >= target_queue.size():
		#fails if target is too far
		#print(data.name + str(target_index))
		return

	target_units.append(target_queue[target_index])


#func _get_target_unit(t:Target) -> SimUnit:
	#var is_player_side : bool = manager.player_queue.has(holder)
	#var ally_queue:Array
	#@warning_ignore("unused_variable")
	#var opp_queue:Array
	#if is_player_side:
		#ally_queue = manager.player_queue
		#opp_queue = manager.enemy_queue
	#else:
		#ally_queue = manager.enemy_queue
		#opp_queue = manager.player_queue
		#
	#var my_index = ally_queue.find(holder)
	#var target_index:int = my_index #- t.value - shift
	##elbow_one = holder.position + Vector2(0,-100)
	##elbow_two = target_unit.position + Vector2(0,-100)
	##queue_redraw()
	#return target_unit

	#if target_index < 0: #if reaching other side
		##flip to opp context
		#target_index *= -1 
		#target_index -= 1 #1st opp is its index 0
		#
		#if target_queue == opp_queue:
			#target_queue = ally_queue
		#else:
			#target_queue = ally_queue

func resolve_give(target):
	target.attack += get_magnitude()
	target.health += get_magnitude() + data.mag_mod
	
func resolve_summon():
	assert(data.subresource,"ASSIGN A SUBRESOURCE")
	##setup new unit data
	var new_data:UnitData = UnitData.new()
	new_data.unit_name = data.subresource.name #yeah idk where to pass this in
	new_data.attack = get_magnitude()
	new_data.health = get_magnitude() + data.mag_mod
	new_data.effect = data.subresource
	
	## Create new unit and place it into appropriate queue
	var new_unit = manager._create_unit(new_data) #lmao we out here accessing a private method oops
	var is_player_side : bool = manager.player_queue.has(holder)
	var target_queue:Array[SimUnit]
	
	if is_player_side:
		target_queue = manager.player_queue
	else:
		target_queue = manager.enemy_queue
	
	var index = target_queue.find(holder)
	target_queue.insert(index,new_unit)
	new_unit.effect.subscribe()
	manager._arrange_units()

func get_magnitude() -> int:
	match data.magnitude_type:
		EffectData.MagnitudeTypes.RAW:
			return data.magnitude + modifier
		EffectData.MagnitudeTypes.ATTACK:
			return holder.attack #could use mag_mod as a coeffecient here 
		EffectData.MagnitudeTypes.HEALTH:
			return holder.health
		EffectData.MagnitudeTypes.SHIFT:
			return shift
		EffectData.MagnitudeTypes.CUSTOM:
			##hmmmmmm idk about this
			
			return 0 #0 for now
		_: ##default
			##this shouldn't come up, but it is necessary
			## to appease compiler
			assert(false, "Magnitude type not found")
			return 67
			
func add_effect(target:SimUnit,effect_data_:EffectData):
	var new_effect = Effect.new()
	new_effect.holder = target
	new_effect.data = effect_data_
	new_effect.manager = manager
	target.add_child(new_effect)
	
	new_effect.subscribe()
