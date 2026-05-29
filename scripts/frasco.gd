extends Node2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var money_label = $MoneyLabel
@export var money: int = 0

func _ready():
	add_to_group("frasco")
	money = GameState.dinero_total
	update_money_display()

func play_coin_animation():
	if animated_sprite:
		animated_sprite.play("monedas")

func update_money_display():
	if money_label:
		money_label.text = "💰 $%d / $%d" % [money, GameState.dinero_objetivo]

func add_money(amount: int):
	money += amount
	GameState.dinero_total = money  # Persistir en GameState
	update_money_display()
	play_coin_animation()
