extends TileMapLayer

var storage_areas_resource = preload("res://resources/storage_areas/storage_areas_resource.tres")

func _ready():
	storage_areas_resource.added_storage_area.connect(_on_added_storage_area)

func _on_added_storage_area(coords: Array[Vector2i]):
	for coord in coords:
		set_cell(coord, 0, Vector2i(0, 1))
	
