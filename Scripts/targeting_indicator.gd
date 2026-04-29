extends VBoxContainer

class_name Indicator

static var _self_scene:PackedScene = preload("uid://dr8wkcgon6xan")
const HOVER_Y:float = 50

@export var center_label:Label
@export var attack_label:Label
@export var health_label:Label
@export var stat_container:Container

##Remember to add the returned instance to the tree!
static func create(data:EffectData, index:int,
		spacing:float, x_size:float, center:float = 0) -> Indicator:
	
	var instance:Indicator = _self_scene.instantiate()
	
	instance.dress(data)
	
	instance.position.y -= HOVER_Y
	var edge = -spacing * 1 + center
	if index > 5:
		index += 1
	instance.position.x = (spacing * (index-5)) + edge
	instance.size.x = x_size

	#instance.drop()
	#source.resolved.connect(instance.queue_free)
	return instance
	
func drop():
	var drop = create_tween().bind_node(self)
	drop.tween_property(self,"position:y",0,0.2)
	drop.tween_callback(queue_free)
	

func dress(data:EffectData):
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
			
