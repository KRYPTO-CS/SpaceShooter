extends Node

var score: int = 0

func add_score(points: int):
	score += points
	print("Score:", score)  # debug

func reset_score():
	score = 0
