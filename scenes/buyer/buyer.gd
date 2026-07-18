class_name Buyer extends Node2D

@export var item_resource: ItemResource
@export var timer: Timer
@export var progress_bar: ProgressBar
@export var label: Label

var shipments = []

func order_items(new_items: Array[String]):
	if not new_items:
		return
	while new_items.size() > 0:
		var new_shipment = []
		for i in range(min(new_items.size(), 4)):
			new_shipment.append(new_items.pop_front())
		_add_shipment(new_shipment)
	if timer.time_left == 0.0:
		timer.start()

func _add_shipment(shipment):
	shipments.append(shipment)
	label.text = "Remaining Shipments: " + str(shipments.size())

func _get_shipment():
	var shipment = shipments.pop_front()
	label.text = "Remaining Shipments: " + str(shipments.size())
	return shipment

func _on_timer_timeout():
	_maybe_deliver_shipment()

func _ready():
	progress_bar.max_value = timer.wait_time

func _physics_process(_delta):
	progress_bar.value = timer.time_left

func _maybe_deliver_shipment():
	if not shipments:
		return
	var open_cells = $StorageArea.get_open_storage_cells(true)
	if open_cells.size() >= shipments.front().size():
		var shipment = _get_shipment()
		for item_name in shipment:
			var item = item_resource.create_from_template(item_name)
			add_sibling(item)
			$StorageArea.get_open_storage_cell(true).drop_item(item)
		if shipments:
			timer.start()

func _on_storage_area_item_was_popped():
	if timer.time_left == 0.0:
		_maybe_deliver_shipment()
