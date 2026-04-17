extends Node
class_name Effect

#signal triggered
signal resolved

var data : EffectData
var shift : int = 0
var modifier : int = 0 #modify-er? hardly even know her!
var manager : CombatSimManager
var holder : SimUnit

##Connect to the appropriate triggers
@warning_ignore("unused_parameter")
func subscribe(units:Array[SimUnit]):
	match data.trigger_state:
		EffectData.TriggerStates.BATTLE_START:
			manager.combat_start.connect(trigger)
		
		EffectData.TriggerStates.HURT:
			holder.hurt.connect(trigger)

func trigger():
	manager.trigger_effect(self)
	
	#TEMP, replace with more sophisticated art later
	holder.position.y -= 40 #bump unit up to show its active

func resolve():
	for t in data.targets:
		var target = _get_target_unit(t)
		if !target: return #fails if target not found
		match data.effect_type:
			EffectData.EffectTypes.GIVE:
				resolve_give(target)
	
	resolved.emit()
	holder.position.y += 40 #reset

func _get_target_unit(t:Target) -> SimUnit:
	var is_player_side : bool = manager.player_queue.has(holder)
	var ally_queue:Array
	var opp_queue:Array
	if is_player_side:
		ally_queue = manager.player_queue
		opp_queue = manager.enemy_queue
	else:
		ally_queue = manager.enemy_queue
		opp_queue = manager.player_queue
		
	var my_index = ally_queue.find(holder)
	var target_index:int
	var target_queue = ally_queue
	match t.type:
		Target.TargetCodes.S:
			
			target_index = my_index - t.value - shift
			
			if target_index < 0: #if reaching other side
				#flip to opp context
				target_index *= -1 
				target_queue = opp_queue
				
				target_index -= 1 #1st opp is its index 0
			
			if target_index >= target_queue.size():
				#fails if target is too far
				return null 
				
		Target.TargetCodes.O:
			pass
		Target.TargetCodes.A:
			pass
			
	return target_queue[target_index]

func resolve_give(target:SimUnit):
	target.attack += data.magnitude
	target.health += data.magnitude - data.give_difference
