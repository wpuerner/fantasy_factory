class_name Item extends Node2D

@export var label: Label
@export var placeholder_label: Label
@export var item_resource: ItemResource

var item_name: String
var icon: Texture2D
var value: float
var container

func _ready():
	if icon:
		$Sprite2D.texture = icon
		$Sprite2D.scale = Vector2.ONE * ((GridResource.CELL_SIZE / 64.0) - 0.1)
	else:
		$Sprite2D.hide()
		placeholder_label.text = item_name
		placeholder_label.show()
	label.text = item_name
	item_resource.add_item(self)

func _exit_tree():
	item_resource.remove_item(self)
