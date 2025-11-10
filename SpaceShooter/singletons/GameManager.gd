extends Node

var score: int = 0
var speed: float = 100
var swiftCounter: float = 1.0

const SPEED_ACCELERATION := 2.0
const MIN_SPEED := 50.0
const MAX_SPEED := INF
const SWIFT_DECAY := 0.25
const MIN_SWIFT := 1.0
const MAX_SWIFT := 2.0

var baseTrack = "res://music/musicPlaceholder.mp3"

func _ready():
	JavaScriptBridge.eval("testMessage();")
	
	MusicManager.play_music(baseTrack, -15.0)

func _process(delta: float) -> void:
	speed = clamp(speed + SPEED_ACCELERATION * delta, MIN_SPEED, MAX_SPEED)
	swiftCounter = clamp(swiftCounter - SWIFT_DECAY * delta, MIN_SWIFT, MAX_SWIFT)

func add_score(points: int) -> void:
	score += points
	if score <= 0:
		score = 0
	JavaScriptBridge.eval("sendScoreToReact(" + str(score) + ");")

func reset_score() -> void:
	score = 0
	JavaScriptBridge.eval("sendScoreToReact(" + str(score) + ");")
