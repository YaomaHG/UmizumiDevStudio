extends Sprite2D

var base_offset = Vector2.ZERO
var animation_speed = 3.0
var bounce_height = 10.0
var time_elapsed = 0.0
var parent_node: Node2D = null

func _ready():
	parent_node = get_parent() as Node2D
	base_offset = position
	# Evita heredar rotacion/escala del padre (estufa rotada).
	top_level = true
	if parent_node:
		global_position = parent_node.global_position + base_offset
	flip_h = false
	flip_v = false
	rotation = 0.0
	set_process(true)

func _process(delta):
	if not visible or not parent_node:
		return
	
	# Mantener orientacion fija sin importar la rotacion de la estufa.
	rotation = 0.0
	flip_h = false
	flip_v = false
	
	time_elapsed += delta * animation_speed
	var bounce = sin(time_elapsed) * bounce_height
	var target = parent_node.global_position + base_offset + Vector2(0, bounce)

	var view_rect = get_viewport().get_visible_rect()
	var cam := get_viewport().get_camera_2d()
	if cam:
		var half_size = texture.get_size() * scale * 0.5 if texture else Vector2(16, 16)
		var rect_size_world = view_rect.size / cam.zoom
		var min_pos = cam.global_position - rect_size_world * 0.5 + half_size
		var max_pos = cam.global_position + rect_size_world * 0.5 - half_size
		target.x = clamp(target.x, min_pos.x, max_pos.x)
		target.y = clamp(target.y, min_pos.y, max_pos.y)

	global_position = target
