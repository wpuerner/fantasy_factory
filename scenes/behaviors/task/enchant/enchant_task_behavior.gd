extends TaskBehavior

@export var work_task_behavior: TaskBehavior
@export var worktables_resource: WorktablesResource


func start() -> bool:
	var enchanting_tables: Array = worktables_resource.get_enchanting_tables()
	for enchanting_table: Node2D in enchanting_tables:
		if not enchanting_table.has_ticket():
			continue
		work_task_behavior.work_node = enchanting_table
		if work_task_behavior.start():
			return true
	return false


func _on_work_task_behavior_complete() -> void:
	complete.emit()
