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

func _on_js_message(args):
	if args[0] == "skins":
		GameManager.test_received = true
		match args[1]: # set body skin
			"red":
				GameManager.shipBody = preload("res://sprites/ship_components/ship_body/shipBodyRed.png")
			"green":
				GameManager.shipBody = preload("res://sprites/ship_components/ship_body/shipBodyGreen.png")
			"blue":
				GameManager.shipBody = preload("res://sprites/ship_components/ship_body/shipBodyBlue.png")
		match args[2]: # set wing skin
			"red":
				GameManager.shipWings = preload("res://sprites/ship_components/ship_wings/shipWingsRed.png")
			"green":
				GameManager.shipWings = preload("res://sprites/ship_components/ship_wings/shipWingsGreen.png")
			"blue":
				GameManager.shipWings = preload("res://sprites/ship_components/ship_wings/shipWingsBlue.png")
