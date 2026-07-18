extends Control

signal priority_changed(new_priority: int)
signal delete_requested

@export var tool_mode: Resource

@onready var priority_spin: SpinBox = $VBoxContainer/PriorityRow/PrioritySpinBox
@onready var delete_button: Button = $VBoxContainer/DeleteButton

var _target_area: StorageArea


func _ready() -> void:
	priority_spin.value_changed.connect(_on_priority_changed)
	delete_button.pressed.connect(_on_delete_pressed)
	hide()

func show_for_area(area: StorageArea, screen_pos: Vector2) -> void:
	_target_area = area
	priority_spin.value = area.priority
	position = screen_pos
	show()

func _on_priority_changed(value: float) -> void:
	_target_area.priority = int(value)
	priority_changed.emit(int(value))

func _on_delete_pressed() -> void:
	if is_instance_valid(_target_area):
		_target_area.remove()
	delete_requested.emit()
	hide()
	_target_area = null
