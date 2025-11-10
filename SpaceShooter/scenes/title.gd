extends Node2D

@onready var prompt: Label = $UI/Prompt

@export var max_tap_duration: float = 0.5  # seconds - must release within this time

var touch_start_time: float = 0.0
var blink_timer: float = 0.0
var blink_interval: float = 0.5

func _process(delta: float) -> void:
	blink_timer += delta
	if blink_timer >= blink_interval:
		prompt.visible = not prompt.visible
		blink_timer = 0.0

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_start_time = Time.get_ticks_msec() / 1000.0
		else:
			var touch_end_time = Time.get_ticks_msec() / 1000.0
			if touch_end_time - touch_start_time <= max_tap_duration:
				start_game()
				
	elif event is InputEventMouseButton:
		if event.pressed:
			touch_start_time = Time.get_ticks_msec() / 1000.0
		else:
			var touch_end_time = Time.get_ticks_msec() / 1000.0
			if touch_end_time - touch_start_time <= max_tap_duration:
				start_game()

func start_game():
	GameManager.begin_game()
