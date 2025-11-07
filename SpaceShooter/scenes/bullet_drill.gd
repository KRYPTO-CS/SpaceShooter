extends Area2D

@export var speed := 600.0
@export var lifetime := 1.5  # seconds before despawn
@export var damage := 1
@export var angle_degrees := 0.0  # 0 = straight up by default

var time_alive := 0.0
var velocity := Vector2.ZERO

func _ready():
	z_index = -1 # so it doesn't layer in front of player
	
	var angle_radians = deg_to_rad(angle_degrees)
	velocity = Vector2(0, -1).rotated(angle_radians) * speed
	rotation = angle_radians

func _process(delta):
	position += velocity * delta
	time_alive += delta
	if time_alive >= lifetime:
		queue_free()

func _on_area_entered(area):
	if area.is_in_group("destroyable"):
		area.flash_red()
		area.take_damage(damage * 1.5)
		AudioManager.play_sound(preload("res://sounds/drillHit.wav"))
