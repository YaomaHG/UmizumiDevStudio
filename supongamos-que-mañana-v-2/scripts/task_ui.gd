extends CanvasLayer

var completed_tasks = 0
var max_tasks = 2

func _ready():
	$Panel.add_theme_stylebox_override("panel", StyleBoxFlat.new())
	var style = $Panel.get_theme_stylebox("panel")
	style.bg_color = Color(0.1, 0.1, 0.1, 0.9)
	style.border_width_bottom = 2
	style.border_color = Color(0.5, 0.5, 0.5)
	
	_create_task_counter()

func _create_task_counter():
	var tareas_container = $Panel/Tareas
	
	var counter_label = Label.new()
	counter_label.name = "TaskCounterLabel"
	counter_label.text = "%d/%d" % [completed_tasks, max_tasks]
	counter_label.custom_minimum_size = Vector2(50, 30)
	counter_label.add_theme_font_size_override("font_size", 20)
	tareas_container.add_child(counter_label)

func update_task_counter():
	var counter_label = $Panel/Tareas.get_node_or_null("TaskCounterLabel") as Label
	if counter_label:
		counter_label.text = "%d/%d" % [completed_tasks, max_tasks]

func add_completed_task():
	if completed_tasks < max_tasks:
		completed_tasks += 1
		update_task_counter()

func _on_task_progress(progress: float):
	pass

func _on_task_completed():
	add_completed_task()

func _process(delta: float) -> void:
	pass
