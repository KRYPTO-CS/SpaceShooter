extends Label

@onready var ship_topper: Sprite2D = $"../ShipTopper"

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if ship_topper.shooting_type == ship_topper.ShootingType.CHARGE:
		text = "%.1f" % (ship_topper.charge_time)
		visible = true
	else:
		text = "0"
		visible = false
