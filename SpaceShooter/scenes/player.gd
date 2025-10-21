extends Node2D

@export var speed := 300.0
@export var bullet_scene: PackedScene

@export var x_limit := 240.0
@export var y_limit := 450.0

func _ready():
	bullet_scene = preload("res://scenes/bullet.tscn")

func _process(delta):
	var direction = Vector2.ZERO

	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_up"):
		direction.y -= 1
	if Input.is_action_pressed("move_down"):
		direction.y += 1

	position += direction.normalized() * speed * delta

	# clamp position to stay inside camera
	position.x = clamp(position.x, -x_limit, x_limit)
	position.y = clamp(position.y, -y_limit, y_limit)

	if Input.is_action_just_pressed("action"):
		shoot()

func shoot():
	var bullet = bullet_scene.instantiate()
	bullet.position = position
	get_parent().add_child(bullet)
