extends Control

func open():
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	var end_position = (get_viewport_rect().end / 2) - (size / 2)
	tween.tween_property(self, "global_position", end_position, 1.0)
