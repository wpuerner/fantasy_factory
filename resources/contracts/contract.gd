class_name Contract extends Resource

@export var contract_name: String = "Contract"
@export var items: Dictionary = {}  # item_name (String) -> required quantity (int)
@export var reward: float = 0.0


func get_required_quantity(item_name: String) -> int:
	return int(items.get(item_name, 0))


func get_total_item_count() -> int:
	var total: int = 0
	for quantity in items.values():
		total += int(quantity)
	return total


func describe_items() -> String:
	var parts: Array[String] = []
	for item_name in items.keys():
		parts.append("%s x%d" % [item_name, get_required_quantity(item_name)])
	return ", ".join(parts)
