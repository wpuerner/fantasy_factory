class_name SellResource extends Resource

signal selection_changed

@export var item_resource: ItemResource

var selected_items: Array[String] = []


func is_selected(item_name: String) -> bool:
	return item_name in selected_items


func set_selected(item_name: String, selected: bool) -> void:
	if selected == is_selected(item_name):
		return
	if selected:
		selected_items.append(item_name)
	else:
		selected_items.erase(item_name)
	selection_changed.emit()


func get_price(item_name: String) -> float:
	for template: ItemTemplate in item_resource.templates:
		if template.item_name == item_name:
			return template.value
	return 0.0
