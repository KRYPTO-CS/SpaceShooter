extends Area2D

@export var speed := 100.0
@export var max_hp := 3.0
@export var points := 1 

var rotation_speed := 45.0  # degrees per second
var hp := max_hp

func _ready():
	# Randomize movement and rotation slightly
	speed += randf_range(-50.0, 50.0)
	rotation_speed += randf_range(0.0, 45.0)
	rotation_speed *= randi_range(0, 1) * 2 - 1
	hp = max_hp

func _process(delta):
	# Move downward
	position.y += speed * delta
	rotation_degrees += rotation_speed * delta

	# Delete after a while
	if position.y > 2100:
		queue_free()
		
	# Take damage from flame
	for area in get_overlapping_areas():
		if area.is_in_group("flame"):
			if area.get_parent().state != area.get_parent().PlayerState.INVINCIBLE:
				self.take_damage(0.025)
		if area.is_in_group("player"):
			if area.get_parent().state != area.get_parent().PlayerState.INVINCIBLE:
				area.get_parent().take_damage(1.0, 1)
				hit_player()

func take_damage(amount: float):
	hp -= amount
	if hp <= 0:
		break_apart()

func break_apart():
	# TODO: Boom
	GameManager.add_score(points)
	GameManager.speed += points * 5
	AudioManager.play_sound(preload("res://sounds/asteroidBreak.wav"))
	queue_free()

func hit_player():
	# TODO: Boom
	GameManager.add_score(-1)
	GameManager.speed -= 20
	AudioManager.play_sound(preload("res://sounds/playerHit.wav"))
	queue_free()
	
func flash_red():
	var original_color = self.modulate
	self.modulate = Color(1, 0.25, 0)
	await get_tree().create_timer(0.075).timeout
	self.modulate = original_color
