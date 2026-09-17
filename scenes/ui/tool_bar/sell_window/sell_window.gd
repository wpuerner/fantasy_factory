extends PanelContainer

signal closed

@export var item_resource: ItemResource
@export var sell_resource: SellResource
@export var item_list_container: Container


func open() -> void:
	_refresh()
	visible = true


func close() -> void:
	visible = false
	for child: Node in item_list_container.get_children():
		child.queue_free()
	closed.emit()


func _refresh() -> void:
	for child: Node in item_list_container.get_children():
		child.queue_free()

	for template: ItemTemplate in item_resource.templates:
		var row: HBoxContainer = HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var checkbox: CheckBox = CheckBox.new()
		checkbox.text = template.item_name
		checkbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		checkbox.button_pressed = sell_resource.is_selected(template.item_name)
		checkbox.toggled.connect(_on_item_toggled.bind(template.item_name))
		row.add_child(checkbox)

		var price_label: Label = Label.new()
		price_label.text = "$" + str(sell_resource.get_price(template.item_name))
		price_label.custom_minimum_size = Vector2(60, 0)
		price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(price_label)

		item_list_container.add_child(row)


func _on_item_toggled(button_pressed: bool, item_name: String) -> void:
	sell_resource.set_selected(item_name, button_pressed)


func _on_close_button_pressed() -> void:
	close()
