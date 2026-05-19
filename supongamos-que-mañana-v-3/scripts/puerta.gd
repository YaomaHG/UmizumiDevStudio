extends Area2D

@export var destino: String = "cocina"  # o "sala"

func _ready():
	# Conectar la señal body_entered
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		# La transición se manejará desde Main
		pass
