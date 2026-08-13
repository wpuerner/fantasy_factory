extends Node2D

@export var worker_name: String = "jimothy"
@export var worker_resource: WorkerResource
@export var enchant_task_behavior: TaskBehavior
@export var haul_task_behavior: TaskBehavior

const SPEED: float = 300.0

var daily_wage: float = 5.0
var state: State = State.WAITING

enum State {WAITING, DOING_TASK}
	
func _ready() -> void:
	worker_resource.register_worker(self)

func _physics_process(delta: float) -> void:
	if state == State.WAITING:
		if enchant_task_behavior.start():
			state = State.DOING_TASK
			return
		if haul_task_behavior.start():
			state = State.DOING_TASK
			return
	
	if !$NavigationAgent2D.is_target_reached():
		global_position = global_position.move_toward($NavigationAgent2D.get_next_path_position(), SPEED * delta)


func _on_enchant_task_behavior_complete() -> void:
	state = State.WAITING

func _on_enchant_task_behavior_abort() -> void:
	state = State.WAITING

func _on_haul_task_behavior_complete() -> void:
	state = State.WAITING

func _on_haul_task_behavior_abort() -> void:
	state = State.WAITING
