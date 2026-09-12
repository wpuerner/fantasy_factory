extends TaskBehavior

@export var navigation_agent: NavigationAgent2D
@export var carry_task_behavior: TaskBehavior

var work_node: Node2D
var grid_resource: GridResource = preload("res://resources/grid/grid_resource.tres")
var storage_areas_resource: StorageAreasResource = preload("res://resources/storage_areas/storage_areas_resource.tres")
var reservation_resource: ReservationResource = preload("res://resources/reservation/reservation_resource.tres")
var state: State = State.WAITING
var work_cooldown_ticks: int = 0
var _reserved_work_node: Node2D

enum State {WAITING, GATHERING_INPUTS, GOING_TO_WORK, WORKING, STORING_OUTPUTS}

const MAX_WORK_COOLDOWN_TICKS: int = 4


func start() -> bool:
	if !work_node:
		return false

	var worker: Node2D = get_parent()

	# Reserve the work table for the full duration of this task
	if not reservation_resource.reserve(work_node, worker):
		return false
	_reserved_work_node = work_node

	if work_node.can_work():
		navigation_agent.target_position = grid_resource.get_adjacent_open_cell_position(work_node, worker)
		state = State.GOING_TO_WORK
		return true

	var input_item: Item = grid_resource.find_nearest_item(work_node.get_input_item_name(), worker.global_position)
	if is_instance_valid(input_item):
		if reservation_resource.is_reserved_by_other(input_item, worker):
			_release_work_node(worker)
			return false
		if not carry_task_behavior.start(input_item.container, work_node):
			_release_work_node(worker)
			return false
		state = State.GATHERING_INPUTS
		return true

	_release_work_node(worker)
	return false


func _release_work_node(worker: Node2D) -> void:
	if _reserved_work_node:
		reservation_resource.release(_reserved_work_node, worker)
		_reserved_work_node = null


func _physics_process(_delta: float) -> void:
	if state == State.GOING_TO_WORK:
		if navigation_agent.is_navigation_finished():
			work_node.complete.connect(_on_work_complete)
			state = State.WORKING
	elif state == State.WORKING:
		if work_cooldown_ticks <= 0:
			work_node.work()
			work_cooldown_ticks = MAX_WORK_COOLDOWN_TICKS
		else:
			work_cooldown_ticks -= 1


func _on_work_complete() -> void:
	work_node.complete.disconnect(_on_work_complete)
	var worker: Node2D = get_parent()

	var storage_cell = _find_available_storage_cell(worker)
	if storage_cell == null:
		storage_cell = grid_resource.find_nearest_open_cell(worker.global_position)

	if not carry_task_behavior.start(work_node, storage_cell):
		# Couldn't start carry — release table so another worker can handle output
		_release_work_node(worker)
		work_node = null
		state = State.WAITING
		complete.emit()
		return

	work_node = null
	state = State.STORING_OUTPUTS


func _find_available_storage_cell(worker: Node2D):
	var sorted_areas: Array = storage_areas_resource.storage_areas.duplicate()
	sorted_areas.sort_custom(func(a: StorageArea, b: StorageArea): return a.priority < b.priority)

	var output_item_name: String = ""
	if work_node and work_node.has_method("get_output_item_name"):
		output_item_name = work_node.get_output_item_name()

	for area: StorageArea in sorted_areas:
		if output_item_name != "" and not area.is_item_allowed(output_item_name):
			continue
		for cell: StorageArea.StorageAreaCell in area.storage_cells:
			if cell.is_open() and not reservation_resource.is_reserved_by_other(cell, worker):
				return cell
	return null


func _on_carry_task_behavior_complete() -> void:
	if state == State.GATHERING_INPUTS:
		start()
	elif state == State.STORING_OUTPUTS:
		_release_work_node(get_parent())
		state = State.WAITING
		complete.emit()
