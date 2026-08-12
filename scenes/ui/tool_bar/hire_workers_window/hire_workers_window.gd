extends PanelContainer

signal worker_hired(worker: Node2D)
signal closed

@export var worker_card_container: Container
@export var candidate_resource: WorkerCandidateResource
@export var hire_worker_card: PackedScene


func open() -> void:
	visible = true
	var candidates: Array[Dictionary] = candidate_resource.get_valid_candidates()
	for candidate: Dictionary in candidates:
		var worker_card: Panel = hire_worker_card.instantiate()
		worker_card.setup(candidate)
		worker_card_container.add_child(worker_card)
		worker_card.hired.connect(_on_worker_card_hired)

func close() -> void:
	visible = false
	for child: Node in worker_card_container.get_children():
		child.queue_free()
	closed.emit()

func _on_worker_card_hired(worker: Node2D, candidate: Dictionary) -> void:
	candidate_resource.remove_candidate(candidate)
	worker_hired.emit(worker)
	close()

func _on_close_button_pressed() -> void:
	close()
