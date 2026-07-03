extends TaskBehavior

@export var work_task_behavior: TaskBehavior

@onready var parent = get_parent()
@onready var worktables_resource = preload("res://resources/worktables/worktables_resource.tres")

func start():
	var enchanting_tables = worktables_resource.get_enchanting_tables()
	for enchanting_table in enchanting_tables:
		if enchanting_table.has_ticket():
			work_task_behavior.work_node = enchanting_table
			return work_task_behavior.start()
	return false


func _on_work_task_behavior_complete():
	complete.emit()
