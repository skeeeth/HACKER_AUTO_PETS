extends Button
class_name PurchaseButton

signal purchased_unit(purchasable_unit)

@export var unit_name : Label
@export var manager : ShopManager

var purchasable_unit : UnitData
var base_unit_text : String


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	purchased_unit.connect(manager.purchase_unit)
	base_unit_text = unit_name.text


func add_unit_to_button(data : UnitData) -> void:
	purchasable_unit = data
	unit_name.text = base_unit_text + data.unit_name


func _on_button_pressed() -> void:
	purchased_unit.emit(purchasable_unit.duplicate())
