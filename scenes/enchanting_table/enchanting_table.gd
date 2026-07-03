extends Node2D

signal complete

@export var progress_bar: ProgressBar
@export var ticket: Node

@onready var item_resource = preload("res://resources/item/item_resource.tres")
@onready var worktables_resource = preload("res://resources/worktables/worktables_resource.tres")

var item
var needed_work_amount: float = 100.0
var current_work: float = 0.0:
	set(value):
		current_work = value
		progress_bar.value = current_work

func can_work():
	return is_instance_valid(item)

func has_ticket():
	return is_instance_valid(ticket)

func has_item():
	return is_instance_valid(item)

func work():
	current_work += 10.0
	if current_work >= needed_work_amount:
		item.queue_free()
		var new_item = item_resource.create_from_template(ticket.output_item_name)
		add_child(new_item)
		item = new_item
		complete.emit()

func drop_item(dropped_item: Item):
	dropped_item.global_position = global_position
	item = dropped_item

func pop_item():
	var temp = item
	item = null
	current_work = 0.0
	return temp

func get_input_item_name():
	return ticket.input_item_name

func _ready():
	worktables_resource.register_enchanting_table(self)
