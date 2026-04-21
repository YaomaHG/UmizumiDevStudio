extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	# Si tienes múltiples estufas, puedes guardarlas en un array
	var stoves = get_tree().get_nodes_in_group("stoves")
	print("Estufas encontradas: ", stoves.size())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func new_game():
	$Player.start($StartPosition.position)
