extends Node

var score: int = 0

func add_score(points: int):
	score += points
	print("Score:", score)  # debug

	JavaScriptBridge.eval("sendScoreToReact(" + str(score) + ");")
		
func reset_score():
	score = 0
	JavaScriptBridge.eval("sendScoreToReact(" + str(score) + ");")
