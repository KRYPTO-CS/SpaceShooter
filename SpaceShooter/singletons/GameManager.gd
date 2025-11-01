extends Node

var score: int = 0
var speed = 100
var commCount = 0

var js_code = """
		window.__godotReceiveMessage = function(message) {
			GodotRuntime.print('Godot received message: ' + message);
			if (typeof godot !== 'undefined' && godot) {
				godot.call('handle_react_message', message);
			}
		}
	"""

func _ready():
	JavaScriptBridge.eval("testMessage();")

func _process(_delta):
	speed += 0.01
	
	JavaScriptBridge.eval(js_code)

func add_score(points: int):
	score += points
	print("Score:", score)  # debug

	JavaScriptBridge.eval("sendScoreToReact(" + str(score) + ");")
		
func reset_score():
	score = 0
	JavaScriptBridge.eval("sendScoreToReact(" + str(score) + ");")
	
func handle_react_message(message: String):
	print("Got message from React:", message)
	commCount += 1
