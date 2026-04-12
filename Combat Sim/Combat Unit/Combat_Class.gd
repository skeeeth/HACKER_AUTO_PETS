extends Node2D
class_name SimUnit

signal died(who:SimUnit)

@export var damage_label: Label #= $VBoxContainer/HBoxContainer/Damage
@export var health_label: Label #= $VBoxContainer/HBoxContainer/Health

var attack:int:
	set(v):
		attack = v
		damage_label.text = str(attack)

var health:int:
	set(v):
		health = v
		health_label.text = str(health)
		if health <= 0:
			die()


func dress(data:UnitData):
	attack = data.attack
	health = data.health

func die():
	died.emit(self)
