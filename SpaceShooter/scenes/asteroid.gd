extends Area2D

var points := 1 
var speed := 100.0
var rotation_speed := 45.0  # degrees per second
var max_hp := 3.0
var hp := max_hp
var prefix = ""

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
	
	# die
	if hp <= 0:
		break_apart()

	# Delete after a while
	if position.y > 2100:
		queue_free()
		
	# Take damage from flame
	for area in get_overlapping_areas():
		if area.is_in_group("flame"):
			if area.get_parent().state != area.get_parent().PlayerState.INVINCIBLE:
				self.take_damage(3.0 * delta)
		if area.is_in_group("player"):
			if area.get_parent().state != area.get_parent().PlayerState.INVINCIBLE:
				area.get_parent().take_damage(1.45)
				hit_player()

func take_damage(amount: float):
	hp -= amount

func break_apart():
	GameManager.add_score(points)
	GameManager.speed += points * 5
	AudioManager.play_sound(preload("res://sounds/asteroidBreak.wav"), 0.6)
	explode()

func hit_player():
	GameManager.add_score(-1)
	GameManager.speed -= 20
	AudioManager.play_sound(preload("res://sounds/playerHit.wav"), 1.0)
	AudioManager.play_sound(preload("res://sounds/playerOuch.wav"), 0.75)
	AudioManager.play_sound(preload("res://sounds/asteroidBreak.wav"), 0.5)
	explode()
	
func flash_red():
	self.modulate = Color(1, 0.25, 0)
	await get_tree().create_timer(0.075).timeout
	self.modulate = Color(1, 1, 1)
	
func explode():
	var explosion = preload("res://scenes/explosion.tscn").instantiate()
	explosion.prefix = prefix
	explosion.global_position = global_position
	get_parent().add_child(explosion)
	queue_free()
