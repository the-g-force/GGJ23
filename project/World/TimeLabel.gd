extends Label


export var timer : NodePath

## How many seconds left before we change color
export var threshold := 5

onready var _actual_timer : Timer = get_node(timer)

func _process(_delta):
	text = str(ceil(_actual_timer.time_left))
	
	modulate = Color.red if _actual_timer.time_left < threshold else Color.white
