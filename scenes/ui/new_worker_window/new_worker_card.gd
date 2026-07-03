extends Panel

signal hired(worker: Node2D)

var worker_name: String
var daily_wage: float

func _ready():
	worker_name = "Worker " + str(randi_range(0, 100))
	$NameLabel.text = worker_name
	
	daily_wage = snappedf(randf_range(2.0, 50.0), 0.01)
	$WageLabel.text = "$" + str(daily_wage) + " / day"

func _on_hire_button_pressed():
	var worker: Node2D = preload("res://scenes/worker/worker.tscn").instantiate()
	worker.worker_name = worker_name
	worker.daily_wage = daily_wage
	hired.emit(worker)
