extends Node

var score: int = 0
var speed = 100
var commCount = 0

func _ready():
	JavaScriptBridge.eval("testMessage();")

	JavaScriptBridge.eval("""
		window.incrementCommInGodot = function() {
			GodotRuntime.sendMessage('incrementComm');
		};
	""")

func _process(_delta):
	speed += 0.01

func add_score(points: int):
	score += points

	JavaScriptBridge.eval("sendScoreToReact(" + str(score) + ");")
		
func reset_score():
	score = 0
	JavaScriptBridge.eval("sendScoreToReact(" + str(score) + ");")
	

func _on_js_message(message: String):
	if message == "incrementComm":
		commCount += 1
		print("CommCount:", commCount)
		JavaScriptBridge.eval("sendScoreToReact('CommCount: ' + " + str(commCount) + ");")
		
