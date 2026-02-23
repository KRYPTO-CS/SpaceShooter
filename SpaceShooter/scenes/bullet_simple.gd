extends Area2D

@export var speed := 600.0
@export var lifetime := 1.0  # seconds before despawn
@export var damage := 1.0
@export var angle_degrees := 0.0  # 0 = straight up by default
@export var volume_mult := 1.0 

const SPEED_MULT := 1.0
const LIFETIME_MULT := 1.0
const DAMAGE_MULT := 1.0

var time_alive := 0.0
var velocity := Vector2.ZERO

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var element_type: GameManager.ElementType = GameManager.ElementType.NEUTRAL

func _ready():
	z_index = -1 # so it doesn't layer in front of player
	AudioManager.play_sound(preload("res://sounds/simpleShoot.wav"), 0.25, volume_mult) # shot sound
	
	sprite.material = sprite.material.duplicate()
	
	match element_type:
		GameManager.ElementType.FIRE:
			sprite.material.set_shader_parameter("new_palette", load("res://sprites/bullets/palettes/paletteFire.png"))
		GameManager.ElementType.ICE:
			sprite.material.set_shader_parameter("new_palette", load("res://sprites/bullets/palettes/paletteIce.png"))
		GameManager.ElementType.WATER:
			sprite.material.set_shader_parameter("new_palette", load("res://sprites/bullets/palettes/paletteWater.png"))
		_:
			sprite.material.set_shader_parameter("new_palette", load("res://sprites/bullets/palettes/paletteDefault.png"))
	
	var angle_radians = deg_to_rad(angle_degrees)
	velocity = Vector2(0, -1).rotated(angle_radians) * speed * SPEED_MULT
	rotation = angle_radians

func _process(delta):
	position += velocity * delta
	time_alive += delta
	if time_alive >= lifetime * LIFETIME_MULT:
		queue_free()

func _on_area_entered(area):
	if area.is_in_group("destroyable"):
		area.flash_red()
		area.take_damage(damage * DAMAGE_MULT, element_type)
		AudioManager.play_sound(preload("res://sounds/simpleHit.wav"), 0.4, volume_mult)
		match element_type:
			GameManager.ElementType.FIRE:
				AudioManager.play_sound(preload("res://sounds/fireEffect.wav"), 0.3, volume_mult)
			GameManager.ElementType.ICE:
				AudioManager.play_sound(preload("res://sounds/iceEffect.wav"), 0.2, volume_mult)
			GameManager.ElementType.WATER:
				AudioManager.play_sound(preload("res://sounds/waterEffect.wav"), 0.3, volume_mult)
				splash(area)
		queue_free()
		
		
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
