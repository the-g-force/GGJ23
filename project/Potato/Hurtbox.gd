extends Area2D


func damage(amount:int)->void:
	get_parent().damage(amount)
