extends Node2D

var asteroid_scene := preload("res://scenes/asteroid.tscn")
var powerup_scene := preload("res://scenes/powerup.tscn")
var asteroid_timer := 0.0

func _ready():
	randomize()

func _process(delta):
	asteroid_timer += delta
	if asteroid_timer > (2.0 - (GameManager.speed/500.0)):
		spawn_asteroid()
		if randi_range(0, 1) == 1:
			spawn_asteroid()
		asteroid_timer = 0.0

func spawn_asteroid():
	var asteroid = asteroid_scene.instantiate()
	asteroid.position = Vector2(randf_range(-255, 255), -750)
	asteroid.speed = GameManager.speed * 0.75 + 150

	if randf() < 0.1: # Golden asteroid for fun!
		var sprite = asteroid.get_node("Sprite2D")
		sprite.texture = load("res://sprites/goldenAsteroid.png")
		asteroid.max_hp *= 3
		asteroid.speed = GameManager.speed * 0.75 + 250
		asteroid.points *= 5
		asteroid.prefix = "golden"
		
	if randf() < 0.1:
		var powerup = powerup_scene.instantiate()
		powerup.position = Vector2(randf_range(-255, 255), -750)
		powerup.speed = GameManager.speed * 0.75 + 150
		add_child(powerup)

	add_child(asteroid)
