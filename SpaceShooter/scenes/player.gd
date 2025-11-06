extends Node2D

@export var speed := 300.0
@export var x_limit := 300.0
@export var y_limit := 500.0
enum PlayerState { NORMAL, INVINCIBLE, DEAD }
var state: PlayerState = PlayerState.NORMAL

# touch
var finger_active := false
var active_finger_index := -1
var last_finger_pos := Vector2.ZERO

# invincibility
var flash_timer := 0.0
var flash_interval := 0.1 

func _process(delta):

	position.x = clamp(position.x, -x_limit, x_limit)
	position.y = clamp(position.y, -y_limit, y_limit)

	if state == PlayerState.INVINCIBLE:
		flash_timer += delta
		if flash_timer >= flash_interval:
			visible = not visible
			flash_timer = 0.0

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed and active_finger_index == -1:
			active_finger_index = event.index
			finger_active = true
			last_finger_pos = event.position
		elif not event.pressed and event.index == active_finger_index:
			finger_active = false
			active_finger_index = -1
	elif event is InputEventScreenDrag and event.index == active_finger_index:
		var delta_pos = event.position - last_finger_pos
		position += delta_pos
		last_finger_pos = event.position

func take_damage(time):
	state = PlayerState.INVINCIBLE
	invincibility_timer(time)
	self.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.1).timeout
	self.modulate = Color(1, 1, 1)

func invincibility_timer(time):
	await get_tree().create_timer(time).timeout
	state = PlayerState.NORMAL
	visible = true
