extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	# Configurar estilo del panel
	$Panel.add_theme_stylebox_override("panel", StyleBoxFlat.new())
	var style = $Panel.get_theme_stylebox("panel")
	style.bg_color = Color(0.1, 0.1, 0.1, 0.9)  # Fondo oscuro semitransparente
	style.border_width_bottom = 2
	style.border_color = Color(0.5, 0.5, 0.5)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
