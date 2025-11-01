extends Node

var score: int = 0
var speed: float = 100
var commCount: int = 0

func _ready():
	print("GameManager ready")

	# Send a test message to confirm game -> React works
	JavaScriptBridge.eval("testMessage();")

	# Inject function accessible from HTML/React
	JavaScriptBridge.eval("""
		window.incrementCommInGodot = function() {
			if (typeof GodotRuntime !== 'undefined' && GodotRuntime.onMessageFromJS) {
				GodotRuntime.onMessageFromJS('incrementComm');
			} else {
				console.log('GodotRuntime not ready to receive message');
			}
		};
	""")

	var engine_interface = JavaScriptBridge.get_interface("engine")
	if engine_interface:
		engine_interface.connect("message", Callable(self, "_on_js_message"))
		print("Connected JS message listener in Godot")
	else:
		print("Could not get JS engine interface")

func _process(_delta: float) -> void:
	speed += 0.01

func add_score(points: int) -> void:
	score += points
	JavaScriptBridge.eval("sendScoreToReact(" + str(score) + ");")

func reset_score() -> void:
	score = 0
	JavaScriptBridge.eval("sendScoreToReact(" + str(score) + ");")

func _on_js_message(message: String) -> void:
	print("Message from JS:", message)
	commCount += 1

	if message == "incrementComm":
		commCount += 1
		print("CommCount incremented to", commCount)
		JavaScriptBridge.eval("sendScoreToReact('CommCount: ' + " + str(commCount) + ");")
