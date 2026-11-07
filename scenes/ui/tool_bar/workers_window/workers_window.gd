extends PanelContainer

signal closed
signal worker_selected(worker: Node2D)

@export var worker_list_container: Container
@export var hire_workers_window: Control
@export var worker_resource: WorkerResource

func open() -> void:
	_refresh_worker_list()
	visible = true


func close() -> void:
	visible = false
	for child: Node in worker_list_container.get_children():
		child.queue_free()
	closed.emit()

func _refresh_worker_list() -> void:
	for child: Node in worker_list_container.get_children():
		child.queue_free()

	var workers: Array = worker_resource.workers.filter(func(w): return is_instance_valid(w))

	if workers.is_empty():
		var empty_label: Label = Label.new()
		empty_label.text = "No workers hired yet."
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		worker_list_container.add_child(empty_label)
		return

	for worker: Node2D in workers:
		var entry: Button = Button.new()
		entry.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		entry.alignment = HORIZONTAL_ALIGNMENT_LEFT
		entry.text = worker.worker_name + "    $" + str(worker.daily_wage) + " / day"
		entry.pressed.connect(_on_worker_entry_pressed.bind(worker))
		worker_list_container.add_child(entry)


func _on_worker_entry_pressed(worker: Node2D) -> void:
	worker_selected.emit(worker)


func _on_hire_button_pressed() -> void:
	close()
	hire_workers_window.open()

func _on_close_button_pressed() -> void:
	close()
