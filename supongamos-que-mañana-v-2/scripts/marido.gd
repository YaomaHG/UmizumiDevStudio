extends Node

const STATES = ["normal", "enojado", "furioso"]

var state_index: int = 0

func _ready():
	pass

func get_state_index() -> int:
	return state_index

func get_state_name() -> String:
	return STATES[clamp(state_index, 0, STATES.size() - 1)]

func is_furioso() -> bool:
	return state_index >= STATES.size() - 1

func incrementar_estado():
	if state_index < STATES.size() - 1:
		state_index += 1

func set_state_normal():
	state_index = 0
