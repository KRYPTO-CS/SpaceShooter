extends Area2D

enum BulletType { NULL, SIMPLE, DRILL, SWIFT }
var bullet_type: BulletType = BulletType.NULL
enum ShootingType { NULL, NORMAL, CHARGE, TRIPLE, BURST, SPRAY, V, DELTA }
var shooting_type: ShootingType = ShootingType.NULL

@onready var box: Sprite2D = $Box
@onready var icon: Sprite2D = $Box/Icon

var box_textures = {
	0: preload("res://sprites/powerups/bulletBoxIcon.png"),
	1: preload("res://sprites/powerups/shootingBoxIcon.png"),
}

var bullet_textures = {
	BulletType.SIMPLE: preload("res://sprites/powerups/simpleIcon.png"),
	BulletType.DRILL:  preload("res://sprites/powerups/drillIcon.png"),
	BulletType.SWIFT:  preload("res://sprites/powerups/swiftIcon.png"),
}

var shooting_textures = {
	ShootingType.NORMAL: preload("res://sprites/powerups/normalIcon.png"),
	ShootingType.CHARGE: preload("res://sprites/powerups/chargeIcon.png"),
	ShootingType.TRIPLE: preload("res://sprites/powerups/tripleIcon.png"),
	ShootingType.BURST: preload("res://sprites/powerups/burstIcon.png"),
	ShootingType.SPRAY: preload("res://sprites/powerups/sprayIcon.png"),
	ShootingType.V: preload("res://sprites/powerups/vIcon.png"),
	ShootingType.DELTA: preload("res://sprites/powerups/deltaIcon.png"),
}

var speed := 100.0

func _ready():
	randomize()
	speed += randf_range(-50.0, 50.0)
	choose_type()
	set_sprite()

func _process(delta):
	position.y += speed * delta
	if position.y > 2100:
		queue_free()
	_check_player_collision()

func _check_player_collision() -> void:
	for area in get_overlapping_areas():
		if area.is_in_group("player"):
			var ship_topper = area.get_parent().get_node_or_null("ShipTopper")
			if ship_topper:
				ship_topper.swap(bullet_type, shooting_type)
			if bullet_type != BulletType.NULL:
				AudioManager.play_sound(preload("res://sounds/powerup1.wav"), 0.75)
			elif shooting_type != ShootingType.NULL:
				AudioManager.play_sound(preload("res://sounds/powerup2.wav"), 0.75)
			queue_free()
			return
	
func choose_type() -> void:
	var bullet_values = BulletType.values().filter(func(v): return v != BulletType.NULL)
	var shooting_values = ShootingType.values().filter(func(v): return v != ShootingType.NULL)
	
	if randi() % 2 == 0:
		bullet_type = bullet_values.pick_random()
	else:
		shooting_type = shooting_values.pick_random()

func set_sprite() -> void:
	if bullet_type != BulletType.NULL:
		icon.texture = bullet_textures.get(bullet_type, null)
		box.texture = box_textures.get(0, null)
	elif shooting_type != ShootingType.NULL:
		icon.texture = shooting_textures.get(shooting_type, null)
		box.texture = box_textures.get(1, null)
