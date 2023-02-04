extends Control

onready var _button_sound := $ButtonSound
onready var _fullscreen_toggle := $"%FullscreenToggle"

func _ready():
	_fullscreen_toggle.pressed = OS.window_fullscreen
	$"%PlayButton".grab_focus()


func _on_PlayButton_pressed()->void:
	print('I need to disable buttons here')
	_button_sound.play()
	yield(_button_sound, "finished")
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://World/World.tscn")


func _on_FullscreenToggle_toggled(button_pressed:bool)->void:
	_button_sound.play()	
	OS.window_fullscreen = button_pressed
