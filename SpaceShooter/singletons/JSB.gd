extends Node

var _callback_ref

var running_web = false

func _ready() -> void:
	if !(OS.has_feature("ios") or OS.has_feature("web_ios") or OS.has_feature("web_windows")):
		print("Not running in web, skipping JS")
		return
		
	running_web = true
	_callback_ref = JavaScriptBridge.create_callback(_on_js_message)
	var window = JavaScriptBridge.get_interface("window")
	window.cb = _callback_ref

func _process(delta: float) -> void:
	pass

func _on_js_message(args):
	if args[0] == "skins":
		GameManager.test_received = true
	if args[1] == "red":
		GameManager.shipBody = preload("res://sprites/ship_components/ship_body/shipBodyRed.png")
