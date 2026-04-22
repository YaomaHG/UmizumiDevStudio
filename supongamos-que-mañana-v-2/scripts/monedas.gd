# Coin.gd
extends Area2D

@export var coin_value: int = 10

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player" or body.is_in_group("player"):
		collect()

func collect():
	var jar = get_tree().get_first_node_in_group("frasco")
	
	if jar:
		jar.add_money(coin_value)  # Usar el método add_money
		print("Moneda recolectada +", coin_value)
	else:
		print("Error: No se encontró el frasco")
	
	queue_free()
