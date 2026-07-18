extends TaskBehavior

@export var navigation_agent: NavigationAgent2D
@export var carry_task_behavior: TaskBehavior

var work_node: Node2D
var grid_resource = preload("res://resources/grid/grid_resource.tres")
var storage_areas_resource = preload("res://resources/storage_areas/storage_areas_resource.tres")
var state: State = State.WAITING
var work_cooldown_ticks: int = 0

enum State {WAITING, GATHERING_INPUTS, GOING_TO_WORK, WORKING, STORING_OUTPUTS}

const MAX_WORK_COOLDOWN_TICKS: int = 4

func start():
	if !work_node:
		return false
	
	if work_node.can_work():
		navigation_agent.target_position = grid_resource.get_adjacent_open_cell_position(work_node, get_parent())
		state = State.GOING_TO_WORK
		return true
	
	var input_item = grid_resource.find_nearest_item(work_node.get_input_item_name(), get_parent().global_position)
	if is_instance_valid(input_item):
		carry_task_behavior.start(grid_resource.get_cell_for_node(input_item), work_node)
		state = State.GATHERING_INPUTS
		return true

	return false

func _physics_process(_delta):
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

func _on_work_complete():
	work_node.complete.disconnect(_on_work_complete)
	var storage_cell = storage_areas_resource.get_open_storage_cell()
	if storage_cell == null:
		storage_cell = grid_resource.find_nearest_open_cell(get_parent().global_position)
	carry_task_behavior.start(work_node, storage_cell)
	work_node = null
	state = State.STORING_OUTPUTS

func _on_carry_task_behavior_complete():
	if state == State.GATHERING_INPUTS:
		start()
	elif state == State.STORING_OUTPUTS:
		state = State.WAITING
		complete.emit()
