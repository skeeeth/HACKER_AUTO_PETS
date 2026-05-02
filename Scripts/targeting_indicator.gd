extends Control

class_name Indicator

static var _self_scene:PackedScene = preload("uid://dr8wkcgon6xan")
const HOVER_Y:float = 50

@export var center_label:Label
@export var attack_label:Label
@export var health_label:Label
@export var stat_container:Container
@export var source_icon:TextureRect

##Remember to add the returned instance to the tree!
static func create(data:EffectData, index:int,
		spacing:float, x_size:float, center:float = 0, y_value:float = 0) -> Indicator:
	
	var instance:Indicator = _self_scene.instantiate()
	
	instance.dress(data)
	
	instance.position.y = y_value
	var edge = -spacing * 1 + center
	if index > 5:
		index += 1
	instance.position.x = (spacing * (index-5)) + edge
	instance.position.x += (spacing/2.0) - (x_size/2.0)
	instance.size.x = x_size

	#instance.drop()
	#source.resolved.connect(instance.queue_free)
	return instance
	
func drop() -> Signal:
	var drop = create_tween().bind_node(self)
	#drop.tween_property(self,"position:y",0,0.2)
	drop.tween_callback(queue_free).set_delay(0.5)
	return drop.finished
	

func dress(data:EffectData):
	source_icon.texture = data.sprite
	match data.effect_type:
		EffectData.EffectTypes.GIVE:
			attack_label.text = str(data.magnitude)
			health_label.text = str(data.magnitude + data.mag_mod)
			stat_container.show()
			
		EffectData.EffectTypes.DAMAGE:
			center_label.text = str(data.magnitude)
			center_label.show()
		
		EffectData.EffectTypes.SHIFT:
			center_label.text = str(data.magnitude)
			center_label.show()
			
