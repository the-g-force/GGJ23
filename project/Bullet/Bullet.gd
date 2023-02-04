extends RigidBody2D

onready var _explosion_shape := $ExplosionShape


func _ready()->void:
	_explosion_shape.visible = false


func _draw()->void:
	draw_circle(Vector2.ZERO, 10, Color.red)


func _on_Bullet_body_entered(body:Node)->void:
	if body.get_parent().has_method("clip"):
		body.get_parent().clip(_explosion_shape)
		queue_free()

