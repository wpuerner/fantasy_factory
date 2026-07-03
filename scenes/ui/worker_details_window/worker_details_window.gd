extends PanelContainer

@export var card_container: Container
@export var worker_name_label: Label
@export var daily_wage_label: Label

var worker: Node2D

func open(opened_worker: Node2D):
	worker = opened_worker
	worker_name_label.text = worker.worker_name
	daily_wage_label.text = "$" + str(worker.daily_wage) + "/day"
	
	visible = true

func _close():
	visible = false
	for child in card_container.get_children():
		child.queue_free()

func _on_button_pressed():
	_close()

func _on_task_deleted(card: Control):
	worker.erase_task(card.task)

func _on_task_priority_increase_requested(card: Control):
	var index = card.get_index()
	if index <= 0:
		return
	card_container.move_child(card, index - 1)
	worker.increase_priority(card.task)
	
func _on_task_priority_decrease_requested(card: Control):
	var index = card.get_index()
	if index >= len(card_container.get_children()) - 1:
		return
	card_container.move_child(card, index + 1)
	worker.decrease_priority(card.task)

func _on_fire_worker_button_pressed():
	worker.queue_free()
	_close()
