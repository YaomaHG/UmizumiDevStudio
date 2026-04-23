extends StaticBody2D

@export var interaction_time = 4.0
@export var debug_interaction = true
@export var interaction_area_padding = Vector2(28, 28)
var is_player_near = false
var is_interacting = false
var current_time = 0.0
var player = null
var is_completed = false
var detection_area: Area2D = null
var _last_debug_near_state = false
var _last_debug_space_state = false

signal task_progress(progress: float)
signal task_completed
signal show_progress_bar(show: bool, position: Vector2)

func _ready():
	detection_area = get_node_or_null("DetectionArea") as Area2D
	if detection_area:
		detection_area.monitoring = true
		detection_area.monitorable = true
		detection_area.collision_mask = 1
		if not detection_area.body_entered.is_connected(_on_detector_body_entered):
			detection_area.body_entered.connect(_on_detector_body_entered)
		if not detection_area.body_exited.is_connected(_on_detector_body_exited):
			detection_area.body_exited.connect(_on_detector_body_exited)

	_update_collision_sizes_from_sprite()
	if has_node("Exclamacion"):
		$Exclamacion.show()

func _update_collision_sizes_from_sprite():
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if not sprite or not sprite.texture:
		return

	# Ajusta colision al tamano visual real (textura * escala).
	var visual_size = sprite.texture.get_size() * sprite.scale.abs()

	var body_collision := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if body_collision and body_collision.shape is RectangleShape2D:
		(body_collision.shape as RectangleShape2D).size = visual_size
		body_collision.position = Vector2.ZERO

	var detect_collision := get_node_or_null("DetectionArea/CollisionShape2D") as CollisionShape2D
	if detect_collision and detect_collision.shape is RectangleShape2D:
		# Area de interaccion atravesable mas grande que la colision solida.
		(detect_collision.shape as RectangleShape2D).size = visual_size + interaction_area_padding
		detect_collision.position = Vector2.ZERO
		detect_collision.disabled = false

func _process(delta):
	if is_completed:
		return

	_update_player_proximity()
	var interact_pressed = Input.is_action_pressed("ui_accept") or Input.is_key_pressed(KEY_SPACE)

	if debug_interaction:
		if is_player_near != _last_debug_near_state:
			print("DEBUG ESTUFA: Cerca de la estufa = ", is_player_near)
			_last_debug_near_state = is_player_near
		if interact_pressed != _last_debug_space_state:
			print("DEBUG ESTUFA: SPACE presionada = ", interact_pressed)
			_last_debug_space_state = interact_pressed
		if is_player_near and interact_pressed:
			print("DEBUG ESTUFA: Detecta colision + SPACE al mismo tiempo")
	
	if is_player_near and interact_pressed:
		if not is_interacting:
			if debug_interaction:
				print("DEBUG ESTUFA: Iniciando interaccion")
			start_interaction()
		
		current_time += delta
		var progress = min(current_time / interaction_time, 1.0)
		task_progress.emit(progress)
		if debug_interaction:
			print("DEBUG ESTUFA: Progreso = ", progress)
		
		if current_time >= interaction_time:
			if debug_interaction:
				print("DEBUG ESTUFA: Interaccion completada")
			complete_interaction()
	elif is_interacting:
		if debug_interaction:
			print("DEBUG ESTUFA: Interaccion cancelada")
		cancel_interaction()

func _update_player_proximity():
	if not detection_area:
		return

	is_player_near = false
	var overlaps = detection_area.get_overlapping_bodies()
	for body in overlaps:
		if body and body.name == "Player":
			is_player_near = true
			player = body
			break

	if not is_player_near:
		player = null

func start_interaction():
	is_interacting = true
	current_time = 0.0
	if player:
		if player.has_method("set_working"):
			player.set_working(true)
		show_progress_bar.emit(true, player.global_position - Vector2(0, 50))

func complete_interaction():
	is_interacting = false
	is_completed = true
	if player and player.has_method("set_working"):
		player.set_working(false)
	task_completed.emit()
	$Sprite2D.modulate = Color(0.5, 1.0, 0.5)
	if has_node("Exclamacion"):
		$Exclamacion.hide()
		if $Exclamacion.has_method("set_process"):
			$Exclamacion.set_process(false)
	show_progress_bar.emit(false, Vector2.ZERO)

func cancel_interaction():
	is_interacting = false
	current_time = 0.0
	if player and player.has_method("set_working"):
		player.set_working(false)
	show_progress_bar.emit(false, Vector2.ZERO)

# Método para detectar al jugador (usando Area2D como detector)
func _on_detector_body_entered(body):
	if body.name == "Player":
		is_player_near = true
		player = body
		if debug_interaction:
			print("DEBUG ESTUFA: body_entered Player")

func _on_detector_body_exited(body):
	if body.name == "Player":
		is_player_near = false
		player = null
		if debug_interaction:
			print("DEBUG ESTUFA: body_exited Player")
		if is_interacting:
			cancel_interaction()
