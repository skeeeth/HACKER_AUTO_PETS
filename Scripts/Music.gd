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
		shop_track.volume_db = -4
		combat_track.volume_db = -80
		first_time_load = true
	
	var crossfade = create_tween().set_parallel()
	var t = 2.5
	crossfade.tween_property(combat_track,"volume_db",-60,t)
	#combat_track.volume_db = -80
	crossfade.tween_property(shop_track,"volume_db",-4,t/2).set_ease(Tween.EASE_OUT)
	#shop_track.volume_db = 0

func combat_entered():
	var crossfade = create_tween().set_parallel()
	var t = 2.5
	crossfade.tween_property(combat_track,"volume_db",-4,t/2).set_ease(Tween.EASE_OUT)
	crossfade.tween_property(shop_track,"volume_db",-60,t)

func results_screen_entered():
	combat_track.stop()
	shop_track.stop()
	

func title_entered():
	boot_up_track.play()
	first_time_load = false
