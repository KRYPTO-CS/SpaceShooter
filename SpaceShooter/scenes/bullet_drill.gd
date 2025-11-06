extends Area2D

@export var speed := 600.0
@export var lifetime := 1.5  # seconds before despawn
@export var damage := 1

var time_alive := 0.0

func _ready():
	z_index = -1 # so it doesn't layer in front of player

func _process(delta):
	position.y -= (speed * 0.5) * delta
	time_alive += delta
	if time_alive >= lifetime:
		queue_free()

func _on_area_entered(area):
	if area.is_in_group("destroyable"):
		area.flash_red()
		area.take_damage(damage * 2)
		AudioManager.play_sound(preload("res://sounds/drillHit.wav"))
