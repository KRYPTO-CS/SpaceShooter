extends Label

@onready var ship_topper: Sprite2D = $"../ShipTopper"

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if ship_topper.bullet_type == GameManager.BulletType.SWIFT:
		text = "%.1f" % (GameManager.swiftCounter)
		visible = true
	else:
		text = "0"
		visible = false
