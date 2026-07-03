extends Node2D

@export var enchant_task_behavior: TaskBehavior

const SPEED: float = 200.0

var worker_name: String
var daily_wage: float
var behaviors: Array[TaskBehavior] = []
var state: State = State.WAITING

enum State {WAITING, DOING_TASK}
	
func _physics_process(delta: float):
	if state == State.WAITING:
		if enchant_task_behavior.start():
			state = State.DOING_TASK
			print("Worker starting an enchanting task.")
			return
	
	if !$NavigationAgent2D.is_target_reached():
		global_position = global_position.move_toward($NavigationAgent2D.get_next_path_position(), SPEED * delta)


func _on_enchant_task_behavior_complete():
	state = State.WAITING

func _on_enchant_task_behavior_abort():
	state = State.WAITING
