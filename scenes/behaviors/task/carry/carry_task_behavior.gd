extends TaskBehavior

const INVALID_DESTINATION: Vector2 = Vector2(-100, -100)

var grid_resource: GridResource = preload("res://resources/grid/grid_resource.tres")
var _navigation_agent: NavigationAgent2D
var _from
var _to
var _held_item: Item
var state: State = State.PICKING_UP
var _worker: Node2D

enum State {PICKING_UP, DROPPING_OFF}

func start(worker, navigation_agent, from, to) -> bool:
	_worker = worker
	_navigation_agent = navigation_agent
	_from = from
	_to = to
	navigation_agent.target_position = grid_resource.get_adjacent_open_cell_position(_from, _worker)
	state = State.PICKING_UP
	return true

func update(_delta: float) -> TaskStatus:
	if state == State.PICKING_UP:
		if _navigation_agent.is_target_reached():
			_held_item = _from.pop_item()
			_navigation_agent.target_position = grid_resource.get_adjacent_open_cell_position(_to, _worker)
			state = State.DROPPING_OFF
	elif state == State.DROPPING_OFF:
		_held_item.global_position = _worker.global_position
		if _navigation_agent.is_target_reached():
			_to.drop_item(_held_item)
			_held_item = null
			return TaskStatus.COMPLETED_SUCCESS
	return TaskStatus.IN_PROGRESS
