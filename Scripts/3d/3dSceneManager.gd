extends Camera3D

const COMBAT_SCENE: PackedScene = preload("res://Scenes/CombatSim.tscn")
@onready var combat_viewport: SubViewport = $"../Combat Mesh/Combat Viewport"
@onready var shop: Shop3D = $Shop

func _ready() -> void:
	shop.closing.connect(on_shop_ending)

func on_shop_ending():
	start_combat()

func start_combat():
	rotate(Vector3.UP, -PI/2.0)
	var new_combat = COMBAT_SCENE.instantiate()
	combat_viewport.add_child(new_combat)
