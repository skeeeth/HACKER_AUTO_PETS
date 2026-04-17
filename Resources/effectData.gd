extends Resource
class_name EffectData

enum TriggerStates {BATTLE_START, FAINT, TURN_START, HURT}
enum EffectTypes {DAMAGE, GIVE, SUMMON}
#enum TargetCodes {S,O,A}

@export var name : String
@export var trigger_state : TriggerStates
@export var effect_type : EffectTypes
@export var magnitude : int
@export var give_difference: int = 0 #ignore for non-give(maybe useful for some HACK later)
	#ex to give 1/2, set magnitude to 2 and give_difference to -1
	#
@export var targets : Array[Target]
@export var trigger_amount : int = 1

#func use_effect() -> void:
	#pass
