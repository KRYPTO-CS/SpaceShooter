extends Node

@export var game_scene: PackedScene = preload("res://scenes/main.tscn")

var score: int = 0
var speed: float = 100
var swiftCounter: float = 1.0

const SPEED_ACCELERATION := 2.0
const MIN_SPEED := 50.0
const MAX_SPEED := 1000.0
const SWIFT_DECAY := 0.3
const MIN_SWIFT := 1.0
const MAX_SWIFT := 3.0

var baseTrack = "res://music/musicPlaceholder.mp3"
var game_started: bool = false
var test_received = false

# enums
enum BulletType { NULL, SIMPLE, DRILL, SWIFT }
enum ShootingType { NULL, NORMAL, CHARGE, TRIPLE, BURST, SPRAY, V, DELTA, RIPPLE, PEA, HEAVY }
enum ElementType { NULL, NEUTRAL, FIRE, ICE, WATER }

func _ready():
	JavaScriptBridge.eval("testMessage();")

func _process(delta: float) -> void:
	if not game_started:
		return
	
	speed = clamp(speed + SPEED_ACCELERATION * delta, MIN_SPEED, MAX_SPEED)
	swiftCounter = clamp(swiftCounter - SWIFT_DECAY * delta, MIN_SWIFT, MAX_SWIFT)
	
func begin_game() -> void:
	if game_scene:
		get_tree().change_scene_to_packed(game_scene)
		MusicManager.play_music(baseTrack, -15.0)
		game_started = true

func add_score(points: int) -> void:
	score += points
	if score <= 0:
		score = 0
	JavaScriptBridge.eval("sendScoreToReact(" + str(score) + ");")

func reset_score() -> void:
	score = 0
	JavaScriptBridge.eval("sendScoreToReact(" + str(score) + ");")
	
