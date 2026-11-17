extends Node2D

signal complete
signal clicked(table: Node2D)

@export var recipes: Array[WorkbenchRecipe] = []
@export var tickets: Array[WorkbenchTicket] = []

@onready var item_resource: ItemResource = preload("res://resources/item/item_resource.tres")
@onready var worktables_resource: WorktablesResource = preload("res://resources/worktables/worktables_resource.tres")

const CLICK_SIZE: Vector2 = Vector2(96, 32)
const WORK_PER_TICK: float = 10.0

var inputs: Array[Item] = []
var output: Item
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
	return not inputs.is_empty() or is_instance_valid(output)

# A bench can work once every input the active ticket asks for is sitting on it.
func can_work() -> bool:
	var ticket: WorkbenchTicket = get_active_ticket()
	if ticket == null:
		return false
	for input_name: String in ticket.input_item_names:
		if not _has_input(input_name):
			return false
	return true

func work() -> bool:
	var ticket: WorkbenchTicket = get_active_ticket()
	if ticket == null or not can_work():
		return false

	current_work += WORK_PER_TICK
	if current_work < float(ticket.work_amount):
		return false

	current_work = 0.0
	for input_name: String in ticket.input_item_names:
		_consume_input(input_name)
	var new_item: Item = item_resource.create_from_template(ticket.output_item_name)
	new_item.container = self
	add_child(new_item)
	new_item.global_position = global_position
	output = new_item

	# A unit was made, so the ticket's remaining quantity drops by one. Once it
	# hits zero the ticket stops being active and no more work is started for it.
	ticket.quantity -= 1
	_last_output_item_name = ticket.output_item_name
	return true

func drop_item(dropped_item: Item):
	dropped_item.container = self
	inputs.append(dropped_item)
	_arrange_inputs()

func pop_item():
	if not is_instance_valid(output):
		return null
	output.container = null
	var temp: Item = output
	output = null
	current_work = 0.0
	return temp

func get_item():
	return output

# Returns an input the active ticket still needs, so the worker knows what to
# fetch next. Empty when there is no ticket or every input is already present.
func get_input_item_name() -> String:
	var ticket: WorkbenchTicket = get_active_ticket()
	if ticket == null:
		return ""
	for input_name: String in ticket.input_item_names:
		if not _has_input(input_name):
			return input_name
	return ""

func get_output_item_name() -> String:
	var ticket: WorkbenchTicket = get_active_ticket()
	if ticket != null:
		return ticket.output_item_name
	return _last_output_item_name

func _has_input(item_name: String) -> bool:
	for input: Item in inputs:
		if is_instance_valid(input) and input.item_name == item_name:
			return true
	return false

func _consume_input(item_name: String) -> void:
	for i in range(inputs.size()):
		if inputs[i].item_name == item_name:
			var consumed: Item = inputs[i]
			inputs.remove_at(i)
			consumed.queue_free()
			return

# Spread gathered inputs across the bench so they don't stack on one another.
func _arrange_inputs() -> void:
	var count: int = inputs.size()
	for i in range(count):
		var offset: float = (float(i) - (count - 1) * 0.5) * GridResource.CELL_SIZE
		inputs[i].global_position = global_position + Vector2(offset, 0)

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
	worktables_resource.register_workbench(self)
	$Sprite2D.texture.size = Vector2(3, 1) * GridResource.CELL_SIZE