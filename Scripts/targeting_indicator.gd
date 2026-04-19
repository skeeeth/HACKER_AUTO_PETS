extends VBoxContainer

class_name Indicator

static var _self_scene:PackedScene = preload("uid://dr8wkcgon6xan")
const HOVER_Y:float = 50

##Remember to add the returned instance to the tree!
static func create(source:Effect,target:SimUnit) -> Indicator:
	var instance:Indicator = _self_scene.instantiate()
	instance.position.y -= HOVER_Y
	instance.size.x = target.sprite.size.x
	source.resolved.connect(instance.queue_free)
	return instance
