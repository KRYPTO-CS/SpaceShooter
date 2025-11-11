extends Area2D

enum BulletType { NULL, SIMPLE, DRILL, SWIFT }
var bullet_type: BulletType = BulletType.NULL
enum ShootingType { NULL, NORMAL, CHARGE, TRIPLE, BURST, SPRAY, V, DELTA }
var shooting_type: ShootingType = ShootingType.NULL
enum ElementType { NULL, NEUTRAL, FIRE, ICE }
var element_type: ElementType = ElementType.NULL

@onready var box: Sprite2D = $Box
@onready var icon: Sprite2D = $Box/Icon

# UI access
@onready var bulletUI = get_tree().root.get_node("Main/UI/PowerupUI/BulletType")
@onready var shootingUI = get_tree().root.get_node("Main/UI/PowerupUI/ShootingType")
@onready var elementUI = get_tree().root.get_node("Main/UI/PowerupUI/ElementType")

var box_textures = {
	0: preload("res://sprites/powerups/bulletBoxIcon.png"),
	1: preload("res://sprites/powerups/shootingBoxIcon.png"),
	2: preload("res://sprites/powerups/elementBoxIcon.png")
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

var element_textures = {
	ElementType.NEUTRAL: preload("res://sprites/powerups/neutralIcon.png"),
	ElementType.FIRE: preload("res://sprites/powerups/fireIcon.png"),
	ElementType.ICE: preload("res://sprites/powerups/iceIcon.png"),
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
				ship_topper.swap(bullet_type, shooting_type, element_type)
			if bullet_type != BulletType.NULL:
				AudioManager.play_sound(preload("res://sounds/powerup1.wav"), 0.75)
				bulletUI.texture = bullet_textures.get(bullet_type, null)
			elif shooting_type != ShootingType.NULL:
				AudioManager.play_sound(preload("res://sounds/powerup2.wav"), 0.75)
				shootingUI.texture = shooting_textures.get(shooting_type, null)
			elif element_type != ElementType.NULL:
				AudioManager.play_sound(preload("res://sounds/powerup3.wav"), 0.75)
				elementUI.texture = element_textures.get(element_type, null)
			queue_free()
			return
	
func choose_type() -> void:
	var bullet_values = BulletType.values().filter(func(v): return v != BulletType.NULL)
	var shooting_values = ShootingType.values().filter(func(v): return v != ShootingType.NULL)
	var element_values = ElementType.values().filter(func(v): return v != ElementType.NULL)
	
	var category = randi_range(0, 2)  # 0 = bullet, 1 = shooting, 2 = element
	match category:
		0:
			bullet_type = bullet_values.pick_random()
		1:
			shooting_type = shooting_values.pick_random()
		2:
			element_type = element_values.pick_random()

func set_sprite() -> void:
	if bullet_type != BulletType.NULL:
		icon.texture = bullet_textures.get(bullet_type, null)
		box.texture = box_textures.get(0, null)
	elif shooting_type != ShootingType.NULL:
		icon.texture = shooting_textures.get(shooting_type, null)
		box.texture = box_textures.get(1, null)
	elif element_type != ElementType.NULL:
		icon.texture = element_textures.get(element_type, null)
		box.texture = box_textures.get(2, null)
