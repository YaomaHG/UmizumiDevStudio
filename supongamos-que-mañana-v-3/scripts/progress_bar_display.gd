extends Node2D

var player = null
var bar_visible = false
var label = null
var background = null
var fill_bar = null
var bar_width = 150.0
var bar_height = 25.0

func _ready():
	player = get_parent().get_node("Player")
	
	# Fondo gris
	background = ColorRect.new()
	background.color = Color(0.15, 0.15, 0.15)
	background.size = Vector2(bar_width, bar_height)
	add_child(background)
	
	# Barra verde
	fill_bar = ColorRect.new()
	fill_bar.color = Color(0.2, 1.0, 0.2)
	fill_bar.size = Vector2(0, bar_height)
	add_child(fill_bar)
	
	# Texto porcentaje
	label = Label.new()
	label.text = "0%"
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.position = Vector2(bar_width / 2.0 - 15, -5)
	add_child(label)
	
	hide()

func _process(_delta):
	if bar_visible and player:
		global_position = player.global_position + Vector2(-bar_width / 2.0, -80)

func _on_show_progress_bar(should_show: bool, _pos: Vector2):
	if should_show:
		if not bar_visible:
			label.text = "0%"
			fill_bar.size.x = 0
		bar_visible = true
		self.show()
	else:
		bar_visible = false
		self.hide()

func update_progress(progress: float):
	if not fill_bar or not label:
		return
	
	var clamped_progress = clamp(progress, 0.0, 1.0)
	var percentage = int(clamped_progress * 100.0)
	var fill_width = clamped_progress * bar_width
	
	label.text = str(percentage) + "%"
	fill_bar.size.x = fill_width
