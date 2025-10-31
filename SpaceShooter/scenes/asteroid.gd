extends Area2D

@export var speed := 100.0
@export var max_hp := 5.0
@export var hp := 5.0
@export var rotation_speed := 45.0  # degrees per second
@export var points := 1 

func _ready():
	# Randomize movement and rotation slightly
	speed += randf_range(-40.0, 40.0)
	rotation_speed = randf_range(-60.0, 60.0)
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
			self.take_damage(0.025)

func _on_area_entered(area):
	if area.is_in_group("player"):
		hit_player()

func take_damage(amount: float):
	hp -= amount
	if hp <= 0:
		break_apart()

func break_apart():
	# TODO: Boom
	GameManager.add_score(points)
	GameManager.speed += points * 5
	queue_free()

func hit_player():
	GameManager.add_score(-1)
	GameManager.speed -= 20
	queue_free()
