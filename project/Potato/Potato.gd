extends KinematicBody2D

var _GRAVITY : float = ProjectSettings.get_setting("physics/2d/default_gravity")

var _velocity := Vector2.ZERO

func _physics_process(_delta:float)->void:
	var direction := Input.get_axis("p0_left", "p0_right")
	var linear_velocity := Vector2(200*direction, 0)
	
	# Only pull downward when in the air
	if not is_on_floor():
		linear_velocity.y = _GRAVITY
	
	_velocity = move_and_slide(linear_velocity, Vector2.UP)


func _draw():
	draw_circle(Vector2.ZERO, 25.0, Color.brown)
