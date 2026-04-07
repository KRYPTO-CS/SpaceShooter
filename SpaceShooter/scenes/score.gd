extends Label

func _process(_delta):
	text = str(GameManager.score) + "x" + str(GameManager.multiplier)
