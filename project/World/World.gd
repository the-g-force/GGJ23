extends Node2D

onready var _collision_polygon : CollisionPolygon2D = $StaticBody2D/CollisionPolygon2D

func _input(event):
	if event.is_pressed():
		print("ping")
		clip($Polygon2D)


func _process(delta):
	update()


func clip(polygon:Polygon2D)->void:
	var offset_polygon : PoolVector2Array = []
	
	for point in polygon.polygon:
		offset_polygon.append(point + polygon.global_position)
	var new_ground_polygon : PoolVector2Array = Geometry.clip_polygons_2d(_collision_polygon.polygon, offset_polygon)[0]
	_collision_polygon.set_deferred("polygon", new_ground_polygon)
	update()


func _draw()->void:
	draw_colored_polygon(_collision_polygon.polygon, Color.blue)
