extends Resource
class_name EffectData

enum triggerStates {BATTLE_START, FAINT, TURN_START}
enum effectTypes {DAMAGE, GIVE, SUMMON, GAIN}
enum targets {PLAYER, ENEMY}

@export var name : String
@export var triggerState : triggerStates
@export var effectType : effectTypes
@export var magnitude : int
@export var target : targets
@export var triggerAmount : int
