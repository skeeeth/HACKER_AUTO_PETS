extends Control

const UNIT_RESULTS_SCENE = preload("uid://bamkuetclphq2")

@export var turn_text_node : Label
@export var wins_text_node : Label
@export var life_text_node : Label

@export var unit_holder : HBoxContainer

var base_life_text : String
var base_turn_text : String
var base_wins_text : String

var player_stack : Array[CombatUnitControl]

var list_index : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	base_life_text = life_text_node.text
	base_turn_text = turn_text_node.text
	base_wins_text = wins_text_node.text
	
	life_text_node.text = base_life_text + str(Gamestate.lives)
	turn_text_node.text = base_turn_text + str(Gamestate.turn)
	wins_text_node.text = base_wins_text + str(Gamestate.wins) + "/" + str(Gamestate.max_wins)
	
	if PlayerUnitsContainer.ally_unit_list.size() != 0:
		_add_all_to_stack()

## This function calls the _add_to_stack function 
## for each unit in the PlayerUnitsContainer class
func _add_all_to_stack() -> void:
	for data in PlayerUnitsContainer.ally_unit_list:
		var new_unit : CombatUnitResults
		new_unit = UNIT_RESULTS_SCENE.instantiate()
		new_unit.dress(data, list_index)
		unit_holder.add_child(new_unit)
		unit_holder.move_child(new_unit,0)
		player_stack.append(new_unit)
		list_index += 1
	list_index = 0
