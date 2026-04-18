extends Area2D

@export var lifetime := 1.5
@export var max_radius := 1600.0
@export var damage := 1.0

const DAMAGE_MULT := 100.0

var time_alive := 0.0
var current_radius := 0.0
var player: Node2D

var flash_timer := 0.0
var flash_interval := 0.1
var fading := false

var element_type: GameManager.ElementType = GameManager.ElementType.NEUTRAL

func _ready():
	player = get_tree().get_first_node_in_group("player")
	z_index = 0

func _process(delta):
	time_alive += delta

	if is_instance_valid(player):
		position = player.position

	var t = clamp(time_alive / lifetime, 0.0, 1.0)
	current_radius = lerp(0.0, max_radius, t)

	# update the collision shape radius
	$CollisionShape2D.shape.radius = current_radius
	$Sprite2D.rotation -= 0.01

	# scale the visual to match
	if current_radius > 0:
		var base_radius := 50.0
		var s = current_radius / base_radius
		$Sprite2D.scale = Vector2(s, s) * 0.08

	# flash near the end
	if lifetime - time_alive <= lifetime / 5.0:
		fading = true

	if fading:
		flash_timer += delta
		if flash_timer >= flash_interval:
			visible = not visible
			flash_timer = 0.0
	else:
		visible = true

	if time_alive >= lifetime:
		queue_free()

func _on_area_entered(area):
	if area.is_in_group("destroyable"):
		area.flash_red()
		area.take_damage(damage * DAMAGE_MULT, element_type)
