extends Node

@onready var default_player = $AudioStreamPlayer

func play_sound(stream: AudioStream, position: Vector2 = Vector2.ZERO):
	var sfx = AudioStreamPlayer2D.new()
	sfx.stream = stream
	sfx.position = position
	add_child(sfx)
	sfx.play()
	sfx.finished.connect(sfx.queue_free)
