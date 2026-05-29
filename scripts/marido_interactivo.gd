extends StaticBody2D

@export var debug_interaction = false
@export var interaction_area_padding = Vector2(28, 28)
var is_player_near = false
var is_interacting = false
var player = null
var is_completed = false
var detection_area: Area2D = null

var minigame_instance = null
const MINIJUEGO_SCENE = preload("res://scenes/minijuego_marido.tscn")

signal task_progress(progress: float)
signal task_completed
signal show_progress_bar(show: bool, position: Vector2)

func _ready():
	# Crear área de detección dinámicamente si no existe
	detection_area = get_node_or_null("DetectionArea") as Area2D
	if not detection_area:
		detection_area = Area2D.new()
		detection_area.name = "DetectionArea"
		add_child(detection_area)
		
		var col = CollisionShape2D.new()
		col.name = "CollisionShape2D"
		var shape = RectangleShape2D.new()
		shape.size = Vector2(90, 90)
		col.shape = shape
		detection_area.add_child(col)

	detection_area.monitoring = true
	detection_area.monitorable = true
	detection_area.collision_mask = 1
	if not detection_area.body_entered.is_connected(_on_detector_body_entered):
		detection_area.body_entered.connect(_on_detector_body_entered)
	if not detection_area.body_exited.is_connected(_on_detector_body_exited):
		detection_area.body_exited.connect(_on_detector_body_exited)

	# Asignar textura inicial enojado
	if has_node("Sprite2D"):
		$Sprite2D.texture = preload("res://art/maridoIrritado.png")
		$Sprite2D.scale = Vector2(1.5, 1.5)

	if has_node("Exclamacion"):
		$Exclamacion.show()

func _process(_delta):
	if is_completed:
		return

	_update_player_proximity()
	var interact_pressed = Input.is_action_just_pressed("ui_accept") or Input.is_key_pressed(KEY_E) or (Input.is_key_pressed(KEY_SPACE) and not Input.is_key_pressed(KEY_ESCAPE))

	if is_player_near and interact_pressed and not is_interacting:
		start_interaction()

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
	start_minigame()

func start_minigame():
	if minigame_instance:
		return
	
	minigame_instance = MINIJUEGO_SCENE.instantiate()
	
	# Conectar las señales
	minigame_instance.marido_completado.connect(_on_minijuego_completado)
	minigame_instance.marido_cancelado.connect(_on_minijuego_cancelado)
	
	# Añadir al árbol de la escena principal
	get_tree().current_scene.add_child(minigame_instance)

func _on_minijuego_completado():
	minigame_instance = null
	complete_interaction()

func _on_minijuego_cancelado():
	minigame_instance = null
	cancel_interaction()

func complete_interaction():
	is_interacting = false
	is_completed = true
	if player:
		player.movement_locked = false
		if player.has_method("set_working"):
			player.set_working(false)
	task_completed.emit()
	
	if has_node("Sprite2D"):
		# Cambiar textura a contento
		$Sprite2D.texture = preload("res://art/marido_0.png")
		$Sprite2D.modulate = Color(0.5, 1.0, 0.5) # Modulación verde suave
		
	if has_node("Exclamacion"):
		$Exclamacion.hide()
		if $Exclamacion.has_method("set_process"):
			$Exclamacion.set_process(false)
	show_progress_bar.emit(false, Vector2.ZERO)

func cancel_interaction():
	is_interacting = false
	if minigame_instance and is_instance_valid(minigame_instance):
		if minigame_instance.has_method("cancelar_juego"):
			minigame_instance.cancelar_juego()
		else:
			minigame_instance.queue_free()
			minigame_instance = null
	if player:
		player.movement_locked = false
		if player.has_method("set_working"):
			player.set_working(false)
	show_progress_bar.emit(false, Vector2.ZERO)

func _on_detector_body_entered(body):
	if body.name == "Player":
		is_player_near = true
		player = body

func _on_detector_body_exited(body):
	if body.name == "Player":
		is_player_near = false
		player = null
		if is_interacting:
			cancel_interaction()
