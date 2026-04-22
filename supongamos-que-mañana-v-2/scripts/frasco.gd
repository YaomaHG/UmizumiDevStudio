extends Node2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var money_label = $MoneyLabel  # Referencia al Label
@export var money: int = 0

func _ready():
	# Agregar el frasco a un grupo
	add_to_group("frasco")
	
	# Actualizar el label al inicio
	update_money_display()

func play_coin_animation():
	if animated_sprite:
		animated_sprite.play("monedas")
		print("Reproduciendo animación: monedas")
	else:
		print("Error: AnimatedSprite2D no encontrado")

func update_money_display():
	# Actualizar el texto del label
	if money_label:
		money_label.text = "💰 " + str(money)
	else:
		print("Error: MoneyLabel no encontrado")

# Método para añadir dinero
func add_money(amount: int):
	money += amount
	update_money_display()  # Actualizar el label
	play_coin_animation()
