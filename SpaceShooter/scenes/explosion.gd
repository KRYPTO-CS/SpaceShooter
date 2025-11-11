extends GPUParticles2D

var prefix = ""

var active_status: GameManager.ElementType = GameManager.ElementType.NEUTRAL

const NORMAL := Color(1.0, 1.0, 1.0)
const RED := Color(1, 0.25, 0)
const ORANGE := Color(1.0, 0.5, 0)
const CYAN := Color(0.4, 0.7, 1)

func _ready():
	if prefix != "":
		var texture_path = "res://sprites/" + prefix + "Debris.png"
		texture = load(texture_path)
		
	match active_status:
		GameManager.ElementType.FIRE:
			modulate = ORANGE
		GameManager.ElementType.ICE:
			modulate = CYAN
		_:
			modulate = NORMAL
	
	emitting = true
	await get_tree().create_timer(lifetime).timeout
	queue_free()
