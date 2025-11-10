extends Node

@onready var default_player = $AudioStreamPlayer

func play_sound(stream: AudioStream, volume: float = 1.0, volume_mult: float = 1.0) -> void:
	var sfx = AudioStreamPlayer2D.new()
	sfx.stream = stream
	sfx.volume_db = linear_to_db(clamp(volume, 0.0, 1.0)) / volume_mult
	sfx.position = Vector2.ZERO
	add_child(sfx)
	sfx.play()
	sfx.finished.connect(sfx.queue_free)
