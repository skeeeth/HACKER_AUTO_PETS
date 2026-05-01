extends Node3D
class_name Shop3D

signal closing

@export var shop_manager:ShopManager
@export var sub_viewport: SubViewport
@onready var quad: MeshInstance3D = $Input/Quad
@onready var area_3d: Area3D = $Input/Quad/Area3D


func _ready() -> void:
	shop_manager.shop_closing.connect(shrink)

func shrink():
	var shrink_tween = create_tween()
	area_3d.input_ray_pickable = false
	shrink_tween.tween_property(quad,"scale:y",0,1.0)
	shrink_tween.tween_callback(closing.emit)
	
