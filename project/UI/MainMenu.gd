extends Control

onready var _button_sound := $ButtonSound
onready var _fullscreen_toggle := $"%FullscreenToggle"
onready var _buttons := [$"%PlayButton", $"%QuitButton", $"%FullscreenToggle"]


func _ready():
	_fullscreen_toggle.pressed = OS.window_fullscreen
	$"%PlayButton".grab_focus()


func _on_PlayButton_pressed()->void:
	for button in _buttons:
		button.disabled = true
	_button_sound.play()
	yield(_button_sound, "finished")
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://World/World.tscn")


func _on_FullscreenToggle_toggled(button_pressed:bool)->void:
	_button_sound.play()
	OS.window_fullscreen = button_pressed


func _on_QuitButton_pressed()->void:
	for button in _buttons:
		button.disabled = true
	_button_sound.play()
	yield(_button_sound, "finished")
	get_tree().quit()
