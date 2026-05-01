extends Node


func play_sound(sound : AudioStream):
	var player = AudioStreamPlayer.new()
	player.volume_db = -5
	add_child(player)
	player.stream = sound
	player.play()
	player.finished.connect(_on_stream_finished.bind(player))


func play_sound_from_path(sound_path : String):
	var player = AudioStreamPlayer.new()
	player.volume_db = -5
	add_child(player)
	player.stream = load(sound_path)
	player.play()
	player.finished.connect(_on_stream_finished.bind(player))

func _on_stream_finished(stream):
	# When finished playing a stream, delete it
	stream.queue_free()
	pass
