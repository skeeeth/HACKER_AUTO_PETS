extends Node2D
class_name CombatSimManager

enum BattlePhases 
{BATTLE_START, TURN_START, ATTACK, TURN_END, FAINT, BATTLE_END}

var current_battle_phase : BattlePhases
var current_phase_number : int = -1

## 5 is the number in SAP could change
@export var board_size : int = 5
#@export var ally_unit_data : Array[UnitData]
@export var enemy_unit_data : Array[UnitData]


const UNIT_SCENE = preload("uid://brlrr5c85a1dd")
@export var step_size: int

var player_won : bool = false
var enemy_won : bool = false
var combat_over : bool = false

## Stacks are FIFO, so index 0 is always the "combat front" unit,
## but are displayed visually as 4 and 5 from the left
var player_stack : Array[SimUnit]
var enemy_stack : Array[SimUnit]


func _ready() -> void:
	# should load from shop phase/encounter list but export works
	for d in PlayerUnitsContainer.ally_unit_list:
		player_stack.append(_create_unit(d))
	for d in enemy_unit_data:
		enemy_stack.append(_create_unit(d))
	
	_arrange_units()

func _create_unit(data:UnitData) -> SimUnit:
	var new_unit:SimUnit
	new_unit = UNIT_SCENE.instantiate()
	new_unit.dress(data)
	new_unit.died.connect(on_unit_death)
	add_child(new_unit)
	return new_unit


func _arrange_units():
	#should like tween to destination placements rather than just snap
	# and hold timeline until animation is finished
	for i in player_stack.size():
		player_stack[i].position.x =  (i+1) * -step_size 

	for i in enemy_stack.size():
		enemy_stack[i].position.x =  (i+1) * step_size 


func _input(event: InputEvent) -> void:
	#activates when you press the spacebar button
	#and when there is still players and enemies alive
	if event.is_action_pressed("ui_accept"):
		if combat_over == false:
			current_phase_number += 1 
			connect_number_to_phase()
			phase_action()
			#advance_step() #DEBUG hotkey
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
		advance_step()
	elif current_battle_phase == BattlePhases.TURN_END:
		print("Turn has ended")
	

#var effect_stack:Array[CombatEffect]
func advance_step():
	#will step though stack of triggers and hit 
	#when nothing else is active
	hit()

func hit():
	player_stack.front().health -= enemy_stack.front().attack
	enemy_stack.front().health -= player_stack.front().attack


func on_unit_death(dying_unit:SimUnit):
	#should probably put some kinda "faint" trigger onto the stack
	#and then do the following as a sort of cleanup step (or other order)?
	
	player_stack.erase(dying_unit)
	enemy_stack.erase(dying_unit)
	
	#maybe change this logic a bit to diff Win/Loss/Draw
	if player_stack.size() == 0 and enemy_stack.size() != 0:
		enemy_won = true
		end_combat()
	elif player_stack.size() != 0 and enemy_stack.size() == 0:
		player_won = true
		end_combat()
	elif player_stack.size() == 0 and enemy_stack.size() == 0:
		end_combat()

	_arrange_units()
	dying_unit.queue_free()
	pass


func end_combat():
	combat_over = true
	print("Combat Over")
