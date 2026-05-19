extends CanvasLayer

signal transition_finished

func mostrar(dia: int, gano: bool):
	$ColorRect.color = Color(0.05, 0.45, 0.15) if gano else Color(0.6, 0.05, 0.05)
	$ColorRect/VBoxContainer/DayLabel.text = "DÍA %d" % dia
	$ColorRect/VBoxContainer/ResultLabel.text = (
		"¡Día completado!" if gano else "Se acabó el tiempo..."
	)
	show()
	# ignore_time_scale=true: el timer funciona aunque Engine.time_scale cambie
	await get_tree().create_timer(2.5, true, false, true).timeout
	hide()
	transition_finished.emit()

func _ready():
	hide()
