extends Node

var purchaseable_units:Array[UnitData]
var food_pool:Array[FoodData]
var turn:int = 0
var turn_cadence = 2

var lives:int = 4

var tier:int = -1
@export var tiers:Array[TierData]
@export var encounter_sequence:Array[Encounter]
@export var food_sequence:Array[FoodData]

func _ready() -> void:
	increase_tier()
	food_pool = food_sequence

func increase_tier():
	if tier < tiers.size()-1:
		tier += 1
		for ud in tiers[tier].units: #ugly ass line of code wtf
			purchaseable_units.append(ud)
		#food_pool.append(food_sequence[tier])

func lose_life():
	lives -= 1
	
func end_turn():
	turn += 1
	if turn % turn_cadence == 0:
		increase_tier()
	
func get_turn_encounter() -> Encounter:
	var read_turn = clamp(turn,0,encounter_sequence.size()-1)
	return encounter_sequence[read_turn]
