extends GPUParticles2D

var prefix = ""

enum Status { NONE, FIRE, ICE }
var active_status: Status = Status.NONE

const NORMAL := Color(1.0, 1.0, 1.0)
const RED := Color(1, 0.25, 0)
const ORANGE := Color(1.0, 0.5, 0)
const CYAN := Color(0.4, 0.7, 1)

func _ready():
	if prefix != "":
		var texture_path = "res://sprites/" + prefix + "Debris.png"
		texture = load(texture_path)
		
	match active_status:
		Status.FIRE:
			modulate = ORANGE
		Status.ICE:
			modulate = CYAN
		_:
			modulate = NORMAL
	
	emitting = true
	await get_tree().create_timer(lifetime).timeout
	queue_free()
