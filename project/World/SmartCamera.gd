class_name SmartCamera
extends Camera2D

export var alpha := 0.2

var target : Node2D

func _physics_process(_delta):
	if is_instance_valid(target):
		global_position.x = lerp(global_position.x, target.global_position.x, alpha)
