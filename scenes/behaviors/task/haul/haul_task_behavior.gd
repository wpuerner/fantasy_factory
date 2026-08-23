class_name HaulTaskBehavior extends TaskBehavior

@export var navigation_agent: NavigationAgent2D
@export var carry_task_behavior: TaskBehavior
@export var grid_resource: GridResource
@export var storage_areas_resource: StorageAreasResource
@export var item_resource: ItemResource
@export var reservation_resource: ReservationResource

var state: State = State.IDLE

enum State {IDLE, HAULING}


func start() -> bool:
	if state != State.IDLE:
		return false

	var worker: Node2D = get_parent()
	var haul_job: Dictionary = _find_haul_job(worker)
	if haul_job.is_empty():
		return false

	if not carry_task_behavior.start(haul_job.source, haul_job.target):
		return false

	state = State.HAULING
	return true


func _find_haul_job(worker: Node2D) -> Dictionary:
	var sorted_areas: Array = storage_areas_resource.storage_areas.duplicate()
	sorted_areas.sort_custom(func(a: StorageArea, b: StorageArea): return a.priority < b.priority)

	if sorted_areas.is_empty():
		return {}

	var best_area: StorageArea = sorted_areas[0]

	for item: Item in item_resource.items:
		if not is_instance_valid(item):
			continue
		if reservation_resource.is_reserved_by_other(item, worker):
			continue

		var cell: GridResource.Cell = grid_resource.get_cell_for_node(item)
		var current_object = cell.object

		if current_object is StorageArea.StorageAreaCell:
			# Item is in a storage area — move to a strictly higher-priority area
			if reservation_resource.is_reserved_by_other(current_object, worker):
				continue

			var current_area: StorageArea = current_object.storage_area
			for area: StorageArea in sorted_areas:
				if area == current_area:
					continue
				if area.priority < current_area.priority:
					var open_cell: StorageArea.StorageAreaCell = _find_open_cell_in_area(area, worker)
					if open_cell != null:
						return {"source": current_object, "target": open_cell}
		else:
			# Item is loose on the grid — move to the highest-priority storage area
			if reservation_resource.is_reserved_by_other(cell, worker):
				continue

			var open_cell: StorageArea.StorageAreaCell = _find_open_cell_in_area(best_area, worker)
			if open_cell != null:
				return {"source": cell, "target": open_cell}

	return {}


func _find_open_cell_in_area(area: StorageArea, worker: Node2D) -> StorageArea.StorageAreaCell:
	for cell: StorageArea.StorageAreaCell in area.storage_cells:
		if cell.is_open() and not reservation_resource.is_reserved_by_other(cell, worker):
			return cell
	return null


func _on_carry_task_behavior_complete() -> void:
	state = State.IDLE
	complete.emit()


func _on_carry_task_behavior_abort() -> void:
	state = State.IDLE
	abort.emit()
