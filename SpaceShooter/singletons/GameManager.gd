extends Node

var score: int = 0
var speed: float = 100
var commCount: int = 0

var baseTrack = "res://music/musicPlaceholder.mp3"

func _ready():
	JavaScriptBridge.eval("testMessage();")
	
	MusicManager.play_music(baseTrack, -15.0)

func _process(_delta: float) -> void:
	speed += 0.01
	if speed <= 50.0:
		speed = 50.0

func add_score(points: int) -> void:
	score += points
	if score <= 0:
		score = 0
	JavaScriptBridge.eval("sendScoreToReact(" + str(score) + ");")

func reset_score() -> void:
	score = 0
	JavaScriptBridge.eval("sendScoreToReact(" + str(score) + ");")
