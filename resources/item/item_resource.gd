class_name ItemResource extends Resource

@export var templates: Array[ItemTemplate]

var reservation_resource = preload("res://resources/reservation/reservation_resource.tres")

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

func find_nearest_available_item(item_name: String, from_position: Vector2):
	var matching_items = find_items(item_name)
	matching_items.sort_custom(func(a, b): return from_position.distance_to(a.global_position) < from_position.distance_to(b.global_position))
	for item in matching_items:
		if item.container and !reservation_resource.is_reserved(item.container):
			return item
	return null
