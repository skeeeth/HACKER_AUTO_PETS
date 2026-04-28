extends VBoxContainer

class_name Indicator

static var _self_scene:PackedScene = preload("uid://dr8wkcgon6xan")
const HOVER_Y:float = 50

##Remember to add the returned instance to the tree!
static func create(source:Effect,index:int,spacing:float, edge:float = 0) -> Indicator:
	var instance:Indicator = _self_scene.instantiate()
	instance.position.y -= HOVER_Y
	edge = -spacing * 2
	if index > 5:
		index += 1
	instance.position.x = (spacing * (index-4)) + edge
	instance.size.x = source.holder.sprite.size.x
	source.resolved.connect(instance.queue_free)
	return instance
