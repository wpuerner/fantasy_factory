extends Node2D

@export var timer: Timer
@export var progress_bar: ProgressBar
@export var label: Label

@onready var money_resource = preload("res://resources/money/money_resource.tres")

const NUM_SHIPMENTS_PER_DAY: int = 4

var num_shipments: int:
	set(value):
		num_shipments = value
		label.text = "Remaining Shipments: " + str(num_shipments)

func start_day():
	num_shipments = NUM_SHIPMENTS_PER_DAY
	var shipment_interval_seconds = GlobalConfig.DAY_DURATION_SECONDS / NUM_SHIPMENTS_PER_DAY
	timer.wait_time = shipment_interval_seconds
	timer.start()
	progress_bar.max_value = shipment_interval_seconds

func _ready():
	global_position = $StorageArea.global_position
	$StorageArea.position = Vector2.ZERO

func _physics_process(_delta):
	progress_bar.value = timer.time_left

func _on_timer_timeout():
	for cell in $StorageArea.cells:
		var item = cell.pop_item()
		if item:
			money_resource.add_amount(item.value)
			var floating_label = preload("res://scenes/floating_label/floating_label.tscn").instantiate()
			floating_label.init("$" + str(item.value))
			floating_label.global_position = item.global_position
			add_sibling(floating_label)
			item.call_deferred("queue_free")
			await get_tree().create_timer(0.1).timeout
