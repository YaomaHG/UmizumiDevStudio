extends CanvasLayer

signal sofa_completado
signal sofa_cancelado

var is_game_active: bool = true
var can_press: bool = true

# Referencia al Jugador
var player: CharacterBody2D = null

# Nodos de UI Comunes
var overlay: ColorRect
var panel: Panel
var title_label: Label
var subtitle_label: Label
var feedback_label: Label
var escape_label: Label
var lights: Array[ColorRect] = []

# Nodos del Tablero de Juego (Sillón)
var board: Panel
var cursor: Panel
var scorpion: Label
var trash_spots: Array[Label] = []

# Configuración del Juego
var score: int = 0
var score_required: int = 5
var cursor_speed: float = 220.0 # Velocidad de movimiento del cursor
var cursor_pos: Vector2 = Vector2(210, 90) # Posición local en el tablero

# Scorpion Física
var scorpion_pos: Vector2 = Vector2(380, 20)
var scorpion_velocity: Vector2 = Vector2(160.0, 130.0) # Bota a gran velocidad

# Tipos de basura
var trash_emojis: Array[String] = ["🗑️", "🕸️", "🪳", "🧦"]

func _ready():
	# Encontrar al jugador en la escena principal
	player = get_tree().current_scene.get_node_or_null("Player") as CharacterBody2D
	if player:
		player.movement_locked = true
		player.velocity = Vector2.ZERO
		if player.has_method("set_working"):
			player.set_working(true)

	# 1. Overlay oscuro semi-translúcido para la pantalla completa
	overlay = ColorRect.new()
	overlay.color = Color(0.0, 0.0, 0.0, 0.65)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)

	# 2. Panel Central Estilizado (Warm retro leather orange/brown style)
	panel = Panel.new()
	panel.custom_minimum_size = Vector2(560, 335)
	panel.size = Vector2(560, 335)
	add_child(panel)

	# Centrar dinámicamente el panel según la pantalla
	var screen_size = get_viewport().get_visible_rect().size
	panel.position = (screen_size - panel.size) / 2.0
	panel.pivot_offset = panel.size / 2.0

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.08, 0.06, 0.96) # Marrón cuero oscuro cálido
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.border_color = Color(0.9, 0.48, 0.22, 0.85) # Borde naranja sillón retro
	style.shadow_color = Color(0, 0, 0, 0.4)
	style.shadow_size = 12
	panel.add_theme_stylebox_override("panel", style)

	# 3. Título Principal
	title_label = Label.new()
	title_label.text = "🛋️ LIMPIEZA EXTREMA DEL SILLÓN"
	title_label.add_theme_font_size_override("font_size", 20)
	title_label.add_theme_color_override("font_color", Color(0.9, 0.48, 0.22))
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.position = Vector2(0, 16)
	title_label.size = Vector2(560, 24)
	panel.add_child(title_label)

	# 4. Subtítulo (Instrucciones)
	subtitle_label = Label.new()
	subtitle_label.text = "Mueve la aspiradora con WASD/Flechas y aspira basura con E/Espacio. ¡Esquiva al escorpión!"
	subtitle_label.add_theme_font_size_override("font_size", 12)
	subtitle_label.add_theme_color_override("font_color", Color(0.75, 0.75, 0.75))
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.position = Vector2(0, 42)
	subtitle_label.size = Vector2(560, 16)
	panel.add_child(subtitle_label)

	# 5. Tablero del Sillón (Área de juego: 420x160)
	board = Panel.new()
	board.size = Vector2(420, 160)
	board.position = Vector2(70, 65)
	panel.add_child(board)

	var board_style = StyleBoxFlat.new()
	board_style.bg_color = Color(0.16, 0.12, 0.10) # Cojines oscuros
	board_style.corner_radius_top_left = 8
	board_style.corner_radius_top_right = 8
	board_style.corner_radius_bottom_left = 8
	board_style.corner_radius_bottom_right = 8
	board_style.border_width_left = 2
	board_style.border_width_top = 2
	board_style.border_width_right = 2
	board_style.border_width_bottom = 2
	board_style.border_color = Color(0.28, 0.22, 0.18)
	board.add_theme_stylebox_override("panel", board_style)

	# --- CURSOR DE LA ASPIRADORA ---
	cursor = Panel.new()
	cursor.size = Vector2(32, 32)
	cursor.pivot_offset = Vector2(16, 16)
	board.add_child(cursor)

	var cursor_style = StyleBoxFlat.new()
	cursor_style.bg_color = Color(0, 0, 0, 0) # Transparente al centro
	cursor_style.border_color = Color(0.2, 0.7, 1.0) # Celeste eléctrico
	cursor_style.border_width_left = 3
	cursor_style.border_width_top = 3
	cursor_style.border_width_right = 3
	cursor_style.border_width_bottom = 3
	cursor_style.corner_radius_top_left = 16
	cursor_style.corner_radius_top_right = 16
	cursor_style.corner_radius_bottom_left = 16
	cursor_style.corner_radius_bottom_right = 16
	cursor.add_theme_stylebox_override("panel", cursor_style)

	# --- EL ESCORPIÓN (🦂) ---
	scorpion = Label.new()
	scorpion.text = "🦂"
	scorpion.add_theme_font_size_override("font_size", 22)
	scorpion.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	scorpion.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	scorpion.size = Vector2(26, 26)
	scorpion.pivot_offset = Vector2(13, 13)
	board.add_child(scorpion)

	# 6. Luces de Progreso (5 luces para las 5 basuras)
	var lights_y = 236.0
	var light_size = 12.0
	var spacing = 12.0
	var total_lights_width = (score_required * light_size) + ((score_required - 1) * spacing)
	var lights_start_x = (panel.size.x - total_lights_width) / 2.0

	for i in range(score_required):
		var light = ColorRect.new()
		light.size = Vector2(light_size, light_size)
		light.position = Vector2(lights_start_x + i * (light_size + spacing), lights_y)
		light.color = Color(0.25, 0.25, 0.25)
		panel.add_child(light)
		lights.append(light)

	# 7. Feedback de Acierto / Picadura
	feedback_label = Label.new()
	feedback_label.text = ""
	feedback_label.add_theme_font_size_override("font_size", 18)
	feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback_label.position = Vector2(0, 255)
	feedback_label.size = Vector2(560, 24)
	feedback_label.pivot_offset = Vector2(280, 12)
	panel.add_child(feedback_label)

	# 8. Tecla de Escape
	escape_label = Label.new()
	escape_label.text = "Presiona [ESC] para salir"
	escape_label.add_theme_font_size_override("font_size", 11)
	escape_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	escape_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	escape_label.position = Vector2(0, 288)
	escape_label.size = Vector2(560, 16)
	panel.add_child(escape_label)

	# Inicializar la primera ronda
	spawn_basuras()
	actualizar_luces()

# ==============================================================================
# 🎮 GENERACIÓN DE BASURAS
# ==============================================================================

func spawn_basuras():
	# Limpiar basuras anteriores
	for t in trash_spots:
		if is_instance_valid(t):
			t.queue_free()
	trash_spots.clear()

	# Generar exactamente 5 basuras en posiciones aleatorias
	for i in range(score_required):
		var tr = Label.new()
		tr.text = trash_emojis[randi() % trash_emojis.size()]
		tr.add_theme_font_size_override("font_size", 18)
		tr.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		tr.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		tr.size = Vector2(24, 24)
		tr.pivot_offset = Vector2(12, 12)
		
		# Evitar que spawneen pegados a las paredes del tablero (ancho 420, alto 160)
		var rand_x = randf_range(20.0, 390.0)
		var rand_y = randf_range(20.0, 135.0)
		tr.position = Vector2(rand_x, rand_y)
		
		board.add_child(tr)
		trash_spots.append(tr)

# ==============================================================================
# 💻 ACTUALIZACIÓN Y PROCESAMIENTO
# ==============================================================================

func _process(delta):
	if not is_game_active:
		return

	_procesar_movimiento_cursor(delta)
	_procesar_fisica_escorpion(delta)
	_evaluar_colision_escorpion()

func _procesar_movimiento_cursor(delta):
	var dir = Vector2.ZERO
	if Input.is_action_pressed("move_left") or Input.is_key_pressed(KEY_A):
		dir.x -= 1
	if Input.is_action_pressed("move_right") or Input.is_key_pressed(KEY_D):
		dir.x += 1
	if Input.is_action_pressed("move_up") or Input.is_key_pressed(KEY_W):
		dir.y -= 1
	if Input.is_action_pressed("move_down") or Input.is_key_pressed(KEY_S):
		dir.y += 1

	if dir.length() > 0:
		dir = dir.normalized()

	cursor_pos += dir * cursor_speed * delta

	# Clampar para no salirse del tablero (Ancho: 420, Alto: 160. Cursor tiene 32x32)
	cursor_pos.x = clamp(cursor_pos.x, 0.0, board.size.x - cursor.size.x)
	cursor_pos.y = clamp(cursor_pos.y, 0.0, board.size.y - cursor.size.y)

	cursor.position = cursor_pos

func _procesar_fisica_escorpion(delta):
	# Movimiento del escorpión
	scorpion_pos += scorpion_velocity * delta

	# Rebote en límites de pared (Ancho: 420, Alto: 160)
	var max_x = board.size.x - scorpion.size.x
	var max_y = board.size.y - scorpion.size.y

	if scorpion_pos.x <= 0.0:
		scorpion_pos.x = 0.0
		scorpion_velocity.x *= -1.0
	elif scorpion_pos.x >= max_x:
		scorpion_pos.x = max_x
		scorpion_velocity.x *= -1.0

	if scorpion_pos.y <= 0.0:
		scorpion_pos.y = 0.0
		scorpion_velocity.y *= -1.0
	elif scorpion_pos.y >= max_y:
		scorpion_pos.y = max_y
		scorpion_velocity.y *= -1.0

	scorpion.position = scorpion_pos

func _evaluar_colision_escorpion():
	# Obtener centros
	var cursor_center = cursor_pos + cursor.size / 2.0
	var scorpion_center = scorpion_pos + scorpion.size / 2.0

	# Distancia
	var dist = cursor_center.distance_to(scorpion_center)
	if dist < 22.0:
		# ¡PICADURA DE ESCORPIÓN! (Resetear todo a 0)
		recibir_picadura()

func recibir_picadura():
	is_game_active = false
	score = 0
	actualizar_luces()
	
	# Mostrar feedback de terror
	mostrar_feedback("💥 ¡PICADURA DE ESCORPIÓN! 🦂 Reset...", Color(0.95, 0.2, 0.2))

	# Flash rojo en toda la pantalla
	var f_tween = create_tween()
	f_tween.tween_property(panel, "theme_override_styles/panel:border_color", Color(0.95, 0.2, 0.2, 1.0), 0.06)
	f_tween.tween_property(panel, "theme_override_styles/panel:border_color", Color(0.9, 0.48, 0.22, 0.85), 0.25)

	# Sacudir panel
	var panel_orig_x = panel.position.x
	var shake = create_tween()
	shake.tween_property(panel, "position:x", panel_orig_x - 14, 0.05)
	shake.tween_property(panel, "position:x", panel_orig_x + 14, 0.05)
	shake.tween_property(panel, "position:x", panel_orig_x - 8, 0.05)
	shake.tween_property(panel, "position:x", panel_orig_x + 8, 0.05)
	shake.tween_property(panel, "position:x", panel_orig_x, 0.05)

	# Reiniciar posiciones del cursor y del escorpión al centro y esquinas seguras
	cursor_pos = Vector2(210, 90)
	cursor.position = cursor_pos
	
	scorpion_pos = Vector2(380, 20)
	scorpion.position = scorpion_pos
	
	# Cambiar dirección del escorpión al azar para variedad
	scorpion_velocity = Vector2(
		160.0 * (1.0 if randf() > 0.5 else -1.0),
		130.0 * (1.0 if randf() > 0.5 else -1.0)
	)

	# Respawn de basuras
	spawn_basuras()

	# Pequeña espera y reactivar
	var timer = get_tree().create_timer(0.7)
	await timer.timeout
	is_game_active = true

func _input(event):
	if not is_game_active:
		return

	if event.is_action_pressed("ui_cancel"):
		cancelar_juego()
		return

	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and (event.keycode == KEY_SPACE or event.keycode == KEY_E)):
		# Intentar aspirar basura cercana
		intentar_aspirar()

func intentar_aspirar():
	var cursor_center = cursor_pos + cursor.size / 2.0
	var trash_cleaned_this_frame = null
	
	# Encontrar si estamos sobre alguna basura
	for t in trash_spots:
		if is_instance_valid(t):
			var trash_center = t.position + t.size / 2.0
			var dist = cursor_center.distance_to(trash_center)
			if dist < 24.0:
				trash_cleaned_this_frame = t
				break

	if trash_cleaned_this_frame != null:
		# ¡ASPIRADA CON ÉXITO!
		score += 1
		trash_spots.erase(trash_cleaned_this_frame)
		trash_cleaned_this_frame.queue_free()
		actualizar_luces()

		# Feedback visual
		mostrar_feedback("🧹 ¡Aspirado! +1", Color(0.2, 0.9, 0.4))

		# Flash de acierto
		var f_tween = create_tween()
		f_tween.tween_property(panel, "theme_override_styles/panel:border_color", Color(0.2, 0.9, 0.4, 1.0), 0.06)
		f_tween.tween_property(panel, "theme_override_styles/panel:border_color", Color(0.9, 0.48, 0.22, 0.85), 0.2)

		# Escalar cursor
		cursor.scale = Vector2(1.3, 1.3)
		var scale_tween = create_tween()
		scale_tween.tween_property(cursor, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

		if score >= score_required:
			completar_juego()
	else:
		# Pulsar al aire
		mostrar_feedback("💨 ¡Aspiradora vacía!", Color(0.5, 0.5, 0.5))

func actualizar_luces():
	for i in range(lights.size()):
		if i < score:
			lights[i].color = Color(0.2, 0.9, 0.4) # Verde éxito
		else:
			lights[i].color = Color(0.25, 0.25, 0.25) # Gris apagado

func mostrar_feedback(texto: String, color: Color):
	feedback_label.text = texto
	feedback_label.add_theme_color_override("font_color", color)
	feedback_label.modulate.a = 1.0
	feedback_label.scale = Vector2(0.85, 0.85)

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(feedback_label, "scale", Vector2(1.15, 1.15), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	var fade_tween = create_tween()
	fade_tween.tween_interval(0.5)
	fade_tween.tween_property(feedback_label, "modulate:a", 0.0, 0.20)

# ==============================================================================
# 🚪 COMPLETACIÓN Y SALIDAS
# ==============================================================================

func completar_juego():
	is_game_active = false
	title_label.text = "🛋️ ¡SILLÓN LIMPIO E IMPECABLE!"
	title_label.add_theme_color_override("font_color", Color(0.2, 0.9, 0.4))
	subtitle_label.text = "¡Has derrotado al escorpión y limpiado el sillón!"
	
	# Desbloquear movimiento
	if player:
		player.movement_locked = false
		if player.has_method("set_working"):
			player.set_working(false)

	# Esperar con felicitaciones
	var delay_timer = get_tree().create_timer(1.2)
	await delay_timer.timeout
	
	sofa_completado.emit()
	queue_free()

func cancelar_juego():
	is_game_active = false
	if player:
		player.movement_locked = false
		if player.has_method("set_working"):
			player.set_working(false)
	
	sofa_cancelado.emit()
	queue_free()
