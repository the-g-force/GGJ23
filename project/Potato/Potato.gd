extends KinematicBody2D

signal fired(bullet)
signal done
signal died
signal unearthed

## Walking speed
const SPEED := 200.0

## Radians per second
const WEAPON_ROTATION_SPEED := TAU/8.0

## What's the longest amount of time that is relevant for increasing power
const MAX_HOLD_DURATION := 1.0

const MIN_IMPULSE_POWER := 100
const MAX_IMPULSE_POWER := 400

const _BURY_DEPTH := 50

enum _Facing { LEFT, RIGHT }

## Index of the controlling player (0-based)
export var player_index := 0

var active := false setget _set_active

var _GRAVITY : float = 10 #ProjectSettings.get_setting("physics/2d/default_gravity")

var _velocity := Vector2.ZERO
var _facing = _Facing.RIGHT
var _elevation := 0.0
var _health := 25 # 100

## The number of seconds the fire button has been held
var _hold_duration := 0.0

onready var _weapon_hinge := $WeaponHinge
onready var _arrow : Sprite = $"%Arrow"
onready var _health_bar : ProgressBar = $HealthBar
onready var _action_prefix := "p%d_" % player_index


func _ready():
	_set_active(false)


func _physics_process(delta:float)->void:
	_health_bar.value = _health
	
	_velocity.y += _GRAVITY
	
	if active:
		var direction := Input.get_axis(_action_prefix + "left", _action_prefix + "right")
		if direction!=0:
			_facing = _Facing.RIGHT if direction>0 else _Facing.LEFT
			_velocity.x = SPEED if direction > 0 else -SPEED
			
			# Setting scale.x to -1 or 1 does not work because then the child's
			# rotation gets unpredictable. Instead, later, the rotation is updated
			# based on facing. Here, then, we have to flip the hinge's y scale so
			# that it's not upside-down.
			_weapon_hinge.scale.y = -1 if direction<0 else 1
		else:
			_velocity.x = 0
			
		var elevation_input := Input.get_axis(_action_prefix + "up", _action_prefix + "down")
		_elevation = clamp(_elevation + elevation_input * WEAPON_ROTATION_SPEED * delta, -TAU/4.0, 0)
		_weapon_hinge.rotation = _elevation if _facing==_Facing.RIGHT else PI - _elevation
		
		_process_shooting(delta)
	
	_velocity = move_and_slide_with_snap(_velocity, Vector2(0,40), Vector2.UP, true)


func _process_shooting(delta:float)->void:
	var percent := clamp(range_lerp(_hold_duration, 0, MAX_HOLD_DURATION, 0, 1), 0, 1)
	if Input.is_action_pressed(_action_prefix + "shoot"):
		_hold_duration += delta
		_set_shader_percent(percent)
	elif Input.is_action_just_released(_action_prefix + "shoot"):
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
	
	SfxPlayer.play_shoot()

	emit_signal("fired", bullet)


func _set_active(value:bool)->void:
	active = value
	_arrow.visible = active
	_set_shader_percent(0)


func _set_shader_percent(percent:float)->void:
	assert(percent >= 0.0 and percent <= 1.0)
	(_arrow.material as ShaderMaterial).set_shader_param("percent", percent)


func damage(amount:int)->void:
	_health -= amount
	if _health<=0:
		emit_signal("died")


func bury()->void:
#	while not is_on_floor():
#		yield(get_tree().create_timer(0.05), "timeout")
	set_physics_process(false)
	$CollisionShape2D.set_deferred("disabled", true)
	$BuryTween.interpolate_property(self, "position", null, Vector2(position.x, position.y + _BURY_DEPTH), 0.75, Tween.TRANS_QUAD)
	$BuryTween.start()
	# the wait is necessary for testing purposes
	yield($BuryTween, "tween_all_completed")
	emit_signal("done")


func unearth()->void:
	$BuryTween.interpolate_property(self, "position", null, Vector2(position.x, position.y - _BURY_DEPTH), 0.75, Tween.TRANS_QUAD)
	$BuryTween.start()
	yield($BuryTween, "tween_all_completed")
	$CollisionShape2D.disabled = false
	set_physics_process(true)
	emit_signal("unearthed")
