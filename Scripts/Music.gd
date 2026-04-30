extends Node

var first_time_load : bool = false

@onready var shop_track: AudioStreamPlayer = $ShopTrack
@onready var combat_track: AudioStreamPlayer = $CombatTrack
@onready var boot_up_track: AudioStreamPlayer = $TitleTrack

func _ready() -> void:
	title_entered()

func shop_entered():
	#var feed = create_tween()
	boot_up_track.stop()
	
	if first_time_load == false:
		combat_track.play()
		shop_track.play()
		first_time_load = true
	
	
	combat_track.volume_db = -80
	shop_track.volume_db = 1

func combat_entered():
	combat_track.volume_db = 1
	shop_track.volume_db = -80

func results_screen_entered():
	combat_track.stop()
	shop_track.stop()
	

func title_entered():
	boot_up_track.play()
	first_time_load = false
