extends StaticBody2D

@export var interaction_time = 5.0
var is_player_near = false
var is_interacting = false
var current_time = 0.0
var player = null  # Referencia al jugador

func _ready():
	# No necesitas conectar señales manualmente si usas el editor
	pass

func _process(delta):
	if is_player_near and Input.is_action_pressed("ui_accept"):
		if not is_interacting:
			start_interaction()
		
		current_time += delta
		
		if current_time >= interaction_time:
			complete_interaction()
			
	elif is_interacting:
		cancel_interaction()

func start_interaction():
	is_interacting = true
	current_time = 0.0
	print("Manteniendo SPACE...")

func complete_interaction():
	print("¡Acción completada!")
	is_interacting = false
	# Aquí tu acción

func cancel_interaction():
	print("Interacción cancelada")
	is_interacting = false
	current_time = 0.0

# Método para detectar al jugador (usando Area2D como detector)
func _on_detector_body_entered(body):
	if body.name == "Player":
		is_player_near = true
		player = body
		print("Cerca de la estufa")

func _on_detector_body_exited(body):
	if body.name == "Player":
		is_player_near = false
		player = null
		if is_interacting:
			cancel_interaction()
