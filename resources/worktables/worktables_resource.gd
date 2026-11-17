class_name WorktablesResource extends Resource

var workbenches: Array[Node2D] = []

func register_workbench(workbench: Node2D) -> void:
	workbenches.append(workbench)

func get_workbenches() -> Array[Node2D]:
	return workbenches
