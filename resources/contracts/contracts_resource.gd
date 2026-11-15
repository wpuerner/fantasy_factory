class_name ContractsResource extends Resource

signal contracts_changed

@export var item_resource: ItemResource
@export var money_resource: MoneyResource

var available_contracts: Array[Contract] = []
var active_contracts: Array[Contract] = []

const MAX_ITEM_LINES: int = 2
const MAX_QUANTITY_PER_ITEM: int = 3
const REWARD_MULTIPLIER: float = 1.5

var _next_contract_number: int = 1


# Builds a fresh contract from the item templates and offers it to the player.
func generate_contract() -> Contract:
	if not is_instance_valid(item_resource) or item_resource.templates.is_empty():
		return null

	var templates: Array = item_resource.templates.duplicate()
	templates.shuffle()

	var line_count: int = randi_range(1, mini(MAX_ITEM_LINES, templates.size()))
	var items: Dictionary = {}
	var base_value: float = 0.0
	for i in range(line_count):
		var template: ItemTemplate = templates[i]
		var quantity: int = randi_range(1, MAX_QUANTITY_PER_ITEM)
		items[template.item_name] = quantity
		base_value += template.value * quantity

	var contract: Contract = Contract.new()
	contract.items = items
	contract.reward = base_value * REWARD_MULTIPLIER
	contract.contract_name = "Contract #%d" % _next_contract_number
	_next_contract_number += 1

	available_contracts.append(contract)
	contracts_changed.emit()
	return contract


# Moves a contract out of the available list and into the active list, permanently.
func accept(contract: Contract) -> void:
	if contract == null or not available_contracts.has(contract):
		return
	available_contracts.erase(contract)
	active_contracts.append(contract)
	contracts_changed.emit()


# Counts every item that currently exists in the game space, keyed by item name.
func count_items_in_game_space() -> Dictionary:
	var counts: Dictionary = {}
	if not is_instance_valid(item_resource):
		return counts
	for item: Item in item_resource.items:
		if _is_in_game_space(item):
			counts[item.item_name] = int(counts.get(item.item_name, 0)) + 1
	return counts


func get_available_count(item_name: String) -> int:
	return int(count_items_in_game_space().get(item_name, 0))


func can_fulfill(contract: Contract) -> bool:
	return can_fulfill_with(count_items_in_game_space(), contract)


func can_fulfill_with(counts: Dictionary, contract: Contract) -> bool:
	if contract == null:
		return false
	for item_name in contract.items.keys():
		if int(counts.get(item_name, 0)) < contract.get_required_quantity(item_name):
			return false
	return true


# Consumes the required items from the game space and pays out the reward.
func fulfill(contract: Contract) -> bool:
	if not can_fulfill(contract):
		return false

	var remaining: Dictionary = contract.items.duplicate()
	for item: Item in item_resource.items.duplicate():
		if not _is_in_game_space(item):
			continue
		var needed: int = int(remaining.get(item.item_name, 0))
		if needed <= 0:
			continue
		remaining[item.item_name] = needed - 1
		_remove_item(item)

	if is_instance_valid(money_resource):
		money_resource.add_amount(contract.reward)

	active_contracts.erase(contract)
	contracts_changed.emit()
	return true


# An item counts as part of the game space when it is sitting in the world
# (a ground cell) or in a storage area. Items held by a worker or being
# processed inside a workbench are deliberately excluded so we never yank an
# item out from under an active task.
func _is_in_game_space(item: Item) -> bool:
	if not is_instance_valid(item):
		return false
	var container = item.container
	return container is GridResource.Cell or container is StorageArea.StorageAreaCell


func _remove_item(item: Item) -> void:
	var container = item.container
	if is_instance_valid(container) and container.has_method("pop_item"):
		container.pop_item()
	item.queue_free()
