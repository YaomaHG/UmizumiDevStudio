extends Node2D

@onready var cocina = $Cocina
@onready var sala = $Sala
@onready var cuarto = $Cuarto
@onready var player = $Player
@onready var hud_game = $HudGame
@onready var task_ui = $HudGame/TaskUi

var area_actual = "cuarto"
var cambiando_area = false
var progress_bar_display = null

# Posiciones de spawn
@export var spawn_cocina: Vector2 = Vector2(100, 450)
@export var spawn_sala_cocina: Vector2 = Vector2(885, 450)
@export var spawn_sala_cuarto: Vector2 = Vector2(785, 310)
@export var spawn_cuarto: Vector2 = Vector2(885, 450)

func _ready():
	activar_cuarto()
	conectar_puertas()
	crear_barra_progreso()
	conectar_interactivos_con_hud()

	var start_marker = get_node_or_null("Start")
	if start_marker and start_marker is Marker2D:
		player.global_position = start_marker.global_position
	else:
		player.global_position = spawn_cuarto

func crear_barra_progreso():
	var progress_layer = Node2D.new()
	progress_layer.name = "ProgressBarLayer"
	progress_layer.script = load("res://scripts/progress_bar_display.gd")
	add_child(progress_layer)
	progress_bar_display = progress_layer

func conectar_interactivos_con_hud():
	if cocina.has_node("Estufa"):
		_conectar_interactivo_con_hud(cocina.get_node("Estufa"))

	if sala.has_node("Sofa"):
		_conectar_interactivo_con_hud(sala.get_node("Sofa"))
	elif sala.has_node("Estufa"):
		_conectar_interactivo_con_hud(sala.get_node("Estufa"))

func _conectar_interactivo_con_hud(interactivo: Node):
	if not interactivo:
		return

	if interactivo.has_signal("task_progress"):
		if not interactivo.task_progress.is_connected(task_ui._on_task_progress):
			interactivo.task_progress.connect(task_ui._on_task_progress)
		if not interactivo.task_progress.is_connected(progress_bar_display.update_progress):
			interactivo.task_progress.connect(progress_bar_display.update_progress)

	if interactivo.has_signal("task_completed"):
		if not interactivo.task_completed.is_connected(task_ui._on_task_completed):
			interactivo.task_completed.connect(task_ui._on_task_completed)

	if interactivo.has_signal("show_progress_bar"):
		if not interactivo.show_progress_bar.is_connected(progress_bar_display._on_show_progress_bar):
			interactivo.show_progress_bar.connect(progress_bar_display._on_show_progress_bar)

func conectar_puertas():
	# Puerta de COCINA -> SALA
	if cocina.has_node("Puerta"):
		var puerta_cocina = cocina.get_node("Puerta")
		if puerta_cocina.has_signal("body_entered"):
			puerta_cocina.body_entered.connect(_on_puerta_entered.bind("sala", "cocina"))

	# Puerta de SALA -> COCINA
	if sala.has_node("PuertaCocina"):
		var puerta_sala_cocina = sala.get_node("PuertaCocina")
		if puerta_sala_cocina.has_signal("body_entered"):
			puerta_sala_cocina.body_entered.connect(_on_puerta_entered.bind("cocina", "sala_cocina"))

	# Puerta de SALA -> CUARTO
	if sala.has_node("PuertaCuarto"):
		var puerta_sala_cuarto = sala.get_node("PuertaCuarto")
		if puerta_sala_cuarto.has_signal("body_entered"):
			puerta_sala_cuarto.body_entered.connect(_on_puerta_entered.bind("cuarto", "sala_cuarto"))

	# Puerta de CUARTO -> SALA
	if cuarto.has_node("Puerta"):
		var puerta_cuarto = cuarto.get_node("Puerta")
		if puerta_cuarto.has_signal("body_entered"):
			puerta_cuarto.body_entered.connect(_on_puerta_entered.bind("sala", "cuarto"))

func _on_puerta_entered(body, destino, origen):
	if body == player and area_actual != destino and not cambiando_area:
		match destino:
			"cocina":
				call_deferred("activar_cocina")
			"sala":
				call_deferred("activar_sala", origen)
			"cuarto":
				call_deferred("activar_cuarto")

func activar_cocina():
	if cambiando_area:
		return

	cambiando_area = true
	area_actual = "cocina"

	sala.visible = false
	sala.process_mode = Node.PROCESS_MODE_DISABLED
	desactivar_colisiones_recursivo(sala, true)

	cuarto.visible = false
	cuarto.process_mode = Node.PROCESS_MODE_DISABLED
	desactivar_colisiones_recursivo(cuarto, true)

	cocina.visible = true
	cocina.process_mode = Node.PROCESS_MODE_INHERIT
	desactivar_colisiones_recursivo(cocina, false)

	player.global_position = spawn_cocina
	await get_tree().process_frame
	cambiando_area = false

func activar_sala(desde: String = "cocina"):
	if cambiando_area:
		return

	cambiando_area = true
	area_actual = "sala"

	cocina.visible = false
	cocina.process_mode = Node.PROCESS_MODE_DISABLED
	desactivar_colisiones_recursivo(cocina, true)

	cuarto.visible = false
	cuarto.process_mode = Node.PROCESS_MODE_DISABLED
	desactivar_colisiones_recursivo(cuarto, true)

	sala.visible = true
	sala.process_mode = Node.PROCESS_MODE_INHERIT
	desactivar_colisiones_recursivo(sala, false)

	match desde:
		"cocina":
			player.global_position = spawn_sala_cocina
		"cuarto":
			player.global_position = spawn_sala_cuarto
		_:
			player.global_position = spawn_sala_cocina

	await get_tree().process_frame
	cambiando_area = false

func activar_cuarto():
	if cambiando_area:
		return

	cambiando_area = true
	area_actual = "cuarto"

	cocina.visible = false
	cocina.process_mode = Node.PROCESS_MODE_DISABLED
	desactivar_colisiones_recursivo(cocina, true)

	sala.visible = false
	sala.process_mode = Node.PROCESS_MODE_DISABLED
	desactivar_colisiones_recursivo(sala, true)

	cuarto.visible = true
	cuarto.process_mode = Node.PROCESS_MODE_INHERIT
	desactivar_colisiones_recursivo(cuarto, false)

	player.global_position = spawn_cuarto
	await get_tree().process_frame
	cambiando_area = false

func desactivar_colisiones_recursivo(node: Node, desactivar: bool):
	for child in node.get_children():
		if child is CollisionShape2D:
			child.set_deferred("disabled", desactivar)
		elif child is Area2D:
			child.set_deferred("monitoring", not desactivar)
		desactivar_colisiones_recursivo(child, desactivar)
