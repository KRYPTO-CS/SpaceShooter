extends Node2D

@export var asteroid_scene: PackedScene
var asteroid_timer := 0.0

func _ready():
	randomize()
	asteroid_scene = preload("res://scenes/asteroid.tscn")

func _process(delta):
	asteroid_timer += delta
	if asteroid_timer > (2.0 - (GameManager.speed/1000.0)):
		spawn_asteroid()
		if randi_range(0, 1) == 1:
			spawn_asteroid()
		asteroid_timer = 0.0

func spawn_asteroid():
	var asteroid = asteroid_scene.instantiate()
	asteroid.position = Vector2(randf_range(-255, 255), -750)
	asteroid.speed = GameManager.speed + 50

	if randf() < 0.1: # Golden asteroid for fun!
		var sprite = asteroid.get_node("Sprite2D")
		sprite.texture = load("res://sprites/goldenAsteroid.png")
		asteroid.max_hp *= 3
		asteroid.speed = GameManager.speed * 1.5
		asteroid.points *= 3
		asteroid.prefix = "golden"

	add_child(asteroid)
