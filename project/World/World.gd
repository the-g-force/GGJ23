extends Node2D

onready var followed_node : Node2D = $Potato
onready var _camera : Camera2D = $Camera2D

var _active_potato : Node2D 

var _player_index := 0

# We want the nested lists to be a continuous queue of potato turn orders.
onready var _player_potatoes := [
	[$Potato],
	[$Potato2]
]


func _ready()->void:
	_active_potato = $Potato
	$Potato.active = true


func _physics_process(_delta)->void:
	_camera.global_position.x = followed_node.global_position.x


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
