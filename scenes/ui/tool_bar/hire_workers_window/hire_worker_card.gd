extends Panel

signal hired(worker: Node2D, candidate: Dictionary)

var _candidate: Dictionary = {}


func setup(candidate: Dictionary) -> void:
	_candidate = candidate
	$NameLabel.text = candidate.name
	$WageLabel.text = "$" + str(candidate.daily_wage) + " / day"


func _on_hire_button_pressed() -> void:
	var worker: Node2D = preload("res://scenes/worker/worker.tscn").instantiate()
	worker.worker_name = _candidate.name
	worker.daily_wage = _candidate.daily_wage
	hired.emit(worker, _candidate)
