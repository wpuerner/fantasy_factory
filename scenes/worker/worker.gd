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
		if enchant_task_behavior.start(self):
			_current_behavior = enchant_task_behavior
		elif haul_task_behavior.start(self):
			_current_behavior = haul_task_behavior
		if is_instance_valid(_current_behavior):
			_current_behavior.completed.connect(_on_current_behavior_completed)
	else:
		_current_behavior.update(self, delta)

	if !$NavigationAgent2D.is_target_reached():
		global_position = global_position.move_toward($NavigationAgent2D.get_next_path_position(), SPEED * delta)

func _on_current_behavior_completed(was_successful: bool):
	_current_behavior.completed.disconnect(_on_current_behavior_completed)
	_current_behavior = null
