extends KinematicBody2D

signal fired(bullet)

var _GRAVITY : float = ProjectSettings.get_setting("physics/2d/default_gravity")

var _velocity := Vector2.ZERO
var _shoot_press_time := 0.0

func _physics_process(delta:float)->void:
	$WeaponHinge.rotation = get_angle_to(get_global_mouse_position())
	
	var direction := Input.get_axis("p0_left", "p0_right")
	var linear_velocity := Vector2(200*direction, 0)
	
	# Only pull downward when in the air
	if not is_on_floor():
		linear_velocity.y = _GRAVITY
	
	_velocity = move_and_slide(linear_velocity, Vector2.UP)
	
	if Input.is_action_pressed("p0_shoot") and _shoot_press_time < 1.0:
		_shoot_press_time += delta
	
	if Input.is_action_just_released("p0_shoot"):
		_shoot()


func _shoot()->void:
	var bullet = preload("res://Bullet/Bullet.tscn").instance()
	bullet.global_position = $WeaponHinge/Position2D.global_position
	get_parent().add_child(bullet)
	bullet.apply_impulse(Vector2.ZERO, lerp(Vector2.ZERO, Vector2.RIGHT.rotated($WeaponHinge.rotation) * 400, _shoot_press_time))
	_shoot_press_time = 0.0
	emit_signal("fired", bullet)


func _draw():
	draw_circle(Vector2.ZERO, 25.0, Color.brown)
