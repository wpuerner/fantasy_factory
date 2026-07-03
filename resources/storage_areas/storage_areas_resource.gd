extends Resource

signal added_storage_area(coords: Array[Vector2i])

var storage_areas: Array[StorageArea] = []
var grid_resource = preload("res://resources/grid/grid_resource.tres")

func create_new_storage_area(start_global_position: Vector2, end_global_position: Vector2):
	var start_coord: Vector2i = grid_resource.get_coordinate_from_global_position(start_global_position)
	var end_coord: Vector2i = grid_resource.get_coordinate_from_global_position(end_global_position)
	
	var storage_area = StorageArea.new()
	var coords: Array[Vector2i] = []
	for x in range(start_coord.x, end_coord.x):
		for y in range(start_coord.y, end_coord.y):
			var coord = Vector2i(x, y)
			storage_area.add_cell(grid_resource.get_cell_from_coord(coord))
			coords.append(coord)
	storage_areas.append(storage_area)
	added_storage_area.emit(coords)

func get_open_storage_cell():
	for storage_area in storage_areas:
		for cell in storage_area.cells:
			if cell.is_open():
				return cell
	
	print_debug("There were not open storage cells")
	return null

class StorageArea:
	var cells: Array[GridResource.Cell]
	
	func add_cell(cell: GridResource.Cell):
		cells.append(cell)
