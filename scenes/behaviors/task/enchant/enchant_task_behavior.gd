extends TaskBehavior

@export var work_task_behavior: TaskBehavior
@export var worktables_resource: WorktablesResource


func start() -> bool:
	var enchanting_tables: Array = worktables_resource.get_enchanting_tables()
	for enchanting_table: Node2D in enchanting_tables:
		if not enchanting_table.has_ticket():
			continue
		if work_task_behavior.start(enchanting_table):
			return true
	return false


func _on_work_task_behavior_completed(was_successful: bool) -> void:
	completed.emit(was_successful)
