extends CanvasLayer

signal marido_completado
signal marido_cancelado

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

# Nodos de Juego
var marido_sprite: TextureRect
var demand_label: Label
var timer_bar_bg: ColorRect
var timer_bar_fill: ColorRect

# Estado de Juego
var current_demand: String = ""
var time_left_demand: float = 0.0
var max_time_demand: float = 2.0
var score: int = 0
var score_required: int = 4

# Texturas del marido
const TEXTURE_CALM = preload("res://art/marido_0.png")
const TEXTURE_ANGRY = preload("res://art/maridoIrritado.png")
const TEXTURE_COZY = preload("res://art/maridoEncojado.png")

# Mapeo de demandas a teclas y pistas
const DEMANDAS = [
	{"name": "cafe", "text": "☕ ¡TRAE UN CAFÉ CALIENTE!", "key_hint": "[W] o [↑]"},
	{"name": "periodico", "text": "📰 ¡DAME EL PERIÓDICO DEL DÍA!", "key_hint": "[A] o [←]"},
	{"name": "control", "text": "📺 ¡PÁSAME EL CONTROL DE LA TV!", "key_hint": "[D] o [→]"},
	{"name": "sandwich", "text": "🥪 ¡PREPÁRAME UN SÁNDWICH!", "key_hint": "[S] o [↓]"}
]

func _ready():
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

	# 2. Panel Central Estilizado
	panel = Panel.new()
	panel.custom_minimum_size = Vector2(560, 340)
	panel.size = Vector2(560, 340)
	add_child(panel)

	# Centrar dinámicamente el panel según la pantalla
	var screen_size = get_viewport().get_visible_rect().size
	panel.position = (screen_size - panel.size) / 2.0
	panel.pivot_offset = panel.size / 2.0

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.09, 0.07, 0.12, 0.96) # Gris morado
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.border_color = Color(0.85, 0.35, 0.45, 0.85) # Borde rojo carmín
	style.shadow_color = Color(0, 0, 0, 0.4)
	style.shadow_size = 12
	panel.add_theme_stylebox_override("panel", style)

	# 3. Título Principal
	title_label = Label.new()
	title_label.text = "🤵 ATENDER AL MARIDO"
	title_label.add_theme_font_size_override("font_size", 22)
	title_label.add_theme_color_override("font_color", Color(0.85, 0.35, 0.45))
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.position = Vector2(0, 18)
	title_label.size = Vector2(560, 26)
	panel.add_child(title_label)

	# 4. Subtítulo (Instrucciones)
	subtitle_label = Label.new()
	subtitle_label.text = "El marido está de mal humor. ¡Trae rápido lo que pida pulsando las teclas indicadas!"
	subtitle_label.add_theme_font_size_override("font_size", 12)
	subtitle_label.add_theme_color_override("font_color", Color(0.75, 0.75, 0.75))
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.position = Vector2(0, 48)
	subtitle_label.size = Vector2(560, 16)
	panel.add_child(subtitle_label)

	# 5. Imagen del Marido
	marido_sprite = TextureRect.new()
	marido_sprite.texture = TEXTURE_ANGRY
	marido_sprite.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	marido_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	marido_sprite.size = Vector2(100, 100)
	marido_sprite.position = Vector2(40, 95)
	panel.add_child(marido_sprite)

	# 6. Texto de Petición (Gran Caja)
	demand_label = Label.new()
	demand_label.text = "..."
	demand_label.add_theme_font_size_override("font_size", 18)
	demand_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	demand_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	demand_label.position = Vector2(160, 95)
	demand_label.size = Vector2(360, 60)
	panel.add_child(demand_label)

	var demand_style = StyleBoxFlat.new()
	demand_style.bg_color = Color(0.14, 0.11, 0.18)
	demand_style.corner_radius_top_left = 8
	demand_style.corner_radius_top_right = 8
	demand_style.corner_radius_bottom_left = 8
	demand_style.corner_radius_bottom_right = 8
	demand_style.border_width_left = 1
	demand_style.border_width_top = 1
	demand_style.border_width_right = 1
	demand_style.border_width_bottom = 1
	demand_style.border_color = Color(0.3, 0.25, 0.35)
	demand_label.add_theme_stylebox_override("panel", demand_style)

	# 7. Barra de tiempo para responder
	timer_bar_bg = ColorRect.new()
	timer_bar_bg.color = Color(0.15, 0.12, 0.18)
	timer_bar_bg.size = Vector2(360, 14)
	timer_bar_bg.position = Vector2(160, 175)
	panel.add_child(timer_bar_bg)

	timer_bar_fill = ColorRect.new()
	timer_bar_fill.color = Color(0.85, 0.35, 0.45)
	timer_bar_fill.size = Vector2(360, 14)
	timer_bar_fill.position = Vector2(0, 0)
	timer_bar_bg.add_child(timer_bar_fill)

	# 8. Luces de Progreso (4 luces para las 4 demandas)
	var lights_y = 222.0
	var light_size = 14.0
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

	# 9. Feedback de acierto/error
	feedback_label = Label.new()
	feedback_label.text = ""
	feedback_label.add_theme_font_size_override("font_size", 20)
	feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback_label.position = Vector2(0, 245)
	feedback_label.size = Vector2(560, 24)
	feedback_label.pivot_offset = Vector2(280, 12)
	panel.add_child(feedback_label)

	# 10. Tecla para salir
	escape_label = Label.new()
	escape_label.text = "Presiona [ESC] para salir"
	escape_label.add_theme_font_size_override("font_size", 11)
	escape_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.55))
	escape_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	escape_label.position = Vector2(0, 296)
	escape_label.size = Vector2(560, 16)
	panel.add_child(escape_label)

	# Iniciar primer estado
	nueva_demanda()

func nueva_demanda():
	if not is_game_active:
		return
	
	# Elegir demanda al azar
	var req = DEMANDAS[randi() % DEMANDAS.size()]
	current_demand = req["name"]
	demand_label.text = "%s\n%s" % [req["text"], req["key_hint"]]
	
	# Ajustar el tiempo máximo según la dificultad (se acorta con el día)
	var dia = GameState.dia_actual
	max_time_demand = max(1.0, 2.5 - dia * 0.2) # Día 1: 2.3s, Día 2: 2.1s, Día 3: 1.9s, etc.
	time_left_demand = max_time_demand
	
	marido_sprite.texture = TEXTURE_ANGRY
	
	# Animación pop en la demanda
	demand_label.scale = Vector2(0.9, 0.9)
	var tween = create_tween()
	tween.tween_property(demand_label, "scale", Vector2(1.0, 1.0), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _process(delta):
	if not is_game_active:
		return

	# Controlar el tiempo de la demanda activa
	time_left_demand -= delta
	var percentage = max(0.0, time_left_demand / max_time_demand)
	timer_bar_fill.size.x = percentage * 360.0

	# Si se agota el tiempo, es un fallo
	if time_left_demand <= 0.0:
		recibir_fallo("¡Te tardaste demasiado! 💨")

func _input(event):
	if not is_game_active:
		return

	if event.is_action_pressed("ui_cancel"):
		cancelar_juego()
		return

	if not can_press:
		return

	# Evaluar respuestas correctas según la demanda actual
	var key_pressed = ""
	
	if event.is_action_pressed("move_up") or (event is InputEventKey and event.pressed and event.keycode == KEY_W):
		key_pressed = "cafe"
	elif event.is_action_pressed("move_left") or (event is InputEventKey and event.pressed and event.keycode == KEY_A):
		key_pressed = "periodico"
	elif event.is_action_pressed("move_right") or (event is InputEventKey and event.pressed and event.keycode == KEY_D):
		key_pressed = "control"
	elif event.is_action_pressed("move_down") or (event is InputEventKey and event.pressed and event.keycode == KEY_S):
		key_pressed = "sandwich"
		
	if key_pressed != "":
		can_press = false
		get_tree().create_timer(0.2).timeout.connect(func(): can_press = true)
		
		if key_pressed == current_demand:
			recibir_acierto()
		else:
			recibir_fallo("¡Eso no es lo que te pedí! ❌")

func recibir_acierto():
	score += 1
	actualizar_luces()
	
	mostrar_feedback("¡Gracias! 👍✨", Color(0.2, 0.9, 0.4))
	marido_sprite.texture = TEXTURE_CALM
	
	# Flash verde
	var f_tween = create_tween()
	f_tween.tween_property(panel, "theme_override_styles/panel:border_color", Color(0.2, 0.9, 0.4, 1.0), 0.05)
	f_tween.tween_property(panel, "theme_override_styles/panel:border_color", Color(0.85, 0.35, 0.45, 0.85), 0.15)
	
	if score >= score_required:
		completar_juego()
	else:
		# Pequeña pausa y siguiente demanda
		is_game_active = false
		var timer = get_tree().create_timer(0.5)
		await timer.timeout
		is_game_active = true
		nueva_demanda()

func recibir_fallo(mensaje: String):
	score = 0
	actualizar_luces()
	
	mostrar_feedback(mensaje, Color(0.95, 0.2, 0.2))
	marido_sprite.texture = TEXTURE_ANGRY
	
	# Flash rojo
	var f_tween = create_tween()
	f_tween.tween_property(panel, "theme_override_styles/panel:border_color", Color(0.95, 0.2, 0.2, 1.0), 0.05)
	f_tween.tween_property(panel, "theme_override_styles/panel:border_color", Color(0.85, 0.35, 0.45, 0.85), 0.15)
	
	# Sacudir panel
	var panel_orig_x = panel.position.x
	var shake = create_tween()
	shake.tween_property(panel, "position:x", panel_orig_x - 10, 0.05)
	shake.tween_property(panel, "position:x", panel_orig_x + 10, 0.05)
	shake.tween_property(panel, "position:x", panel_orig_x, 0.05)
	
	# Pausa y resetear
	is_game_active = false
	var timer = get_tree().create_timer(0.6)
	await timer.timeout
	is_game_active = true
	nueva_demanda()

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
	fade_tween.tween_interval(0.4)
	fade_tween.tween_property(feedback_label, "modulate:a", 0.0, 0.15)

func completar_juego():
	is_game_active = false
	title_label.text = "🤵 ¡MARIDO TOTALMENTE CONTENTO!"
	title_label.add_theme_color_override("font_color", Color(0.2, 0.9, 0.4))
	subtitle_label.text = "¡Has atendido todas las quejas de forma increíble!"
	marido_sprite.texture = TEXTURE_COZY
	
	# Desbloquear movimiento
	if player:
		player.movement_locked = false
		if player.has_method("set_working"):
			player.set_working(false)

	# Esperar con felicitaciones
	var delay_timer = get_tree().create_timer(1.2)
	await delay_timer.timeout
	
	marido_completado.emit()
	queue_free()

func cancelar_juego():
	is_game_active = false
	if player:
		player.movement_locked = false
		if player.has_method("set_working"):
			player.set_working(false)
	
	marido_cancelado.emit()
	queue_free()
