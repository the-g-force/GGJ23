extends Node2D

onready var followed_node : Node2D = $Potato
onready var _ground_polygon : CollisionPolygon2D = $StaticBody2D/CollisionPolygon2D
onready var _camera : Camera2D = $Camera2D

var _active_potato : Node2D 

var _player_index := 0

# We want the nested lists to be a continuous queue of potato turn orders.
onready var _player_potatoes := [
	[$Potato],
	[$Potato2]
]


func _ready():
	_active_potato = $Potato
	$Potato.active = true


func _input(event):
	if event.is_pressed():
		clip($Polygon2D)


func _physics_process(_delta):
	_camera.global_position.x = followed_node.global_position.x
	


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


func _on_Potato_fired(bullet:Node2D)->void:
	_active_potato.active = false
	followed_node = bullet
	yield(bullet, "tree_exited")
	
	_start_next_turn()
	

func _start_next_turn()->void:
	# NB: Remember to rotate the past player's potato list
	# (Once there is more than one)
	
	_player_index = (_player_index + 1) % _player_potatoes.size()
	
	_active_potato = _player_potatoes[_player_index][0]
	_active_potato.active = true
	followed_node = _active_potato
