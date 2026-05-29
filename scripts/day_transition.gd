extends CanvasLayer

signal transition_finished

func _ready():
	hide()

func mostrar(dia: int, gano: bool, tareas_falladas: Dictionary = {}, penalizacion: int = 0):
	$ColorRect.color = Color(0.05, 0.45, 0.15) if gano else Color(0.6, 0.05, 0.05)
	$ColorRect/VBoxContainer/DayLabel.text = "DÍA %d COMPLETADO" % dia if gano else "DÍA %d FALLADO" % dia
	
	var result_txt = "¡Buen trabajo hoy!" if gano else "Se acabó el tiempo..."
	$ColorRect/VBoxContainer/ResultLabel.text = result_txt
	
	# Limpiar reporte de fallas si existiera uno anterior
	var old_penalty = $ColorRect/VBoxContainer.get_node_or_null("PenaltyLabel")
	if old_penalty:
		old_penalty.queue_free()
	
	# Mostrar reporte de fallas y penalización
	if not gano and tareas_falladas.size() > 0:
		var penalty_label = Label.new()
		penalty_label.name = "PenaltyLabel"
		penalty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		penalty_label.add_theme_font_size_override("font_size", 22)
		penalty_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3)) # Amarillo/Dorado
		
		var txt = "\n¡Tareas Falladas!\n"
		for tarea in tareas_falladas.keys():
			txt += "- %s\n" % tarea
		txt += "\nPenalización: -$%d" % penalizacion
		penalty_label.text = txt
		$ColorRect/VBoxContainer.add_child(penalty_label)
		
	show()
	
	# Auto-avanzar después de 3.5 segundos
	await get_tree().create_timer(3.5).timeout
	hide()
	transition_finished.emit()
