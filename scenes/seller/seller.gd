extends Node2D

@onready var money_resource = preload("res://resources/money/money_resource.tres")

func drop_item(item: Item):
	money_resource.add_amount(item.value)
	var floating_label = preload("res://scenes/floating_label/floating_label.tscn").instantiate()
	floating_label.init("$" + str(item.value))
	floating_label.global_position = item.global_position
	add_sibling(floating_label)
	item.call_deferred("queue_free")
