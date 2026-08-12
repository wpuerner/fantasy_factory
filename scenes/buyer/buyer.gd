class_name Buyer extends Node2D

@export var item_resource: ItemResource
@export var buyer_resource: BuyerResource
@export var timer: Timer
@export var progress_bar: ProgressBar
@export var label: Label

var shipments: Array[Array] = []


func add_shipment(shipment: Array[String]) -> void:
	shipments.append(shipment)
	label.text = "Remaining Shipments: " + str(shipments.size())
	if timer.time_left == 0.0 and not shipments.is_empty():
		timer.start()


func get_shipment_count() -> int:
	return shipments.size()


func _get_shipment() -> Array[String]:
	var shipment: Array[String] = shipments.pop_front()
	label.text = "Remaining Shipments: " + str(shipments.size())
	return shipment


func _on_timer_timeout() -> void:
	_maybe_deliver_shipment()


func _ready() -> void:
	progress_bar.max_value = timer.wait_time
	global_position = $StorageArea.global_position
	$StorageArea.position = Vector2.ZERO
	buyer_resource.register_buyer(self)


func _exit_tree() -> void:
	if is_instance_valid(buyer_resource):
		buyer_resource.deregister_buyer(self)


func _physics_process(_delta: float) -> void:
	progress_bar.value = timer.time_left


func _maybe_deliver_shipment() -> void:
	if shipments.is_empty():
		return
	var open_cells: Array = $StorageArea.get_open_storage_cells(true)
	if open_cells.size() >= shipments.front().size():
		var shipment: Array[String] = _get_shipment()
		for item_name: String in shipment:
			var item: Item = item_resource.create_from_template(item_name)
			add_sibling(item)
			$StorageArea.get_open_storage_cell(true).drop_item(item)
		if not shipments.is_empty():
			timer.start()


func _on_storage_area_item_was_popped() -> void:
	if timer.time_left == 0.0:
		_maybe_deliver_shipment()
