extends Node2D

var asteroid_scene := preload("res://scenes/asteroid.tscn")
var crystal_scene := preload("res://scenes/crystal.tscn")
var powerup_scene := preload("res://scenes/powerup.tscn")
var asteroid_timer := 0.0

var baseTrack = "res://music/musicPlaceholder.mp3"

@export var mode := 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	asteroid_timer += delta
	if asteroid_timer > max(0.1, (1 - (GameManager.speed/750.0))):
		spawn_asteroid()
		if randi_range(0, 1) == 1:
			spawn_crystal()
		asteroid_timer = 0.0
		
func spawn_asteroid():
	var asteroid = asteroid_scene.instantiate()
	asteroid.position = Vector2(650, randf_range(-880, 880))
	asteroid.speed_x = GameManager.speed + 150
	
	if randf() < 0.1 and !GameManager.inv_active:
		var powerup = powerup_scene.instantiate()
		powerup.position = Vector2(650, randf_range(-880, 880))
		powerup.speed_x = GameManager.speed + 160
		add_child(powerup)
		print(powerup)
		
	asteroid.add_to_group("asteroid")
	add_child(asteroid)

func spawn_crystal():
	var crystal = crystal_scene.instantiate()
	crystal.position = Vector2(540, randf_range(-880, 880))
	crystal.speed = GameManager.speed + 175
	
	crystal.add_to_group("crystal")
	add_child(crystal)
