extends Area2D

@export var speed := 600.0
@export var lifetime := 10.0  # seconds before despawn
@export var damage := 1.0
@export var angle_degrees := 0.0  # 0 = straight up by default
@export var volume_mult := 1.0 

const SPEED_MULT := 1.0
const LIFETIME_MULT := 1.0
const DAMAGE_MULT := 100.0

enum PlayerState { NORMAL, INVINCIBLE, DEAD }
var state: PlayerState = PlayerState.NORMAL
var starttoggle = false

# invincibility
var flash_timer := 0.0
var flash_interval := 0.1

var time_alive := 0.0
var velocity := Vector2.ZERO
var player: Node2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var element_type: GameManager.ElementType = GameManager.ElementType.NEUTRAL

func _ready():
	player = get_tree().get_first_node_in_group("player")
	var bg = get_tree().get_first_node_in_group("background")
	
	# check if the powerup is currently acvtive
	if !GameManager.inv_active:
		bg.continue_pos()
		bg.mode = 3000
	z_index = 0 # so it doesn't layer in front of player

	var angle_radians = deg_to_rad(angle_degrees)
	velocity = Vector2(0, -1).rotated(angle_radians) * speed * SPEED_MULT
	rotation = angle_radians

func _process(delta):
	time_alive += delta
	GameManager.speed *= 1.05
	if is_instance_valid(player):
		rotation = player.rotation
		var offset = Vector2.UP.rotated(player.rotation) * 700
		position = player.position + offset
	if time_alive >= lifetime * LIFETIME_MULT:
		queue_free()
	
	if (lifetime * LIFETIME_MULT) - time_alive <= lifetime / 5:
		state = PlayerState.INVINCIBLE
	
	if state == PlayerState.INVINCIBLE:
		flash_timer += delta
		if flash_timer >= flash_interval:
			visible = not visible
			flash_timer = 0.0
	else:
		visible = true

func _on_area_entered(area):
	if area.is_in_group("destroyable"):
		area.flash_red()
		area.take_damage(damage * DAMAGE_MULT, element_type)
		
		
func splash(hit_asteroid):
	var splish = preload("res://scenes/splash.tscn").instantiate()
	splish.global_position = global_position
	splish.scale = scale
	get_parent().add_child(splish)
	
	var splash_radius := 200.0 * ((scale.x + scale.y) / 2.0)

	for asteroid in get_tree().get_nodes_in_group("destroyable"):
		if asteroid == null or not asteroid.is_inside_tree():
			continue
		if asteroid == hit_asteroid:
			continue
		var dist = position.distance_to(asteroid.position)
		if dist <= splash_radius:
			asteroid.take_damage(damage * DAMAGE_MULT * 0.5, GameManager.ElementType.WATER)
			asteroid.flash_red()
