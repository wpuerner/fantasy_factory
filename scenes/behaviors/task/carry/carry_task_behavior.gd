extends TaskBehavior

@export var navigation_agent: NavigationAgent2D

const INVALID_DESTINATION: Vector2 = Vector2(-100, -100)

var grid_resource = preload("res://resources/grid/grid_resource.tres")
var from_node
var to_node
var held_item: Item
var state: State = State.WAITING

enum State {WAITING, PICKING_UP, DROPPING_OFF}

func can_start():
	if not to_node or to_node.has_item():
		return false
	return true

func start():
	if !can_start():
		push_error("Tried to start behavior, but was not able to. Aborting..")
		abort.emit()
	print_debug("Starting carry task behavior.")
	navigation_agent.target_position = grid_resource.get_adjacent_open_cell_position(from_node, get_parent())
	state = State.PICKING_UP

func _physics_process(_delta):
	if state == State.PICKING_UP:
		if navigation_agent.is_target_reached():
			held_item = from_node.pop_item()
			navigation_agent.target_position = grid_resource.get_adjacent_open_cell_position(to_node, get_parent())
			state = State.DROPPING_OFF
	elif state == State.DROPPING_OFF:
		held_item.global_position = get_parent().global_position
		if navigation_agent.is_target_reached():
			to_node.drop_item(held_item)
			held_item = null
			state = State.WAITING
			to_node = null
			from_node = null
			complete.emit()
