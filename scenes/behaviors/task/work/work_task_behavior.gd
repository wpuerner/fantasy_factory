extends TaskBehavior

@export var carry_task_behavior: TaskBehavior

var item_resource: ItemResource = preload("res://resources/item/item_resource.tres")
var grid_resource: GridResource = preload("res://resources/grid/grid_resource.tres")
var storage_areas_resource: StorageAreasResource = preload("res://resources/storage_areas/storage_areas_resource.tres")
var reservation_resource: ReservationResource = preload("res://resources/reservation/reservation_resource.tres")
var state: State = State.GATHERING_INPUTS
var work_cooldown_ticks: int = 0

var _worker: Node2D
var _navigation_agent: NavigationAgent2D
var _workbench: Node2D
var _input_item_container
var _storage_container

enum State {GATHERING_INPUTS, GOING_TO_WORK, WORKING, STORING_OUTPUTS}

const MAX_WORK_COOLDOWN_TICKS: int = 4

func start(worker, navigation_agent: NavigationAgent2D, workbench) -> bool:
	_worker = worker
	_navigation_agent = navigation_agent
	if not reservation_resource.reserve(_workbench, _worker):
		return false
	_workbench = workbench

	return _start()

func _start() -> bool:
	if _workbench.can_work():
		_navigation_agent.target_position = grid_resource.get_adjacent_open_cell_position(_workbench, _worker)
		state = State.GOING_TO_WORK
		return true

	var input_item: Item = item_resource.find_nearest_available_item(_workbench.get_input_item_name(), _worker.global_position)
	if is_instance_valid(input_item):
		_input_item_container = input_item.container
		if not reservation_resource.reserve(_input_item_container, _worker):
			_release_reservations()
			return false
		if not carry_task_behavior.start(_worker, _navigation_agent, input_item.container, _workbench):
			_release_reservations()
			return false
		state = State.GATHERING_INPUTS
		return true
	else:
		# abort if there are no available items
		_release_reservations()
		return false

func _release_reservations() -> void:
	if _workbench:
		reservation_resource.release(_workbench, _worker)
		_workbench = null
	if _input_item_container:
		reservation_resource.release(_input_item_container, _worker)
		_input_item_container = null
	if _storage_container:
		reservation_resource.release(_storage_container, _worker)
		_storage_container = null

func update(worker, delta: float) -> TaskStatus:
	if state == State.GATHERING_INPUTS:
		var result: TaskStatus = carry_task_behavior.update(delta)
		if result == TaskStatus.COMPLETED_SUCCESS:
			if !_start():
				_release_reservations()
				return TaskStatus.COMPLETED_FAILURE
		elif result == TaskStatus.COMPLETED_FAILURE:
			_release_reservations()
			return result
	elif state == State.GOING_TO_WORK:
		if _navigation_agent.is_navigation_finished():
			_workbench.complete.connect(_on_work_complete)
			state = State.WORKING
	elif state == State.WORKING:
		if not is_instance_valid(_workbench):
			_release_reservations()
			return TaskStatus.COMPLETED_FAILURE
		if work_cooldown_ticks <= 0:
			if _workbench.work():
				return _on_work_complete()
			work_cooldown_ticks = MAX_WORK_COOLDOWN_TICKS
		else:
			work_cooldown_ticks -= 1
	elif state == State.STORING_OUTPUTS:
		var result: TaskStatus = carry_task_behavior.update(delta)
		if result != TaskStatus.IN_PROGRESS:
			_release_reservations()
			return result
	return TaskStatus.IN_PROGRESS

func _on_work_complete() -> TaskStatus:
	_workbench.complete.disconnect(_on_work_complete)

	_storage_container = _find_available_storage_cell()
	if _storage_container == null:
		_storage_container = grid_resource.find_nearest_open_cell(_worker.global_position)
	if not reservation_resource.reserve(_storage_container, _worker):
		_release_reservations()
		return TaskStatus.COMPLETED_FAILURE
	if not carry_task_behavior.start(_worker, _navigation_agent, _workbench, _storage_container):
		_release_reservations()
		return TaskStatus.COMPLETED_FAILURE

	state = State.STORING_OUTPUTS
	return TaskStatus.IN_PROGRESS

func _find_available_storage_cell():
	var sorted_areas: Array = storage_areas_resource.storage_areas.duplicate()
	sorted_areas.sort_custom(func(a: StorageArea, b: StorageArea): return a.priority < b.priority)

	var output_item_name: String = ""
	if _workbench and _workbench.has_method("get_output_item_name"):
		output_item_name = _workbench.get_output_item_name()

	for area: StorageArea in sorted_areas:
		if output_item_name != "" and not area.is_item_allowed(output_item_name):
			continue
		for cell: StorageArea.StorageAreaCell in area.storage_cells:
			if cell.is_open() and not reservation_resource.is_reserved_by_other(cell, _worker):
				return cell
	return null
