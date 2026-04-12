extends Node2D
class_name CombatSimManager

@export var board_size:int = 5 #5 is the number in SAP could change
@export var ally_unit_data:Array[UnitData]
@export var enemy_unit_data:Array[UnitData]

const UNIT_SCENE = preload("uid://brlrr5c85a1dd")
@export var step_size: int

#stacks are FIFO, so index 0 is always the "combat front" unit
# but are displayed visually as 4 and 5 from the left
var player_stack:Array[SimUnit]
var enemy_stack:Array[SimUnit]

func _ready() -> void:
	#should load from shop phase/encounter list but export works
	for d in ally_unit_data:
		player_stack.append(_create_unit(d))
	for d in enemy_unit_data:
		enemy_stack.append(_create_unit(d))
	
	_arrange_units()

#var effect_stack:Array[CombatEffect]
func advance_step():
	#will step though stack of triggers and hit when nothing else is active
	hit()

func end_combat():
	print("Combat Over")

func hit():
	player_stack.front().health -= enemy_stack.front().attack
	enemy_stack.front().health -= player_stack.front().attack
	
	

func on_unit_death(dying_unit:SimUnit):
	#should probably put some kinda "faint" trigger onto the stack
	#and then do the following as a sort of cleanup step (or other order)?
	
	player_stack.erase(dying_unit)
	enemy_stack.erase(dying_unit)
	
	#maybe change this logic a bit to diff Win/Loss/Draw
	if player_stack.size() == 0:
		end_combat()
	
	if enemy_stack.size() == 0:
		end_combat()
		
	_arrange_units()
	dying_unit.queue_free()
	pass

func _create_unit(data:UnitData):
	var new_unit:SimUnit
	new_unit = UNIT_SCENE.instantiate()
	new_unit.dress(data)
	new_unit.died.connect(on_unit_death)
	add_child(new_unit)
	return new_unit
	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		advance_step() #DEBUG hotkey


func _arrange_units():
	#should like tween to destination placements rather than just snap
	# and hold timeline until animation is finished
	for i in player_stack.size():
		player_stack[i].position.x =  (i+1) * -step_size 
	
	for i in enemy_stack.size():
		enemy_stack[i].position.x =  (i+1) * step_size 
