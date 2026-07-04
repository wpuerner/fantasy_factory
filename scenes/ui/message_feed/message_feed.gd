extends Control

@export var message_resource: MessageResource
@export var label_container: Container

func _ready():
	message_resource.message_published.connect(_on_message_published)
	
func _on_message_published(message_text: String):
	var new_label = preload("res://scenes/ui/message_feed/message_label.tscn").instantiate()
	new_label.text = message_text
	label_container.add_child(new_label)
	visible = true

func _on_label_container_child_exiting_tree(node):
	if len(label_container.get_children()) < 2:
		visible = false
