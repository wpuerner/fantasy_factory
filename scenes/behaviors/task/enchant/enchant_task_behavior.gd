extends TaskBehavior

@export var work_task_behavior: TaskBehavior
@export var worktables_resource: WorktablesResource

func start(worker) -> bool:
	var enchanting_tables: Array = worktables_resource.get_enchanting_tables()
	for enchanting_table: Node2D in enchanting_tables:
		if not enchanting_table.has_ticket():
			continue
		if work_task_behavior.start(worker, enchanting_table):
			work_task_behavior.completed.connect(_on_work_task_behavior_completed)
			return true
	return false

func update(worker, delta):
	work_task_behavior.update(worker, delta)

func _on_work_task_behavior_completed(was_successful: bool) -> void:
	work_task_behavior.completed.disconnect(_on_work_task_behavior_completed)
	completed.emit(was_successful)
