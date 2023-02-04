extends KinematicBody2D

signal fired(bullet)

## Radians per second
const WEAPON_ROTATION_SPEED := TAU/8.0

enum _Facing { LEFT, RIGHT }

## Index of the controlling player (0-based)
export var player_index := 0

var active := false

var _GRAVITY : float = ProjectSettings.get_setting("physics/2d/default_gravity")

var _velocity := Vector2.ZERO
var _shoot_press_time := 0.0
var _can_shoot := true
var _facing = _Facing.RIGHT
var _elevation := 0.0

onready var _weapon_hinge := $WeaponHinge


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
	
	if Input.is_action_pressed("p0_shoot") and _shoot_press_time < 1.0 and _can_shoot:
		_shoot_press_time += delta
	
	if Input.is_action_just_released("p0_shoot") and _can_shoot:
		_shoot()


func _shoot()->void:
	var bullet = preload("res://Bullet/Bullet.tscn").instance()

	bullet.global_position = $WeaponHinge/Position2D.global_position
	get_parent().add_child(bullet)
	bullet.apply_impulse(Vector2.ZERO, lerp(Vector2.ZERO, Vector2.RIGHT.rotated($WeaponHinge.rotation) * 400, _shoot_press_time))

	_shoot_press_time = 0.0
	_can_shoot = false

	emit_signal("fired", bullet)
	
	# single-player playtest placeholder
	yield(bullet, "tree_exited")
	_can_shoot = true


func _draw():
	draw_circle(Vector2.ZERO, 25.0, Color.brown)
