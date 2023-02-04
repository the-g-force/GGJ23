extends Node2D
tool

export var radius := 10.0 setget _set_radius

func _draw():
	draw_circle(Vector2.ZERO, radius, Color.whitesmoke)
	draw_circle(Vector2(0,2), 3, Color(.1,.1,.1))


func _set_radius(value:float)->void:
	radius = value
	update()
