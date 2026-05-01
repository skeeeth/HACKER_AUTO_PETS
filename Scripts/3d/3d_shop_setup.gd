extends Node3D
class_name Shop3D

signal closing

var shop_manager:ShopManager
@export var sub_viewport: SubViewport
@onready var quad: MeshInstance3D = $Input/Quad
@onready var area_3d: Area3D = $Input/Quad/Area3D

const SHOP_SCENE = preload("res://Scenes/ShopScene.tscn")

#func _ready() -> void:
	#shop_manager.shop_closing.connect(shrink)

func shrink():
	var shrink_tween = create_tween()
	area_3d.input_ray_pickable = false
	shrink_tween.tween_property(quad, "scale:y",0 ,0.4).set_ease(Tween.EASE_OUT)
	shrink_tween.tween_callback(closing.emit)
	shrink_tween.tween_callback(shop_manager.queue_free)
	
	
func start_shop(): 
	var new_shop = SHOP_SCENE.instantiate()
	sub_viewport.add_child(new_shop)
	shop_manager = new_shop
	shop_manager.shop_closing.connect(shrink)
	
	quad.visible = true
	var grow_panel = create_tween()
	grow_panel.tween_property(quad,"scale", Vector3.ONE, 0.4).set_ease(Tween.EASE_OUT)
	grow_panel.tween_property(area_3d,"input_ray_pickable", true, 0)
