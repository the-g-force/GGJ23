extends Node2D

onready var followed_node : Node2D = $Potato
onready var _camera : Camera2D = $Camera2D

var _active_potato : Node2D 

var _player_index := 0
var _is_game_over := false

# We want the nested lists to be a continuous queue of potato turn orders.
onready var _player_potatoes := [
	[$Potato],
	[$Potato2]
]


func _ready()->void:
	for player_list in _player_potatoes:
		for potato in player_list:
			potato.connect("died", self, "_on_Potato_died", [potato])
	
	_active_potato = $Potato
	$Potato.active = true


func _physics_process(_delta)->void:
	if is_instance_valid(followed_node):
		_camera.global_position.x = followed_node.global_position.x


func _on_Potato_fired(bullet:Node2D)->void:
	_active_potato.active = false
	followed_node = bullet
	yield(bullet, "done")
	
	if not _is_game_over:
		followed_node = _active_potato
		_active_potato.bury()
		yield(_active_potato, "done")
		print("hey")
		_start_next_turn()
	

func _start_next_turn()->void:
	# NB: Remember to rotate the past player's potato list
	# (Once there is more than one)
	
	_player_index = (_player_index + 1) % _player_potatoes.size()
	
	_active_potato = _player_potatoes[_player_index][0]
	_active_potato.active = true
	followed_node = _active_potato


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
