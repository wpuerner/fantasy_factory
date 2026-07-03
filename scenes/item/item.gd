class_name Item extends Area2D

@export var label: Label
@export var item_resource: ItemResource

var item_name: String
var icon: Texture2D
var value: float

func _ready():
	$Sprite2D.texture = icon
	label.text = item_name
	item_resource.add_item(self)

func _exit_tree():
	item_resource.remove_item(self)
