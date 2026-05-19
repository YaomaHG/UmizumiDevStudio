extends Node2D

@onready var cocina = $Cocina
@onready var sala = $Sala
@onready var cuarto = $Cuarto
@onready var player = $Player
@onready var hud_game = $HudGame
@onready var task_ui = $HudGame/TaskUi

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
var day: int = 1
const DAY_TIMES = [60.0, 50.0, 40.0, 30.0]
const MAX_DAYS = 4

var marido = null
var marido_state_label: Label = null
var day_overlay: ColorRect = null
var day_label: Label = null
var day_tasks_label: Label = null
var day_penalty_label: Label = null
var day_marido_label: Label = null
var day_continue_label: Label = null
var skip_day_label: Label = null
var _waiting_for_day_advance: bool = false
var _time_out_handled: bool = false

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

	# Inicializar tiempo según el día actual
	time_left = DAY_TIMES[clamp(day - 1, 0, DAY_TIMES.size() - 1)]

	# Attach script for Marido instance in HUD (si existe)
	if hud_game and hud_game.has_node("Marido"):
		var marido_node = hud_game.get_node("Marido")
		marido_node.script = load("res://scripts/marido.gd")
		marido = marido_node
		_actualizar_marido_label()

	var start_marker = get_node_or_null("Start")
	if start_marker and start_marker is Marker2D:
		player.global_position = start_marker.global_position
	else:
		player.global_position = spawn_cuarto

func _process(delta):
	if _waiting_for_day_advance:
		if Input.is_action_just_pressed("ui_accept") or Input.is_key_pressed(KEY_SPACE):
			_waiting_for_day_advance = false
			day_overlay.visible = false
			reiniciar_dia()
		return

	# DEBUG: Botón para saltar día (tecla K)
	if Input.is_key_pressed(KEY_K):
		_time_out_handled = false
		time_left = 0.0

	if game_finished:
		return

	time_left = max(time_left - delta, 0.0)
	actualizar_timer_label()

	if task_ui and task_ui.completed_tasks >= task_ui.max_tasks:
		terminar_juego(true)
		return

	if time_left <= 0.0:
		_on_time_out()

func _actualizar_marido_label():
	if not marido_state_label:
		return
	if marido:
		marido_state_label.text = "Esposo: %s" % [marido.get_state_name().capitalize()]
	else:
		marido_state_label.text = "Esposo: Normal"

func _on_time_out():
	# Prevenir ejecución múltiple
	if _time_out_handled:
		return
	_time_out_handled = true

	# Si el esposo ya está furioso, la siguiente derrota es Game Over permanente.
	if not marido:
		# intentar adjuntar script si faltó
		if hud_game and hud_game.has_node("Marido"):
			var mnode = hud_game.get_node("Marido")
			mnode.script = load("res://scripts/marido.gd")
			marido = mnode

	if marido and marido.is_furioso():
		terminar_juego(false) # Game Over definitivo
		return

	# Si es el día 1: mostrar solo "DIA 2" sin estadísticas
	if day == 1:
		if marido:
			marido.incrementar_estado()
			_actualizar_marido_label()
		
		day = 2
		_waiting_for_day_advance = true
		game_finished = true
		_show_simple_day_overlay(day)
		return

	# Día 2+: mostrar transición completa con estadísticas
	var next_day = min(day + 1, MAX_DAYS)
	var penalty = 10 # segundos a restar por día
	var marido_got_angrier = false
	var new_state_name = "Normal"

	# Recopilar estado previo
	var prev_state_index = -1
	if marido:
		prev_state_index = marido.get_state_index()
		# incrementar estado aquí para reflejar el cambio que debe mostrarse
		marido.incrementar_estado()
		new_state_name = marido.get_state_name().capitalize()
		marido_got_angrier = marido.get_state_index() > prev_state_index
		_actualizar_marido_label()

	# Recopilar tareas incompletas para mostrar cuáles fallaron
	var incomplete = _collect_incomplete_tasks()
	# Mostrar pantalla de cambio de día con la info
	_show_day_transition(next_day, incomplete, penalty, marido_got_angrier, new_state_name)

	# Actualizaremos `day` y reiniciaremos al terminar la animación (en callback)
	day = next_day

func reiniciar_dia():
	# Reinicia el estado de la partida para el siguiente día sin mostrar Game Over
	game_finished = false
	Engine.time_scale = 1.0
	get_tree().paused = false

	if timer_label:
		timer_label.visible = true
	if end_overlay:
		end_overlay.visible = false
	if end_image:
		end_image.visible = false

	# Reset de tareas
	if task_ui:
		task_ui.completed_tasks = 0
		if task_ui.has_method("update_task_counter"):
			task_ui.update_task_counter()

	# Reset progress bar si aplica
	if progress_bar_display and progress_bar_display.has_method("update_progress"):
		# dejar en 0
		progress_bar_display.update_progress(0.0)

	# Reposicionar jugador y ajustar tiempo para el nuevo día
	player.global_position = spawn_cuarto
	time_left = DAY_TIMES[clamp(day - 1, 0, DAY_TIMES.size() - 1)]
	actualizar_timer_label()
	_time_out_handled = false

func _create_day_overlay():
	# Capa negra full screen
	day_overlay = ColorRect.new()
	day_overlay.name = "DayOverlay"
	day_overlay.color = Color(0, 0, 0, 0)
	day_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	day_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	day_overlay.visible = false
	hud_game.add_child(day_overlay)

	# Label grande para 'DIA X'
	day_label = Label.new()
	day_label.name = "DayLabel"
	day_label.text = "DIA 1"
	day_label.position = Vector2(540, 160)
	day_label.add_theme_font_size_override("font_size", 56)
	day_label.horizontal_alignment = 1
	day_label.add_theme_color_override("font_color", Color(1,1,1))
	day_label.modulate = Color(1,1,1,0)
	day_overlay.add_child(day_label)

	# Label para tareas falladas (DERECHA)
	day_tasks_label = Label.new()
	day_tasks_label.name = "DayTasksLabel"
	day_tasks_label.text = ""
	day_tasks_label.position = Vector2(850, 220)
	day_tasks_label.add_theme_font_size_override("font_size", 18)
	day_tasks_label.horizontal_alignment = 0
	day_tasks_label.custom_minimum_size = Vector2(250, 0)
	day_tasks_label.add_theme_color_override("font_color", Color(1,1,1))
	day_tasks_label.modulate = Color(1,1,1,0)
	day_overlay.add_child(day_tasks_label)

	# Label para penalizacion de tiempo (DERECHA)
	day_penalty_label = Label.new()
	day_penalty_label.name = "DayPenaltyLabel"
	day_penalty_label.text = ""
	day_penalty_label.position = Vector2(850, 300)
	day_penalty_label.add_theme_font_size_override("font_size", 20)
	day_penalty_label.horizontal_alignment = 0
	day_penalty_label.add_theme_color_override("font_color", Color(1,1,1))
	day_penalty_label.modulate = Color(1,1,1,0)
	day_overlay.add_child(day_penalty_label)

	# Label para estado del esposo (si aumentó) (DERECHA)
	day_marido_label = Label.new()
	day_marido_label.name = "DayMaridoLabel"
	day_marido_label.text = ""
	day_marido_label.position = Vector2(850, 350)
	day_marido_label.add_theme_font_size_override("font_size", 20)
	day_marido_label.horizontal_alignment = 0
	day_marido_label.add_theme_color_override("font_color", Color(1,1,1))
	day_marido_label.modulate = Color(1,1,1,0)
	day_overlay.add_child(day_marido_label)

	# Label para confirmación (continuar con espacio)
	day_continue_label = Label.new()
	day_continue_label.name = "DayContinueLabel"
	day_continue_label.text = "Presiona ESPACIO para continuar"
	day_continue_label.position = Vector2(540, 500)
	day_continue_label.add_theme_font_size_override("font_size", 18)
	day_continue_label.horizontal_alignment = 1
	day_continue_label.add_theme_color_override("font_color", Color(1,1,1))
	day_continue_label.modulate = Color(1,1,1,0)
	day_overlay.add_child(day_continue_label)

func _collect_incomplete_tasks() -> Array:
	var list = []
	# Buscar en habitaciones principales
	for root in [cocina, sala, cuarto]:
		if not root:
			continue
		for child in root.get_children():
			var val = null
			# Intentar leer propiedad is_completed (si existe)
			val = child.get("is_completed")
			if val != null:
				list.append({"name": child.name, "completed": bool(val)})
			# También buscar recursivamente dentro
			for sub in child.get_children():
				var sval = sub.get("is_completed")
				if sval != null:
					list.append({"name": sub.name, "completed": bool(sval)})
	return list

func _show_day_transition(next_day: int, incomplete: Array, penalty: int, marido_got_angrier: bool, new_state_name: String):
	if not day_overlay:
		_create_day_overlay()

	# Preparar texto
	day_label.text = "DIA %d" % next_day
	var failed_count = 0
	var tasks_text = ""
	for item in incomplete:
		if not item.completed:
			failed_count += 1
			tasks_text += "- %s\n" % item.name
	if tasks_text == "":
		tasks_text = "No hubo tareas incompletas."
	day_tasks_label.text = "Tareas incompletas: %d/%d\n%s" % [failed_count, task_ui.max_tasks, tasks_text]
	day_penalty_label.text = "Perderás: -%ds" % penalty
	day_marido_label.text = "Esposo: %s %s" % [new_state_name, "(se enojó)" if marido_got_angrier else ""]

	# Mostrar overlay y animar aparición
	day_overlay.visible = true
	# Fade in overlay color alpha
	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(day_overlay, "color:a", 1.0, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_property(day_label, "modulate:a", 1.0, 0.6)
	tw.tween_property(day_tasks_label, "modulate:a", 1.0, 0.6)
	tw.tween_property(day_penalty_label, "modulate:a", 1.0, 0.6)
	tw.tween_property(day_marido_label, "modulate:a", 1.0, 0.6)
	tw.tween_property(day_continue_label, "modulate:a", 1.0, 0.6)

	# Esperar a que terminen las animaciones y luego poner en estado de espera
	await tw.finished
	_waiting_for_day_advance = true

func _show_simple_day_overlay(next_day: int):
	# Mostrar solo "DIA X" sin estadísticas (para el día 1)
	if not day_overlay:
		_create_day_overlay()

	# Preparar texto
	day_label.text = "DIA %d" % next_day
	day_tasks_label.text = ""
	day_penalty_label.text = ""
	day_marido_label.text = ""
	day_continue_label.text = "Presiona ESPACIO para continuar"

	# Mostrar overlay y animar aparición
	day_overlay.visible = true
	# Fade in overlay color alpha
	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(day_overlay, "color:a", 1.0, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_property(day_label, "modulate:a", 1.0, 0.6)
	tw.tween_property(day_continue_label, "modulate:a", 1.0, 0.6)

	# Esperar a que terminen las animaciones y luego poner en estado de espera
	await tw.finished
	_waiting_for_day_advance = true

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

	if cuarto.has_node("Estufa"):
		_conectar_interactivo_con_hud(cuarto.get_node("Estufa"))

func crear_ui_tiempo_resultado():
	timer_label = Label.new()
	timer_label.name = "TimerLabel"
	timer_label.position = Vector2(965, 120)
	timer_label.add_theme_font_size_override("font_size", 24)
	timer_label.add_theme_color_override("font_color", Color(1, 1, 1))
	hud_game.add_child(timer_label)
	actualizar_timer_label()

	# Label para mostrar estado del esposo
	marido_state_label = Label.new()
	marido_state_label.name = "MaridoStateLabel"
	marido_state_label.position = Vector2(965, 150)
	marido_state_label.add_theme_font_size_override("font_size", 20)
	marido_state_label.add_theme_color_override("font_color", Color(1, 1, 1))
	hud_game.add_child(marido_state_label)
	_actualizar_marido_label()

	# Label para botón de saltar día (DEBUG)
	skip_day_label = Label.new()
	skip_day_label.name = "SkipDayLabel"
	skip_day_label.text = "[K] Saltar Día"
	skip_day_label.position = Vector2(965, 570)
	skip_day_label.add_theme_font_size_override("font_size", 16)
	skip_day_label.add_theme_color_override("font_color", Color(1, 1, 0))
	hud_game.add_child(skip_day_label)

	# Crear overlay de transición de día (invisible hasta el momento)
	_create_day_overlay()

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
	game_finished = true
	if timer_label:
		timer_label.visible = false

	if end_overlay:
		end_overlay.visible = true
		# Derrota: fondo rojo. Victoria: fondo verde.
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

	# Derrota en camara lenta; victoria con ritmo ligeramente acelerado.
	Engine.time_scale = 0.40 if not gano else 1.08

	_animar_fin_partida(gano)

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

	# Espera mas larga para disfrutar la animacion antes de pausar.
	await get_tree().create_timer(2.2, true, false, true).timeout
	Engine.time_scale = 1.0
	get_tree().paused = true

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
