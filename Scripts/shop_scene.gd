extends Node2D
class_name ShopManager

const UNIT_CONTROL_SCENE = preload("uid://cuol4iet7e1w2")

@export var combat_scene_file_path : String

@export var purchasable_units : Array[UnitData]
@export var purchase_buttons : Array[PurchaseButton]
@export var coins : int = 10
@export var unit_cost : int = 3
@export var coin_text_node : Label
@export var life_text_node : Label
@export var turn_text_node : Label
@export var wins_text_node : Label

@export var unit_holder : HBoxContainer
@export var effect_manager:ShopEffectManager
@export var info_display:InfoDisplay
var food_pool:Array[FoodData]

@onready var combat_scene_button: Button = $Buttons/CombatSceneButton
@onready var item_list: ItemList = $"Shop Panel/HBoxContainer/ItemList"


var base_coin_text : String
var base_life_text : String
var base_turn_text : String
var base_wins_text : String

var player_stack : Array[CombatUnitControl]

var list_index : int = 0
var shop_data:Array[UnitData]

func _ready() -> void:
	base_coin_text = coin_text_node.text
	base_life_text = life_text_node.text
	base_turn_text = turn_text_node.text
	base_wins_text = wins_text_node.text
	
	life_text_node.text = base_life_text + str(Gamestate.lives)
	turn_text_node.text = base_turn_text + str(Gamestate.turn)
	wins_text_node.text = base_wins_text + str(Gamestate.wins) + "/" + str(Gamestate.max_wins)
	
	_set_coin_text()

	if PlayerUnitsContainer.ally_unit_list.size() != 0:
		_add_all_to_stack()
	
	purchasable_units.clear()
	purchasable_units = Gamestate.purchaseable_units
	_set_buttons()
	restock_shop()
	item_list.item_activated.connect(on_shop_item_activated)
	item_list.item_clicked.connect(on_shop_item_selected)
	
	food_pool = Gamestate.food_pool
	create_food(food_pool.pick_random())
	
	effect_manager.shop_entered.emit()
	effect_manager.resolve_effects()
	
	MusicManager.shop_entered()

## This function adds the unit data to the shop player stack
func _add_to_stack(data : UnitData) -> void:
	var unit : CombatUnitControl = _create_unit(data)
	player_stack.append(unit)

## This function calls the _add_to_stack function 
## for each unit in the PlayerUnitsContainer class
func _add_all_to_stack() -> void:
	for data in PlayerUnitsContainer.ally_unit_list:
		_create_unit(data)
		#var new_unit : CombatUnitControl
		#new_unit = UNIT_CONTROL_SCENE.instantiate()
		#new_unit.dress(data, list_index)
		#new_unit.effect_node.subscribe(effect_manager)
		#unit_holder.add_child(new_unit)
		#unit_holder.move_child(new_unit,0)
		#player_stack.append(new_unit)
		#list_index += 1
	#list_index = 0

## This function creates a new CombatUnit scene 
## and spawns it into the level. Then, it sets the data perameter
## into the new CombatUnit scene and adds it to the Unit Holder Node
func _create_unit(data:UnitData) -> CombatUnitControl:
	var new_unit : CombatUnitControl
	new_unit = UNIT_CONTROL_SCENE.instantiate()
	new_unit.dress(data, PlayerUnitsContainer.ally_unit_list.size() - 1)
	new_unit.clicked.connect(info_display.set_info)
	for i in range(4,-1,-1):
		var panel = unit_holder.get_child(i)
		if panel.get_children().size() == 0:
			panel.add_child(new_unit)
			#unit_holder.move_child(panel, 0)
			break
	#unit_holder.add_child(new_unit)

	new_unit.effect_node.subscribe(effect_manager)
	return new_unit

func create_food(food_data:FoodData):
	var new_food = Food.create(food_data)
	new_food.shop = self
	%FoodContainer.add_child(new_food)

func create_shop_item(from_data:UnitData):
	item_list.add_item(from_data.unit_name)
	shop_data.append(from_data.duplicate())

func on_shop_item_activated(index:int):
	item_list.remove_item(index)
	purchase_unit(shop_data[index])
	shop_data.remove_at(index)
	
func restock_shop():
	shop_data.clear()
	item_list.clear()
	for i in range(3):
		create_shop_item(purchasable_units.pick_random())

func on_shop_item_selected(index:int, at_position, _button):
	info_display.set_info(shop_data[index])

func _set_coin_text() -> void:
	coin_text_node.text = base_coin_text + str(coins)

## This function adds a unit to the Player Unit Container class 
## based on the button pressed. 
## If there are not enough coins or space, the unit is not purchased.
func purchase_unit(unit:UnitData) -> void:
	if PlayerUnitsContainer.ally_unit_list.size() != PlayerUnitsContainer.ARRAY_MAX_SIZE:
		if coins >= unit_cost:
			PlayerUnitsContainer.add_unit_to_list(unit)
			_add_to_stack(unit)
			reduce_coin(unit_cost)
	else:
		print("Size full")


func sell() -> void:
	increase_coin(1)
	
func reduce_coin(price : int) -> void:
	coins -= price
	_set_coin_text()

func increase_coin(sell_price : int) -> void:
	coins += sell_price
	_set_coin_text()

func _go_to_combat_scene() -> void:
	if PlayerUnitsContainer.ally_unit_list.size() != 0:
		effect_manager.end_combat()
		await effect_manager.ending_resolved
		save_stats_to_data()
		get_tree().change_scene_to_file(combat_scene_file_path)
	elif PlayerUnitsContainer.ally_unit_list.size() == 0 and coins < 3:
		print("No units and no coins? Here is some money.")
		coins = unit_cost
		_set_coin_text()
		pass
		
func _reroll() -> void:
	if coins != 0:
		reduce_coin(1)
		_set_buttons()
		restock_shop()
		for f in %FoodContainer.get_children():
			f.queue_free()
		create_food(food_pool.pick_random())

func _set_buttons() -> void:

	for button in purchase_buttons:
		var random_unit_num : int = randi_range(0, purchasable_units.size() - 1)
		button.add_unit_to_button(purchasable_units[random_unit_num])


func move_unit(unit : CombatUnitControl, direction : int) -> void:
	print(unit.name_label.text, ": ", unit.object_index - 1)
	if direction == -1:
		unit_holder.move_child(unit, unit.get_index() - 1)
		print(unit.name_label.text, ": ", unit.object_index)
	else:
		unit_holder.move_child(unit, unit.get_index() + 1)
		print(unit.name_label.text, ": ", unit.object_index)


func save_stats_to_data():
	PlayerUnitsContainer.ally_unit_list.clear()
	
	#iterating on unit holder has less type safety than player stack
	# but player stack doesn't reflect movement
	for u in get_unit_stack():
		#u.unit_data.attack = u.attack
		#u.unit_data.health = u.health
		#u.unit_data.shift  = u.shift
		PlayerUnitsContainer.add_unit_to_list(u.unit_data)

func get_unit_stack() -> Array[CombatUnitControl]:
	var stack:Array[CombatUnitControl]
	for panel in unit_holder.get_children():
		if panel.get_children().size() > 0:
			var u = panel.get_child(0)
			assert(u is CombatUnitControl, "Invalid Top-Level child!")
			stack.push_front(u)
	return stack
