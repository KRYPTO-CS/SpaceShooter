extends Area2D

var bullet_type: GameManager.BulletType = GameManager.BulletType.NULL
var shooting_type: GameManager.ShootingType = GameManager.ShootingType.NULL
var element_type: GameManager.ElementType = GameManager.ElementType.NULL

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
	GameManager.BulletType.SIMPLE: preload("res://sprites/powerups/simpleIcon.png"),
	GameManager.BulletType.DRILL:  preload("res://sprites/powerups/drillIcon.png"),
	GameManager.BulletType.SWIFT:  preload("res://sprites/powerups/swiftIcon.png"),
	GameManager.BulletType.BOOMER:  preload("res://sprites/powerups/boomerIcon.png"),
	GameManager.BulletType.LASER: preload("res://sprites/powerups/laser_p.png"),
}

var shooting_textures = {
	GameManager.ShootingType.NORMAL: preload("res://sprites/powerups/normalIcon.png"),
	GameManager.ShootingType.CHARGE: preload("res://sprites/powerups/chargeIcon.png"),
	GameManager.ShootingType.TRIPLE: preload("res://sprites/powerups/tripleIcon.png"),
	GameManager.ShootingType.BURST: preload("res://sprites/powerups/burstIcon.png"),
	GameManager.ShootingType.SPRAY: preload("res://sprites/powerups/sprayIcon.png"),
	GameManager.ShootingType.V: preload("res://sprites/powerups/vIcon.png"),
	GameManager.ShootingType.DELTA: preload("res://sprites/powerups/deltaIcon.png"),
	GameManager.ShootingType.RIPPLE: preload("res://sprites/powerups/rippleIcon.png"),
	GameManager.ShootingType.PEA: preload("res://sprites/powerups/peaIcon.png"),
	GameManager.ShootingType.HEAVY: preload("res://sprites/powerups/heavyIcon.png"),
}

var element_textures = {
	GameManager.ElementType.NEUTRAL: preload("res://sprites/powerups/neutralIcon.png"),
	GameManager.ElementType.FIRE: preload("res://sprites/powerups/fireIcon.png"),
	GameManager.ElementType.ICE: preload("res://sprites/powerups/iceIcon.png"),
	GameManager.ElementType.WATER: preload("res://sprites/powerups/waterIcon.png"),
}

var speed_x := 0.0
var speed_y := 0.0

func _ready():
	randomize()
	speed_y += randf_range(-50.0, 50.0)
	choose_type()
	set_sprite()

func _process(delta):
	position.y += speed_y * delta
	position.x -= speed_x * delta
	if position.y > 2100:
		queue_free()
	_check_player_collision()

func _check_player_collision() -> void:
	for area in get_overlapping_areas():
		if area.is_in_group("player"):
			var ship_topper = area.get_parent().get_node_or_null("ShipTopper")
			if ship_topper:
				ship_topper.swap(bullet_type, shooting_type, element_type)
			if bullet_type != GameManager.BulletType.NULL:
				AudioManager.play_sound(preload("res://sounds/powerup1.wav"), 0.75)
				bulletUI.texture = bullet_textures.get(bullet_type, null)
			elif shooting_type != GameManager.ShootingType.NULL:
				AudioManager.play_sound(preload("res://sounds/powerup2.wav"), 0.75)
				shootingUI.texture = shooting_textures.get(shooting_type, null)
			elif element_type != GameManager.ElementType.NULL:
				AudioManager.play_sound(preload("res://sounds/powerup3.wav"), 0.75)
				elementUI.texture = element_textures.get(element_type, null)
			queue_free()
			return
	
func choose_type() -> void:
	if get_parent().mode == 0:
		var bullet_values = GameManager.BulletType.values().filter(func(v): return v != GameManager.BulletType.NULL)
		var shooting_values = GameManager.ShootingType.values().filter(func(v): return v != GameManager.ShootingType.NULL)
		var element_values = GameManager.ElementType.values().filter(func(v): return v != GameManager.ElementType.NULL)
		var category = randi_range(0, 2)  # 0 = bullet, 1 = shooting, 2 = element
		match category:
			0:
				bullet_type = bullet_values.pick_random()
			1:
				shooting_type = shooting_values.pick_random()
			2:
				element_type = element_values.pick_random()
	elif get_parent().mode == 1:
		var bullet_values = GameManager.BulletType.values().filter(func(v): return v == GameManager.BulletType.LASER)
		var shooting_values = GameManager.ShootingType.values().filter(func(v): return v != GameManager.ShootingType.NULL)
		var element_values = GameManager.ElementType.values().filter(func(v): return v != GameManager.ElementType.NULL)
		var category = randi_range(0, 0)  # 0 = bullet, 1 = shooting, 2 = element
		match category:
			0:
				bullet_type = bullet_values.pick_random()
			1:
				shooting_type = shooting_values.pick_random()
			2:
				element_type = element_values.pick_random()

func set_sprite() -> void:
	if bullet_type != GameManager.BulletType.NULL:
		icon.texture = bullet_textures.get(bullet_type, null)
		box.texture = box_textures.get(0, null)
	elif shooting_type != GameManager.ShootingType.NULL:
		icon.texture = shooting_textures.get(shooting_type, null)
		box.texture = box_textures.get(1, null)
	elif element_type != GameManager.ElementType.NULL:
		icon.texture = element_textures.get(element_type, null)
		box.texture = box_textures.get(2, null)
