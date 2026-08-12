extends Control

signal worker_hired(worker)

@export var workers_window: Control
@export var order_items_window: Control
@export var storage_area_tool_mode: StorageAreaToolMode

var active_window: Control

func _on_workers_button_pressed():
	_open_tool_window(workers_window)

func _on_orders_button_pressed():
	_open_tool_window(order_items_window)

func _on_add_storage_button_pressed():
	storage_area_tool_mode.toggle_placing()

func _open_tool_window(window: Control):
	if is_instance_valid(active_window):
		if active_window != window:
			active_window.close()
		else:
			# if the current window is already open, do nothing
			return
	window.open()
	active_window = window

func _on_workers_window_closed():
	active_window = null

func _on_order_items_window_closed():
	active_window = null


func _on_hire_workers_window_worker_hired(worker):
	worker_hired.emit(worker)
