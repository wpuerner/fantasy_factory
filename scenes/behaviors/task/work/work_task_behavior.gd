extends TaskBehavior

@export var navigation_agent: NavigationAgent2D
@export var carry_task_behavior: TaskBehavior

var grid_resource: GridResource = preload("res://resources/grid/grid_resource.tres")
var storage_areas_resource: StorageAreasResource = preload("res://resources/storage_areas/storage_areas_resource.tres")
var reservation_resource: ReservationResource = preload("res://resources/reservation/reservation_resource.tres")
var state: State = State.WAITING
var work_cooldown_ticks: int = 0

@onready var _worker = get_parent()
var _workbench: Node2D

enum State {WAITING, GATHERING_INPUTS, GOING_TO_WORK, WORKING, STORING_OUTPUTS}

const MAX_WORK_COOLDOWN_TICKS: int = 4


func start(workbench) -> bool:
	if state != State.WAITING:
		return false
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
		if input_item.container == null or not carry_task_behavior.start(input_item.container, _workbench):
			_abort()
			return false
		state = State.GATHERING_INPUTS
		return true
	else:
		# abort if there are no available items
		_abort()
		return false

func _release_workbench() -> void:
	if _workbench:
		reservation_resource.release(_workbench, _worker)
		_workbench = null
	state = State.WAITING

func _physics_process(_delta: float) -> void:
	if state == State.GOING_TO_WORK:
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

func _on_work_complete() -> void:
	_workbench.complete.disconnect(_on_work_complete)
	var worker: Node2D = get_parent()

	var storage_cell = _find_available_storage_cell()
	if storage_cell == null:
		storage_cell = grid_resource.find_nearest_open_cell(worker.global_position)

	if not carry_task_behavior.start(_workbench, storage_cell):
		_abort()
		return

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
	_release_workbench()
	completed.emit(false)

func _on_carry_task_behavior_completed(was_successful: bool) -> void:
	if not was_successful:
		if state == State.GATHERING_INPUTS or state == State.STORING_OUTPUTS:
			_abort()
		return

	if state == State.GATHERING_INPUTS:
		if not _start():
			_abort()
	elif state == State.STORING_OUTPUTS:
		_release_workbench()
		completed.emit(true)
