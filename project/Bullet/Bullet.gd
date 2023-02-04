extends RigidBody2D

onready var _explosion_shape := $ExplosionShape


func _ready()->void:
	_explosion_shape.visible = false


func _on_Bullet_body_shape_entered(body_rid, body, body_shape_index, local_shape_index)->void:
	if body.get_parent().has_method("clip"):
		body.get_parent().clip(_explosion_shape)
		queue_free()


func _draw()->void:
	draw_circle(Vector2.ZERO, 10, Color.red)
