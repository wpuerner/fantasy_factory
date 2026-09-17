class_name HaulTaskBehavior extends TaskBehavior

@export var worker: Node2D
@export var navigation_agent: NavigationAgent2D
@export var carry_task_behavior: TaskBehavior
@export var grid_resource: GridResource
@export var storage_areas_resource: StorageAreasResource
@export var item_resource: ItemResource
@export var reservation_resource: ReservationResource

var _worker: Node2D
var _from
var _to

func start() -> bool:
	_worker = worker
	var haul_job: Dictionary = _find_haul_job(_worker)
	if haul_job.is_empty():
		return false

	_from = haul_job.source
	_to = haul_job.target
	
	if not (reservation_resource.reserve(_from, _worker) and reservation_resource.reserve(_to, _worker)):
		_release_reservations()
		return false

	if not carry_task_behavior.start(worker, navigation_agent, haul_job.source, haul_job.target):
		_release_reservations()
		return false

	return true

func update(delta: float) -> TaskStatus:
	var result: TaskStatus = carry_task_behavior.update(delta)
	if result != TaskStatus.IN_PROGRESS:
		_release_reservations()
	return result

func _release_reservations():
	if _from:
		reservation_resource.release(_from, _worker)
		_from = null
	if _to:
		reservation_resource.release(_to, _worker)
		_to = null

func _find_haul_job(worker: Node2D) -> Dictionary:
	var sorted_areas: Array = storage_areas_resource.storage_areas.duplicate()
	sorted_areas.sort_custom(func(a: StorageArea, b: StorageArea): return a.priority < b.priority)

	if sorted_areas.is_empty():
		return {}

	for item: Item in item_resource.items:
		if not is_instance_valid(item):
			continue

		var container = item.container
		if reservation_resource.is_reserved_by_other(container, worker):
			continue
		
		if !is_instance_valid(container):
			continue
			
		if container is StorageArea.StorageAreaCell:
			var current_area: StorageArea = container.storage_area
			for area: StorageArea in sorted_areas:
				if area == current_area:
					continue
				if area.priority < current_area.priority or item.item_name not in current_area.allowed_items:
					if not area.is_item_allowed(item.item_name):
						continue
					var open_cell: StorageArea.StorageAreaCell = _find_open_cell_in_area(area, worker)
					if open_cell != null:
						return {"source": container, "target": open_cell}
		else:
			# Item is in a free cell or on a workbench -- move it to the
			# highest-priority storage area that accepts this item type.
			for area: StorageArea in sorted_areas:
				if not area.is_item_allowed(item.item_name):
					continue
				var open_cell: StorageArea.StorageAreaCell = _find_open_cell_in_area(area, worker)
				if open_cell != null:
					return {"source": container, "target": open_cell}
	return {}

func _find_open_cell_in_area(area: StorageArea, worker: Node2D) -> StorageArea.StorageAreaCell:
	for cell: StorageArea.StorageAreaCell in area.storage_cells:
		if cell.is_open() and not reservation_resource.is_reserved_by_other(cell, worker):
			return cell
	return null
