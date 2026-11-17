extends TaskBehavior

@export var worker: Node2D
@export var navigation_agent: NavigationAgent2D
@export var work_task_behavior: TaskBehavior
@export var worktables_resource: WorktablesResource

func start() -> bool:
	var workbenches: Array = worktables_resource.get_workbenches()
	for workbench: Node2D in workbenches:
		if not workbench.has_ticket():
			continue
		return work_task_behavior.start(worker, navigation_agent, workbench)
	return false

func update(delta) -> TaskStatus:
	return work_task_behavior.update(worker, delta)
