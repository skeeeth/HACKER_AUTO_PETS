extends Node2D
class_name CombatSimManager

enum BattlePhases 
{BATTLE_START, TURN_START, ATTACK, TURN_END, FAINT, BATTLE_END}

signal combat_start

var current_battle_phase : BattlePhases
var current_phase_number : int = -1

## 5 is the number in SAP could change
@export var board_size : int = 5
@export var ally_unit_data : Array[UnitData]
@export var enemy_unit_data : Array[UnitData]


const UNIT_SCENE = preload("uid://brlrr5c85a1dd")
@export var step_size: int

var player_won : bool = false
var enemy_won : bool = false
var combat_over : bool = false

## queues are FIFO, so index 0 is always the "combat front" unit,
## but are displayed visually as 4 and 5 from the left
var player_queue : Array[SimUnit]
var enemy_queue : Array[SimUnit]
##renamed from stack because stacks are literally FILO, mb -eth
##queue is the proper term for a FIFO data structure


var effect_stack:Array[Effect]
var dying_units:Array[SimUnit]

func _ready() -> void:
	# should load from shop phase/encounter list but export works
	for d in ally_unit_data:
		player_queue.append(_create_unit(d))
	for d in enemy_unit_data:
		enemy_queue.append(_create_unit(d))
	
	var all_units:Array[SimUnit] = player_queue.duplicate()
	all_units.append_array(enemy_queue)
	for u in all_units:
		u.effect.subscribe(all_units)
	
	combat_start.emit()
	_arrange_units()

func _create_unit(data:UnitData) -> SimUnit:
	var new_unit:SimUnit
	new_unit = UNIT_SCENE.instantiate()
	new_unit.dress(data)
	new_unit.died.connect(on_unit_death)
	new_unit.effect.manager = self
	#new_unit.effect.triggered.connect(on_effect_trigger)
	add_child(new_unit)
	return new_unit


func _arrange_units():
	#should like tween to destination placements rather than just snap
	# and hold timeline until animation is finished
	for i in player_queue.size():
		player_queue[i].position.x =  (i+1) * -step_size 

	for i in enemy_queue.size():
		enemy_queue[i].position.x =  (i+1) * step_size 


func _input(event: InputEvent) -> void:
	#activates when you press the spacebar button
	#and when there is still players and enemies alive
	if event.is_action_pressed("ui_accept"):
		if combat_over == false:
			current_phase_number += 1 
			connect_number_to_phase()
			#phase_action()
			advance_step() #DEBUG hotkey
		else:
			print("Combat has stopped already")

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

func phase_action():
	if current_battle_phase == BattlePhases.BATTLE_START:
		print("Battle has begun")
	elif current_battle_phase == BattlePhases.TURN_START:
		print("Turn has begun")
	elif current_battle_phase == BattlePhases.ATTACK:
		print("Time to attack")
		hit()
	elif current_battle_phase == BattlePhases.TURN_END:
		print("Turn has ended")
	

func advance_step():
	#will step though stack of triggers and hit 
	#when nothing else is active
	if effect_stack.size() > 0:
		var last_effect = effect_stack.pop_back()
		last_effect.resolve()
		#last_effect.resolved.connect(advance_step,4)
	else:
		cleanup()
		phase_action()

func hit():
	player_queue.front().take_damage(enemy_queue.front().attack)
	enemy_queue.front().take_damage(player_queue.front().attack)

func on_unit_death(dying_unit:SimUnit):
	dying_units.append(dying_unit)

##checks for dead bodies and removes them, only called when stack is empty
func cleanup():
	for dying_unit in dying_units:
		player_queue.erase(dying_unit)
		enemy_queue.erase(dying_unit)
		
		#maybe change this logic a bit to diff Win/Loss/Draw
		if player_queue.size() == 0 and enemy_queue.size() != 0:
			enemy_won = true
			end_combat()
		elif player_queue.size() != 0 and enemy_queue.size() == 0:
			player_won = true
			end_combat()
		elif player_queue.size() == 0 and enemy_queue.size() == 0:
			end_combat()

		_arrange_units()
		dying_unit.queue_free()
	
	dying_units.clear()
	
func trigger_effect(effect:Effect):
	effect_stack.append(effect)

func end_combat():
	combat_over = true
	print("Combat Over")
