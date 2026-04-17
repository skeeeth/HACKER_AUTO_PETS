extends Node2D
class_name SimUnit

signal died(who:SimUnit)
signal hurt

@export var damage_label: Label #= $VBoxContainer/HBoxContainer/Damage
@export var health_label: Label #= $VBoxContainer/HBoxContainer/Health
@export var name_label:Label
@export var effect:Effect

var attack : int:
	set(v):
		attack = v
		damage_label.text = str(attack)

var health : int:
	set(v):
		health = v
		health_label.text = str(health)
		if health <= 0:
			die()

#var effect : EffectData

## This sets up the unit data for the unit
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

func die():
	died.emit(self)
