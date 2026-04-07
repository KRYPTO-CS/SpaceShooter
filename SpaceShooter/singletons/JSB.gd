extends Node

var _callback_ref

var running_web = false

func _ready() -> void:
	if !(OS.has_feature("web_android") or OS.has_feature("web_ios") or OS.has_feature("web_windows")):
		print("Not running in web, skipping JS")
		GameManager.active_scene = 0
		return
	
	JavaScriptBridge.eval("testMessage();")
	
	running_web = true
	_callback_ref = JavaScriptBridge.create_callback(_on_js_message)
	var window = JavaScriptBridge.get_interface("window")
	window.cb = _callback_ref

func _on_js_message(args):
	if args[0] == "skins":
		GameManager.test_received = true
		match args[1]: # set body skin
			"1":
				GameManager.shipBody = preload("res://sprites/ship_components/ship_body/shipBodyRed.png")
			"2":
				GameManager.shipBody = preload("res://sprites/ship_components/ship_body/shipBodyGreen.png")
			"0":
				GameManager.shipBody = preload("res://sprites/ship_components/ship_body/shipBodyBlue.png")
			"3":
				GameManager.shipBody = preload("res://sprites/ship_components/ship_body/shipBodyYellow.png")
			_:
				GameManager.shipBody = preload("res://sprites/ship_components/ship_body/shipBodyBlue.png")
		match args[2]: # set wing skin
			"1":
				GameManager.shipWings = preload("res://sprites/ship_components/ship_wings/shipWingsRed.png")
			"2":
				GameManager.shipWings = preload("res://sprites/ship_components/ship_wings/shipWingsGreen.png")
			"0":
				GameManager.shipWings = preload("res://sprites/ship_components/ship_wings/shipWingsBlue.png")
			"3":
				GameManager.shipWings = preload("res://sprites/ship_components/ship_wings/shipWingsYellow.png")
			_:
				GameManager.shipWings = preload("res://sprites/ship_components/ship_wings/shipWingsRed.png")
		match args[3]: # set game
			"0":
				GameManager.active_scene = 0
			"1":
				GameManager.active_scene = 1
			_:
				pass
		match args[4]: # set mult
			"1":
				GameManager.multiplier = 1.0
			"2":
				GameManager.multiplier = 1.1
			"3":
				GameManager.multiplier = 1.2
			"4":
				GameManager.multiplier = 1.4
			"5":
				GameManager.multiplier = 1.6
			"6":
				GameManager.multiplier = 1.8
			"7":
				GameManager.multiplier = 2.0
			"8":
				GameManager.multiplier = 2.5
			"9":
				GameManager.multiplier = 3.0
			_:
				pass
		match args[5]: # set colorblind
			"0":
				GameManager.colorblind = 0
			"1":
				GameManager.colorblind = 1
			"2":
				GameManager.colorblind = 2
			"3":
				GameManager.colorblind = 3
			_:
				pass
		match args[6]: # set details
			"0":
				GameManager.shipDetails = "blue_fire"
			"1":
				GameManager.shipDetails = "blue_fire"
			_:
				pass
