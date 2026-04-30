extends Node

var purchaseable_units:Array[UnitData]
var food_pool:Array[FoodData]
var turn:int = 0
var turn_cadence = 2


var wins : int = 0

var tier:int = -1

var base_lives : int
@export var lives : int = 4

@export var tiers:Array[TierData]
@export var encounter_sequence:Array[Encounter]
@export var food_sequence:Array[FoodData]

func _ready() -> void:
	increase_tier()
	base_lives = lives
	food_pool = food_sequence

func increase_tier():
	if tier < tiers.size()-1:
		tier += 1
		for ud in tiers[tier].units: #ugly ass line of code wtf
			purchaseable_units.append(ud)
		#food_pool.append(food_sequence[tier])

func lose_life():
	lives -= 1

func log_win():
	wins += 1

func end_turn():
	turn += 1
	if turn % turn_cadence == 0:
		increase_tier()

func reset_game():
	turn = 0
	wins = 0
	lives = base_lives

func get_turn_encounter() -> Encounter:
	var read_turn = clamp(turn,0,encounter_sequence.size()-1)
	return encounter_sequence[read_turn]
