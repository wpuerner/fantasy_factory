class_name StorageAreaToolMode extends Resource

signal mode_changed
signal settings_changed

enum Mode {NONE, PLACING}

var active_mode: Mode = Mode.NONE:
	set(value):
		active_mode = value
		mode_changed.emit()

var priority: int = 5:
	set(value):
		priority = value
		settings_changed.emit()

func toggle_placing() -> void:
	if active_mode == Mode.PLACING:
		active_mode = Mode.NONE
	else:
		active_mode = Mode.PLACING

func is_active() -> bool:
	return active_mode != Mode.NONE
