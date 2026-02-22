extends Parallax2D

@onready var bg_1: AnimatedSprite2D = $BG1
@onready var bg_2: AnimatedSprite2D = $BG2
@onready var bg_3: AnimatedSprite2D = $BG3

@export var bg_height: float = 1920.0  # height of each background in pixels
@export var bg_width: float = 1215.0 # width

func _ready():
	# Initial positions
	bg_1.position = Vector2(0, 0)
	bg_2.position = Vector2(bg_width, 0) 
	bg_3.position = Vector2(-bg_width, 0) 

func _process(delta):
	
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
