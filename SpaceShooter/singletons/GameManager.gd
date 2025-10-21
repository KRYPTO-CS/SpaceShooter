extends Node

var score: int = 0

func add_score(points: int):
	score += points
	print("Score:", score)  # debug

	if Engine.has_singleton("JavaScript"):
		JavaScriptBridge.eval("sendScoreToReact(" + str(score) + ");")
		
func reset_score():
	score = 0
	if Engine.has_singleton("JavaScript"):
		JavaScriptBridge.eval("sendScoreToReact(" + str(score) + ");")
