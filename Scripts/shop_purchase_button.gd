extends Button
class_name PurchaseButton


var purchasable_unit : UnitData
@export var unit_name : Label
@export var manager : ShopManager

signal purchased_unit(purchasable_unit)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	purchased_unit.connect(manager.purchase_unit)


func add_unit_to_button(data : UnitData) -> void:
	purchasable_unit = data
	unit_name.text += data.unit_name


func _on_button_pressed() -> void:
	purchased_unit.emit(purchasable_unit)
