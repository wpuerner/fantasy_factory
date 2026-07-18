class_name StorageArea extends Node2D

signal item_was_popped

@export var width: int = 3
@export var height: int = 2
@export var priority: int = 5
@export var system_only: bool = false
@export var player_editable: bool = true
@export var grid_resource: GridResource
@export var storage_areas_resource: StorageAreasResource

var storage_cells: Array[StorageAreaCell] = []


class StorageAreaCell:
	signal item_was_popped()
	
	var grid_cell: GridResource.Cell
	var global_position: Vector2
	var storage_area: StorageArea
	var held_item

	func _init(p_grid_cell: GridResource.Cell, p_global_position, p_storage_area) -> void:
		grid_cell = p_grid_cell
		global_position = p_global_position
		storage_area = p_storage_area

	func is_open() -> bool:
		return held_item == null

	func pop_item():
		var temp = held_item
		held_item = null
		item_was_popped.emit()
		return temp

	func drop_item(item: Item) -> void:
		held_item = item
		item.global_position = grid_cell.global_position

func get_open_storage_cell(is_system: bool = false) -> StorageAreaCell:
	if not is_system and system_only:
		return null
	var open_cells: Array = get_open_storage_cells(is_system)
	return open_cells.front() if open_cells else null

func get_open_storage_cells(is_system: bool = false) -> Array:
	if not is_system and system_only:
		return []
	return storage_cells.filter(func(c: StorageAreaCell): return c.is_open())

func _on_item_was_popped() -> void:
	item_was_popped.emit()

func _ready() -> void:
	var start_coord: Vector2i = grid_resource.get_coordinate_from_global_position(global_position)
	for x in range(width):
		for y in range(height):
			var cell: GridResource.Cell = grid_resource.get_cell_from_coord(start_coord + Vector2i(x, y))
			var area_cell: StorageAreaCell = StorageAreaCell.new(cell, cell.global_position, self)
			cell.object = area_cell
			area_cell.item_was_popped.connect(_on_item_was_popped)
			storage_cells.append(area_cell)
	storage_areas_resource.register_storage_area(self)
	$Sprite2D.texture.size = Vector2(width, height) * GridResource.CELL_SIZE
	global_position = grid_resource.get_global_position_from_coordinate(start_coord)


func remove() -> void:
	storage_areas_resource.remove_storage_area(self)
	for storage_cell in storage_cells:
		if not storage_cell.is_open():
			storage_cell.grid_cell.object = storage_cell.held_item
		else:
			storage_cell.grid_cell.object = null
	queue_free()
