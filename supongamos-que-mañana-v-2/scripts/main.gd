extends Node2D

@onready var cocina = $Cocina
@onready var sala = $Sala
@onready var player = $Player

var area_actual = "cocina"
var cambiando_area = false  # Para evitar múltiples cambios

@export var spawn_cocina: Vector2 = Vector2(880, 220)
@export var spawn_sala: Vector2 = Vector2(280, 220)

func _ready():
	# Buscar el Marker2D llamado "Start"
	var start_marker = get_node_or_null("Start")
	
	activar_cocina()
	conectar_puertas()
	
	if start_marker and start_marker is Marker2D:
		# Usar la posición del Start Marker2D
		player.global_position = start_marker.global_position
		print("🎮 Jugador iniciado en Start Marker: ", start_marker.global_position)
	else:
		# Si no existe Start Marker, usar la posición de cocina por defecto
		player.global_position = spawn_cocina
		print("⚠️ No se encontró Start Marker, usando spawn_cocina: ", spawn_cocina)

func conectar_puertas():
	if cocina.has_node("Puerta"):
		var puerta_cocina = cocina.get_node("Puerta")
		if puerta_cocina.has_signal("body_entered"):
			puerta_cocina.body_entered.connect(_on_puerta_entered.bind("sala"))
	
	if sala.has_node("Puerta"):
		var puerta_sala = sala.get_node("Puerta")
		if puerta_sala.has_signal("body_entered"):
			puerta_sala.body_entered.connect(_on_puerta_entered.bind("cocina"))

func _on_puerta_entered(body, destino):
	# Evitar cambios múltiples mientras ya estamos cambiando
	if body == player and area_actual != destino and not cambiando_area:
		if destino == "sala":
			# Usar call_deferred para evitar el error
			call_deferred("activar_sala")
		else:
			call_deferred("activar_cocina")

func activar_cocina():
	if cambiando_area:
		return
	
	cambiando_area = true
	area_actual = "cocina"
	
	# Desactivar sala - Usar set_deferred para cada propiedad
	sala.visible = false
	sala.process_mode = Node.PROCESS_MODE_DISABLED
	desactivar_colisiones_recursivo(sala, true)
	
	# Activar cocina
	cocina.visible = true
	cocina.process_mode = Node.PROCESS_MODE_INHERIT
	desactivar_colisiones_recursivo(cocina, false)
	
	# Mover al jugador
	player.global_position = spawn_cocina
	print("🟢 Cambiando a cocina - Posición: ", spawn_cocina)
	
	# Pequeño delay para permitir que termine la física
	await get_tree().process_frame
	cambiando_area = false

func activar_sala():
	if cambiando_area:
		return
	
	cambiando_area = true
	area_actual = "sala"
	
	# Desactivar cocina - Usar set_deferred para cada propiedad
	cocina.visible = false
	cocina.process_mode = Node.PROCESS_MODE_DISABLED
	desactivar_colisiones_recursivo(cocina, true)
	
	# Activar sala
	sala.visible = true
	sala.process_mode = Node.PROCESS_MODE_INHERIT
	desactivar_colisiones_recursivo(sala, false)
	
	# Mover al jugador
	player.global_position = spawn_sala
	print("🟢 Cambiando a sala - Posición: ", spawn_sala)
	
	# Pequeño delay para permitir que termine la física
	await get_tree().process_frame
	cambiando_area = false

func desactivar_colisiones_recursivo(node: Node, desactivar: bool):
	# Desactivar/activar colisiones de todos los hijos
	for child in node.get_children():
		if child is CollisionObject2D:
			# Usar set_deferred para evitar el error
			child.set_deferred("disabled", desactivar)
		# Buscar recursivamente
		desactivar_colisiones_recursivo(child, desactivar)
