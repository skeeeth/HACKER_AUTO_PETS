extends Camera3D

const COMBAT_SCENE: PackedScene = preload("res://Scenes/CombatSim.tscn")
@onready var combat_viewport: SubViewport = $"Combat Mesh/Combat Viewport"
@onready var shop: Shop3D = $Shop
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var combat_mesh: MeshInstance3D = $"Combat Mesh"

var post_combat:bool = false
var recent_combat:CombatSimManager

func _ready() -> void:
	shop.closing.connect(on_shop_ending)
	animation_player.play("Starting Camera Move")

func on_shop_ending():
	start_combat()

func start_combat():
	var cam_move = create_tween()
	#cam_move.tween_method(rotate_y, 0, , 2.0)
	cam_move.tween_property(self,"quaternion",Quaternion(0,0,0,1),1.0)
	cam_move.tween_property(combat_mesh, "visible", true, 0)
	cam_move.tween_property(combat_mesh,"scale",Vector3.ONE,0.1)
	#rotate(Vector3.UP, -PI/2.0)
	var new_combat:CombatSimManager = COMBAT_SCENE.instantiate()
	new_combat.combat_end.connect(wait_for_input)
	#post_combat = true
	combat_viewport.add_child(new_combat)
	recent_combat = new_combat

func end_combat():
	var reset = create_tween()
	reset.tween_property(combat_mesh,"scale",Vector3.ZERO,0.5)
	reset.tween_property(combat_mesh,"visible",false,0)
	reset.tween_property(self,"quaternion",
			Quaternion(0,0.707107,0,0.707107),2.0)
	reset.tween_callback(shop.start_shop)
	reset.tween_callback(recent_combat.queue_free)
	
func _input(event: InputEvent) -> void:
	if event.is_action("lmb"):
		if post_combat:
			end_combat()
			post_combat = false

func wait_for_input():
	post_combat = true
