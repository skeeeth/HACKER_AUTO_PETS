extends Node

@onready var shop_track: AudioStreamPlayer = $ShopTrack
@onready var combat_track: AudioStreamPlayer = $CombatTrack


func shop_entered():
	var feed = create_tween()
	feed
	pass

func combat_entered():
	pass
