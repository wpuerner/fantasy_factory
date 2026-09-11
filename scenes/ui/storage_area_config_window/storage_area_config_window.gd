extends PanelContainer

signal closed

@export var item_resource: ItemResource

var _target_area: StorageArea

@onready var _priority_section: Control = $MarginContainer/VBoxContainer/PrioritySection
@onready var _priority_spin: SpinBox = $MarginContainer/VBoxContainer/PrioritySection/PriorityRow/PrioritySpinBox
@onready var _config_list_container: VBoxContainer = $MarginContainer/VBoxContainer/ItemsSection/ScrollContainer/ItemsList


func open(area: StorageArea) -> void:
	_target_area = area
	_priority_section.visible = area.can_change_priority
	_priority_spin.value = area.priority
	_refresh_items()
	visible = true


func close() -> void:
	visible = false
	for child: Node in _config_list_container.get_children():
		child.queue_free()
	closed.emit()


func _refresh_items() -> void:
	for child: Node in _config_list_container.get_children():
		child.queue_free()

	for template: ItemTemplate in item_resource.templates:
		var row: HBoxContainer = HBoxContainer.new()
		row.size_flags_horizontal = SIZE_EXPAND_FILL

		var checkbox: CheckBox = CheckBox.new()
		checkbox.text = template.item_name
		checkbox.size_flags_horizontal = SIZE_EXPAND_FILL
		checkbox.button_pressed = _target_area.is_item_allowed(template.item_name)
		checkbox.toggled.connect(_on_item_toggled.bind(template.item_name))
		row.add_child(checkbox)

		_config_list_container.add_child(row)


func _on_item_toggled(button_pressed: bool, item_name: String) -> void:
	if button_pressed:
		# Add to allowed list (allow this item)
		if not item_name in _target_area.allowed_items:
			_target_area.allowed_items.append(item_name)
	else:
		# Remove from allowed list (disallow this item)
		_target_area.allowed_items.erase(item_name)


func _on_priority_changed(value: float) -> void:
	if _target_area:
		_target_area.priority = int(value)


func _on_close_button_pressed() -> void:
	close()
