extends VBoxContainer

class_name Indicator

static var _self_scene:PackedScene = preload("uid://dr8wkcgon6xan")
const HOVER_Y:float = 50

##Remember to add the returned instance to the tree!
static func create(type:EffectData.EffectTypes, index:int,
		spacing:float, x_size:float, center:float = 0) -> Indicator:
	
	var instance:Indicator = _self_scene.instantiate()
	instance.position.y -= HOVER_Y
	var edge = -spacing * 1 + center
	if index > 5:
		index += 1
	instance.position.x = (spacing * (index-5)) + edge
	instance.size.x = x_size
	#source.resolved.connect(instance.queue_free)
	return instance
