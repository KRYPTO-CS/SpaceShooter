extends Label

func _process(_delta):
	text = "%.1f" % GameManager.speed
