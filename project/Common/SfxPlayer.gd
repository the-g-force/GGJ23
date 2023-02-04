extends Node

func _ready():
	# You might ask yourself, "Why is this being called here?"
	# It is so that we seed the randomizer only once, and as this
	# is effectively a singleton, this is a good a place as any.
	randomize()

func play_explosion()->void:
	$Explosion.play()


func play_splash()->void:
	$Splash.play()


func play_shoot()->void:
	$Shoot.play()


func play_timeout()->void:
	$Timeout.play()
