extends PanelContainer

signal closed

@export var worker_name_label: Label
@export var daily_wage_label: Label
@export var haul_check_box: CheckBox
@export var enchant_check_box: CheckBox

var worker: Node2D

func open(opened_worker: Node2D):
	worker = opened_worker
	worker_name_label.text = worker.worker_name
	daily_wage_label.text = "$" + str(worker.daily_wage) + " / day"
	haul_check_box.set_pressed_no_signal(worker.can_haul)
	enchant_check_box.set_pressed_no_signal(worker.can_enchant)
	visible = true

func close():
	visible = false
	worker = null
	closed.emit()

func _on_close_button_pressed():
	close()

func _on_haul_check_box_toggled(toggled_on: bool):
	if is_instance_valid(worker):
		worker.can_haul = toggled_on

func _on_enchant_check_box_toggled(toggled_on: bool):
	if is_instance_valid(worker):
		worker.can_enchant = toggled_on

func _on_fire_worker_button_pressed():
	if is_instance_valid(worker):
		worker.fire()
	close()
