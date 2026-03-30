extends ColorRect


# Called when the node enters the scene tree for the first time.
func _process(_delta: float) -> void:
	match GameManager.colorblind: # set colorblind
		0:
			pass
		1:
			color = Color(1, 0, 1, 0.15)
			visible = true
		2:
			color = Color(0, 1, 1, 0.15)
			visible = true
		3:
			color = Color(1, 1, 0, 0.15)
			visible = true
		_:
			pass
