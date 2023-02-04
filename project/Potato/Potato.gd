extends KinematicBody2D

signal fired(bullet)

## Radians per second
const WEAPON_ROTATION_SPEED := TAU/8.0

## What's the longest amount of time that is relevant for increasing power
const MAX_HOLD_DURATION := 1.0

const MIN_IMPULSE_POWER := 100
const MAX_IMPULSE_POWER := 400

enum _Facing { LEFT, RIGHT }

## Index of the controlling player (0-based)
export var player_index := 0

var active := false setget _set_active

var _GRAVITY : float = ProjectSettings.get_setting("physics/2d/default_gravity")

var _velocity := Vector2.ZERO
var _facing = _Facing.RIGHT
var _elevation := 0.0

## The number of seconds the fire button has been held
var _hold_duration := 0.0

onready var _weapon_hinge := $WeaponHinge
onready var _arrow : Sprite = $"%Arrow"


func _physics_process(delta:float)->void:
	if not active:
		return
	
	var action_prefix := "p%d_" % player_index
	var direction := Input.get_axis(action_prefix + "left", action_prefix + "right")
	var linear_velocity := Vector2(200*direction, 0)

	if direction!=0:
		_facing = _Facing.RIGHT if direction>0 else _Facing.LEFT
		# Setting scale.x to -1 or 1 does not work because then the child's
		# rotation gets unpredictable. Instead, later, the rotation is updated
		# based on facing. Here, then, we have to flip the hinge's y scale so
		# that it's not upside-down.
		_weapon_hinge.scale.y = -1 if direction<0 else 1
	
	# Only pull downward when in the air
	if not is_on_floor():
		linear_velocity.y = _GRAVITY
	
	_velocity = move_and_slide(linear_velocity, Vector2.UP)
	
	var elevation_input := Input.get_axis(action_prefix + "up", action_prefix + "down")
	_elevation = clamp(_elevation + elevation_input * WEAPON_ROTATION_SPEED * delta, -TAU/4.0, 0)
	_weapon_hinge.rotation = _elevation if _facing==_Facing.RIGHT else PI - _elevation
	
	var percent := clamp(range_lerp(_hold_duration, 0, MAX_HOLD_DURATION, 0, 1), 0, 1)
	if Input.is_action_pressed(action_prefix + "shoot"):
		_hold_duration += delta
		_set_shader_percent(percent)
	elif Input.is_action_just_released(action_prefix + "shoot"):
		_shoot(percent)
		_hold_duration = 0.0
		

## Shoot a projectile
##
## [power] is the strength as a percent from 0 to 1.
func _shoot(power:float)->void:
	assert(power >= 0 and power <= 1.0)
	var bullet = preload("res://Bullet/Bullet.tscn").instance()

	bullet.global_position = $WeaponHinge/Position2D.global_position
	get_parent().add_child(bullet)
	var impulse_power = lerp(MIN_IMPULSE_POWER, MAX_IMPULSE_POWER, power)
	var impulse = Vector2.RIGHT.rotated($WeaponHinge.rotation) * impulse_power
	bullet.apply_impulse(Vector2.ZERO, impulse)

	emit_signal("fired", bullet)
	
	# single-player playtest placeholder
	yield(bullet, "tree_exited")


func _draw():
	draw_circle(Vector2.ZERO, 25.0, Color.brown)


func _set_active(value:bool)->void:
	active = value
	_arrow.visible = active
	_set_shader_percent(0)


func _set_shader_percent(percent:float)->void:
	assert(percent >= 0.0 and percent <= 1.0)
	(_arrow.material as ShaderMaterial).set_shader_param("percent", percent)

