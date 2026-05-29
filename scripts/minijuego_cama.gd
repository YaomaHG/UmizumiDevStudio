extends CanvasLayer

signal cama_completada
signal cama_cancelada

# Estados del minijuego
enum Fase { SACUDIR, ALMOHADAS }
var estado_actual: Fase = Fase.SACUDIR

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

# Contenedores de Fases
var sacudir_container: Control
var almohadas_container: Control

# --- VARIABLES FASE 1: SACUDIR ---
var shake_count: int = 0
var shake_required: int = 10 # Dificultad aumentada (de 5 a 10)
var shake_bar_fill: ColorRect
var sheet_label: Label

# --- VARIABLES FASE 2: ALMOHADAS ---
var pillow_hits: int = 0
var pillow_required: int = 2
var needle_speed: float = 220.0 # Dificultad aumentada (de 120 a 220 - ¡Más rápido!)
var needle_direction: float = 1.0
var needle_value: float = 0.0 # 0.0 a 100.0
var perfect_zone_min: float = 45.0 # Dificultad aumentada (de 40 a 45)
var perfect_zone_max: float = 55.0 # Dificultad aumentada (de 60 a 55)

var bar_bg: ColorRect
var perfect_zone: ColorRect
var needle: ColorRect

func _ready():
	# Dificultad escalada progresivamente según el día
	var dia = GameState.dia_actual
	shake_required = 4 + dia * 2  # Día 1: 6, Día 2: 8, Día 3: 10, Día 4: 12, etc.
	needle_speed = 130.0 + dia * 25.0 # Día 1: 155, Día 2: 180, Día 3: 205, Día 4: 230, etc.
	var half_width = max(3.5, 12.0 - dia * 1.5) # Día 1: 10.5%, Día 2: 9.0%, Día 3: 7.5%, etc.
	perfect_zone_min = 50.0 - half_width
	perfect_zone_max = 50.0 + half_width

	# Encontrar al jugador en la escena principal de forma infalible
	player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	if not player:
		player = get_tree().current_scene.get_node_or_null("Player") as CharacterBody2D
	if player:
		player.movement_locked = true
		player.velocity = Vector2.ZERO
		if player.has_method("set_working"):
			player.set_working(true)

	# 1. Overlay oscuro semi-translúcido para la pantalla completa
	overlay = ColorRect.new()
	overlay.color = Color(0.0, 0.0, 0.0, 0.6)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)

	# 2. Panel Central Estilizado (Cozy Slate Blue style)
	panel = Panel.new()
	panel.custom_minimum_size = Vector2(550, 290)
	panel.size = Vector2(550, 290)
	add_child(panel)

	# Centrar dinámicamente el panel según la pantalla
	var screen_size = get_viewport().get_visible_rect().size
	panel.position = (screen_size - panel.size) / 2.0

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.08, 0.14, 0.96) # Gris azulado acogedor
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.border_color = Color(0.42, 0.68, 0.90, 0.85) # Borde celeste suave
	style.shadow_color = Color(0, 0, 0, 0.35)
	style.shadow_size = 12
	panel.add_theme_stylebox_override("panel", style)

	# 3. Título Principal
	title_label = Label.new()
	title_label.text = "🛌 TENDER LA CAMA"
	title_label.add_theme_font_size_override("font_size", 22)
	title_label.add_theme_color_override("font_color", Color(0.42, 0.68, 0.90))
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.position = Vector2(0, 18)
	title_label.size = Vector2(550, 28)
	title_label.pivot_offset = Vector2(275, 14)
	panel.add_child(title_label)

	# 4. Subtítulo (Instrucciones)
	subtitle_label = Label.new()
	subtitle_label.text = "Instrucciones de la tarea..."
	subtitle_label.add_theme_font_size_override("font_size", 13)
	subtitle_label.add_theme_color_override("font_color", Color(0.75, 0.75, 0.75))
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.position = Vector2(0, 48)
	subtitle_label.size = Vector2(550, 18)
	panel.add_child(subtitle_label)

	# --- CREAR CONTENEDORES DE FASES ---
	sacudir_container = Control.new()
	sacudir_container.size = Vector2(550, 160)
	sacudir_container.position = Vector2(0, 70)
	panel.add_child(sacudir_container)

	almohadas_container = Control.new()
	almohadas_container.size = Vector2(550, 160)
	almohadas_container.position = Vector2(0, 70)
	almohadas_container.visible = false
	panel.add_child(almohadas_container)

	# --- MAQUETAR FASES ---
	_disenar_fase_sacudir()
	_disenar_fase_almohadas()

	# 5. Luces de Progreso (representan los 2 almohadazos de la fase 2)
	var lights_y = 222.0
	var light_size = 12.0
	var spacing = 12.0
	var total_lights_width = (pillow_required * light_size) + ((pillow_required - 1) * spacing)
	var lights_start_x = (panel.size.x - total_lights_width) / 2.0

	for i in range(pillow_required):
		var light = ColorRect.new()
		light.size = Vector2(light_size, light_size)
		light.position = Vector2(lights_start_x + i * (light_size + spacing), lights_y)
		light.color = Color(0.25, 0.25, 0.25)
		panel.add_child(light)
		lights.append(light)

	# 6. Feedback de acierto/error
	feedback_label = Label.new()
	feedback_label.text = ""
	feedback_label.add_theme_font_size_override("font_size", 20)
	feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback_label.position = Vector2(0, 235)
	feedback_label.size = Vector2(550, 24)
	feedback_label.pivot_offset = Vector2(275, 12)
	panel.add_child(feedback_label)

	# 7. Tecla para salir
	escape_label = Label.new()
	escape_label.text = "Presiona [ESC] para salir"
	escape_label.add_theme_font_size_override("font_size", 11)
	escape_label.add_theme_color_override("font_color", Color(0.45, 0.45, 0.5))
	escape_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	escape_label.position = Vector2(0, 264)
	escape_label.size = Vector2(550, 16)
	panel.add_child(escape_label)

	# Iniciar primer estado
	iniciar_fase_sacudir()

# ==============================================================================
# 🎨 DISEÑO E INICIALIZACIÓN DE FASES
# ==============================================================================

func _disenar_fase_sacudir():
	# Barra de Sacudido Vacía
	var bar_width = 360.0
	var bar_height = 20.0
	var bar_x = (sacudir_container.size.x - bar_width) / 2.0
	
	var bar_bg = ColorRect.new()
	bar_bg.color = Color(0.15, 0.17, 0.22)
	bar_bg.size = Vector2(bar_width, bar_height)
	bar_bg.position = Vector2(bar_x, 30)
	sacudir_container.add_child(bar_bg)

	shake_bar_fill = ColorRect.new()
	shake_bar_fill.color = Color(0.42, 0.68, 0.90) # Celeste
	shake_bar_fill.size = Vector2(0, bar_height)
	shake_bar_fill.position = Vector2(0, 0)
	bar_bg.add_child(shake_bar_fill)

	# Texto / Dibujo Sábana
	sheet_label = Label.new()
	sheet_label.text = "💨 Sacudiendo sábanas..."
	sheet_label.add_theme_font_size_override("font_size", 26)
	sheet_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sheet_label.position = Vector2(0, 75)
	sheet_label.size = Vector2(550, 45)
	sheet_label.pivot_offset = Vector2(275, 22.5)
	sacudir_container.add_child(sheet_label)

func _disenar_fase_almohadas():
	var bar_width = 360.0
	var bar_height = 28.0
	var bar_x = (almohadas_container.size.x - bar_width) / 2.0
	var bar_y = 35.0

	# Contenedor del medidor
	bar_bg = ColorRect.new()
	bar_bg.color = Color(0.15, 0.17, 0.22)
	bar_bg.size = Vector2(bar_width, bar_height)
	bar_bg.position = Vector2(bar_x, bar_y)
	almohadas_container.add_child(bar_bg)

	# Zona verde óptima calculada dinámicamente según la dificultad
	perfect_zone = ColorRect.new()
	perfect_zone.color = Color(0.15, 0.72, 0.35, 0.85) # Verde óptimo
	var p_min_pct = perfect_zone_min / 100.0
	var p_max_pct = perfect_zone_max / 100.0
	perfect_zone.size = Vector2(bar_width * (p_max_pct - p_min_pct), bar_height)
	perfect_zone.position = Vector2(bar_width * p_min_pct, 0)
	bar_bg.add_child(perfect_zone)

	# Aguja indicadora
	needle = ColorRect.new()
	needle.color = Color(0.42, 0.68, 0.90) # Celeste suave
	needle.size = Vector2(6, bar_height + 8)
	needle.position = Vector2(0, -4)
	bar_bg.add_child(needle)

	# Etiqueta Almohada
	var pillow_txt = Label.new()
	pillow_txt.text = "☁️ ¡Sacude las almohadas!"
	pillow_txt.add_theme_font_size_override("font_size", 24)
	pillow_txt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pillow_txt.position = Vector2(0, 80)
	pillow_txt.size = Vector2(550, 40)
	pillow_txt.pivot_offset = Vector2(275, 20)
	almohadas_container.add_child(pillow_txt)

# ==============================================================================
# 🎮 MÁQUINA DE ESTADOS Y CONTROL JUGABLE
# ==============================================================================

func iniciar_fase_sacudir():
	estado_actual = Fase.SACUDIR
	title_label.text = "💨 PASO 1/2: ESTIRAR SÁBANAS"
	subtitle_label.text = "Presiona repetidamente [E] o [ESPACIO] rápido para quitar arrugas"
	sacudir_container.show()
	almohadas_container.hide()
	
	# Apagar luces de progreso
	for l in lights:
		l.color = Color(0.25, 0.25, 0.25)
		
	shake_count = 0
	shake_bar_fill.size.x = 0

func iniciar_fase_almohadas():
	estado_actual = Fase.ALMOHADAS
	title_label.text = "☁️ PASO 2/2: ACOMODAR ALMOHADAS"
	subtitle_label.text = "Presiona [E] o [ESPACIO] cuando la aguja celeste esté en la zona VERDE"
	
	sacudir_container.hide()
	almohadas_container.show()
	
	pillow_hits = 0
	needle_value = 0.0
	needle_direction = 1.0

# ==============================================================================
# 💻 ACTUALIZACIÓN Y PROCESAMIENTO
# ==============================================================================

func _process(delta):
	if not is_game_active:
		return

	if estado_actual == Fase.ALMOHADAS:
		_procesar_fase_almohadas(delta)

func _procesar_fase_almohadas(delta):
	# Mover aguja de un lado a otro
	needle_value += needle_speed * delta * needle_direction
	if needle_value >= 100.0:
		needle_value = 100.0
		needle_direction = -1.0
	elif needle_value <= 0.0:
		needle_value = 0.0
		needle_direction = 1.0

	var bar_w = bar_bg.size.x
	needle.position.x = (needle_value / 100.0) * bar_w - (needle.size.x / 2.0)

func _input(event):
	if not is_game_active:
		return

	if event.is_action_pressed("ui_cancel"):
		cancelar_juego()
		return

	if estado_actual == Fase.SACUDIR:
		_procesar_input_sacudir(event)
	elif estado_actual == Fase.ALMOHADAS:
		_procesar_input_almohadas(event)

func _procesar_input_sacudir(event):
	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and (event.keycode == KEY_SPACE or event.keycode == KEY_E)):
		shake_count += 1

		# Animación de rebote visual en el texto de sábanas
		sheet_label.scale = Vector2(1.22, 1.22)
		var t = create_tween()
		t.tween_property(sheet_label, "scale", Vector2(1.0, 1.0), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

		# Feedback texto flotante
		mostrar_feedback("¡Sacude! ✨", Color(0.42, 0.68, 0.90))

		# Relleno de la barra
		var percentage = min(float(shake_count) / shake_required, 1.0)
		shake_bar_fill.size.x = percentage * 360.0

		# Flash rápido en el borde del panel
		var flash = create_tween()
		flash.tween_property(panel, "theme_override_styles/panel:border_color", Color(0.42, 0.68, 0.90, 1.0), 0.05)
		flash.tween_property(panel, "theme_override_styles/panel:border_color", Color(0.42, 0.68, 0.90, 0.85), 0.15)

		if shake_count >= shake_required:
			completar_fase_sacudir()

func _procesar_input_almohadas(event):
	if not can_press:
		return

	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and (event.keycode == KEY_SPACE or event.keycode == KEY_E)):
		can_press = false
		get_tree().create_timer(0.25).timeout.connect(func(): can_press = true)

		# Evaluar si la aguja está en el rango verde (40% - 60%)
		if needle_value >= perfect_zone_min and needle_value <= perfect_zone_max:
			# ¡ACIERTO!
			pillow_hits += 1
			mostrar_feedback("¡Esponjosa! ☁️✨", Color(0.2, 0.9, 0.4))

			# Encender luz de progreso
			if pillow_hits <= lights.size():
				lights[pillow_hits - 1].color = Color(0.2, 0.9, 0.4) # Verde

			# Flash verde en el panel
			var f_tween = create_tween()
			f_tween.tween_property(panel, "theme_override_styles/panel:border_color", Color(0.2, 0.9, 0.4, 1.0), 0.05)
			f_tween.tween_property(panel, "theme_override_styles/panel:border_color", Color(0.42, 0.68, 0.90, 0.85), 0.15)

			if pillow_hits >= pillow_required:
				completar_juego()
		else:
			# ¡FALLO! (Penalización extrema: ¡Resetear a 0 aciertos consecutivos!)
			pillow_hits = 0
			for l in lights:
				l.color = Color(0.25, 0.25, 0.25) # Apagar luces (gris)

			mostrar_feedback("¡Se desacomodó! ¡Otra vez! 💨", Color(0.95, 0.2, 0.2))

			# Flash rojo de error
			var f_tween = create_tween()
			f_tween.tween_property(panel, "theme_override_styles/panel:border_color", Color(0.95, 0.2, 0.2, 1.0), 0.05)
			f_tween.tween_property(panel, "theme_override_styles/panel:border_color", Color(0.42, 0.68, 0.90, 0.85), 0.15)

# ==============================================================================
# 🚪 COMPLETACIÓN Y TRANSICIONES DE FASES
# ==============================================================================

func completar_fase_sacudir():
	is_game_active = false
	title_label.text = "💨 ¡SÁBANAS ESTIRADAS!"
	title_label.add_theme_color_override("font_color", Color(0.2, 0.9, 0.4))
	subtitle_label.text = "Sábanas perfectamente lisas y estiradas."
	mostrar_feedback("¡Excelente! Acomodando almohadas...", Color(0.2, 0.9, 0.4))

	var timer = get_tree().create_timer(0.7)
	await timer.timeout
	
	is_game_active = true
	iniciar_fase_almohadas()

func completar_juego():
	is_game_active = false
	title_label.text = "🛌 ¡CAMA IMPECABLE!"
	title_label.add_theme_color_override("font_color", Color(0.2, 0.9, 0.4))
	subtitle_label.text = "¡Has tendido la cama de forma fantástica!"
	
	# Desbloquear movimiento
	if player:
		player.movement_locked = false
		if player.has_method("set_working"):
			player.set_working(false)

	# Esperar con felicitaciones
	var delay_timer = get_tree().create_timer(1.2)
	await delay_timer.timeout
	
	cama_completada.emit()
	queue_free()

func cancelar_juego():
	is_game_active = false
	if player:
		player.movement_locked = false
		if player.has_method("set_working"):
			player.set_working(false)
	
	cama_cancelada.emit()
	queue_free()

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
