extends Parallax2D

@onready var bg_1: AnimatedSprite2D = $BG1
@onready var bg_2: AnimatedSprite2D = $BG2

@export var bg_height: float = 1920.0  # height of each background in pixels

func _ready():
	# Initial positions
	bg_1.position = Vector2(0, 0)
	bg_2.position = Vector2(0, -bg_height)

func _process(delta):
	
	# Move both backgrounds downward
	bg_1.position.y += GameManager.speed * 0.75 * delta
	bg_2.position.y += GameManager.speed * 0.75 * delta

	# When bg_2 reaches (0, 0), reset positions
	if bg_2.position.y >= 0:
		bg_1.position = Vector2(0, 0)
		bg_2.position = Vector2(0, -bg_height)
