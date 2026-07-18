class_name StorageArea extends Node2D

signal item_was_popped

@export var width: int = 3
@export var height: int = 2
@export var priority: int = 5
@export var system_only: bool = false
@export var grid_resource: GridResource
@export var storage_areas_resource: StorageAreasResource

var cells: Array[GridResource.Cell] = []

func get_open_storage_cell(is_system = false):
	if not is_system and system_only:
		return null
	var open_cells = get_open_storage_cells(is_system)
	return open_cells.front() if open_cells else null

func get_open_storage_cells(is_system = false):
	if not is_system and system_only:
		return null
	return cells.filter(func(cell): return cell.is_open())

func _on_item_was_popped():
	item_was_popped.emit()

func _ready():
	var start_coord = grid_resource.get_coordinate_from_global_position(global_position)
	for x in range(width):
		for y in range(height):
			var cell = grid_resource.get_cell_from_coord(start_coord + Vector2i(x, y))
			cell.is_storage = true
			cell.item_was_popped.connect(_on_item_was_popped)
			cells.append(cell)
	storage_areas_resource.register_storage_area(self)
	$Sprite2D.texture.size = Vector2(width, height) * GridResource.CELL_SIZE
	global_position = grid_resource.get_global_position_from_coordinate(start_coord)
