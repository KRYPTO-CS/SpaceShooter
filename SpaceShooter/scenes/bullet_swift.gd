extends Area2D

@export var speed := 600.0
@export var lifetime := 1.0  # seconds before despawn
@export var damage := 1.0
@export var angle_degrees := 0.0  # 0 = straight up by default
@export var volume_mult := 1.0 

const SPEED_MULT := 1.0
const LIFETIME_MULT := 0.5
const DAMAGE_MULT := 0.75

var time_alive := 0.0
var velocity := Vector2.ZERO

func _ready():
	z_index = -1 # so it doesn't layer in front of player
	AudioManager.play_sound(preload("res://sounds/swiftShoot.wav"), 0.25, volume_mult) # shot sound
	
	var angle_radians = deg_to_rad(angle_degrees)
	velocity = Vector2(0, -1).rotated(angle_radians) * speed * SPEED_MULT
	rotation = angle_radians

func _process(delta):
	position += velocity * delta
	rotation_degrees += 360.0 * 2.0 * delta
	time_alive += delta
	if time_alive >= lifetime * LIFETIME_MULT:
		queue_free()

func _on_area_entered(area):
	if area.is_in_group("destroyable"):
		GameManager.swiftCounter += 0.1
		area.flash_red()
		area.take_damage(damage * DAMAGE_MULT)
		AudioManager.play_sound(preload("res://sounds/swiftHit.wav"), 0.25, volume_mult)
		queue_free()
