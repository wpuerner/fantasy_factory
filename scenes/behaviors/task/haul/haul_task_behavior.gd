class_name HaulTaskBehavior extends TaskBehavior

@export var navigation_agent: NavigationAgent2D
@export var carry_task_behavior: TaskBehavior

var grid_resource: GridResource = preload("res://resources/grid/grid_resource.tres")
var storage_areas_resource: StorageAreasResource = preload("res://resources/storage_areas/storage_areas_resource.tres")
var item_resource: ItemResource = preload("res://resources/item/item_resource.tres")

var state: State = State.IDLE
var _source_cell
var _target_cell

enum State {IDLE, HAULING}


func start() -> bool:
	if state != State.IDLE:
		return false

	var haul_job: Dictionary = _find_haul_job()
	if haul_job.is_empty():
		return false

	_source_cell = haul_job.source
	_target_cell = haul_job.target
	carry_task_behavior.start(_source_cell, _target_cell)
	state = State.HAULING
	return true


func _find_haul_job() -> Dictionary:
	var sorted_areas: Array = storage_areas_resource.storage_areas.duplicate()
	sorted_areas.sort_custom(func(a: StorageArea, b: StorageArea): return a.priority < b.priority)

	if sorted_areas.is_empty():
		return {}

	var best_area: StorageArea = sorted_areas[0]

	for item: Item in item_resource.items:
		if not is_instance_valid(item):
			continue

		var cell: GridResource.Cell = grid_resource.get_cell_for_node(item)
		var current_object = cell.object

		if current_object is StorageArea.StorageAreaCell:
			# Item is in a storage area — move to a strictly higher-priority area
			var current_area: StorageArea = current_object.storage_area
			for area: StorageArea in sorted_areas:
				if area == current_area:
					continue
				if area.priority < current_area.priority:
					var open_cell: StorageArea.StorageAreaCell = area.get_open_storage_cell()
					if open_cell != null:
						return {"source": current_object, "target": open_cell}
		else:
			# Item is loose on the grid — move to the highest-priority storage area
			var open_cell: StorageArea.StorageAreaCell = best_area.get_open_storage_cell()
			if open_cell != null:
				return {"source": cell, "target": open_cell}

	return {}


func _on_carry_task_behavior_complete() -> void:
	state = State.IDLE
	complete.emit()
