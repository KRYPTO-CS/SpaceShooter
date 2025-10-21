extends Node2D

@export var asteroid_scene: PackedScene
var asteroid_timer := 0.0

func _ready():
	randomize()
	asteroid_scene = preload("res://scenes/asteroid.tscn")

func _process(delta):
	asteroid_timer += delta
	if asteroid_timer > 2.0:
		spawn_asteroid()
		asteroid_timer = 0.0

func spawn_asteroid():
	var asteroid = asteroid_scene.instantiate()
	asteroid.position = Vector2(randf_range(-255, 255), -500)

	# Random asteroid size scale (0.5x to 2x)
	var size_scale = randf_range(0.5, 2.0)
	var sprite = asteroid.get_node("Sprite2D")
	sprite.scale = Vector2(size_scale, size_scale)

	# Adjust HP and speed based on size
	# Bigger size = more HP, slower speed
	var base_hp = 3
	var base_speed = 300.0
	asteroid.max_hp = int(base_hp * size_scale)
	asteroid.speed = base_speed / size_scale

	# Occasionally spawn golden asteroid
	if randf() < 0.1:
		sprite.texture = load("res://sprites/GoldenAsteroid.png")
		asteroid.max_hp = 9
		asteroid.speed = 200

	add_child(asteroid)
