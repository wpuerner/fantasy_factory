extends Resource

signal update_moving_allowed

var is_moving_allowed: bool = false:
	set(value):
		is_moving_allowed = value
		update_moving_allowed.emit(is_moving_allowed)
