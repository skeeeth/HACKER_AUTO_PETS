extends Resource
class_name FoodData

enum food_types {GIVE,SHIFT}

@export var type:food_types
@export var magnitude:int
@export var price:int = 2
@export var display_string:String
