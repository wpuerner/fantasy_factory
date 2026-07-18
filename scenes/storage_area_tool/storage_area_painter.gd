extends Node2D

const ToolModeClass = preload("res://resources/storage_area_tool_mode/storage_area_tool_mode.gd")

@export var tool_mode: Resource
@export var grid_resource: GridResource
@export var context_popup: Control

var storage_area_scene: PackedScene = preload("res://scenes/storage_area/storage_area.tscn")

@onready var preview_sprite: Sprite2D = $PreviewSprite

enum DragState {NONE, PLACING_DRAG}

var _drag_state: DragState = DragState.NONE
var _drag_start: Vector2
var _mouse_was_pressed: bool = false


func _ready() -> void:
	tool_mode.mode_changed.connect(_on_mode_changed)
	preview_sprite.visible = false
	if not is_instance_valid(context_popup):
		await get_tree().process_frame
	if is_instance_valid(context_popup):
		context_popup.delete_requested.connect(_on_context_delete)


func _on_mode_changed() -> void:
	_drag_state = DragState.NONE
	var active: bool = tool_mode.is_active()
	preview_sprite.visible = active
	context_popup.hide()
	if active:
		_update_hover_preview()


func _on_context_delete() -> void:
	pass


func _process(_delta: float) -> void:
	var mouse_pressed: bool = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	var just_pressed: bool = mouse_pressed and not _mouse_was_pressed
	var just_released: bool = not mouse_pressed and _mouse_was_pressed
	_mouse_was_pressed = mouse_pressed

	if _is_mouse_over_popup():
		return

	if tool_mode.active_mode == ToolModeClass.Mode.PLACING:
		if just_pressed:
			_start_placing_drag()
		elif mouse_pressed and _drag_state == DragState.PLACING_DRAG:
			_update_drag_preview()
		elif just_released and _drag_state == DragState.PLACING_DRAG:
			_finish_placing_drag()
		elif _drag_state == DragState.NONE:
			_update_hover_preview()
	else:
		if just_pressed:
			_handle_idle_click()


func _handle_idle_click() -> void:
	var mouse_pos: Vector2 = get_global_mouse_position()
	var coord: Vector2i = grid_resource.get_coordinate_from_global_position(mouse_pos)
	var cell: GridResource.Cell = grid_resource.get_cell_from_coord(coord)

	if cell.object is StorageArea.StorageAreaCell:
		var area: StorageArea = cell.object.storage_area
		if area.player_editable:
			_show_context_popup(area)
		else:
			context_popup.hide()
	else:
		context_popup.hide()


func _is_mouse_over_popup() -> bool:
	if not is_instance_valid(context_popup) or not context_popup.visible:
		return false
	var mouse_in_viewport: Vector2 = get_viewport().get_mouse_position()
	return context_popup.get_global_rect().has_point(mouse_in_viewport)


func _show_context_popup(area: StorageArea) -> void:
	var screen_pos: Vector2 = get_viewport().get_canvas_transform() * area.global_position
	screen_pos.x += 8.0
	screen_pos.y += 8.0
	context_popup.show_for_area(area, screen_pos)


func _start_placing_drag() -> void:
	_drag_state = DragState.PLACING_DRAG
	_drag_start = grid_resource.get_snapped_global_position(get_global_mouse_position())
	preview_sprite.global_position = _drag_start
	preview_sprite.texture.size = Vector2(GridResource.CELL_SIZE, GridResource.CELL_SIZE)


func _update_drag_preview() -> void:
	var mouse_pos: Vector2 = get_global_mouse_position()
	var s: Vector2 = grid_resource.get_snapped_global_position(mouse_pos)

	var top_left: Vector2 = Vector2(min(_drag_start.x, s.x), min(_drag_start.y, s.y))
	var size: Vector2 = Vector2(abs(s.x - _drag_start.x) + GridResource.CELL_SIZE, abs(s.y - _drag_start.y) + GridResource.CELL_SIZE)

	preview_sprite.global_position = top_left
	preview_sprite.texture.size = size


func _finish_placing_drag() -> void:
	_drag_state = DragState.NONE

	var mouse_pos: Vector2 = get_global_mouse_position()
	var s: Vector2 = grid_resource.get_snapped_global_position(mouse_pos)

	var start_coord: Vector2i = grid_resource.get_coordinate_from_global_position(_drag_start)
	var end_coord: Vector2i = grid_resource.get_coordinate_from_global_position(s)

	var min_coord: Vector2i = Vector2i(min(start_coord.x, end_coord.x), min(start_coord.y, end_coord.y))
	var max_coord: Vector2i = Vector2i(max(start_coord.x, end_coord.x), max(start_coord.y, end_coord.y))

	var area_width: int = max_coord.x - min_coord.x + 1
	var area_height: int = max_coord.y - min_coord.y + 1

	for x in range(area_width):
		for y in range(area_height):
			var cell: GridResource.Cell = grid_resource.get_cell_from_coord(min_coord + Vector2i(x, y))
			if not cell.is_open():
				_update_hover_preview()
				return

	var top_left_pos: Vector2 = grid_resource.get_global_position_from_coordinate(min_coord)

	var storage_area: StorageArea = storage_area_scene.instantiate()
	storage_area.width = area_width
	storage_area.height = area_height
	storage_area.priority = tool_mode.priority
	storage_area.global_position = top_left_pos
	get_parent().add_child(storage_area)

	tool_mode.active_mode = ToolModeClass.Mode.NONE


func _update_hover_preview() -> void:
	if tool_mode.active_mode != ToolModeClass.Mode.PLACING:
		return
	var mouse_pos: Vector2 = get_global_mouse_position()
	var s: Vector2 = grid_resource.get_snapped_global_position(mouse_pos)
	preview_sprite.global_position = s
	preview_sprite.texture.size = Vector2(GridResource.CELL_SIZE, GridResource.CELL_SIZE)


func _exit_tree() -> void:
	if is_instance_valid(tool_mode):
		tool_mode.mode_changed.disconnect(_on_mode_changed)
	if is_instance_valid(context_popup) and context_popup.delete_requested.is_connected(_on_context_delete):
		context_popup.delete_requested.disconnect(_on_context_delete)
