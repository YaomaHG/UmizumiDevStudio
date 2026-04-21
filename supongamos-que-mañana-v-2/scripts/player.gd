extends CharacterBody2D

@export var speed = 400  # How fast the player will move (pixels/sec).
var screen_size  # Size of the game window.

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var input_direction = Vector2.ZERO  # The player's movement vector.
	
	if Input.is_action_pressed("move_right"):
		input_direction.x += 1
	if Input.is_action_pressed("move_left"):
		input_direction.x -= 1
	if Input.is_action_pressed("move_down"):
		input_direction.y += 1
	if Input.is_action_pressed("move_up"):
		input_direction.y -= 1
	
	# Normalizar para movimiento diagonal a la misma velocidad
	if input_direction.length() > 0:
		input_direction = input_direction.normalized()
	
	# Aplicar velocidad
	velocity = input_direction * speed
	
	# Mover el personaje usando move_and_slide()
	move_and_slide()
	
	# Limitar la posición a la pantalla (opcional)
	position = position.clamp(Vector2.ZERO, screen_size)
	
	# Animar según la dirección
	if input_direction != Vector2.ZERO:
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()

func start(pos):
	position = pos
	show()
