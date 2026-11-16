extends Node2D

signal complete
signal clicked(table: Node2D)

@export var recipes: Array[WorkbenchRecipe] = []
@export var tickets: Array[WorkbenchTicket] = []

@onready var item_resource = preload("res://resources/item/item_resource.tres")
@onready var worktables_resource = preload("res://resources/worktables/worktables_resource.tres")

const CLICK_SIZE: Vector2 = Vector2(96, 32)
const WORK_PER_TICK: float = 10.0

var item: Item
var current_work: float = 0.0

var _last_output_item_name: String = ""


# Tickets are worked one at a time, in order: the first ticket that is neither
# paused nor out of units is the one this bench is currently working on.
func get_active_ticket() -> WorkbenchTicket:
	for ticket: WorkbenchTicket in tickets:
		if ticket.is_active():
			return ticket
	return null

func has_ticket() -> bool:
	return get_active_ticket() != null

func has_item() -> bool:
	return is_instance_valid(item)

func can_work() -> bool:
	var ticket: WorkbenchTicket = get_active_ticket()
	if ticket == null or not is_instance_valid(item):
		return false
	return item.item_name == ticket.input_item_name

func work() -> bool:
	var ticket: WorkbenchTicket = get_active_ticket()
	if ticket == null or not is_instance_valid(item):
		return false

	current_work += WORK_PER_TICK
	if current_work < float(ticket.work_amount):
		return false

	current_work = 0.0
	item.queue_free()
	var new_item: Item = item_resource.create_from_template(ticket.output_item_name)
	new_item.container = self
	add_child(new_item)
	item = new_item

	# A unit was made, so the ticket's remaining quantity drops by one. Once it
	# hits zero the ticket stops being active and no more work is started for it.
	ticket.quantity -= 1
	_last_output_item_name = ticket.output_item_name
	return true

func drop_item(dropped_item: Item):
	dropped_item.global_position = global_position
	item = dropped_item
	item.container = self

func pop_item():
	item.container = null
	var temp = item
	item = null
	current_work = 0.0
	return temp

func get_item():
	return item

func get_input_item_name() -> String:
	var ticket: WorkbenchTicket = get_active_ticket()
	return ticket.input_item_name if ticket != null else ""


func get_output_item_name() -> String:
	var ticket: WorkbenchTicket = get_active_ticket()
	if ticket != null:
		return ticket.output_item_name
	return _last_output_item_name


func _unhandled_input(event: InputEvent) -> void:
	var mouse_button := event as InputEventMouseButton
	if mouse_button == null or not mouse_button.pressed:
		return
	if mouse_button.button_index != MOUSE_BUTTON_LEFT:
		return
	if Rect2(-CLICK_SIZE * 0.5, CLICK_SIZE).has_point(to_local(get_global_mouse_position())):
		clicked.emit(self)
		get_viewport().set_input_as_handled()


func _ready():
	worktables_resource.register_enchanting_table(self)
	$Sprite2D.texture.size = Vector2(3, 1) * GridResource.CELL_SIZE
