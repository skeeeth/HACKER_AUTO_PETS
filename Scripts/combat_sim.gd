extends Node2D
class_name CombatSimManager

enum BattlePhases 
{BATTLE_START, TURN_START, ATTACK, TURN_END, FAINT, BATTLE_END}

signal combat_start
signal turn_start
signal turn_end

var current_battle_phase : BattlePhases
var current_phase_number : int = -1
const UNIT_SCENE = preload("uid://brlrr5c85a1dd")

## 5 is the number in SAP could change
@export var board_size : int = 5

#@export var ally_unit_data : Array[UnitData]

@export var encounter : Encounter
var enemy_unit_data : Array[UnitData]

## This variable is for spacing the units
@export var step_size : int
@export var next_scene_button_node : Button
@export var combat_timer : Timer

@export var lose_scene_path : String
@export var win_scene_path : String

var player_won : bool = false
var enemy_won : bool = false
var combat_over : bool = false

## queues are FIFO, so index 0 is always the "combat front" unit,
## but are displayed visually as 4 and 5 from the left
var player_queue : Array[SimUnit]
var enemy_queue : Array[SimUnit]
##renamed from stack because stacks are literally FILO, mb -eth
##queue is the proper term for a FIFO data structure

#var effect_stack:Array[CombatEffect]

var effect_stack:Array[Effect]
var dying_units:Array[SimUnit]

func _ready() -> void:
	MusicManager.combat_entered()
	
	next_scene_button_node.visible = false
	encounter = Gamestate.get_turn_encounter()
	enemy_unit_data = encounter.unit_data
	# should load from shop phase/encounter list but export works
	for d in PlayerUnitsContainer.ally_unit_list:
		player_queue.append(_create_unit(d))
	for d in enemy_unit_data:
		enemy_queue.append(_create_unit(d))
	
	var all_units = get_all_units()
	#reverse sort units by attack before subscribing.
	# nodes trigger on the same signal in the order 
	# they're connected, 
	# so the last to subscribe(highest attack) will be first in stack
	var reverse_attack_sort = func atk_sort(one:SimUnit,two:SimUnit) -> bool:
		return (one.attack < two.attack)
	all_units.sort_custom(reverse_attack_sort)
	
	for u in all_units:
		u.effect.subscribe()
	
	#combat_start.emit()
	_arrange_units()
	
	combat_timer.start()

func _process(delta: float) -> void:
	#$Timer/TimerText.text = str(combat_timer.time_left)
	pass


func get_all_units() -> Array[SimUnit]:
	var all_units:Array[SimUnit] = player_queue.duplicate()
	all_units.append_array(enemy_queue)
	return all_units

## This function creates a new CombatUnit scene 
## and spawns it into the level. Then, it sets the data perameter
## into the new CombatUnit scene and connects the on_unit_death function
## to the died signal. This function returns the new CombatUnit scene.
func _create_unit(data:UnitData) -> SimUnit:
	var new_unit : SimUnit
	new_unit = UNIT_SCENE.instantiate()
	new_unit.dress(data)
	new_unit.died.connect(on_unit_death)
	new_unit.effect.manager = self
	#new_unit.effect.triggered.connect(on_effect_trigger)
	add_child(new_unit)
	return new_unit

## This function sets the positions of the units
func _arrange_units():
	var slide = self.create_tween()
	#should like tween to destination placements rather than just snap
	# and hold timeline until animation is finished
	for i in player_queue.size():
		slide.tween_property(player_queue[i],"position:x",(i+1) * -step_size,0.1)
		#player_queue[i].position.x =  (i+1) * -step_size 

	for i in enemy_queue.size():
		slide.tween_property(enemy_queue[i],"position:x",(i+1) * step_size,0.1)
		enemy_queue[i].position.x =  (i+1) * step_size 

## This function is called when the player presses the spacebar button.
## This goes through the battle phases.
#func _input(event: InputEvent) -> void:
	#activates when you press the spacebar button
	#and when there is still players and enemies alive
	#if event.is_action_pressed("ui_accept"):
		#if combat_over == false:
			#phase_action()
			#advance_step() #DEBUG hotkey
		#else:
			#print("Combat has stopped already")

func _on_combat_timer_timeout() -> void:
	if combat_over == false:
		#phase_action()
		advance_step() #DEBUG hotkey
		combat_timer.start()
	else:
		combat_timer.stop()
		print("Combat has stopped already")

## This function sets the current battle phase based on the phase number
func connect_number_to_phase():
	if current_phase_number == 0:
		current_battle_phase = BattlePhases.BATTLE_START
	elif current_phase_number == 1:
		current_battle_phase = BattlePhases.TURN_START
	elif current_phase_number == 2:
		current_battle_phase = BattlePhases.ATTACK
	elif current_phase_number == 3:
		current_battle_phase = BattlePhases.TURN_END
	elif current_phase_number == 4:
		current_phase_number = 1
		current_battle_phase = BattlePhases.TURN_START

## This function executes the action for each battle phase
func phase_action():
	if current_battle_phase == BattlePhases.BATTLE_START:
		combat_start.emit()
	elif current_battle_phase == BattlePhases.TURN_START:
		print("Turn has begun")
		turn_start.emit()
	elif current_battle_phase == BattlePhases.ATTACK:
		print("Time to attack")
		player_queue.front().attack_queued.emit()
		enemy_queue.front().attack_queued.emit()
	elif current_battle_phase == BattlePhases.TURN_END:
		turn_end.emit()
		print("Turn has ended")

## This function calls the hit function
func advance_step():
	#will step though stack of triggers and hit 
	#when nothing else is active
	if effect_stack.size() > 0:
		var last_effect = effect_stack.pop_back()
		last_effect.resolve()
		#last_effect.resolved.connect(advance_step,4)
	elif dying_units.size() > 0:
		cleanup()
	else:
		if current_battle_phase == BattlePhases.ATTACK: 	##hit on appropriate phase
			hit()										## otherise just move on

		current_phase_number += 1 
		connect_number_to_phase()
		phase_action()

## This function executes the attack phase 
## and reduces the units' health accordingly 
func hit():
	print("Attacking")
	var player_unit = player_queue.front()
	var enemy_unit = enemy_queue.front()

	## animation lambda
	var attack_animation = func animate(unit:SimUnit,max_translation:float,max_rotation:float):
		
		var attack_tween = create_tween()
		var starting_position = unit.position.x
		
		#windup
		attack_tween.tween_property(unit,"position:x",
				starting_position + max_translation*-0.25,0.1).set_ease(Tween.EASE_IN)
		#attack_tween.parallel().tween_property(unit,"rotation",max_rotation*-0.333,0.1)
		
		#action
		attack_tween.tween_property(unit,"position:x",
				starting_position + max_translation,0.03).set_delay(0.1)
		#attack_tween.parallel().tween_property(unit,"rotation",max_rotation,0.05)
		
		attack_tween.tween_callback(SoundManager.play_sound_from_path.bind("res://Assets/Sound Effects/Fireball.mp3"))
		
		
		#recovery
		attack_tween.tween_property(unit,"position:x",
				starting_position,0.2).set_delay(0.1).set_ease(Tween.EASE_OUT)
		#attack_tween.parallel().tween_property(unit,"rotation",0,0.2).set_delay(0.1).set_ease(Tween.EASE_OUT)
	
	#call animation
	attack_animation.call(player_unit,+80,+0.2)
	attack_animation.call(enemy_unit ,-80,-0.2)
	
	player_unit.take_damage(enemy_unit.attack,true)
	enemy_unit.take_damage(player_unit.attack,true)

func on_unit_death(dying_unit:SimUnit):
	dying_units.append(dying_unit)

##checks for dead bodies and removes them, only called when stack is empty
func cleanup():
	for dying_unit in dying_units:
		await dying_unit.death_squeeze()
		player_queue.erase(dying_unit)
		enemy_queue.erase(dying_unit)
		
		dying_unit.queue_free()
	
	_arrange_units()
	dying_units.clear()
	
	#maybe change this logic a bit to diff Win/Loss/Draw
	if player_queue.size() == 0 and enemy_queue.size() != 0:
		enemy_won = true
		Gamestate.lose_life()
		
		if Gamestate.lives == 0:
			get_tree().change_scene_to_file(lose_scene_path)
			MusicManager.results_screen_entered()
		else:
			end_combat()
	elif player_queue.size() != 0 and enemy_queue.size() == 0:
		player_won = true
		Gamestate.log_win()
		
		if Gamestate.wins == Gamestate.max_wins:
			get_tree().change_scene_to_file(win_scene_path)
			MusicManager.results_screen_entered()
		else:
			end_combat()
			
	elif player_queue.size() == 0 and enemy_queue.size() == 0:
		end_combat()

func trigger_effect(effect:Effect):
	effect_stack.append(effect)

## This function shows the button to move to the shop scene.
func end_combat():
	combat_over = true
	Gamestate.end_turn()

	next_scene_button_node.visible = true
	print("Combat Over")
