extends Panel

signal worker_hired(worker: Node2D)

@export var worker_card_container: Container

func open():
	visible = true
	for i in range(randi_range(2, 5)):
		var worker_card = preload("res://scenes/ui/new_worker_window/new_worker_card.tscn").instantiate()
		worker_card_container.add_child(worker_card)
		worker_card.hired.connect(_on_worker_card_hired)

func _close():
	visible = false
	for child in worker_card_container.get_children():
		child.queue_free()

func _on_worker_card_hired(worker: Node2D):
	worker_hired.emit(worker)
	_close()

func _on_close_button_pressed():
	_close()
