extends PanelContainer

signal closed

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

	for worker in workers:
		var entry: HBoxContainer = HBoxContainer.new()
		entry.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var name_label: Label = Label.new()
		name_label.text = worker.worker_name
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		entry.add_child(name_label)

		var wage_label: Label = Label.new()
		wage_label.text = "$" + str(worker.daily_wage) + " / day"
		wage_label.custom_minimum_size = Vector2(80, 0)
		wage_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		entry.add_child(wage_label)

		var fire_button: Button = Button.new()
		fire_button.text = "Fire"
		fire_button.custom_minimum_size = Vector2(50, 0)
		fire_button.pressed.connect(_on_fire_worker_pressed.bind(worker))
		entry.add_child(fire_button)

		worker_list_container.add_child(entry)


func _on_fire_worker_pressed(worker: Node2D) -> void:
	worker_resource.deregister_worker(worker)
	worker.queue_free()
	_refresh_worker_list()


func _on_hire_button_pressed() -> void:
	close()
	hire_workers_window.open()

func _on_close_button_pressed() -> void:
	close()
