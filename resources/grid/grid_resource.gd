class_name GridResource extends Resource

const CELL_SIZE: int = 64

var grid = []
var item_resource = preload("res://resources/item/item_resource.tres")

func get_snapped_global_position(global_position: Vector2):
	var coord: Vector2i = get_coordinate_from_global_position(global_position)
	return get_global_position_from_coordinate(coord)

func init(grid_rect: Rect2i):
	@warning_ignore("integer_division")
	var cell_count: Vector2i = Vector2i(grid_rect.size.x / CELL_SIZE, grid_rect.size.y / CELL_SIZE)
	grid.resize(cell_count.x)
	for i in range(len(grid)):
		grid[i] = []
		grid[i].resize(cell_count.y)

# Attempts to place a node in the grid and returns true if it was successful.
# Returns false if it failed, to be handled by the caller.
func maybe_add_node(node: Node2D) -> bool:
	var collection = _get_node_collection(node)
	for n in collection:
		if is_instance_valid(get_cell_for_node(n).object):
			return false
	
	for n in collection:
		get_cell_for_node(n).object = n
	
	node.global_position = get_cell_for_node(node).global_position

	return true

func remove_node(node: Node2D) -> bool:
	var collection = _get_node_collection(node)
	for n in collection:
		get_cell_for_node(n).object = null
	return true

# returns the position of an open cell adjacent to to_node, if it exiWhensts, otherwise null.
func get_adjacent_open_cell_position(to_node, from_node):
	var coord = get_coordinate_from_global_position(to_node.global_position)
	var check_coords = [coord + Vector2i.UP, coord + Vector2i.DOWN, coord + Vector2i.LEFT, coord + Vector2i.RIGHT]
	var open_positions = check_coords.filter(func(check_coord): return get_cell_from_coord(check_coord).is_open()).map(func(check_coord): return get_global_position_from_coordinate(check_coord))
	if open_positions.is_empty():
		return null
	
	var closest_position: Vector2 = open_positions[0]
	if len(open_positions) > 1:
		for i in range(1, len(open_positions)):
			if open_positions[i].distance_to(from_node.global_position) < closest_position.distance_to(from_node.global_position):
				closest_position = open_positions[i]
	return closest_position

func find_nearest_open_cell(from_position: Vector2) -> Cell:
	var from_coord: Vector2i = get_coordinate_from_global_position(from_position)
	var max_radius: int = 50
	for r in range(max_radius + 1):
		for dx in range(-r, r + 1):
			for dy in range(-r, r + 1):
				if abs(dx) != r and abs(dy) != r:
					continue
				var coord: Vector2i = from_coord + Vector2i(dx, dy)
				if coord.x < 0 or coord.x >= grid.size():
					continue
				if grid[coord.x].size() == 0 or coord.y < 0 or coord.y >= grid[coord.x].size():
					continue
				var cell: Cell = get_cell_from_coord(coord)
				if cell.is_open():
					return cell
	return null

func find_nearest_item(item_name: String, from_position: Vector2):
	var closest_item = null
	for matching_item in item_resource.find_items(item_name):
		if closest_item == null or from_position.distance_to(matching_item.global_position) < from_position.distance_to(closest_item.global_position):
			closest_item = matching_item
	return closest_item

func get_cell_for_node(node: Node2D) -> Cell:
	return _get_cell_from_global_position(node.global_position)

func _get_cell_from_global_position(global_position: Vector2) -> Cell:
	return get_cell_from_coord(get_coordinate_from_global_position(global_position))

func get_cell_from_coord(coord: Vector2i) -> Cell:
	var cell: Cell = grid[coord.x][coord.y]
	if cell == null:
		cell = Cell.new()
		cell.global_position = get_global_position_from_coordinate(coord)
		grid[coord.x][coord.y] = cell
	return cell

func get_global_position_from_coordinate(coord: Vector2i) -> Vector2:
	@warning_ignore("integer_division")
	return Vector2(coord.x * CELL_SIZE + (CELL_SIZE / 2), coord.y * CELL_SIZE + (CELL_SIZE / 2))
	
func get_coordinate_from_global_position(position: Vector2) -> Vector2i:
	return Vector2i(floor(position.x / CELL_SIZE), floor(position.y / CELL_SIZE))

func _get_node_collection(node: Node2D):
	var collection = [node]
	collection.append_array(node.get_children().filter(func(child): return child.is_in_group("subnode")))
	return collection

class Cell:
	signal item_was_popped
	
	var global_position: Vector2
	var coord: Vector2i
	var object
	
	func is_open():
		return object == null
	
	func has_item():
		return is_instance_valid(object)
		
	func pop_item():
		if object != null and object.has_method("pop_item"):
			return object.pop_item()
		var temp = object
		object = null
		item_was_popped.emit()
		return temp

	func drop_item(item: Item):
		if object != null and object.has_method("drop_item"):
			object.drop_item(item)
			return
		object = item
		item.global_position = global_position
