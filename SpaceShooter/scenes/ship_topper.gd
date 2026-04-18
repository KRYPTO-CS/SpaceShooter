extends Sprite2D

# scene root
@onready var scene_root = get_tree().current_scene
@onready var rng = RandomNumberGenerator.new()

# bullet scenes
@export var simple_bullet: PackedScene = preload("res://scenes/bullet_simple.tscn")
@export var drill_bullet: PackedScene = preload("res://scenes/bullet_drill.tscn")
@export var swift_bullet: PackedScene = preload("res://scenes/bullet_swift.tscn")
@export var boomer_bullet: PackedScene = preload("res://scenes/bullet_boomer.tscn")
@export var laser_beam: PackedScene = preload("res://scenes/laser.tscn")
@export var invincible: PackedScene = preload("res://scenes/invincibility.tscn")
@export var magnet_icon: PackedScene = preload("res://scenes/magnet.tscn")
@export var screenwipe_scene: PackedScene = preload("res://scenes/screenwipe.tscn")
@export var bullet_scene: PackedScene = simple_bullet
@export var bullet_scene_2: PackedScene = simple_bullet

# textures
@onready var simple_texture: Texture2D = preload("res://sprites/ship_toppers/simpleTopper.png")
@onready var drill_texture: Texture2D = preload("res://sprites/ship_toppers/drillTopper.png")
@onready var swift_texture: Texture2D = preload("res://sprites/ship_toppers/swiftTopper.png")
@onready var boomer_texture: Texture2D = preload("res://sprites/ship_toppers/boomerTopper.png")

# states
var bullet_type: GameManager.BulletType = GameManager.BulletType.NULL
var shooting_type: GameManager.ShootingType = GameManager.ShootingType.NULL
var element_type: GameManager.ElementType = GameManager.ElementType.NULL

# properties
var base_shoot_interval := 0.3
var shoot_interval := base_shoot_interval
var shoot_timer := 0.0
var base_damage := 1.0
var shoot_interval_mult := 1.0

# laser
var laser_active := false
var laser_ptr: Node2D = null # tracks the current instance of laser
var laser_max_time := 10.0 # laser time
var laser_timer := 0.0 # time state counter for the laser

# forcefield/invinvibility
var inv_ptr: Node2D = null # tracks the current instance of laser
var inv_max_time := 10.0 # laser time
var inv_timer := 0.0 # time state counter for the laser

# magnet
var magnet_active := false
var mag: Node2D = null # tracks current magnet instanceS
var magnet_max_time := 15.0
var magnet_timer := 0.0

# screenwipe
var screenwipe_active := false
var screenwipe_ptr: Node2D = null
var screenwipe_max_time := 1.0
var screenwipe_timer := 0.0

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

# ripple
const RIPPLE_INC := 5.0
var ripple_offset := RIPPLE_INC
var ripple_direction := false

func _ready():
	swap(GameManager.BulletType.SIMPLE, GameManager.ShootingType.NORMAL, GameManager.ElementType.NEUTRAL)

func _process(delta):
	if get_parent().mode == 1:
		match bullet_type:
			GameManager.BulletType.LASER:
				if laser_timer <= 0:
					shoot_laser_beam()
					laser_active = true
				laser_timer += delta
				if laser_timer >= laser_max_time:
					laser_timer = 0.0
					laser_active = false
					swap(GameManager.BulletType.SIMPLE, shooting_type, element_type)
			GameManager.BulletType.INVINCIBLE:
				if inv_timer <= 0:
					go_invincible()
					GameManager.inv_active = true
				inv_timer += delta
				if inv_timer >= inv_max_time:
					inv_timer = 0.0
					GameManager.inv_active = false
					swap(GameManager.BulletType.SIMPLE, shooting_type, element_type)
		match shooting_type:
			GameManager.ShootingType.SCREENWIPE:
				if screenwipe_timer <= 0:
					activate_screenwipe()
					screenwipe_active = true
				screenwipe_timer += delta
				if screenwipe_timer >= screenwipe_max_time:
					screenwipe_timer = 0.0
					screenwipe_active = false
					swap(bullet_type, GameManager.ShootingType.NORMAL, element_type)
		match element_type:
			GameManager.ElementType.MAGNET:
				if magnet_timer <= 0:
					magnetize()
					magnet_active = true
				magnet_timer += delta
				if magnet_timer >= magnet_max_time:
					magnet_timer = 0.0
					magnet_active = false
					swap(bullet_type, shooting_type, GameManager.ElementType.NEUTRAL)
	elif get_parent().mode == 0:
		shoot_interval = base_shoot_interval / GameManager.swiftCounter
		
		match shooting_type:
			GameManager.ShootingType.NORMAL:
				charge_time = 0.0
				shoot_timer += delta
				if shoot_timer >= shoot_interval * shoot_interval_mult:
					shoot_normal_bullet()
					shoot_timer = 0.0
			GameManager.ShootingType.CHARGE:
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
			GameManager.ShootingType.TRIPLE:
				charge_time = 0.0
				shoot_timer += delta
				if shoot_timer >= shoot_interval * shoot_interval_mult:
					shoot_normal_bullet(0.0, 1.0, 1.0, 0.75)
					shoot_normal_bullet(20.0, 1.0, 1.0, 0.75)
					shoot_normal_bullet(-20.0, 1.0, 1.0, 0.75)
					shoot_timer = 0.0
			GameManager.ShootingType.BURST:
				charge_time = 0.0
				if not is_bursting:
					shoot_timer += delta
				if shoot_timer >= shoot_interval * shoot_interval_mult and not is_bursting:
					shoot_timer = 0.0
					fire_burst()
			GameManager.ShootingType.SPRAY:
				charge_time = 0.0
				shoot_timer += delta
				if shoot_timer >= shoot_interval * shoot_interval_mult:
					shoot_normal_bullet(rng.randf_range(-20.0, 20.0))
					shoot_timer = 0.0
			GameManager.ShootingType.V:
						charge_time = 0.0
						shoot_timer += delta
						if shoot_timer >= shoot_interval * shoot_interval_mult:
							if v_count:
								shoot_normal_bullet(45.0)
							else:
								shoot_normal_bullet(-45.0)
							v_count = !v_count
							shoot_timer = 0.0
			GameManager.ShootingType.DELTA:
				charge_time = 0.0
				shoot_timer += delta
				if shoot_timer >= shoot_interval * shoot_interval_mult:
					shoot_normal_bullet(0.0, 1.0, 1.0, 0.75)
					shoot_normal_bullet(225.0, 1.0, 1.0, 0.75)
					shoot_normal_bullet(-225.0, 1.0, 1.0, 0.75)
					shoot_timer = 0.0
			GameManager.ShootingType.RIPPLE:
				charge_time = 0.0
				shoot_timer += delta
				if shoot_timer >= shoot_interval * shoot_interval_mult:
					shoot_normal_bullet(0.0, 0.75, 0.75, 0.65)
					shoot_normal_bullet(ripple_offset, 0.75, 0.75, 0.65)
					shoot_normal_bullet(-ripple_offset, 0.75, 0.75, 0.65)
					shoot_normal_bullet(ripple_offset * 2.0, 0.75, 0.75, 0.65)
					shoot_normal_bullet(-ripple_offset * 2.0, 0.75, 0.75, 0.65)
					if !ripple_direction:
						ripple_offset += RIPPLE_INC
					else:
						ripple_offset -= RIPPLE_INC
					if ripple_offset == RIPPLE_INC:
						ripple_direction = !ripple_direction
					if ripple_offset == RIPPLE_INC * 10.0:
						ripple_direction = !ripple_direction
					shoot_timer = 0.0
			GameManager.ShootingType.PEA:
				charge_time = 0.0
				shoot_timer += delta
				if shoot_timer >= shoot_interval * shoot_interval_mult:
					shoot_normal_bullet(0.0, 0.75, 0.75, 0.9)
					shoot_timer = 0.0
			GameManager.ShootingType.HEAVY:
				charge_time = 0.0
				shoot_timer += delta
				if shoot_timer >= shoot_interval * shoot_interval_mult:
					shoot_normal_bullet(0.0, 1.5, 2.5, 1.25)
					shoot_timer = 0.0
					
		self.material = self.material.duplicate()
		
		match element_type:
			GameManager.ElementType.FIRE:
				self.material.set_shader_parameter("new_palette", load("res://sprites/bullets/palettes/paletteFire.png"))
			GameManager.ElementType.ICE:
				self.material.set_shader_parameter("new_palette", load("res://sprites/bullets/palettes/paletteIce.png"))
			GameManager.ElementType.WATER:
				self.material.set_shader_parameter("new_palette", load("res://sprites/bullets/palettes/paletteWater.png"))
			_:
				self.material.set_shader_parameter("new_palette", load("res://sprites/bullets/palettes/paletteDefault.png"))
			
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
				
func shoot_laser_beam() -> void:
	if is_instance_valid(laser_ptr):
		laser_ptr.queue_free()

	if laser_beam == null:
		return
		
	var laser = bullet_scene.instantiate()
	laser.lifetime = laser_max_time
	
	laser_ptr = laser
	
	scene_root.add_child(laser)
	
func go_invincible() -> void:
	if is_instance_valid(inv_ptr):
		inv_ptr.queue_free()

	if invincible == null:
		return
		
	var laser = bullet_scene.instantiate()
	laser.lifetime = laser_max_time
	
	inv_ptr = laser
	
	scene_root.add_child(laser)
	
func activate_screenwipe() -> void:
	if is_instance_valid(screenwipe_ptr):
		screenwipe_ptr.queue_free()

	var wipe = screenwipe_scene.instantiate()
	wipe.lifetime = screenwipe_max_time

	screenwipe_ptr = wipe

	scene_root.add_child(wipe)

func magnetize() -> void:
	if is_instance_valid(mag):
		mag.queue_free()

	if laser_beam == null:
		return
		
	var magnet = bullet_scene_2.instantiate()
	magnet.lifetime = magnet_max_time
	
	mag = magnet
	
	scene_root.add_child(magnet)

func shoot_normal_bullet(angle: float = 0.0, scale_mult: float = 1.0, damage_mult: float = 1.0, volume_mult: float = 1.0) -> void:
	if bullet_scene == null:
		return
	var bullet = bullet_scene.instantiate()
	bullet.position = global_position + Vector2(0, -25)
	bullet.scale *= scale_mult
	bullet.damage = base_damage * damage_mult
	bullet.angle_degrees = angle
	bullet.volume_mult = volume_mult
	bullet.element_type = element_type
	scene_root.add_child(bullet)

func shoot_charged_bullet():
	if bullet_scene == null:
		return
	var bullet = bullet_scene.instantiate()
	bullet.position = global_position + Vector2(0, -25)
	var charge_ratio = charge_time / max_charge_time
	bullet.scale = Vector2.ONE * lerp(1.0, max_bullet_scale, charge_ratio)
	bullet.volume_mult = lerp(1.0, 4.0, charge_ratio)
	bullet.element_type = element_type
	bullet.damage = current_damage
	bullet.speed *= (1.0 + charge_ratio / 1.5)
	scene_root.add_child(bullet)

func swap(new_bullet_type: GameManager.BulletType = GameManager.BulletType.NULL, new_shooting_type: GameManager.ShootingType = GameManager.ShootingType.NULL, new_element_type: GameManager.ElementType = GameManager.ElementType.NULL) -> void:
	if new_bullet_type != GameManager.BulletType.NULL:
		bullet_type = new_bullet_type
	if new_shooting_type != GameManager.ShootingType.NULL:
		shooting_type = new_shooting_type
	if new_element_type != GameManager.ElementType.NULL:
		element_type = new_element_type
		
	match bullet_type:
		GameManager.BulletType.SIMPLE:
			texture = simple_texture
			base_shoot_interval = 0.3
			bullet_scene = simple_bullet
			GameManager.swiftCounter = 1.0
		GameManager.BulletType.DRILL:
			texture = drill_texture
			base_shoot_interval = 0.6
			bullet_scene = drill_bullet
			GameManager.swiftCounter = 1.0
		GameManager.BulletType.SWIFT:
			texture = swift_texture
			base_shoot_interval = 0.3
			bullet_scene = swift_bullet
		GameManager.BulletType.BOOMER:
			texture = boomer_texture
			base_shoot_interval = 0.6
			bullet_scene = boomer_bullet
		GameManager.BulletType.LASER:
			bullet_scene = laser_beam
			if new_bullet_type == GameManager.BulletType.LASER:
				laser_timer = 0.0 # reset timer
		GameManager.BulletType.INVINCIBLE:
			bullet_scene = invincible
			if new_bullet_type == GameManager.BulletType.INVINCIBLE:
				inv_timer = 0.0 # reset timer
	
	match element_type:
		GameManager.ElementType.MAGNET:
			bullet_scene_2 = magnet_icon
			magnet_timer = 0.0
			
	match shooting_type:
		GameManager.ShootingType.SCREENWIPE:
			screenwipe_timer = 0.0
		GameManager.ShootingType.NORMAL:
			shoot_interval_mult = 1.0
		GameManager.ShootingType.CHARGE:
			shoot_interval_mult = 1.0
		GameManager.ShootingType.TRIPLE:
			shoot_interval_mult = 2.0
		GameManager.ShootingType.BURST:
			shoot_interval_mult = 1.75
		GameManager.ShootingType.SPRAY:
			shoot_interval_mult = 0.75
		GameManager.ShootingType.V:
			shoot_interval_mult = 0.5
		GameManager.ShootingType.DELTA:
			shoot_interval_mult = 1.25
		GameManager.ShootingType.RIPPLE:
			shoot_interval_mult = 2.0
		GameManager.ShootingType.PEA:
			shoot_interval_mult = 0.75
		GameManager.ShootingType.HEAVY:
			shoot_interval_mult = 2.0
			
func fire_burst():
	is_bursting = true
	burst_count = 0

	while burst_count < 5:
		shoot_normal_bullet(0.0, 0.75, 0.75, 0.9)
		burst_count += 1
		await get_tree().create_timer(0.075).timeout 

	is_bursting = false
