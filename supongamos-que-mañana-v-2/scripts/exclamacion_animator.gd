extends Sprite2D

var base_y = 0.0
var animation_speed = 3.0
var bounce_height = 10.0
var time_elapsed = 0.0

func _ready():
	base_y = position.y
	flip_h = false
	flip_v = false
	set_process(true)

func _process(delta):
	if not visible:
		return
	
	time_elapsed += delta * animation_speed
	
	var new_y = base_y + sin(time_elapsed) * bounce_height
	position.y = new_y
