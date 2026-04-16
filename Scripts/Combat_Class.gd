extends Node2D
class_name SimUnit

signal died(who:SimUnit)

@export var damage_label: Label
@export var health_label: Label

var effect : EffectData

## This variable has a set function that changes the attack text
var attack : int:
	set(v):
		attack = v
		damage_label.text = str(attack)

## This variable has a set function that changes the health text
## and calls the die function to emit the died signal
var health : int:
	set(v):
		health = v
		health_label.text = str(health)
		if health <= 0:
			die()



## This sets up the unit data for the combat unit
func dress(data:UnitData):
	attack = data.attack
	health = data.health
	effect = data.effect

## This function emits the died signal
func die():
	died.emit(self)
