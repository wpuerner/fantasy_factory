class_name StorageAreasResource extends Resource

var storage_areas: Array[StorageArea] = []

func register_storage_area(storage_area: StorageArea):
	storage_areas.append(storage_area)

func get_open_storage_cell():
	var open_cell
	storage_areas.sort_custom(func (a, b): return a.priority <= b.priority)
	for storage_area in storage_areas:
		open_cell = storage_area.get_open_storage_cell()
		if open_cell != null:
			break
			
	if open_cell == null:
		print_debug("There were no open storage cells")
	return open_cell

func remove_storage_area(storage_area: StorageArea):
	storage_areas.erase(storage_area)
