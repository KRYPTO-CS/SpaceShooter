extends Label

func _process(_delta: float) -> void:
	if JSB.running_web == true:
		text = ""
