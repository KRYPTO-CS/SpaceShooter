extends Parallax2D

@export var mode = 0

@onready var bg_1: AnimatedSprite2D = $BG1
@onready var bg_2: AnimatedSprite2D = $BG2
@onready var bg_3: AnimatedSprite2D = $BG3

## transition into light speed
@onready var t_1: AnimatedSprite2D = $InTransition
@onready var t_2: AnimatedSprite2D = $InTransition2
@onready var t_3: AnimatedSprite2D = $InTransition3

@export var bg_height: float = 1920.0  # height of each background in pixels
@export var bg_width: float = 1215.0 # width

func _ready():
	original_mode = mode
	add_to_group("background")
	## signal when the transition is over to set new state
	#$InTransition.animation_finished.connect(_on_anim_finished)
	#$InTransition2.animation_finished.connect(_on_anim_finished)
	#$InTransition3.animation_finished.connect(_on_anim_finished)
	if mode == 0:
		bg_3.queue_free()
		
	# Initial positions
	match mode:
		0:
			bg_1.position = Vector2(0, 0)
			bg_2.position = Vector2(0, -bg_height)
		1:
			bg_1.position = Vector2(0, 0)
			bg_2.position = Vector2(bg_width, 0) 
			bg_3.position = Vector2(-bg_width, 0) 
		3000:
			t_1.position = Vector2(0, 0)
			t_2.position = Vector2(bg_width, 0) 
			t_3.position = Vector2(-bg_width, 0) 

func _process(delta):
	if winding_down:
		wind_down_timer += delta
		var t = clamp(wind_down_timer / WIND_DOWN_DURATION, 0.0, 1.0)
		GameManager.speed = lerp(wind_down_from, init_speed, t)
	match mode:
		0:
			# Move both backgrounds downward
			bg_1.position.y += GameManager.speed * 0.75 * delta
			bg_2.position.y += GameManager.speed * 0.75 * delta

			# When bg_2 reaches (0, 0), reset positions
			if bg_2.position.y >= 0:
				bg_1.position = Vector2(0, 0)
				bg_2.position = Vector2(0, -bg_height)
		1:
			# Move both backgrounds to the left
			bg_1.position.x += -GameManager.speed * 2 * delta
			bg_2.position.x += -GameManager.speed * 2 * delta
			bg_3.position.x += -GameManager.speed * 2 * delta
			
			# Sync animation frames
			bg_2.frame = bg_1.frame
			bg_3.frame = bg_1.frame

			# When bg_2 reaches (0, 0), reset positions
			if bg_2.position.x <= 0:
				bg_1.position = Vector2(0, 0)
				bg_2.position = Vector2(bg_width, 0)
				bg_3.position = Vector2(-bg_width, 0)
			
			if bg_3.position.x >= 0:
				bg_1.position = Vector2(0, 0)
				bg_2.position = Vector2(bg_width, 0)
				bg_3.position = Vector2(-bg_width, 0)
				
		## I'm making a new series of modes for the game, starting in the 3000s. Just in case
		3000:
			# Move both backgrounds to the left
			t_1.position.x += -GameManager.speed * 2 * delta
			t_2.position.x += -GameManager.speed * 2 * delta
			t_3.position.x += -GameManager.speed * 2 * delta
			
			# Sync animation frames
			t_2.frame = t_1.frame
			t_3.frame = t_1.frame

			# When bg_2 reaches (0, 0), reset positions
			if t_2.position.x <= 0:
				t_1.position = Vector2(0, 0)
				t_2.position = Vector2(bg_width, 0)
				t_3.position = Vector2(-bg_width, 0)
			
			if t_3.position.x >= 0:
				t_1.position = Vector2(0, 0)
				t_2.position = Vector2(bg_width, 0)
				t_3.position = Vector2(-bg_width, 0)

# helper function to change the mode
func set_mode(m):
	mode = m

var original_mode := 0
var init_speed
var winding_down := false
var wind_down_from := 0.0
var wind_down_timer := 0.0
const WIND_DOWN_DURATION := 1.0

# call when inv is activbe
func continue_pos():
	init_speed = GameManager.speed
	t_1.visible = true
	t_2.visible = true
	t_3.visible = true
	t_1.position = bg_1.position
	t_2.position = bg_2.position
	t_3.position = bg_3.position
	t_1.stop()
	t_2.stop()
	t_3.stop()
	t_1.play("default")
	t_2.play("default")
	t_3.play("default")

# call when deactivating
func resume_pos():
	wind_down_from = GameManager.speed
	wind_down_timer = 0.0
	winding_down = true
	if t_1.animation_finished.is_connected(_on_out_finished):
		t_1.animation_finished.disconnect(_on_out_finished)
	t_1.stop()
	t_2.stop()
	t_3.stop()
	t_1.play("out")
	t_2.play("out")
	t_3.play("out")
	t_1.animation_finished.connect(_on_out_finished)

func _on_out_finished():
	t_1.animation_finished.disconnect(_on_out_finished)
	winding_down = false
	GameManager.speed = init_speed
	t_1.animation = "default"
	t_2.animation = "default"
	t_3.animation = "default"
	bg_1.position = t_1.position
	bg_2.position = t_2.position
	bg_3.position = t_3.position
	t_1.visible = false
	t_2.visible = false
	t_3.visible = false
	mode = original_mode
