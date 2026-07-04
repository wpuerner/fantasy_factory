class_name Buyer extends Node2D

@export var item_resource: ItemResource
@export var timer: Timer
@export var progress_bar: ProgressBar

var ordered_items: Array[String]

func order_items(new_items: Array[String]):
	ordered_items.append_array(new_items)
	if timer.is_stopped():
		timer.start()

func _on_timer_timeout():
	var cell = $StorageArea.get_open_storage_cell()
	while cell and len(ordered_items) > 0:
		var item = item_resource.create_from_template(ordered_items.pop_front())
		add_sibling(item)
		cell.drop_item(item)
		cell = $StorageArea.get_open_storage_cell()

	if len(ordered_items) > 0:
		timer.start()

func _ready():
	progress_bar.max_value = timer.wait_time

func _physics_process(_delta):
	progress_bar.value = timer.time_left
