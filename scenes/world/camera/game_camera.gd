extends Camera2D

const MOVE_SPEED: int = 300

func _process(delta: float):
	var move_direction = Vector2(Input.get_axis("pan_camera_left", "pan_camera_right"), Input.get_axis("pan_camera_up", "pan_camera_down"))
	global_position += move_direction * MOVE_SPEED * delta
