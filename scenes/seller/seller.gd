extends Node2D

@onready var money_resource = preload("res://resources/money/money_resource.tres")

func _ready():
	global_position = $StorageArea.global_position
	$StorageArea.position = Vector2.ZERO
	
	$ProgressBar.max_value = $Timer.wait_time

func _physics_process(_delta):
	$ProgressBar.value = $Timer.time_left

func _on_timer_timeout():
	for cell in $StorageArea.cells:
		var item = cell.pop_item()
		if item:
			money_resource.add_amount(item.value)
			var floating_label = preload("res://scenes/floating_label/floating_label.tscn").instantiate()
			floating_label.init("$" + str(item.value))
			floating_label.global_position = item.global_position
			add_sibling(floating_label)
			item.call_deferred("queue_free")
			await get_tree().create_timer(0.1).timeout
