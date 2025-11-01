extends Node

var score: int = 0
var speed: float = 100
var commCount: int = 0

func _ready():
	print("GameManager ready")
	
	var js = JavaScriptBridge.get_interface("window")
	if js:
		js.register_callback("increment_comm_from_js", increment_comm)

	# Send a test message to confirm game -> React works
	JavaScriptBridge.eval("testMessage();")

func _process(_delta: float) -> void:
	speed += 0.01

func add_score(points: int) -> void:
	score += points
	JavaScriptBridge.eval("sendScoreToReact(" + str(score) + ");")

func reset_score() -> void:
	score = 0
	JavaScriptBridge.eval("sendScoreToReact(" + str(score) + ");")

func increment_comm():
	commCount += 1
	print("commCount incremented to:", commCount)
