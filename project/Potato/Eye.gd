extends Node2D
tool

const DEFAULT_POSITION := Vector2(0,1.5)

export var radius := 10.0 setget _set_radius
export var distance_to_pupil := 5

var tracked : Node2D

onready var _pupil := $Pupil

func _physics_process(_delta):
	if is_instance_valid(tracked):
		var direction = tracked.global_position - global_position
		var target = direction.normalized() * distance_to_pupil
		_pupil.position = lerp(_pupil.position, target, 0.1)
	else:
		_pupil.position = lerp(_pupil.position, DEFAULT_POSITION, 0.2)


func _draw():
	draw_circle(Vector2.ZERO, radius, Color.whitesmoke)


func _set_radius(value:float)->void:
	radius = value
	update()


func _on_Area2D_body_entered(body:PhysicsBody2D):
	if body.is_in_group("bullet"):
		tracked = body


func _on_Area2D_body_exited(body):
	if body==tracked:
		tracked = null
