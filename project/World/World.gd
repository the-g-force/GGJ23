extends Node2D


export var camera_move_speed := 100.0

var _active_potato : Node2D 

var _player_index := 0
var _is_game_over := false
var _camera_offset := 0.0

onready var followed_node : Node2D = $Potato
onready var _camera : Camera2D = $Camera2D

# We want the nested lists to be a continuous queue of potato turn orders.
onready var _player_potatoes := [
	[$Potato],
	[$Potato2]
]


func _ready()->void:
	_active_potato = $Potato
	
	for player_list in _player_potatoes:
		for potato in player_list:
			potato.connect("died", self, "_on_Potato_died", [potato])
			if potato != _active_potato:
				potato.bury()
	
	yield($Potato2, "done")
	
	_active_potato.active = true


func _physics_process(delta:float)->void:
	if is_instance_valid(followed_node):
		_camera.global_position.x = followed_node.global_position.x + _camera_offset
	
		if _active_potato.active:
			var action_prefix := "p%d_" % _player_index
			var camera_movement := Input.get_axis(action_prefix + "look_left", action_prefix + "look_right")
			_camera_offset += camera_movement * camera_move_speed * delta


func _on_Potato_fired(bullet:Node2D)->void:
	_active_potato.active = false
	followed_node = bullet
	_camera_offset = 0.0
	yield(bullet, "done")
	
	if not _is_game_over:
		followed_node = _active_potato
		_active_potato.bury()
		yield(_active_potato, "done")
		_start_next_turn()
	

func _start_next_turn()->void:
	# NB: Remember to rotate the past player's potato list
	# (Once there is more than one)
	
	_player_index = (_player_index + 1) % _player_potatoes.size()
	
	_active_potato = _player_potatoes[_player_index][0]
	followed_node = _active_potato
	_active_potato.unearth()
	yield(_active_potato, "unearthed")
	_active_potato.active = true


func _on_Potato_died(potato:Node2D)->void:
	# Short circuit is not savvy to mutual destruction
	# but it's good enough for jam time.
	if _is_game_over:
		return
	
	# Remove the potato from its list
	for potato_list in _player_potatoes:
		if potato_list.has(potato):
			potato_list.erase(potato)
	
	# Eliminate the potato from the world
	potato.queue_free()
	
	# See if anyone has won
	if _player_potatoes[0].size() == 0:
		print('PLAYER 2 WON')
		_do_game_over('PLAYER 2')
		
	
	elif _player_potatoes[1].size() == 0:
		print('PLAYER 1 WON')
		_do_game_over('PLAYER 1')


func _do_game_over(message:String)->void:
	_is_game_over = true
	$"%WinnerLabel".text = "%s has won" % message
	$"%EndGamePanel".visible = true


func _on_PlayAgainButton_pressed():
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://World/World.tscn")
