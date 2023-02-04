class_name DestructibleTerrain
extends StaticBody2D

export var color := Color.blue

var polygon : PoolVector2Array setget _set_polygon, _get_polygon

onready var _collision_polygon : CollisionPolygon2D = $CollisionPolygon2D


func clip(polygon_to_clip:Polygon2D)->void:
	var offset_polygon := _offset_polygon(polygon_to_clip.polygon, polygon_to_clip.global_position)
	
	var clip_result := Geometry.clip_polygons_2d(_collision_polygon.polygon, offset_polygon)
	
	# clip_polygons_2d returns an array of polygon results. Right now,
	# we are only using the first one.
	if clip_result.size() > 0:
		_set_polygon(clip_result[0])
	else:
		queue_free()
	
	if clip_result.size() > 1:
		clip_result.remove(0)
		for island_polygon in clip_result:
			var island = load("res://World/DestructibleTerrain.tscn").instance()
			get_parent().call_deferred("add_child", island)
			# wait until the island has been added to the scene tree
			# to add the proper collision polygon
			yield(island, "ready")
			island.polygon = island_polygon


func _draw()->void:
	draw_colored_polygon(_get_polygon(), color)


func _set_polygon(value:PoolVector2Array)->void:
	_collision_polygon.set_deferred("polygon", value)
	# the idle_frame signal is emitted just before the _process function is called.
	# it's used here to update the drawing AFTER the set_deferred kicks in.
	# Otherwise, it would update drawing the polygon before setting the polygon to the new value.
	yield(get_tree(), "idle_frame")
	update()


func _get_polygon()->PoolVector2Array:
	return _offset_polygon(_collision_polygon.polygon, _collision_polygon.global_position)


func _offset_polygon(polygon_to_offset, offset)->PoolVector2Array:
	var offset_polygon : PoolVector2Array = []
	
	for point in polygon_to_offset:
		offset_polygon.append(point + offset)
	
	return offset_polygon
