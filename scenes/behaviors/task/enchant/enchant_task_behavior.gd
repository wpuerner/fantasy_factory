extends TaskBehavior

@export var worker: Node2D
@export var navigation_agent: NavigationAgent2D
@export var work_task_behavior: TaskBehavior
@export var worktables_resource: WorktablesResource

func start() -> bool:
	var enchanting_tables: Array = worktables_resource.get_enchanting_tables()
	for enchanting_table: Node2D in enchanting_tables:
		if not enchanting_table.has_ticket():
			continue
		return work_task_behavior.start(worker, navigation_agent, enchanting_table)
	return false

func update(delta) -> TaskStatus:
	return work_task_behavior.update(worker, delta)
