extends Sprite2D

@export var simple_bullet: PackedScene = preload("res://scenes/bullet_simple.tscn")
@export var drill_bullet: PackedScene = preload("res://scenes/bullet_drill.tscn")
@export var bullet_scene: PackedScene = simple_bullet

# textures
@onready var simple_texture: Texture2D = preload("res://sprites/ship_toppers/simpleTopper.png")
@onready var drill_texture: Texture2D = preload("res://sprites/ship_toppers/drillTopper.png")

# states
enum BulletType { NULL, SIMPLE, DRILL }
var bullet_type: BulletType = BulletType.NULL
enum ShootingType { NULL, NORMAL, CHARGE }
var shooting_type: ShootingType = ShootingType.NULL

# properties
var shoot_interval := 0.3
var shoot_timer := 0.0
var base_damage := 1.0

# charging
var max_charge_time := 1.0
var max_bullet_scale := 2.0

# charge variables
var is_charging := false
var charge_time := 0.0
var current_damage := 1.0

func _ready():
	swap(BulletType.SIMPLE, ShootingType.NORMAL)

func _process(delta):
	match shooting_type:
		ShootingType.NORMAL:
			charge_time = 0.0
			shoot_timer += delta
			if shoot_timer >= shoot_interval:
				shoot_normal_bullet()
				shoot_timer = 0.0
		ShootingType.CHARGE:
			if not get_parent().finger_active:
				charge_time = 0.0
				shoot_timer += delta
				if shoot_timer >= shoot_interval:
					shoot_normal_bullet()
					shoot_timer = 0.0
			else:
				is_charging = true
				charge_time = clamp(charge_time + delta, 0, max_charge_time)
				current_damage = lerp(base_damage, base_damage * 3, charge_time / max_charge_time)
				shoot_timer = 0.0
		
func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed and get_parent().active_finger_index == -1:
			pass
		elif not event.pressed and event.index == get_parent().active_finger_index:
			if charge_time > 0.25:
				shoot_charged_bullet()
				charge_time = 0.0
				current_damage = base_damage
				is_charging = false

func shoot_normal_bullet():
	if bullet_scene == null:
		return
	var bullet = bullet_scene.instantiate()
	bullet.position = global_position + Vector2(0, -25)
	bullet.damage = base_damage
	get_tree().current_scene.add_child(bullet)

func shoot_charged_bullet():
	if bullet_scene == null:
		return
	var bullet = bullet_scene.instantiate()
	bullet.position = global_position + Vector2(0, -25)
	var charge_ratio = charge_time / max_charge_time
	bullet.scale = Vector2.ONE * lerp(1.0, max_bullet_scale, charge_ratio)
	bullet.damage = current_damage
	bullet.speed *= (1.0 + charge_ratio / 1.5)
	get_tree().current_scene.add_child(bullet)

func swap(new_bullet_type: BulletType = BulletType.NULL, new_shooting_type: ShootingType = ShootingType.NULL) -> void:
	if new_bullet_type != BulletType.NULL:
		bullet_type = new_bullet_type
	if new_shooting_type != ShootingType.NULL:
		shooting_type = new_shooting_type
		
	match bullet_type:
		BulletType.SIMPLE:
			texture = simple_texture
			shoot_interval = 0.3
			bullet_scene = simple_bullet
		BulletType.DRILL:
			texture = drill_texture
			shoot_interval = 0.65
			bullet_scene = drill_bullet
