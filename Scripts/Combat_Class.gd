extends Node2D
class_name SimUnit

signal died(who:SimUnit)
signal hurt
signal attack_queued

@export var damage_label: Label #= $VBoxContainer/HBoxContainer/Damage
@export var health_label: Label #= $VBoxContainer/HBoxContainer/Health
@export var name_label:Label
@export var effect:Effect
@export var sprite:TextureRect

#var effect : EffectData

## This variable has a set function that changes the attack text
var attack : int:
	set(v):
		_roll_text(damage_label,attack,v)
		attack = v
		#damage_label.text = str(attack)

## This variable has a set function that changes the health text
## and calls the die function to emit the died signal
var health : int:
	set(v):
		_roll_text(health_label,health,v)
		health = v
		#health_label.text = str(health)
		if health <= 0:
			die()



## This sets up the unit data for the combat unit
func dress(data:UnitData):
	attack = data.attack
	health = data.health
	name_label.text = data.unit_name
	sprite.texture = data.effect.sprite
	effect.data = data.effect
	effect.holder = self

##calls hurt signal, different than setting hp
func take_damage(amount:int): 
	health -= amount
	hurt.emit()

## This function emits the died signal
func die():
	var squeeze = self.create_tween()
	squeeze.set_parallel()
	squeeze.tween_property(self, "scale:x", 0.0,0.1)
	squeeze.tween_property(self,"position:y", -50, 0.1)
	squeeze.tween_property(self,"position:x",
			position.x + (sprite.size.x/2.0), 0.1)
	died.emit(self)
	
func _roll_text(label:Label,previous:int,next:int):
	const MIN_DURATION:float = 0.017 * 3 #~3 frames @60 fps
	const STEP:float = 1.0/60.0
	var change = abs(previous-next)
	var duration = MIN_DURATION + (STEP * change)
	
	var roll_text = self.create_tween()
	roll_text.tween_property(label,"text",str(next),duration).set_ease(Tween.EASE_IN_OUT)
