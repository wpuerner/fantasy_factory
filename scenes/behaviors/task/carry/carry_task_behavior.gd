extends TaskBehavior

@export var navigation_agent: NavigationAgent2D

const INVALID_DESTINATION: Vector2 = Vector2(-100, -100)

var grid_resource: GridResource = preload("res://resources/grid/grid_resource.tres")
var reservation_resource: ReservationResource = preload("res://resources/reservation/reservation_resource.tres")
var from_node
var to_node
var held_item: Item
var state: State = State.WAITING

var _reserved_from
var _reserved_to
var _reserved_item: Item

enum State {WAITING, PICKING_UP, DROPPING_OFF}


func start(from, to) -> bool:
	var worker: Node2D = get_parent()

	if not reservation_resource.reserve(from, worker):
		return false
	_reserved_from = from

	if not reservation_resource.reserve(to, worker):
		reservation_resource.release(_reserved_from, worker)
		_reserved_from = null
		return false
	_reserved_to = to

	from_node = from
	to_node = to
	navigation_agent.target_position = grid_resource.get_adjacent_open_cell_position(from_node, worker)
	state = State.PICKING_UP
	return true


func _abort() -> void:
	_release_all()
	state = State.WAITING
	abort.emit()


func _release_all() -> void:
	var worker: Node2D = get_parent()
	if _reserved_item:
		reservation_resource.release(_reserved_item, worker)
		_reserved_item = null
	if _reserved_from:
		reservation_resource.release(_reserved_from, worker)
		_reserved_from = null
	if _reserved_to:
		reservation_resource.release(_reserved_to, worker)
		_reserved_to = null


func _physics_process(_delta: float) -> void:
	if state == State.PICKING_UP:
		if navigation_agent.is_target_reached():
			held_item = from_node.pop_item()
			if !is_instance_valid(held_item):
				_abort()
				return
			# Reserve the item now that we hold it
			reservation_resource.reserve(held_item, get_parent())
			_reserved_item = held_item
			navigation_agent.target_position = grid_resource.get_adjacent_open_cell_position(to_node, get_parent())
			state = State.DROPPING_OFF
	elif state == State.DROPPING_OFF:
		if !is_instance_valid(held_item):
			_abort()
			return
		held_item.global_position = get_parent().global_position
		if navigation_agent.is_target_reached():
			to_node.drop_item(held_item)
			held_item = null
			_release_all()
			state = State.WAITING
			to_node = null
			from_node = null
			complete.emit()
