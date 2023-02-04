extends Node2D

onready var _ground_polygon : CollisionPolygon2D = $StaticBody2D/CollisionPolygon2D


func _input(event):
	if event.is_pressed():
		clip($Polygon2D)


func clip(polygon:Polygon2D)->void:
	var offset_polygon := []
	
	for point in polygon.polygon:
		offset_polygon.append(point + polygon.global_position)
	var clip_result := Geometry.clip_polygons_2d(_ground_polygon.polygon, offset_polygon)
	
	# clip_polygons_2d returns an array of polygon results. Right now,
	# we are only using the first one.
	_ground_polygon.set_deferred("polygon", clip_result[0])
	update()
	


func _draw()->void:
	draw_colored_polygon(_ground_polygon.polygon, Color.blue)
