extends TaskBehavior

@export var navigation_agent: NavigationAgent2D

@onready var worker = get_parent()

const INVALID_DESTINATION: Vector2 = Vector2(-100, -100)

var grid_resource: GridResource = preload("res://resources/grid/grid_resource.tres")
var reservation_resource: ReservationResource = preload("res://resources/reservation/reservation_resource.tres")
var from_node
var to_node
var held_item: Item
var state: State = State.WAITING

enum State {WAITING, PICKING_UP, DROPPING_OFF}


func start(from, to) -> bool:
	if !is_instance_valid(from.get_item()):
		return false

	if not reservation_resource.reserve(from, worker):
		return false

	if not reservation_resource.reserve(to, worker):
		_abort()
		return false

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
	if from_node:
		reservation_resource.release(from_node, worker)
		from_node = null
	if to_node:
		reservation_resource.release(to_node, worker)
		to_node = null

func _physics_process(_delta: float) -> void:
	if state == State.PICKING_UP:
		if navigation_agent.is_target_reached():
			held_item = from_node.pop_item()
			if !is_instance_valid(held_item):
				_abort()
				return
			reservation_resource.release(from_node, worker)
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
			complete.emit()
