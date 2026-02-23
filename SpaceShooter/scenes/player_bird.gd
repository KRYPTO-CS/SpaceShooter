extends Node2D

@export var mode := 1
var speed := 300.0
var x_limit := 300.0
var y_limit := 880.0

# player state
enum PlayerState { NORMAL, INVINCIBLE, DEAD }
var state: PlayerState = PlayerState.NORMAL
var starttoggle = false

# invincibility
var flash_timer := 0.0
var flash_interval := 0.1 

# touch
var finger_active := false
var active_finger_index := -1
var last_finger_pos := Vector2.ZERO

# physics
var acceleration_y := 8.0
var velocity_y := 0.0
var acceleration_strength := 2500.0
var max_velocity := 1250.0
var rotation_speed := 2.0
var max_tilt = deg_to_rad(45)
	
func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed and active_finger_index == -1:
			active_finger_index = event.index
			acceleration_y = 1
			finger_active = true
			last_finger_pos = event.position
			starttoggle = true
		elif not event.pressed and event.index == active_finger_index:
			finger_active = false
			acceleration_y = -1
			active_finger_index = -1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	position.y = clamp(position.y, -y_limit, y_limit)
	
	# this block determines player speed.
	# acceleration stays constant (we can change with game state variables)
	if finger_active:
		velocity_y -= acceleration_strength*acceleration_y*delta
		velocity_y = max(velocity_y, -max_velocity)
	else:
		velocity_y -= acceleration_strength*acceleration_y*delta
		velocity_y = min(velocity_y, max_velocity)
		
	if starttoggle:
		if self.position.y == y_limit:
			velocity_y = -0.01
		if self.position.y == -y_limit:
			velocity_y = 0.01
		self.position += Vector2(0, velocity_y*delta)
	else:
		self.velocity_y = 5.0
	# Rotation based on vertical speed
	var target_rotation = clamp(velocity_y / max_velocity, -1.0, 1.0) * max_tilt
	rotation = lerp(rotation, target_rotation + deg_to_rad(90), 8.0 * delta)
		
	if state == PlayerState.INVINCIBLE:
		flash_timer += delta
		if flash_timer >= flash_interval:
			visible = not visible
			flash_timer = 0.0

func take_damage(time):
	state = PlayerState.INVINCIBLE
	velocity_y = -velocity_y * 0.75
	invincibility_timer(time)
	self.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.1).timeout
	self.modulate = Color(1, 1, 1)

func invincibility_timer(time):
	await get_tree().create_timer(time).timeout
	state = PlayerState.NORMAL
	visible = true
