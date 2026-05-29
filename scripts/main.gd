extends Node2D

@onready var cocina = $Cocina
@onready var sala = $Sala
@onready var cuarto = $Cuarto
@onready var player = $Player
@onready var hud_game = $HudGame
@onready var task_ui = $HudGame/TaskUi
@onready var day_transition = $DayTransition


const YOU_WIN_TEXTURE = preload("res://art/YouWin.png")
const YOU_LOSE_TEXTURE = preload("res://art/EndGame.png")

var area_actual = "cuarto"
var cambiando_area = false
var progress_bar_display = null
var time_left = 60.0
var game_finished = false
var timer_label: Label = null
var end_overlay: ColorRect = null
var end_image: TextureRect = null
var end_image_base_position = Vector2(265, 180)
var dia_label: Label = null


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
	crear_ui_tiempo_resultado()
	_crear_label_dia()

	# Configurar tiempo del día (60 segundos)
	time_left = 60.0

	# Configurar tareas del HUD según el día
	if GameState.dia_actual >= 2:
		_spawn_marido_interactivo()
		task_ui.max_tasks = 4
	else:
		task_ui.max_tasks = 3
	task_ui.update_task_counter()

	var start_marker = get_node_or_null("Start")
	if start_marker and start_marker is Marker2D:
		player.global_position = start_marker.global_position
	else:
		player.global_position = spawn_cuarto
	
	for room in [cocina, sala, cuarto]:
		var moneda_estatica = room.get_node_or_null("Monedas")
		if moneda_estatica:
			moneda_estatica.queue_free()

	_spawn_monedas_del_dia()
	
func _crear_label_dia():
	dia_label = Label.new()
	dia_label.name = "DiaLabel"
	dia_label.position = Vector2(965, 150)  # debajo del timer
	dia_label.add_theme_font_size_override("font_size", 20)
	dia_label.add_theme_color_override("font_color", Color(1, 1, 0))
	dia_label.text = "Día %d / %d" % [GameState.dia_actual, GameState.total_dias]
	hud_game.add_child(dia_label)

		
func _process(delta):
	if game_finished:
		return

	time_left = max(time_left - delta, 0.0)
	actualizar_timer_label()

	if GameState.dinero_total >= GameState.dinero_objetivo:
		terminar_juego(true)
		return

	if task_ui and task_ui.completed_tasks >= task_ui.max_tasks:
		terminar_juego(true)
		return

	if time_left <= 0.0:
		terminar_juego(false)

func _reiniciar_dia():
	time_left = 60.0
	game_finished = false
	area_actual = "cuarto"
	
	if GameState.dia_actual >= 2:
		_spawn_marido_interactivo()
		task_ui.max_tasks = 4
	else:
		task_ui.max_tasks = 3
		if sala.has_node("MaridoInteractivo"):
			sala.get_node("MaridoInteractivo").queue_free()

	task_ui.completed_tasks = 0
	task_ui.update_task_counter()
	
	_reiniciar_interactivos()
	activar_cuarto()
	
	if dia_label:
		dia_label.text = "Día %d / %d" % [GameState.dia_actual, GameState.total_dias]
		
	if timer_label:
		timer_label.visible = true
		
	_spawn_monedas_del_dia()
func _reiniciar_interactivos():
	var interactivos = []
	if cocina.has_node("Estufa"):
		interactivos.append(cocina.get_node("Estufa"))
	if sala.has_node("Sofa"):
		interactivos.append(sala.get_node("Sofa"))
	if cuarto.has_node("Cama"):
		interactivos.append(cuarto.get_node("Cama"))
	
	for obj in interactivos:
		obj.is_completed = false
		obj.is_interacting = false
		if "current_time" in obj:
			obj.current_time = 0.0
		if obj.has_node("Sprite2D"):
			obj.get_node("Sprite2D").modulate = Color(1, 1, 1)
		
		if obj.has_node("Exclamacion"):
			obj.get_node("Exclamacion").show()
			if obj.get_node("Exclamacion").has_method("set_process"):
				obj.get_node("Exclamacion").set_process(true)

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

	if cuarto.has_node("Cama"):
		_conectar_interactivo_con_hud(cuarto.get_node("Cama"))

func crear_ui_tiempo_resultado():
	timer_label = Label.new()
	timer_label.name = "TimerLabel"
	timer_label.position = Vector2(965, 120)
	timer_label.add_theme_font_size_override("font_size", 24)
	timer_label.add_theme_color_override("font_color", Color(1, 1, 1))
	hud_game.add_child(timer_label)
	actualizar_timer_label()

	# Capa visual para fin de partida (color + imagen animada).
	end_overlay = ColorRect.new()
	end_overlay.name = "EndOverlay"
	end_overlay.color = Color(0, 0, 0, 0)
	end_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	end_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	end_overlay.visible = false
	hud_game.add_child(end_overlay)

	end_image = TextureRect.new()
	end_image.name = "EndImage"
	end_image.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	end_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	end_image.custom_minimum_size = Vector2(620, 260)
	end_image.size = Vector2(620, 260)
	end_image.position = end_image_base_position
	end_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	end_image.visible = false
	hud_game.add_child(end_image)

func actualizar_timer_label():
	if not timer_label:
		return
	var seconds = int(ceil(time_left))
	var minutes_part = int(seconds / 60.0)
	var seconds_part = seconds % 60
	timer_label.text = "Tiempo: %02d:%02d" % [minutes_part, seconds_part]

func terminar_juego(gano: bool):
	if game_finished:
		return
	game_finished = true
	if player and player.has_method("set_working"):
		player.set_working(false)

	_cancelar_todas_las_interacciones()

	var tareas_falladas = {}
	var penalizacion = 0
	if not gano:
		tareas_falladas = _obtener_tareas_falladas()
		penalizacion = tareas_falladas.size() * 50
		GameState.dinero_total = max(0, GameState.dinero_total - penalizacion)
		
		# Actualizar frasco HUD inmediatamente
		var jar = get_tree().get_first_node_in_group("frasco")
		if jar:
			jar.money = GameState.dinero_total
			jar.update_money_display()

	day_transition.transition_finished.connect(
		_on_transicion_terminada.bind(gano),
		CONNECT_ONE_SHOT
	)
	day_transition.mostrar(GameState.dia_actual, gano, tareas_falladas, penalizacion)

func _cancelar_todas_las_interacciones():
	var interactivos = []
	if cocina.has_node("Estufa"):
		interactivos.append(cocina.get_node("Estufa"))
	if sala.has_node("Sofa"):
		interactivos.append(sala.get_node("Sofa"))
	if cuarto.has_node("Cama"):
		interactivos.append(cuarto.get_node("Cama"))
	
	# También cancelar al Marido si existe en la escena
	var marido_obj = sala.get_node_or_null("MaridoInteractivo")
	if marido_obj:
		interactivos.append(marido_obj)
	
	for obj in interactivos:
		if obj.has_method("cancel_interaction") and obj.is_interacting:
			obj.cancel_interaction()

func _obtener_tareas_falladas() -> Dictionary:
	var falladas = {}
	if cocina.has_node("Estufa"):
		var estufa = cocina.get_node("Estufa")
		if not estufa.is_completed:
			falladas["Apagar la Estufa"] = 50
	if sala.has_node("Sofa"):
		var sofa = sala.get_node("Sofa")
		if not sofa.is_completed:
			falladas["Limpiar el Sofá"] = 50
	if cuarto.has_node("Cama"):
		var cama = cuarto.get_node("Cama")
		if not cama.is_completed:
			falladas["Tender la Cama"] = 50
	
	# Verificar también al marido si está activo en la sala
	var marido_obj = sala.get_node_or_null("MaridoInteractivo")
	if marido_obj:
		if not marido_obj.is_completed:
			falladas["Atender al Marido"] = 50
			
	return falladas


func _on_transicion_terminada(gano: bool):
	GameState.dia_actual += 1
	if GameState.dia_actual > GameState.total_dias or GameState.dinero_total >= GameState.dinero_objetivo:
		var gano_final: bool = GameState.dinero_total >= GameState.dinero_objetivo
		_mostrar_fin_total(gano_final)
	else:
		_reiniciar_dia()

func _animar_fin_partida(gano: bool):
	# Matematica base: cada propiedad sigue una interpolacion en el tiempo.
	# v(t) = v0 + (v1 - v0) * E(t), donde E(t) es una curva de easing.
	# En victoria usamos curvas con "overshoot" (BACK) para energia positiva.
	# En derrota usamos curvas exponenciales/suaves para sensacion pesada y triste.
	if gano:
		var tw_enter_win = create_tween()
		tw_enter_win.set_parallel(true)
		tw_enter_win.tween_property(end_overlay, "color:a", 0.58, 0.55).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tw_enter_win.tween_property(end_image, "modulate:a", 1.0, 0.42)
		tw_enter_win.tween_property(end_image, "position", end_image_base_position + Vector2(0, 12), 0.46).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw_enter_win.tween_property(end_image, "scale", Vector2(1.30, 1.30), 0.52).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw_enter_win.tween_property(end_image, "rotation", deg_to_rad(2), 0.40).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

		var tw_settle_win = create_tween()
		tw_settle_win.tween_interval(0.52)
		tw_settle_win.tween_property(end_image, "position", end_image_base_position, 0.24).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tw_settle_win.tween_property(end_image, "scale", Vector2(1.0, 1.0), 0.28).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tw_settle_win.tween_property(end_image, "rotation", 0.0, 0.22).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

		# Pulso final alegre para rematar el triunfo.
		var tw_pulse_win = create_tween()
		tw_pulse_win.tween_interval(0.92)
		tw_pulse_win.tween_property(end_image, "scale", Vector2(1.08, 1.08), 0.20).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tw_pulse_win.tween_property(end_image, "scale", Vector2(1.0, 1.0), 0.22).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	else:
		var tw_enter_lose = create_tween()
		tw_enter_lose.set_parallel(true)
		tw_enter_lose.tween_property(end_overlay, "color:a", 0.82, 0.90).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		tw_enter_lose.tween_property(end_image, "modulate:a", 1.0, 0.70)
		tw_enter_lose.tween_property(end_image, "position", end_image_base_position + Vector2(0, 14), 0.78).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		tw_enter_lose.tween_property(end_image, "scale", Vector2(0.96, 0.96), 0.86).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		tw_enter_lose.tween_property(end_image, "rotation", deg_to_rad(-2), 0.74).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

		var tw_settle_lose = create_tween()
		tw_settle_lose.tween_interval(0.86)
		tw_settle_lose.tween_property(end_image, "position", end_image_base_position, 0.36).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tw_settle_lose.tween_property(end_image, "scale", Vector2(1.0, 1.0), 0.34).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tw_settle_lose.tween_property(end_image, "rotation", 0.0, 0.30).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

		# Pulso tenue triste (como latido lento).
		var tw_pulse_lose = create_tween()
		tw_pulse_lose.tween_interval(1.16)
		tw_pulse_lose.tween_property(end_overlay, "color:a", 0.90, 0.34).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tw_pulse_lose.tween_property(end_overlay, "color:a", 0.82, 0.44).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

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
			puerta_cuarto.body_entered.connect(_on_puerta_entered.bind("sala", "sala_cuarto"))

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

func _mostrar_fin_total(gano: bool):
	game_finished = true
	if timer_label:
		timer_label.visible = false
		
	if end_overlay:
		end_overlay.visible = true
		end_overlay.color = Color(0.6, 0.05, 0.05, 0.0) if not gano else Color(0.05, 0.45, 0.15, 0.0)
	
	if end_image:
		end_image.texture = YOU_WIN_TEXTURE if gano else YOU_LOSE_TEXTURE
		end_image.visible = true
		end_image.scale = Vector2(0.25, 0.25)
		end_image.modulate = Color(1, 1, 1, 0)
		end_image.position = end_image_base_position + (Vector2(0, -90) if gano else Vector2(0, -30))
		end_image.rotation = deg_to_rad(-16) if gano else deg_to_rad(8)
		
	if player and player.has_method("set_working"):
		player.set_working(false)
	
	Engine.time_scale = 0.40 if not gano else 1.08
	_animar_fin_partida(gano)

const MONEDA_SCENE = preload("res://scenes/monedas.tscn")

# Puntos de spawn válidos por habitación (evitan obstáculos y paredes)
# Cocina: pared_arriba y=240, objetos en (250,284), (90,326), (708,363)
const SPAWNS_COCINA = [
	Vector2(660, 280), Vector2(820, 280), Vector2(500, 470),
	Vector2(750, 470), Vector2(200, 470), Vector2(880, 450),
]
# Sala: objetos en (499,346), (920,287), (493,504)
const SPAWNS_SALA = [
	Vector2(200, 360), Vector2(700, 360), Vector2(150, 470),
	Vector2(750, 470), Vector2(350, 470), Vector2(820, 450),
]
# Cuarto: objeto en (492,369) tamaño (280,151), Estufa en (244,309)
const SPAWNS_CUARTO = [
	Vector2(720, 340), Vector2(820, 430), Vector2(150, 380),
	Vector2(150, 470), Vector2(700, 470), Vector2(400, 460),
]

var monedas_activas: Array = []

func _spawn_monedas_del_dia():
	_limpiar_monedas()

	# Pool de todos los puntos posibles etiquetados con su habitación
	var pool: Array = []
	for pos in SPAWNS_COCINA:
		pool.append({"room": "cocina", "pos": pos})
	for pos in SPAWNS_SALA:
		pool.append({"room": "sala", "pos": pos})
	for pos in SPAWNS_CUARTO:
		pool.append({"room": "cuarto", "pos": pos})

	pool.shuffle()

	# Spawnear exactamente 4 montones (o menos si el pool fuera muy chico)
	for i in range(min(4, pool.size())):
		var entrada = pool[i]
		var valor = randi() % 31 + 10  # 10 a 40 inclusive
		_crear_moneda(entrada["room"], entrada["pos"], valor)

func _crear_moneda(room_name: String, pos: Vector2, valor: int):
	var moneda = MONEDA_SCENE.instantiate()
	moneda.coin_value = valor
	moneda.position = pos

	match room_name:
		"cocina": cocina.add_child(moneda)
		"sala":   sala.add_child(moneda)
		"cuarto": cuarto.add_child(moneda)

	monedas_activas.append(moneda)

func _limpiar_monedas():
	for m in monedas_activas:
		if is_instance_valid(m):
			m.queue_free()
	monedas_activas.clear()

func _spawn_marido_interactivo():
	# Verificar si ya existe en la sala
	if sala.has_node("MaridoInteractivo"):
		var marido = sala.get_node("MaridoInteractivo")
		# Resetear estado interactivo
		marido.is_completed = false
		marido.is_interacting = false
		if marido.has_node("Sprite2D"):
			marido.get_node("Sprite2D").texture = preload("res://art/maridoIrritado.png")
			marido.get_node("Sprite2D").modulate = Color(1, 1, 1)
		if marido.has_node("Exclamacion"):
			marido.get_node("Exclamacion").show()
			if marido.get_node("Exclamacion").has_method("set_process"):
				marido.get_node("Exclamacion").set_process(true)
		return

	# Instanciar marido
	var marido = StaticBody2D.new()
	marido.name = "MaridoInteractivo"
	marido.script = load("res://scripts/marido_interactivo.gd")
	marido.position = Vector2(300, 360) # Posición segura y despejada en la Sala
	
	# Añadir colisión
	var col = CollisionShape2D.new()
	col.name = "CollisionShape2D"
	var shape = RectangleShape2D.new()
	shape.size = Vector2(60, 80)
	col.shape = shape
	marido.add_child(col)

	# Añadir Sprite2D
	var sprite = Sprite2D.new()
	sprite.name = "Sprite2D"
	sprite.texture = preload("res://art/maridoIrritado.png")
	sprite.scale = Vector2(1.5, 1.5)
	marido.add_child(sprite)

	# Añadir Exclamación
	var exclam = Sprite2D.new()
	exclam.name = "Exclamacion"
	exclam.texture = preload("res://art/Exclamacion.png")
	exclam.position = Vector2(0, -60)
	exclam.scale = Vector2(0.35, 0.35)
	exclam.script = load("res://scripts/exclamacion_no_rotar.gd")
	marido.add_child(exclam)

	# Añadir a la sala
	sala.add_child(marido)

	# Conectar con el HUD
	_conectar_interactivo_con_hud(marido)
