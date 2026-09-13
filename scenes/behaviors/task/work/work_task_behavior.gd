extends TaskBehavior

@export var navigation_agent: NavigationAgent2D
@export var carry_task_behavior: TaskBehavior

var grid_resource: GridResource = preload("res://resources/grid/grid_resource.tres")
var storage_areas_resource: StorageAreasResource = preload("res://resources/storage_areas/storage_areas_resource.tres")
var reservation_resource: ReservationResource = preload("res://resources/reservation/reservation_resource.tres")
var state: State = State.GATHERING_INPUTS
var work_cooldown_ticks: int = 0

var _worker: Node2D
var _workbench: Node2D
var _input_item_container
var _storage_container

enum State {GATHERING_INPUTS, GOING_TO_WORK, WORKING, STORING_OUTPUTS}

const MAX_WORK_COOLDOWN_TICKS: int = 4

## need to fix reservation system so objects are reserved in the correct way
## release reservation on input item containers but not workbench

func start(worker, workbench) -> bool:
	_worker = worker
	if not reservation_resource.reserve(_workbench, _worker):
		return false
	_workbench = workbench

	return _start()

func _start() -> bool:
	if _workbench.can_work():
		navigation_agent.target_position = grid_resource.get_adjacent_open_cell_position(_workbench, _worker)
		state = State.GOING_TO_WORK
		return true

	var input_item: Item = grid_resource.find_nearest_item(_workbench.get_input_item_name(), _worker.global_position)
	if is_instance_valid(input_item):
		_input_item_container = input_item.container
		if not reservation_resource.reserve(_input_item_container, _worker):
			_abort()
			return false
		if not carry_task_behavior.start(_worker, input_item.container, _workbench):
			_abort()
			return false
		carry_task_behavior.completed.connect(_on_gathering_inputs_completed)
		state = State.GATHERING_INPUTS
		return true
	else:
		# abort if there are no available items
		_abort()
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

func update(worker, delta: float) -> void:
	if state == State.GATHERING_INPUTS:
		carry_task_behavior.update(worker, delta)
	elif state == State.GOING_TO_WORK:
		if navigation_agent.is_navigation_finished():
			_workbench.complete.connect(_on_work_complete)
			state = State.WORKING
	elif state == State.WORKING:
		if not is_instance_valid(_workbench):
			_abort()
			return
		if work_cooldown_ticks <= 0:
			_workbench.work()
			work_cooldown_ticks = MAX_WORK_COOLDOWN_TICKS
		else:
			work_cooldown_ticks -= 1
	elif state == State.STORING_OUTPUTS:
		carry_task_behavior.update(worker, delta)

func _on_work_complete() -> void:
	_workbench.complete.disconnect(_on_work_complete)

	var _storage_container = _find_available_storage_cell()
	if _storage_container == null:
		_storage_container = grid_resource.find_nearest_open_cell(_worker.global_position)
	if not reservation_resource.reserve(_storage_container, _worker):
		_abort()
		return
	if not carry_task_behavior.start(_worker, _workbench, _storage_container):
		_abort()
		return

	carry_task_behavior.completed.connect(_on_storing_outputs_completed)
	state = State.STORING_OUTPUTS


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

func _abort() -> void:
	_release_reservations()
	completed.emit(false)

func _on_gathering_inputs_completed(was_successful: bool) -> void:
	carry_task_behavior.completed.disconnect(_on_gathering_inputs_completed)
	
	if not was_successful:
		_abort()
		return
	else:
		_start()

func _on_storing_outputs_completed(was_successful: bool) -> void:
	carry_task_behavior.completed.disconnect(_on_storing_outputs_completed)
	
	_release_reservations()
	completed.emit(was_successful)
