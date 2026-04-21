extends Node

# Estados del juego según el GDD
enum Estado {PLANIFICACION, ACCION, EVALUACION, PROGRESION}
var estado_actual = Estado.PLANIFICACION

# Variables de control (Los cimientos de tu MVP)
var paciencia: float = 100.0 # De 0 a 100 [cite: 147]
var dinero_escondido: int = 0 # Meta: $500 [cite: 86]
var dia_actual: int = 1 # Jugaremos del 1 al 3 en el MVP [cite: 105]

# Esto avisa al resto del juego que algo cambió
signal cambio_de_estado(nuevo_estado)
