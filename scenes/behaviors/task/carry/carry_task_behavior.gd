extends TaskBehavior

@export var navigation_agent: NavigationAgent2D

const INVALID_DESTINATION: Vector2 = Vector2(-100, -100)

var grid_resource: GridResource = preload("res://resources/grid/grid_resource.tres")
var _from
var _to
var _held_item: Item
var state: State = State.PICKING_UP
var _worker: Node2D

enum State {PICKING_UP, DROPPING_OFF}


func start(worker, from, to) -> bool:
	_worker = worker
	_from = from
	_to = to
	navigation_agent.target_position = grid_resource.get_adjacent_open_cell_position(_from, worker)
	state = State.PICKING_UP
	return true

func update(worker: Node2D, _delta: float) -> void:
	if state == State.PICKING_UP:
		if navigation_agent.is_target_reached():
			_held_item = _from.pop_item()
			navigation_agent.target_position = grid_resource.get_adjacent_open_cell_position(_to, get_parent())
			state = State.DROPPING_OFF
	elif state == State.DROPPING_OFF:
		_held_item.global_position = get_parent().global_position
		if navigation_agent.is_target_reached():
			_to.drop_item(_held_item)
			_held_item = null
			completed.emit(true)
