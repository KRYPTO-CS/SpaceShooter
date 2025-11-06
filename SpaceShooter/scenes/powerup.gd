extends Area2D

@onready var simple_texture: Texture2D = preload("res://sprites/powerups/simpleIcon.png")
@onready var drill_texture: Texture2D = preload("res://sprites/powerups/drillIcon.png")
@onready var normal_texture: Texture2D = preload("res://sprites/powerups/normalIcon.png")
@onready var charge_texture: Texture2D = preload("res://sprites/powerups/chargeIcon.png")

enum BulletType { NULL, SIMPLE, DRILL }
var bullet_type: BulletType = BulletType.NULL
enum ShootingType { NULL, NORMAL, CHARGE }
var shooting_type: ShootingType = ShootingType.NULL

@export var speed := 100.0

var prefix = ""

func _ready():
	speed += randf_range(-50.0, 50.0)
	
	if randi() % 2 == 0:
		var options = [BulletType.SIMPLE, BulletType.DRILL]
		bullet_type = options[randi() % options.size()]
	else:
		var options = [ShootingType.NORMAL, ShootingType.CHARGE]
		shooting_type = options[randi() % options.size()]
		
	match bullet_type:
		BulletType.SIMPLE:
			get_child(0).get_child(0).texture = simple_texture
		BulletType.DRILL:
			get_child(0).get_child(0).texture = drill_texture
			
	match shooting_type:
		ShootingType.NORMAL:
			get_child(0).get_child(0).texture = normal_texture
		ShootingType.CHARGE:
			get_child(0).get_child(0).texture = charge_texture

func _process(delta):
	# Move downward
	position.y += speed * delta

	# Delete after a while
	if position.y > 2100:
		queue_free()
		
	# Take damage from flame
	for area in get_overlapping_areas():
		if area.is_in_group("player"):
			var ship_topper = area.get_parent().get_node("ShipTopper")
			if ship_topper:
				ship_topper.swap(bullet_type, shooting_type)
			queue_free()
