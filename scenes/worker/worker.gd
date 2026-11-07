extends Node2D

signal clicked(worker: Node2D)

@export var worker_name: String = "jimothy"
@export var worker_resource: WorkerResource
@export var enchant_task_behavior: TaskBehavior
@export var haul_task_behavior: TaskBehavior

var can_haul: bool = true
var can_enchant: bool = true

const SPEED: float = 300.0

var daily_wage: float = 5.0

var _current_behavior: TaskBehavior
	
func _ready() -> void:
	worker_resource.register_worker(self)

func _physics_process(delta: float) -> void:
	if !is_instance_valid(_current_behavior):
		if can_enchant and enchant_task_behavior.start():
			_current_behavior = enchant_task_behavior
		elif can_haul and haul_task_behavior.start():
			_current_behavior = haul_task_behavior
	else:
		var result: TaskBehavior.TaskStatus = _current_behavior.update(delta)
		if result != TaskBehavior.TaskStatus.IN_PROGRESS:
			_current_behavior = null

	if !$NavigationAgent2D.is_target_reached():
		global_position = global_position.move_toward($NavigationAgent2D.get_next_path_position(), SPEED * delta)


func fire() -> void:
	worker_resource.deregister_worker(self)
	queue_free()


func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		clicked.emit(self)
