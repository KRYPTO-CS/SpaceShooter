extends Node2D

@export var speed := 300.0
@export var bullet_scene: PackedScene
@export var x_limit := 240.0
@export var y_limit := 450.0
@export var shoot_interval := 0.3  # seconds between shots

# charging
@export var base_damage := 1.0
@export var max_charge_time := 1.25
@export var max_bullet_scale := 2.5

# charge variables
var is_charging := false
var charge_time := 0.0
var current_damage := 1.0

# touch
var finger_active := false
var shoot_timer := 0.0
var active_finger_index := -1
var last_finger_pos := Vector2.ZERO

func _ready():
	bullet_scene = preload("res://scenes/bullet.tscn")

func _process(delta):
	# auto-fire when idle
	if not finger_active:
		shoot_timer += delta
		if shoot_timer >= shoot_interval:
			_shoot_normal_bullet()
			shoot_timer = 0.0
	else:
		# charge if touching
		is_charging = true
		charge_time = clamp(charge_time + delta, 0, max_charge_time)
		current_damage = lerp(base_damage, base_damage * 3, charge_time / max_charge_time)
		shoot_timer = 0.0  # reset auto-fire while charging

	# clamp player position to camera bounds
	position.x = clamp(position.x, -x_limit, x_limit)
	position.y = clamp(position.y, -y_limit, y_limit)

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed and active_finger_index == -1:
			active_finger_index = event.index
			finger_active = true
			last_finger_pos = event.position
		elif not event.pressed and event.index == active_finger_index:
			finger_active = false
			active_finger_index = -1
			if charge_time > 0:
				_shoot_charged_bullet()
				charge_time = 0.0
				current_damage = base_damage
				is_charging = false
	elif event is InputEventScreenDrag and event.index == active_finger_index:
		# move player relative to finger drag
		var delta_pos = event.position - last_finger_pos
		position += delta_pos
		last_finger_pos = event.position

func _shoot_normal_bullet():
	if bullet_scene == null:
		return
	var bullet = bullet_scene.instantiate()
	bullet.position = position
	bullet.damage = base_damage
	get_parent().add_child(bullet)

func _shoot_charged_bullet():
	if bullet_scene == null:
		return
	var bullet = bullet_scene.instantiate()
	bullet.position = position
	var charge_ratio = charge_time / max_charge_time
	bullet.scale = Vector2.ONE * lerp(1.0, max_bullet_scale, charge_ratio)
	bullet.damage = current_damage
	bullet.speed *= (1.0 + charge_ratio / 1.5)
	get_parent().add_child(bullet)
