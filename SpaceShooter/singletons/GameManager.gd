extends Node

var game_scene_0: PackedScene = preload("res://scenes/shooter_main.tscn")
var game_scene_1: PackedScene = preload("res://scenes/bird_main.tscn")

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
var colorblind = 0
var multiplier = 1.0

# communication w/ app
var active_scene
var shipBody: Texture2D = preload("res://sprites/ship_components/ship_body/shipBodyBlue.png")
var shipWings: Texture2D = preload("res://sprites/ship_components/ship_wings/shipWingsRed.png")
var shipDetails: String = ""

# preloads
var explosion = preload("res://scenes/explosion.tscn")

# enums
enum BulletType { NULL, SIMPLE, DRILL, SWIFT, BOOMER, LASER }
enum ShootingType { NULL, NORMAL, CHARGE, TRIPLE, BURST, SPRAY, V, DELTA, RIPPLE, PEA, HEAVY }
enum ElementType { NULL, NEUTRAL, FIRE, ICE, WATER }

func _ready():
	pass

func _process(delta: float) -> void:
	if not game_started:
		return
	
	speed = clamp(speed + SPEED_ACCELERATION * delta, MIN_SPEED, MAX_SPEED)
	swiftCounter = clamp(swiftCounter - SWIFT_DECAY * delta, MIN_SWIFT, MAX_SWIFT)
	
func begin_game() -> void:
	match active_scene:
		0:
			get_tree().change_scene_to_packed(game_scene_0)
		1:
			get_tree().change_scene_to_packed(game_scene_1)
		_:
			get_tree().change_scene_to_packed(game_scene_0)
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
	
