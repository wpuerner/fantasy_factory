extends Area2D

@export var refill_interval: float
@export var item_name: String
@export var progress_bar: ProgressBar
@export var timer: Timer

@onready var money_resource = preload("res://resources/money/money_resource.tres")
@onready var item_resource = preload("res://resources/item/item_resource.tres")

var blocked: bool = true
var value: float = 0.0
var item

func pop_item():
	return item

func _ready():
	_create_new_item_delivery()
	value = item_resource.create(item_name).value

func _physics_process(_delta):
	progress_bar.value = timer.wait_time - timer.time_left
	if !blocked and timer.time_left == 0.0 and value <= money_resource.get_amount():
		money_resource.add_amount(-value)
		var floating_label = preload("res://scenes/floating_label/floating_label.tscn").instantiate()
		floating_label.init("-$" + str(value))
		floating_label.global_position = global_position
		add_sibling(floating_label)
		var new_item: Item = item_resource.create_from_template(item_name)
		add_child(new_item)
		item = new_item
		blocked = true

func _create_new_item_delivery():
	timer.wait_time = refill_interval
	progress_bar.max_value = refill_interval
	timer.start()
	blocked = false
