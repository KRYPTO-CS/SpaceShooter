extends Node

var score: int = 0
var speed = 100

func _ready():
	JavaScriptBridge.eval("testMessage();")

func _process(_delta):
	speed += 0.01

func add_score(points: int):
	score += points
	print("Score:", score)  # debug

	JavaScriptBridge.eval("sendScoreToReact(" + str(score) + ");")
		
func reset_score():
	score = 0
	JavaScriptBridge.eval("sendScoreToReact(" + str(score) + ");")
