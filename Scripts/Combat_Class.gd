extends Node2D
class_name SimUnit

signal died(who:SimUnit)
signal hurt

@export var damage_label: Label #= $VBoxContainer/HBoxContainer/Damage
@export var health_label: Label #= $VBoxContainer/HBoxContainer/Health
@export var name_label:Label
@export var effect:Effect

#var effect : EffectData

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
	name_label.text = data.effect.name
	effect.data = data.effect
	effect.holder = self

##calls hurt signal, different than setting hp
func take_damage(amount:int): 
	health -= amount
	hurt.emit()

## This function emits the died signal
func die():
	died.emit(self)
