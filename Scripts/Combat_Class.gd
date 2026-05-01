extends Node2D
class_name SimUnit

signal died(who:SimUnit)
signal hurt
@warning_ignore("unused_signal")
signal attack_queued

@export var damage_label: Label #= $VBoxContainer/HBoxContainer/Damage
@export var health_label: Label #= $VBoxContainer/HBoxContainer/Health
@export var shift_label:Label

@export var name_label:Label
@export var effect:Effect
@export var sprite:TextureRect
@onready var background: PanelContainer = $PanelContainer/VBoxContainer/BevelContainer/Background
const DEAD_BACKGROUND = preload("uid://bdvdcqe04dvv1")

var dead:bool
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
		##clamp to 0 is important so that hurt is only called on real hp loss
		v = clamp(v,0,99)
		_roll_text(health_label,health,v)
		health = v
		#health_label.text = str(health)
		if health == 0:
			if !dead:
				die()

var shift:int = 0:
	set(v):
		shift = v
		shift_label.text = "Shift: %+d" % shift #shift_string
		#var shift_string:String = ""
		#var shift_character:String = ""
		#if shift < 0:
			#shift_character = "<"
		#else:
			#shift_character = ">"
		#
		#for i in range(abs(shift)):
			#shift_string += shift_character

## This sets up the unit data for the combat unit
func dress(data:UnitData):
	attack = data.attack
	health = data.health
	name_label.text = data.unit_name
	sprite.texture = data.effect.sprite
	effect.data = data.effect
	effect.holder = self
	effect.sound_effect = data.effect.sound_effect
	shift = data.shift
	effect.shift = shift

##calls hurt signal, different than setting hp
func take_damage(amount:int, from_attack:bool = false):
	var start = health
	health -= amount
	var end = health
	
	##actual change in hp may be different than queued damage due to clamp
	## also dont call hurt on 0 damage effects, 
	## but do call hurt on any attack, to prevent softlock
	if (start - end) > 0 or from_attack:
		hurt.emit()

## This function emits the died signal
func die():
	dead = true
	died.emit(self)
	set_background_style(DEAD_BACKGROUND)


##Death animation
func death_squeeze() -> Signal:
	var squeeze = self.create_tween()
	squeeze.set_parallel()
	squeeze.tween_property(self, "scale:x", 0.0,0.1)
	squeeze.tween_property(self,"position:y", -50, 0.1)
	squeeze.tween_property(self,"position:x",
			position.x + (sprite.size.x/2.0), 0.1)
	
	return squeeze.finished

func _roll_text(label:Label,previous:int,next:int):
	const MIN_DURATION:float = 0.017 * 3 #~3 frames @60 fps
	const STEP:float = 1.0/60.0
	var change = abs(previous-next)
	var duration = MIN_DURATION + (STEP * change)
	
	var roll_text = self.create_tween()
	roll_text.tween_property(label,"text",str(next),duration).set_ease(Tween.EASE_IN_OUT)

func on_effect_shifted():
	shift = effect.shift
	#shift_label.text = "%+d" % effect.shift

func set_background_style(style:StyleBox):
	background.add_theme_stylebox_override("panel",style)
	pass
