extends RigidBody2D

export var explosion_radius := 0.0

var _explosion_shape := []


func _ready()->void:
	for i in 16:
		_explosion_shape.append(Vector2.RIGHT.rotated(TAU * i / 16) * explosion_radius)


func _draw()->void:
	draw_circle(Vector2.ZERO, 10, Color.red)


func _on_Bullet_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	pass
#	if body.get_parent().has_method("clip"):
#		body.get_parent().clip(_explosion_shape, global_position)
#		queue_free()
