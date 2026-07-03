class_name ItemResource extends Resource

@export var templates: Array[ItemTemplate]

var items: Array[Item] = []

func add_item(item: Item):
	items.append(item)

func remove_item(item: Item):
	items.erase(item)

func find_items(item_name: String):
	return items.filter(func (item): return item.item_name == item_name)

func create_from_template(item_name: String):
	for template in templates:
		if template.item_name == item_name:
			var item = load("res://scenes/item/item.tscn").instantiate()
			item.item_name = template.item_name
			item.icon = template.icon
			item.value = template.value
			return item
