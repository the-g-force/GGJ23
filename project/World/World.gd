extends Node2D

# camera move speed in pixels per second
export var camera_move_speed := 500.0
export var normal_height := 250
export var height_variation := 300
export (int, 100, 1000) var detail := 400

var potato_names := [
	"Steve",
	"The Masher",
	"Horatio Potatio",
	"Thumbelina",
	"Baked Baron",
	"McSpudders",
	"Latke",
	"Tomorrow's Gnocchi",
	"Hashbrown",
	"Solanum Tuberosum",
	"Starchmeister",
	"Papa Batata",
	"Chippy",
	"Fry",
	"Vladimir Poutine",
	"Pomme Pomme",
	"Yukon Gold",
	"Brotato",
	"Idaho Jones",
	"Argos",
	"Quayle's Folly",
	"Mr. Head",
]

var _active_potato : Node2D 

var _player_index := 0
var _is_game_over := false
var _shot_this_turn := false
var _potato_died := false

onready var _camera : SmartCamera = $Camera2D
onready var _turn_timer : Timer = $TurnTimer
onready var _buttons := [$"%PlayAgainButton", $"%MainMenuButton"]


# We want the nested lists to be a continuous queue of potato turn orders.
var _player_potatoes := [
	[],
	[]
]


func _ready()->void:
	_generate_ground()
	
	yield(get_tree(), "idle_frame")
	
	_spawn_potatoes()
	
	_player_index = randi() % 2
	_active_potato = _player_potatoes[_player_index][randi()%4]
	_player_potatoes[_player_index].erase(_active_potato)
	_player_potatoes[_player_index].append(_active_potato)
	_camera.target = _active_potato
	
	var buried_potato
	
	for player_list in _player_potatoes:
		for potato in player_list:
			potato.connect("died", self, "_on_Potato_died")
			potato.connect("fired", self, "_on_Potato_fired")
			potato.spud_name = potato_names[randi()%potato_names.size()]
			potato_names.erase(potato.spud_name)
			if potato != _active_potato:
				potato.bury()
				buried_potato = potato
	
	yield(buried_potato, "done")
	
	_active_potato.active = true
	_turn_timer.start()


func _physics_process(delta:float)->void:
	if is_instance_valid(_active_potato) and _active_potato.active:
		var action_prefix := "p%d_" % _player_index
		var camera_movement := Input.get_axis(action_prefix + "look_left", action_prefix + "look_right")
		_camera.offset.x += camera_movement * camera_move_speed * delta


func _generate_ground()->void:
	var noise = OpenSimplexNoise.new()
	noise.seed = randi()
	
	var points := []
	
	for i in detail:
		points.append(Vector2(i * 4000 / detail, 600 - (normal_height + noise.get_noise_1d(i) * height_variation)))
	points.append_array([
		Vector2(4000, 700), Vector2(0, 700)
	])
	
	$Ground.polygon = points


func _spawn_potatoes()->void:
	for spawn_point in $RedSpawns.get_children():
		_add_potato(spawn_point, 0)
	for spawn_point in $BlueSpawns.get_children():
		_add_potato(spawn_point, 1)
	_player_potatoes[0].shuffle()
	_player_potatoes[1].shuffle()


func _add_potato(spawn_point:Position2D, index:int)->void:
	var intersection := get_world_2d().direct_space_state.intersect_ray(spawn_point.position, Vector2(spawn_point.position.x, 700))
	var potato := preload("res://Potato/Potato.tscn").instance()
	potato.player_index = index
	potato.position = Vector2(intersection.position.x, intersection.position.y - 50)
	$Potatoes.add_child(potato)
	_player_potatoes[index].append(potato)


func _on_Potato_fired(bullet:Node2D)->void:
	_shot_this_turn = true
	_camera.offset.x = 0.0
	_turn_timer.stop() # so that the turn doesn't end twice
	_active_potato.active = false
	_camera.target = bullet
	var explosion = yield(bullet, "exploded")
	yield(explosion, "tree_exited")
	if not _potato_died:
		_end_potato_turn()


func _end_potato_turn()->void:
	if not _is_game_over:
		if is_instance_valid(_active_potato):
			_camera.target = _active_potato
			_active_potato.bury()
			yield(_active_potato, "done")
			_start_next_turn()
		else:
			_start_next_turn()


func _start_next_turn()->void:
	_potato_died = false
	_shot_this_turn = false
	_player_index = (_player_index + 1) % _player_potatoes.size()
	
	_active_potato = _player_potatoes[_player_index][0]
	_player_potatoes[_player_index].remove(0)
	_player_potatoes[_player_index].append(_active_potato)
	_camera.target = _active_potato
	_active_potato.unearth()
	yield(_active_potato, "unearthed")
	_active_potato.active = true
	_turn_timer.start()


func _on_Potato_died(potato:Node2D, ghost:Node2D)->void:
	_potato_died = true
	_turn_timer.stop()
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
	yield(ghost, "tree_exited")
	
	# See if anyone has won
	if _player_potatoes[0].size() == 0:
		_do_game_over('Blue team')
	
	elif _player_potatoes[1].size() == 0:
		_do_game_over('Red team')
	
	if _potato_died:
		_end_potato_turn()


func _do_game_over(message:String)->void:
	_is_game_over = true
	$"%WinnerLabel".text = "%s has won!" % message
	
	# make the panel blue if blue guys won
	if _player_potatoes[0].size() == 0:
		$"%EndGamePanel".set("custom_styles/panel", load("res://Resources/Player2StyleBox.tres"))
	
	$"%EndGamePanel".visible = true
	$"%PlayAgainButton".grab_focus()


func _on_PlayAgainButton_pressed():
	for button in _buttons:
		button.disabled = true
	
	$ButtonClickSound.play()
	yield($ButtonClickSound, "finished")
	
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://World/World.tscn")


func _on_TurnTimer_timeout()->void:
	SfxPlayer.play_timeout()
	_active_potato.active = false
	_camera.offset.x = 0.0
	_end_potato_turn()


func _on_MainMenuButton_pressed():
	for button in _buttons:
		button.disabled = true
	
	$ButtonClickSound.play()
	yield($ButtonClickSound, "finished")
	
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://UI/MainMenu.tscn")
