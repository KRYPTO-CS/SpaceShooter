extends Sprite2D

# scene root
@onready var scene_root = get_tree().current_scene
@onready var rng = RandomNumberGenerator.new()

# bullet scenes
@export var simple_bullet: PackedScene = preload("res://scenes/bullet_simple.tscn")
@export var drill_bullet: PackedScene = preload("res://scenes/bullet_drill.tscn")
@export var swift_bullet: PackedScene = preload("res://scenes/bullet_swift.tscn")
@export var bullet_scene: PackedScene = simple_bullet

# textures
@onready var simple_texture: Texture2D = preload("res://sprites/ship_toppers/simpleTopper.png")
@onready var drill_texture: Texture2D = preload("res://sprites/ship_toppers/drillTopper.png")
@onready var swift_texture: Texture2D = preload("res://sprites/ship_toppers/swiftTopper.png")

# states
enum BulletType { NULL, SIMPLE, DRILL, SWIFT }
var bullet_type: BulletType = BulletType.NULL
enum ShootingType { NULL, NORMAL, CHARGE, TRIPLE, BURST, SPRAY, V, DELTA }
var shooting_type: ShootingType = ShootingType.NULL

# properties
var base_shoot_interval := 0.3
var shoot_interval := base_shoot_interval
var shoot_timer := 0.0
var base_damage := 1.0
var shoot_interval_mult := 1.0

# charge
var max_charge_time := 3.0
var max_bullet_scale := 2.0
var is_charging := false
var charge_time := 0.0
var current_damage := 1.0

# burst
var burst_count := 0
var is_bursting = false

# v
var v_count := false

func _ready():
	swap(BulletType.SIMPLE, ShootingType.NORMAL)

func _process(delta):
	shoot_interval = base_shoot_interval / GameManager.swiftCounter
	
	match shooting_type:
		ShootingType.NORMAL:
			charge_time = 0.0
			shoot_timer += delta
			if shoot_timer >= shoot_interval * shoot_interval_mult:
				shoot_normal_bullet()
				shoot_timer = 0.0
		ShootingType.CHARGE:
			if not get_parent().finger_active:
				charge_time = 0.0
				shoot_timer += delta
				if shoot_timer >= shoot_interval * shoot_interval_mult:
					shoot_normal_bullet()
					shoot_timer = 0.0
			else:
				is_charging = true
				charge_time = clamp(charge_time + (delta / shoot_interval), 0, max_charge_time)
				current_damage = lerp(base_damage, base_damage * 3, charge_time / max_charge_time)
				shoot_timer = 0.0
		ShootingType.TRIPLE:
			charge_time = 0.0
			shoot_timer += delta
			if shoot_timer >= shoot_interval * shoot_interval_mult:
				shoot_normal_bullet(0.0, 1.0, 1.0, 0.75)
				shoot_normal_bullet(20.0, 1.0, 1.0, 0.75)
				shoot_normal_bullet(-20.0, 1.0, 1.0, 0.75)
				shoot_timer = 0.0
		ShootingType.BURST:
			charge_time = 0.0
			if not is_bursting:
				shoot_timer += delta
			if shoot_timer >= shoot_interval * shoot_interval_mult and not is_bursting:
				shoot_timer = 0.0
				fire_burst()
		ShootingType.SPRAY:
			charge_time = 0.0
			shoot_timer += delta
			if shoot_timer >= shoot_interval * shoot_interval_mult:
				shoot_normal_bullet(rng.randf_range(-20.0, 20.0))
				shoot_timer = 0.0
		ShootingType.V:
					charge_time = 0.0
					shoot_timer += delta
					if shoot_timer >= shoot_interval * shoot_interval_mult:
						if v_count:
							shoot_normal_bullet(45.0)
						else:
							shoot_normal_bullet(-45.0)
						v_count = !v_count
						shoot_timer = 0.0
		ShootingType.DELTA:
			charge_time = 0.0
			shoot_timer += delta
			if shoot_timer >= shoot_interval * shoot_interval_mult:
				shoot_normal_bullet(0.0, 1.0, 1.0, 0.75)
				shoot_normal_bullet(225.0, 1.0, 1.0, 0.75)
				shoot_normal_bullet(-225.0, 1.0, 1.0, 0.75)
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

func shoot_normal_bullet(angle: float = 0.0, scale_mult: float = 1.0, damage_mult: float = 1.0, volume_mult: float = 1.0) -> void:
	if bullet_scene == null:
		return
	var bullet = bullet_scene.instantiate()
	bullet.position = global_position + Vector2(0, -25)
	bullet.scale *= scale_mult
	bullet.damage = base_damage * damage_mult
	bullet.angle_degrees = angle
	bullet.volume_mult = volume_mult
	scene_root.add_child(bullet)

func shoot_charged_bullet():
	if bullet_scene == null:
		return
	var bullet = bullet_scene.instantiate()
	bullet.position = global_position + Vector2(0, -25)
	var charge_ratio = charge_time / max_charge_time
	bullet.scale = Vector2.ONE * lerp(1.0, max_bullet_scale, charge_ratio)
	bullet.volume_mult = lerp(1.0, 4.0, charge_ratio)
	bullet.damage = current_damage
	bullet.speed *= (1.0 + charge_ratio / 1.5)
	scene_root.add_child(bullet)

func swap(new_bullet_type: BulletType = BulletType.NULL, new_shooting_type: ShootingType = ShootingType.NULL) -> void:
	if new_bullet_type != BulletType.NULL:
		bullet_type = new_bullet_type
	if new_shooting_type != ShootingType.NULL:
		shooting_type = new_shooting_type
		
	match bullet_type:
		BulletType.SIMPLE:
			texture = simple_texture
			base_shoot_interval = 0.3
			bullet_scene = simple_bullet
			GameManager.swiftCounter = 1.0
		BulletType.DRILL:
			texture = drill_texture
			base_shoot_interval = 0.6
			bullet_scene = drill_bullet
			GameManager.swiftCounter = 1.0
		BulletType.SWIFT:
			texture = swift_texture
			base_shoot_interval = 0.3
			bullet_scene = swift_bullet
			
	match shooting_type:
		ShootingType.NORMAL:
			shoot_interval_mult = 1.0
		ShootingType.CHARGE:
			shoot_interval_mult = 1.0
		ShootingType.TRIPLE:
			shoot_interval_mult = 2.0
		ShootingType.BURST:
			shoot_interval_mult = 1.75
		ShootingType.SPRAY:
			shoot_interval_mult = 0.75
		ShootingType.V:
			shoot_interval_mult = 0.5
		ShootingType.DELTA:
			shoot_interval_mult = 1.25
			
func fire_burst():
	is_bursting = true
	burst_count = 0

	while burst_count < 5:
		shoot_normal_bullet(0.0, 0.75, 0.75, 0.9)
		burst_count += 1
		await get_tree().create_timer(0.075).timeout 

	is_bursting = false
