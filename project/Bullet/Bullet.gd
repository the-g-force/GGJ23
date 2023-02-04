extends RigidBody2D

const KILL_LINE := 600

onready var _explosion_shape : CollisionPolygon2D = $Area2D/ExplosionShape


func _ready()->void:
	_explosion_shape.visible = false

func _process(_delta:float)->void:
	if global_position.y > KILL_LINE:
		queue_free()


func _draw()->void:
	draw_circle(Vector2.ZERO, 10, Color.red)


func _on_Bullet_body_entered(body:Node)->void:
	if body.has_method("clip"):
		body.clip(_explosion_shape)
	for object in $Area2D.get_overlapping_bodies():
		if object.has_method("damage"):
			object.damage(25)
	queue_free()

