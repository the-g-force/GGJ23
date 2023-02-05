extends RigidBody2D

signal exploded(explosion)

const KILL_LINE := 600

onready var _explosion_shape : CollisionPolygon2D = $Area2D/ExplosionShape
onready var _spin := rand_range(-PI,PI)

func _ready()->void:
	var points := []
	for i in 32:
		points.append(Vector2.RIGHT.rotated(TAU * i / 32) * lerp(65, 70, randf()))
	_explosion_shape.polygon = points


func _process(delta:float)->void:
	$Sprite.rotate(_spin*delta)
	
	if global_position.y > KILL_LINE:
		var splash := preload("res://Bullet/Splash.tscn").instance()
		splash.global_position = global_position
		splash.one_shot = true
		get_parent().add_child(splash)
		SfxPlayer.play_splash()
		emit_signal("exploded", splash)
		queue_free()


func _on_Bullet_body_entered(body:Node)->void:
	# If we hit the ground, clip out the explosion shape
	if body.has_method("clip"):
		body.clip(_explosion_shape)
	
	# Make the explosion
	var explosion := preload("res://Bullet/Explosion.tscn").instance()
	explosion.global_position = global_position
	body.get_parent().add_child(explosion)
	explosion.one_shot = true
	
	# This has to be deferred so that the physics state can catch
	# up with the overlapping of the explosion area and potatoes.
	call_deferred("_damage_in_area")
	
	SfxPlayer.play_explosion()
	
	emit_signal("exploded", explosion)
	queue_free()


func _damage_in_area()->void:
	# Damage every potato in the area
	for object in $Area2D.get_overlapping_areas():
		if object.has_method("damage"):
			object.damage()
