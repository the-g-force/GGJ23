extends Node2D


func _ready()->void:
	$Tween.interpolate_property(self, "position", null, Vector2(global_position.x, -50), 3.0, Tween.TRANS_QUAD)
	$Tween.start()


func _process(_delta)->void:
	if position.y < 50:
		queue_free()
