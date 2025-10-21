extends Node2D

@export var speed := 300.0
@export var bullet_scene: PackedScene
@export var x_limit := 240.0
@export var y_limit := 450.0
@export var shoot_interval := 0.3  # seconds between shots

# Charging system
@export var base_damage := 1.0
@export var max_charge_time := 1.25  # seconds to reach full charge
@export var max_bullet_scale := 2.5

var target_position: Vector2
var finger_active := false
var shoot_timer := 0.0
var moving := false
var was_finger_active := false

# Charge variables
var is_charging := false
var charge_time := 0.0
var current_damage := 1.0

func _ready():
	bullet_scene = preload("res://scenes/bullet.tscn")
	target_position = position

func _process(delta):
	if finger_active:
		# move toward finger position if dragging
		if position.distance_to(target_position) > 5.0:
			position = position.lerp(target_position, delta * 10)

		# clamp player position
		position.x = clamp(position.x, -x_limit, x_limit)
		position.y = clamp(position.y, -y_limit, y_limit)

		# charge while finger is touching
		is_charging = true
		charge_time = clamp(charge_time + delta, 0, max_charge_time)
		current_damage = lerp(base_damage, base_damage * 3, charge_time / max_charge_time)

	else:
		if was_finger_active:
			shoot()
			charge_time = 0.0
			current_damage = base_damage
			shoot_timer = 0.0
			is_charging = false
		else:
			# auto-fire when idle
			shoot_timer += delta
			if shoot_timer >= shoot_interval:
				shoot()
				shoot_timer = 0.0

	was_finger_active = finger_active

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			finger_active = true
			target_position = get_global_mouse_position()
		else:
			finger_active = false
	elif event is InputEventScreenDrag and finger_active:
		target_position = get_global_mouse_position()

func shoot():
	var bullet = bullet_scene.instantiate()
	bullet.position = position

	# scale and damage based on charge
	var charge_ratio = charge_time / max_charge_time
	bullet.scale = Vector2.ONE * lerp(1.0, max_bullet_scale, charge_ratio)
	bullet.damage = current_damage
	bullet.speed *= charge_time / 2 + 1

	get_parent().add_child(bullet)
