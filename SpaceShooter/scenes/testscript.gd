extends Label

func _process(_delta: float) -> void:
	if GameManager.test_received == true:
		label_settings.font_color = Color.BLUE
