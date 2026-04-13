extends Resource
class_name EffectData

enum TriggerStates {BATTLE_START, FAINT, TURN_START}
enum EffectTypes {DAMAGE, GIVE, SUMMON, GAIN}
enum Targets {PLAYER, ENEMY}

@export var name : String
@export var trigger_state : TriggerStates
@export var effect_type : EffectTypes
@export var magnitude : int
@export var target : Targets
@export var trigger_amount : int

func use_effect() -> void:
	pass
