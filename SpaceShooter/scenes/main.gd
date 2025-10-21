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

	if randf() < 0.1: # Golden asteroid for fun!!!!!!!!!!!!
		var sprite = asteroid.get_node("Sprite2D")
		sprite.texture = load("res://sprites/GoldenAsteroid.png")
		asteroid.max_hp = 9
		asteroid.speed = 200

	add_child(asteroid)
