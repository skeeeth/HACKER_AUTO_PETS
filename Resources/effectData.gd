extends Resource
class_name EffectData

enum TriggerStates {BATTLE_START, FAINT, TURN_START,
		HURT, B_ATTACK, A_ATTACK}

enum EffectTypes {DAMAGE, GIVE, SUMMON}
enum MagnitudeTypes {RAW, ATTACK, HEALTH, CUSTOM}
#enum TargetCodes {S,O,A}

@export_group("Identity")
@export var name : String
@export var effect_description : String
@export var sprite : Texture2D = preload("res://icon.svg")
@export var trigger_state : TriggerStates
@export var effect_type : EffectTypes

@export_group("Magnitude")
@export var magnitude_type: MagnitudeTypes = MagnitudeTypes.RAW
@export var magnitude : int

## mag mod is used to pass in extra data
## for cases where a single number isnt enough
## for "give" effects it is added to hp
## I.E: give 1/2 is magnitude 1 with mod + 1
@export var mag_mod: int = 0


@export_group("")
@export var targets : Array[Target]
@export var trigger_amount : int = 1

#func use_effect() -> void:
	#pass
