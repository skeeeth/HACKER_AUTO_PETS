extends Control
class_name CombatUnitControl


@export var damage_label: Label
@export var health_label: Label

var effect : EffectData

## This variable has a set function that changes the attack text
var attack : int:
	set(v):
		attack = v
		damage_label.text = str(attack)

## This variable has a set function that changes the health text
var health : int:
	set(v):
		health = v
		health_label.text = str(health)



## This sets up the unit data for the unit
func dress(data:UnitData):
	attack = data.attack
	health = data.health
	effect = data.effect
