extends Resource
class_name Target

enum TargetCodes {S,O,A, STRICT_SELF} #Self, Opposite, Absolute

@export var type : TargetCodes = TargetCodes.S
@export var value : int = 0 
