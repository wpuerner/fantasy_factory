extends Button

func _on_toggled(toggled_on):
	if toggled_on:
		text = ">"
		get_tree().paused = true
	else:
		text = "||"
		get_tree().paused = false
