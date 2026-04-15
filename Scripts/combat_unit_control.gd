extends Control
class_name CombatUnitControl


@export var damage_label: Label #= $VBoxContainer/HBoxContainer/Damage
@export var health_label: Label #= $VBoxContainer/HBoxContainer/Health

var attack : int:
	set(v):
		attack = v
		damage_label.text = str(attack)

var health : int:
	set(v):
		health = v
		health_label.text = str(health)


var effect : EffectData

## This sets up the unit data for the unit
func dress(data:UnitData):
	attack = data.attack
	health = data.health
	effect = data.effect
