extends CharacterBody2D

@export var speed = 400  # How fast the player will move (pixels/sec).
var screen_size  # Size of the game window.
var is_working = false

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
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

	_update_animation(input_direction)

func _update_animation(input_direction: Vector2):
	var sprite := $AnimatedSprite2D as AnimatedSprite2D
	if not sprite:
		return

	if is_working:
		_play_animation_if_exists(sprite, "job")
		sprite.play()
		return

	# Priorizar izquierda/derecha. Para eje vertical usar iddle/default.
	if input_direction.x > 0:
		_play_animation_if_exists(sprite, "right")
		sprite.play()
	elif input_direction.x < 0:
		_play_animation_if_exists(sprite, "left")
		sprite.play()
	elif input_direction.y != 0:
		_play_animation_if_exists(sprite, "iddle")
		sprite.play()
	else:
		_play_animation_if_exists(sprite, "iddle")
		sprite.play()

func _play_animation_if_exists(sprite: AnimatedSprite2D, anim_name: String):
	if sprite.sprite_frames and sprite.sprite_frames.has_animation(anim_name):
		sprite.animation = anim_name
	elif sprite.sprite_frames and sprite.sprite_frames.has_animation("default"):
		sprite.animation = "default"

func set_working(value: bool):
	is_working = value

func start(pos):
	position = pos
	show()
