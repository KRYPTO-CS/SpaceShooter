extends GPUParticles2D

var prefix = ""

func _ready():
	if prefix != "":
		var texture_path = "res://sprites/" + prefix + "Debris.png"
		texture = load(texture_path)
	
	emitting = true
	await get_tree().create_timer(lifetime).timeout
	queue_free()
