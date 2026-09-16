extends Node2D

@export var worker_name: String = "jimothy"
@export var worker_resource: WorkerResource
@export var enchant_task_behavior: TaskBehavior
@export var haul_task_behavior: TaskBehavior

const SPEED: float = 300.0

var daily_wage: float = 5.0

var _current_behavior: TaskBehavior
	
func _ready() -> void:
	worker_resource.register_worker(self)

func _physics_process(delta: float) -> void:
	if !is_instance_valid(_current_behavior):
		if enchant_task_behavior.start():
			_current_behavior = enchant_task_behavior
		elif haul_task_behavior.start():
			_current_behavior = haul_task_behavior
	else:
		var result: TaskBehavior.TaskStatus = _current_behavior.update(delta)
		if result != TaskBehavior.TaskStatus.IN_PROGRESS:
			_current_behavior = null

	if !$NavigationAgent2D.is_target_reached():
		global_position = global_position.move_toward($NavigationAgent2D.get_next_path_position(), SPEED * delta)
