extends Node2D

@onready var cocina = $Cocina
@onready var sala = $Sala
@onready var cuarto = $Cuarto
@onready var player = $Player

var area_actual = "cuarto"  # Puede ser "cocina", "sala" o "cuarto"
var cambiando_area = false

# Posiciones de spawn
@export var spawn_cocina: Vector2 = Vector2(100, 450)
@export var spawn_sala_cocina: Vector2 = Vector2(885, 450)
@export var spawn_sala_cuarto: Vector2 = Vector2(785, 310)
@export var spawn_cuarto: Vector2 = Vector2(885, 450)

func _ready():
	# Configurar estado inicial
	activar_cuarto()
	conectar_puertas()
	
	# Posicionar al jugador en el Start Marker o spawn por defecto
	var start_marker = get_node_or_null("Start")
	if start_marker and start_marker is Marker2D:
		player.global_position = start_marker.global_position
		print("🎮 Jugador iniciado en Start Marker: ", start_marker.global_position)
	else:
		player.global_position = spawn_cuarto
		print("⚠️ No se encontró Start Marker, usando spawn_cocina: ", spawn_cuarto)

func conectar_puertas():
	# Puerta de COCINA -> SALA
	if cocina.has_node("Puerta"):
		var puerta_cocina = cocina.get_node("Puerta")
		if puerta_cocina.has_signal("body_entered"):
			puerta_cocina.body_entered.connect(_on_puerta_entered.bind("sala", "cocina"))
	
	# Puerta de SALA -> COCINA
	if sala.has_node("PuertaCocina"):
		var puerta_sala_cocina = sala.get_node("PuertaCocina")
		if puerta_sala_cocina.has_signal("body_entered"):
			puerta_sala_cocina.body_entered.connect(_on_puerta_entered.bind("cocina", "sala_cocina"))
	
	# Puerta de SALA -> CUARTO
	if sala.has_node("PuertaCuarto"):
		var puerta_sala_cuarto = sala.get_node("PuertaCuarto")
		if puerta_sala_cuarto.has_signal("body_entered"):
			puerta_sala_cuarto.body_entered.connect(_on_puerta_entered.bind("cuarto", "sala_cuarto"))
	
	# Puerta de CUARTO -> SALA
	if cuarto.has_node("Puerta"):
		var puerta_cuarto = cuarto.get_node("Puerta")
		if puerta_cuarto.has_signal("body_entered"):
			puerta_cuarto.body_entered.connect(_on_puerta_entered.bind("sala", "cuarto"))

func _on_puerta_entered(body, destino, origen):
	# Evitar cambios múltiples mientras ya estamos cambiando
	if body == player and area_actual != destino and not cambiando_area:
		match destino:
			"cocina":
				call_deferred("activar_cocina")
			"sala":
				# Necesitamos saber de dónde viene para elegir el spawn correcto
				call_deferred("activar_sala", origen)
			"cuarto":
				call_deferred("activar_cuarto")

func activar_cocina():
	if cambiando_area:
		return
	
	cambiando_area = true
	area_actual = "cocina"
	
	# Desactivar otras áreas
	sala.visible = false
	sala.process_mode = Node.PROCESS_MODE_DISABLED
	desactivar_colisiones_recursivo(sala, true)
	
	cuarto.visible = false
	cuarto.process_mode = Node.PROCESS_MODE_DISABLED
	desactivar_colisiones_recursivo(cuarto, true)
	
	# Activar cocina
	cocina.visible = true
	cocina.process_mode = Node.PROCESS_MODE_INHERIT
	desactivar_colisiones_recursivo(cocina, false)
	
	# Mover al jugador
	player.global_position = spawn_cocina
	print("🟢 Cambiando a cocina - Posición: ", spawn_cocina)
	
	await get_tree().process_frame
	cambiando_area = false

func activar_sala(desde: String = "cocina"):
	if cambiando_area:
		return
	
	cambiando_area = true
	area_actual = "sala"
	
	# Desactivar otras áreas
	cocina.visible = false
	cocina.process_mode = Node.PROCESS_MODE_DISABLED
	desactivar_colisiones_recursivo(cocina, true)
	
	cuarto.visible = false
	cuarto.process_mode = Node.PROCESS_MODE_DISABLED
	desactivar_colisiones_recursivo(cuarto, true)
	
	# Activar sala
	sala.visible = true
	sala.process_mode = Node.PROCESS_MODE_INHERIT
	desactivar_colisiones_recursivo(sala, false)
	
	# Elegir el spawn según de dónde viene
	match desde:
		"cocina":
			player.global_position = spawn_sala_cocina
			print("🟢 Cambiando a sala (desde cocina) - Posición: ", spawn_sala_cocina)
		"cuarto":
			player.global_position = spawn_sala_cuarto
			print("🟢 Cambiando a sala (desde cuarto) - Posición: ", spawn_sala_cuarto)
		_:
			# Por defecto
			player.global_position = spawn_sala_cocina
			print("🟢 Cambiando a sala (default) - Posición: ", spawn_sala_cocina)
	
	await get_tree().process_frame
	cambiando_area = false

func activar_cuarto():
	if cambiando_area:
		return
	
	cambiando_area = true
	area_actual = "cuarto"
	
	# Desactivar otras áreas
	cocina.visible = false
	cocina.process_mode = Node.PROCESS_MODE_DISABLED
	desactivar_colisiones_recursivo(cocina, true)
	
	sala.visible = false
	sala.process_mode = Node.PROCESS_MODE_DISABLED
	desactivar_colisiones_recursivo(sala, true)
	
	# Activar cuarto
	cuarto.visible = true
	cuarto.process_mode = Node.PROCESS_MODE_INHERIT
	desactivar_colisiones_recursivo(cuarto, false)
	
	# Mover al jugador
	player.global_position = spawn_cuarto
	print("🟢 Cambiando a cuarto - Posición: ", spawn_cuarto)
	
	await get_tree().process_frame
	cambiando_area = false

func desactivar_colisiones_recursivo(node: Node, desactivar: bool):
	for child in node.get_children():
		if child is CollisionObject2D:
			child.set_deferred("disabled", desactivar)
		desactivar_colisiones_recursivo(child, desactivar)
