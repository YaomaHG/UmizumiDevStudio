extends CanvasLayer

signal cocina_completada
signal cocina_cancelada

# Estados del juego
enum Fase { PICAR, FUEGO, SAZONAR }
var estado_actual: Fase = Fase.PICAR

var is_game_active: bool = true
var can_press: bool = true

# Referencia al Jugador
var player: CharacterBody2D = null

# Nodos Comunes de la UI
var overlay: ColorRect
var panel: Panel
var title_label: Label
var subtitle_label: Label
var feedback_label: Label
var escape_label: Label
var lights: Array[ColorRect] = []

# Nodos de Contenedores de Fases
var picar_container: Control
var fuego_container: Control
var sazonar_container: Control

# --- VARIABLES Y NODOS FASE 1: PICAR ---
var chop_count: int = 0
var chop_required: int = 8
var picar_bar_fill: ColorRect
var picar_percentage_label: Label
var onion_label: Label

# --- VARIABLES Y NODOS FASE 2: FUEGO ---
var temp_value: float = 40.0
var temp_rise_rate: float = 26.0 # La temperatura sube por segundo
var temp_cool_rate: float = 19.0 # Baja la temperatura al pulsar
var perfect_temp_min: float = 60.0
var perfect_temp_max: float = 80.0
var cook_time: float = 0.0
var cook_time_required: float = 3.0

var temp_bar_fill: ColorRect
var temp_needle: ColorRect
var cook_bar_fill: ColorRect
var cook_time_label: Label

# --- VARIABLES Y NODOS FASE 3: SAZONAR ---
var season_count: int = 0
var season_required: int = 3
var current_requested_spice: String = ""
var spices_list: Array[String] = ["sal", "pimienta", "oregano"]

var request_box: Panel
var request_label: Label
var card_sal: Panel
var card_pimienta: Panel
var card_oregano: Panel

func _ready():
	# Dificultad escalada progresivamente según el día
	var dia = GameState.dia_actual
	chop_required = 5 + dia * 2  # Día 1: 7, Día 2: 9, Día 3: 11, Día 4: 13, etc.
	temp_rise_rate = 16.0 + dia * 5.0 # Día 1: 21, Día 2: 26, Día 3: 31, Día 4: 36, etc.
	cook_time_required = 2.0 + dia * 0.4 # Día 1: 2.4s, Día 2: 2.8s, Día 3: 3.2s, Día 4: 3.6s, etc.
	var half_width = max(4.0, 14.0 - dia * 1.5) # Día 1: 12.5%, Día 2: 11.0%, Día 3: 9.5%, etc.
	perfect_temp_min = 70.0 - half_width
	perfect_temp_max = 70.0 + half_width

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
	overlay.color = Color(0.0, 0.0, 0.0, 0.65)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)

	# 2. Panel Central Estilizado (Glassmorphism)
	panel = Panel.new()
	panel.custom_minimum_size = Vector2(600, 340)
	panel.size = Vector2(600, 340)
	add_child(panel)

	# Centrar dinámicamente el panel según la pantalla
	var screen_size = get_viewport().get_visible_rect().size
	panel.position = (screen_size - panel.size) / 2.0

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.07, 0.07, 0.10, 0.96) # Fondo oscuro moderno
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.border_color = Color(0.95, 0.72, 0.15, 0.85) # Borde dorado elegante
	style.shadow_color = Color(0, 0, 0, 0.45)
	style.shadow_size = 14
	panel.add_theme_stylebox_override("panel", style)

	# 3. Título Principal
	title_label = Label.new()
	title_label.text = "🍳 SIMULADOR DE COCINA"
	title_label.add_theme_font_size_override("font_size", 24)
	title_label.add_theme_color_override("font_color", Color(0.95, 0.72, 0.15))
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.position = Vector2(0, 20)
	title_label.size = Vector2(600, 30)
	title_label.pivot_offset = Vector2(300, 15)
	panel.add_child(title_label)

	# 4. Subtítulo (Instrucciones)
	subtitle_label = Label.new()
	subtitle_label.text = "Instrucciones de la tarea..."
	subtitle_label.add_theme_font_size_override("font_size", 14)
	subtitle_label.add_theme_color_override("font_color", Color(0.75, 0.75, 0.75))
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.position = Vector2(0, 52)
	subtitle_label.size = Vector2(600, 20)
	panel.add_child(subtitle_label)

	# --- CREAR CONTENEDORES PARA CADA FASE ---
	picar_container = Control.new()
	picar_container.size = Vector2(600, 200)
	picar_container.position = Vector2(0, 75)
	panel.add_child(picar_container)

	fuego_container = Control.new()
	fuego_container.size = Vector2(600, 200)
	fuego_container.position = Vector2(0, 75)
	fuego_container.visible = false
	panel.add_child(fuego_container)

	sazonar_container = Control.new()
	sazonar_container.size = Vector2(600, 200)
	sazonar_container.position = Vector2(0, 75)
	sazonar_container.visible = false
	panel.add_child(sazonar_container)

	# --- MAQUETAR FASE 1: PICAR ---
	_disenar_fase_picar()

	# --- MAQUETAR FASE 2: FUEGO ---
	_disenar_fase_fuego()

	# --- MAQUETAR FASE 3: SAZONAR ---
	_disenar_fase_sazonar()

	# 5. Luces de Progreso Global (reutilizadas para aciertos de condimentos / pasos)
	var lights_y = 265.0
	var light_size = 14.0
	var spacing = 12.0
	var total_lights_width = (season_required * light_size) + ((season_required - 1) * spacing)
	var lights_start_x = (panel.size.x - total_lights_width) / 2.0

	for i in range(season_required):
		var light = ColorRect.new()
		light.size = Vector2(light_size, light_size)
		light.position = Vector2(lights_start_x + i * (light_size + spacing), lights_y)
		light.color = Color(0.25, 0.25, 0.25)
		panel.add_child(light)
		lights.append(light)

	# 6. Feedback de acierto/error
	feedback_label = Label.new()
	feedback_label.text = ""
	feedback_label.add_theme_font_size_override("font_size", 22)
	feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback_label.position = Vector2(0, 282)
	feedback_label.size = Vector2(600, 26)
	feedback_label.pivot_offset = Vector2(300, 13)
	panel.add_child(feedback_label)

	# 7. Tecla para salir
	escape_label = Label.new()
	escape_label.text = "Presiona [ESC] para salir"
	escape_label.add_theme_font_size_override("font_size", 12)
	escape_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	escape_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	escape_label.position = Vector2(0, 312)
	escape_label.size = Vector2(600, 18)
	panel.add_child(escape_label)

	# Iniciar el primer estado
	iniciar_fase_picar()

# ==============================================================================
# 🎨 DISEÑO E INICIALIZACIÓN DE FASES
# ==============================================================================

func _disenar_fase_picar():
	# Barra de Picado Vacía
	var bar_width = 400.0
	var bar_height = 24.0
	var bar_x = (picar_container.size.x - bar_width) / 2.0
	
	var bar_bg = ColorRect.new()
	bar_bg.color = Color(0.16, 0.16, 0.20)
	bar_bg.size = Vector2(bar_width, bar_height)
	bar_bg.position = Vector2(bar_x, 40)
	picar_container.add_child(bar_bg)

	picar_bar_fill = ColorRect.new()
	picar_bar_fill.color = Color(0.95, 0.72, 0.15) # Dorado
	picar_bar_fill.size = Vector2(0, bar_height)
	picar_bar_fill.position = Vector2(0, 0)
	bar_bg.add_child(picar_bar_fill)

	# Texto Porcentaje
	picar_percentage_label = Label.new()
	picar_percentage_label.text = "0%"
	picar_percentage_label.add_theme_font_size_override("font_size", 16)
	picar_percentage_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	picar_percentage_label.position = Vector2(0, 15)
	picar_percentage_label.size = Vector2(600, 20)
	picar_container.add_child(picar_percentage_label)

	# Vegetal Cebolla
	onion_label = Label.new()
	onion_label.text = "🧅 Tabla de Picar"
	onion_label.add_theme_font_size_override("font_size", 34)
	onion_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	onion_label.position = Vector2(0, 85)
	onion_label.size = Vector2(600, 50)
	onion_label.pivot_offset = Vector2(300, 25)
	picar_container.add_child(onion_label)

func _disenar_fase_fuego():
	var bar_width = 400.0
	var bar_height = 26.0
	var bar_x = (fuego_container.size.x - bar_width) / 2.0

	# Thermometer bar bg
	var temp_bar_bg = ColorRect.new()
	temp_bar_bg.color = Color(0.16, 0.16, 0.20)
	temp_bar_bg.size = Vector2(bar_width, bar_height)
	temp_bar_bg.position = Vector2(bar_x, 30)
	fuego_container.add_child(temp_bar_bg)

	# Perfect Temperature Zone calculada dinámicamente según la dificultad
	var perfect_zone = ColorRect.new()
	perfect_zone.color = Color(0.15, 0.72, 0.35, 0.85) # Verde brillante óptimo
	var p_min_pct = perfect_temp_min / 100.0
	var p_max_pct = perfect_temp_max / 100.0
	perfect_zone.size = Vector2(bar_width * (p_max_pct - p_min_pct), bar_height)
	perfect_zone.position = Vector2(bar_width * p_min_pct, 0)
	temp_bar_bg.add_child(perfect_zone)

	# Fill bar representing current heat
	temp_bar_fill = ColorRect.new()
	temp_bar_fill.color = Color(0.9, 0.4, 0.1, 0.6) # Naranja fuego
	temp_bar_fill.size = Vector2(0, bar_height)
	temp_bar_fill.position = Vector2(0, 0)
	temp_bar_bg.add_child(temp_bar_fill)

	# Needle showing current heat percentage
	temp_needle = ColorRect.new()
	temp_needle.color = Color(1.0, 1.0, 1.0) # Aguja blanca
	temp_needle.size = Vector2(6, bar_height + 10)
	temp_needle.position = Vector2(0, -5)
	temp_bar_bg.add_child(temp_needle)

	# --- PROGRESS BAR FOR PERFECT COOK TIME ---
	var cook_width = 300.0
	var cook_height = 12.0
	var cook_x = (fuego_container.size.x - cook_width) / 2.0

	var cook_bg = ColorRect.new()
	cook_bg.color = Color(0.1, 0.1, 0.12)
	cook_bg.size = Vector2(cook_width, cook_height)
	cook_bg.position = Vector2(cook_x, 90)
	fuego_container.add_child(cook_bg)

	cook_bar_fill = ColorRect.new()
	cook_bar_fill.color = Color(0.15, 0.72, 0.35) # Verde cocinado
	cook_bar_fill.size = Vector2(0, cook_height)
	cook_bar_fill.position = Vector2(0, 0)
	cook_bg.add_child(cook_bar_fill)

	cook_time_label = Label.new()
	cook_time_label.text = "Olla fría"
	cook_time_label.add_theme_font_size_override("font_size", 14)
	cook_time_label.add_theme_color_override("font_color", Color(0.75, 0.75, 0.75))
	cook_time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cook_time_label.position = Vector2(0, 115)
	cook_time_label.size = Vector2(600, 20)
	fuego_container.add_child(cook_time_label)

func _disenar_fase_sazonar():
	# Caja central de solicitud de condimento
	request_box = Panel.new()
	request_box.size = Vector2(320, 48)
	request_box.position = Vector2(140, 10)
	request_box.pivot_offset = Vector2(160, 24)
	sazonar_container.add_child(request_box)

	var box_style = StyleBoxFlat.new()
	box_style.bg_color = Color(0.12, 0.12, 0.15, 0.95)
	box_style.corner_radius_top_left = 10
	box_style.corner_radius_top_right = 10
	box_style.corner_radius_bottom_left = 10
	box_style.corner_radius_bottom_right = 10
	box_style.border_width_left = 2
	box_style.border_width_top = 2
	box_style.border_width_right = 2
	box_style.border_width_bottom = 2
	box_style.border_color = Color(0.95, 0.72, 0.15)
	request_box.add_theme_stylebox_override("panel", box_style)

	request_label = Label.new()
	request_label.text = "¡SOLICITUD!"
	request_label.add_theme_font_size_override("font_size", 18)
	request_label.add_theme_color_override("font_color", Color(0.95, 0.72, 0.15))
	request_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	request_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	request_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	request_box.add_child(request_label)

	# --- 3 TARJETAS PARA LOS CONDIMENTOS ---
	var card_w = 140.0
	var card_h = 75.0
	var spacing = 20.0
	var total_w = (3 * card_w) + (2 * spacing)
	var start_x = (sazonar_container.size.x - total_w) / 2.0
	var cards_y = 80.0

	# 1. Tarjeta Sal (Izquierda)
	card_sal = Panel.new()
	card_sal.size = Vector2(card_w, card_h)
	card_sal.position = Vector2(start_x, cards_y)
	card_sal.pivot_offset = Vector2(card_w / 2.0, card_h / 2.0)
	sazonar_container.add_child(card_sal)
	_crear_card_especias(card_sal, "🧂 SAL", "A / <-")

	# 2. Tarjeta Pimienta (Centro)
	card_pimienta = Panel.new()
	card_pimienta.size = Vector2(card_w, card_h)
	card_pimienta.position = Vector2(start_x + card_w + spacing, cards_y)
	card_pimienta.pivot_offset = Vector2(card_w / 2.0, card_h / 2.0)
	sazonar_container.add_child(card_pimienta)
	_crear_card_especias(card_pimienta, "🌶️ PIMIENTA", "ESPACIO / E")

	# 3. Tarjeta Orégano (Derecha)
	card_oregano = Panel.new()
	card_oregano.size = Vector2(card_w, card_h)
	card_oregano.position = Vector2(start_x + 2 * (card_w + spacing), cards_y)
	card_oregano.pivot_offset = Vector2(card_w / 2.0, card_h / 2.0)
	sazonar_container.add_child(card_oregano)
	_crear_card_especias(card_oregano, "🌿 ORÉGANO", "D / ->")

func _crear_card_especias(card: Panel, name: String, key_hint: String):
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.10, 0.10, 0.13)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.4, 0.4, 0.45)
	card.add_theme_stylebox_override("panel", style)

	var label_name = Label.new()
	label_name.text = name
	label_name.add_theme_font_size_override("font_size", 14)
	label_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_name.position = Vector2(0, 15)
	label_name.size = Vector2(card.size.x, 20)
	card.add_child(label_name)

	var label_hint = Label.new()
	label_hint.text = key_hint
	label_hint.add_theme_font_size_override("font_size", 12)
	label_hint.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	label_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_hint.position = Vector2(0, 42)
	label_hint.size = Vector2(card.size.x, 15)
	card.add_child(label_hint)

# ==============================================================================
# 🎮 MÁQUINA DE ESTADOS Y CONTROL JUGABLE
# ==============================================================================

func iniciar_fase_picar():
	estado_actual = Fase.PICAR
	title_label.text = "🔪 PASO 1/3: PICAR CEBULLA"
	subtitle_label.text = "Presiona repetidamente [E] o [ESPACIO] rápidamente para picar la verdura"
	picar_container.show()
	fuego_container.hide()
	sazonar_container.hide()
	
	# Actualizar luces para la fase
	for l in lights:
		l.color = Color(0.25, 0.25, 0.25)
	
	chop_count = 0
	picar_bar_fill.size.x = 0
	picar_percentage_label.text = "0%"

func iniciar_fase_fuego():
	estado_actual = Fase.FUEGO
	title_label.text = "🔥 PASO 2/3: CONTROLAR EL FUEGO"
	subtitle_label.text = "La olla se calienta sola. ¡Presiona [E] o [ESPACIO] para regular el fuego y mantenerlo en VERDE!"
	
	picar_container.hide()
	fuego_container.show()
	sazonar_container.hide()
	
	# Encender la primera luz de progreso
	lights[0].color = Color(0.2, 0.9, 0.4)
	
	temp_value = 40.0
	cook_time = 0.0
	cook_bar_fill.size.x = 0
	cook_time_label.text = "Calentando..."

func iniciar_fase_sazonar():
	estado_actual = Fase.SAZONAR
	title_label.text = "🧂 PASO 3/3: CONDIMENTAR AL GUSTO"
	subtitle_label.text = "Presiona la especia solicitada: Izquierda (Sal), Espacio (Pimienta), Derecha (Orégano)"
	
	picar_container.hide()
	fuego_container.hide()
	sazonar_container.show()
	
	# Encender la segunda luz de progreso
	lights[0].color = Color(0.2, 0.9, 0.4)
	lights[1].color = Color(0.2, 0.9, 0.4)
	
	season_count = 0
	solicitar_especia()

func solicitar_especia():
	# Elegir especia aleatoria
	current_requested_spice = spices_list[randi() % spices_list.size()]
	
	match current_requested_spice:
		"sal":
			request_label.text = "¡AGREGA SAL! 🧂"
		"pimienta":
			request_label.text = "¡AGREGA PIMIENTA! 🌶️"
		"oregano":
			request_label.text = "¡AGREGA ORÉGANO! 🌿"
			
	# Animación pop-in del cajón
	request_box.scale = Vector2(0.9, 0.9)
	var tween = create_tween()
	tween.tween_property(request_box, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

# ==============================================================================
# 💻 ACTUALIZACIÓN Y PROCESAMIENTO
# ==============================================================================

func _process(delta):
	if not is_game_active:
		return

	if estado_actual == Fase.FUEGO:
		_procesar_fase_fuego(delta)

func _procesar_fase_fuego(delta):
	# La temperatura se calienta por sí sola progresivamente
	temp_value += temp_rise_rate * delta
	if temp_value > 100.0:
		temp_value = 100.0

	# Mover aguja y barra de relleno visual
	var bar_w = temp_bar_fill.get_parent().size.x
	temp_bar_fill.size.x = (temp_value / 100.0) * bar_w
	temp_needle.position.x = (temp_value / 100.0) * bar_w - (temp_needle.size.x / 2.0)

	# Evaluar si está en el rango óptimo (60%-80%)
	if temp_value >= perfect_temp_min and temp_value <= perfect_temp_max:
		cook_time += delta
		var percentage = min(cook_time / cook_time_required, 1.0)
		
		cook_bar_fill.size.x = percentage * 300.0
		cook_time_label.text = "♨️ ¡Cocinando óptimo! " + str(int(percentage * 100.0)) + "%"
		cook_time_label.add_theme_color_override("font_color", Color(0.2, 0.9, 0.4)) # Verde
		
		# Pulso de iluminación en el panel
		panel.get_theme_stylebox("panel").border_color = Color(0.2, 0.9, 0.4, 0.85)

		if cook_time >= cook_time_required:
			completar_fase_fuego()
	else:
		# Flashes de alerta
		panel.get_theme_stylebox("panel").border_color = Color(0.95, 0.72, 0.15, 0.85)
		
		if temp_value < perfect_temp_min:
			cook_time_label.text = "⚠️ ¡SE ENFRÍA! (Bajo fuego)"
			cook_time_label.add_theme_color_override("font_color", Color(0.4, 0.6, 0.95)) # Azul frío
		else:
			cook_time_label.text = "🔥 ¡SE QUEMA! (Baja el fuego)"
			cook_time_label.add_theme_color_override("font_color", Color(0.95, 0.2, 0.2)) # Rojo caliente

func _input(event):
	if not is_game_active:
		return

	if event.is_action_pressed("ui_cancel"):
		cancelar_juego()
		return

	if estado_actual == Fase.PICAR:
		_procesar_input_picar(event)
	elif estado_actual == Fase.FUEGO:
		_procesar_input_fuego(event)
	elif estado_actual == Fase.SAZONAR:
		_procesar_input_sazonar(event)

func _procesar_input_picar(event):
	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and (event.keycode == KEY_SPACE or event.keycode == KEY_E)):
		chop_count += 1
		
		# Animación de golpe en la tabla de picar
		onion_label.scale = Vector2(1.25, 1.25)
		var t = create_tween()
		t.tween_property(onion_label, "scale", Vector2(1.0, 1.0), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

		# Sonido/feedback visual de impacto
		mostrar_feedback("¡ZAS! 🔪", Color(0.95, 0.72, 0.15))

		# Actualizar progreso
		var percentage = min(float(chop_count) / chop_required, 1.0)
		picar_bar_fill.size.x = percentage * 400.0
		picar_percentage_label.text = str(int(percentage * 100)) + "%"

		# Flash de corte
		var f_tween = create_tween()
		f_tween.tween_property(panel, "theme_override_styles/panel:border_color", Color(0.95, 0.72, 0.15, 1.0), 0.05)
		f_tween.tween_property(panel, "theme_override_styles/panel:border_color", Color(0.95, 0.72, 0.15, 0.85), 0.15)

		if chop_count >= chop_required:
			completar_fase_picar()

func _procesar_input_fuego(event):
	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and (event.keycode == KEY_SPACE or event.keycode == KEY_E)):
		# Presionar Space/E reduce la temperatura (simula agua fría o bajar gas)
		temp_value = max(temp_value - temp_cool_rate, 0.0)
		
		# Feedback de ajuste
		mostrar_feedback("¡Temperatura bajada! 💧", Color(0.4, 0.6, 0.95))

		# Flash azul en el panel
		var f_tween = create_tween()
		f_tween.tween_property(panel, "theme_override_styles/panel:border_color", Color(0.4, 0.6, 0.95, 1.0), 0.05)
		f_tween.tween_property(panel, "theme_override_styles/panel:border_color", Color(0.95, 0.72, 0.15, 0.85), 0.15)

func _procesar_input_sazonar(event):
	if not can_press:
		return

	# Tecla Izquierda / A -> SAL
	if event.is_action_pressed("move_left") or (event is InputEventKey and event.pressed and event.keycode == KEY_A):
		_evaluar_condimento("sal", card_sal)
		
	# Tecla Derecha / D -> ORÉGANO
	elif event.is_action_pressed("move_right") or (event is InputEventKey and event.pressed and event.keycode == KEY_D):
		_evaluar_condimento("oregano", card_oregano)
		
	# Tecla Espacio / E -> PIMIENTA
	elif event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and (event.keycode == KEY_SPACE or event.keycode == KEY_E)):
		_evaluar_condimento("pimienta", card_pimienta)

func _evaluar_condimento(espece: String, card: Panel):
	can_press = false
	get_tree().create_timer(0.3).timeout.connect(func(): can_press = true)

	if espece == current_requested_spice:
		# ¡ACIERTO!
		season_count += 1
		
		# Encender luz de acierto
		if season_count <= lights.size():
			lights[season_count - 1].color = Color(0.2, 0.9, 0.4) # Verde

		# Animar la tarjeta
		card.scale = Vector2(1.2, 1.2)
		var tween = create_tween()
		tween.tween_property(card, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		
		# Flash verde en la tarjeta
		var flash_style = card.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
		card.add_theme_stylebox_override("panel", flash_style)
		var flash = create_tween()
		flash.tween_property(flash_style, "border_color", Color(0.2, 0.9, 0.4, 1.0), 0.08)
		flash.tween_property(flash_style, "border_color", Color(0.4, 0.4, 0.45), 0.22)

		if season_count >= season_required:
			mostrar_feedback("¡Delicioso! 🍲🏆", Color(0.2, 0.9, 0.4))
			completar_juego()
		else:
			mostrar_feedback("¡Excelente toque! 🌶️", Color(0.2, 0.9, 0.4))
			solicitar_especia()
	else:
		# ¡FALLO!
		mostrar_feedback("¡Cuidado, muy fuerte! 💨", Color(0.95, 0.2, 0.2))

		# Flash rojo en la tarjeta incorrecta
		var flash_style = card.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
		card.add_theme_stylebox_override("panel", flash_style)
		var flash = create_tween()
		flash.tween_property(flash_style, "border_color", Color(0.95, 0.2, 0.2, 1.0), 0.08)
		flash.tween_property(flash_style, "border_color", Color(0.4, 0.4, 0.45), 0.22)
		
		# Sacudir tarjeta
		card.position.x += 10
		var shake = create_tween()
		shake.tween_property(card, "position:x", card.position.x - 20, 0.05)
		shake.tween_property(card, "position:x", card.position.x + 10, 0.05)

		# Solicitar otra especia
		solicitar_especia()

# ==============================================================================
# 🚪 COMPLETACIÓN Y TRANSICIONES DE FASES
# ==============================================================================

func completar_fase_picar():
	is_game_active = false
	title_label.text = "🧅 ¡PICADO COMPLETADO!"
	title_label.add_theme_color_override("font_color", Color(0.2, 0.9, 0.4))
	subtitle_label.text = "Ingredientes listos para la olla."
	mostrar_feedback("¡Excelente! Avanzando...", Color(0.2, 0.9, 0.4))

	var timer = get_tree().create_timer(0.7)
	await timer.timeout
	
	is_game_active = true
	iniciar_fase_fuego()

func completar_fase_fuego():
	is_game_active = false
	title_label.text = "🍲 ¡COCCIÓN CORRECTA!"
	title_label.add_theme_color_override("font_color", Color(0.2, 0.9, 0.4))
	subtitle_label.text = "La comida se ha cocinado a fuego perfecto."
	mostrar_feedback("¡Hora de sazonar! Avanzando...", Color(0.2, 0.9, 0.4))

	var timer = get_tree().create_timer(0.7)
	await timer.timeout

	is_game_active = true
	iniciar_fase_sazonar()

func completar_juego():
	is_game_active = false
	title_label.text = "🍲 ¡PLATO TERMINADO!"
	title_label.add_theme_color_override("font_color", Color(0.2, 0.9, 0.4))
	subtitle_label.text = "¡Has completado la receta de forma espectacular!"
	
	# Desbloquear movimiento
	if player:
		player.movement_locked = false
		if player.has_method("set_working"):
			player.set_working(false)

	# Esperar con felicitaciones
	var delay_timer = get_tree().create_timer(1.2)
	await delay_timer.timeout
	
	cocina_completada.emit()
	queue_free()

func cancelar_juego():
	is_game_active = false
	if player:
		player.movement_locked = false
		if player.has_method("set_working"):
			player.set_working(false)
	
	cocina_cancelada.emit()
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
	fade_tween.tween_interval(0.55)
	fade_tween.tween_property(feedback_label, "modulate:a", 0.0, 0.20)
