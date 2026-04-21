extends Node2D

var horas = 8
var minutos = 0
var segundos_reales = 0.0

func _process(delta):
	# Solo corre el tiempo si estamos en fase de ACCIÓN [cite: 45]
	if GameManager.estado_actual == GameManager.Estado.ACCION:
		segundos_reales += delta
		
		# Ajuste para que 11 horas de juego duren ~12 min reales [cite: 140]
		if segundos_reales >= 1.1: 
			minutos += 1
			segundos_reales = 0
			
		if minutos >= 60:
			horas += 1
			minutos = 0
			
		# Actualizar el texto que ve el jugador
		$Label.text = str(horas).pad_zeros(2) + ":" + str(minutos).pad_zeros(2)
		
		# Si dan las 19:00, se acaba el tiempo de acción [cite: 51]
		if horas >= 19:
			GameManager.estado_actual = GameManager.Estado.EVALUACION
			print("¡Es la hora! El marido ha llegado.")
