extends RigidBody2D

signal done

const KILL_LINE := 600

onready var _explosion_shape : CollisionPolygon2D = $Area2D/ExplosionShape
onready var _spin := rand_range(-PI,PI)

func _ready()->void:
	_explosion_shape.visible = false


func _process(delta:float)->void:
	$Sprite.rotate(_spin*delta)
	
	if global_position.y > KILL_LINE:
		var splash := preload("res://Bullet/Splash.tscn").instance()
		splash.global_position = global_position
		splash.one_shot = true
		get_parent().add_child(splash)
		SfxPlayer.play_splash()
		emit_signal("done")
		queue_free()


func _on_Bullet_body_entered(body:Node)->void:
	if body.has_method("clip"):
		body.clip(_explosion_shape)
		var explosion := preload("res://Bullet/Explosion.tscn").instance()
		explosion.global_position = global_position
		body.get_parent().add_child(explosion)
		explosion.one_shot = true
	
	for object in $Area2D.get_overlapping_areas():
		if object.has_method("damage"):
			object.damage()
	
	SfxPlayer.play_explosion()
	
	emit_signal("done")
	queue_free()

