extends PanelContainer

signal day_was_started
signal bankrupted

@export var revenues_label: Label
@export var expenses_label: Label
@export var current_money_label: Label
@export var next_day_button: Button
@export var money_resource: MoneyResource
@export var worker_resource: WorkerResource

func open():
	var current_money_amount = money_resource.get_amount()
	var worker_cost = worker_resource.get_total_worker_cost()
	money_resource.add_amount(-1 * worker_cost)
	revenues_label.text = "Money at day end: $" + str(current_money_amount)
	expenses_label.text = "Expenses: $" + str(worker_cost)
	current_money_label.text = "Total funds: $" + str(money_resource.get_amount())
	visible = true
	if money_resource.get_amount() < 0:
		bankrupted.emit()
		next_day_button.disabled = true

func _on_next_day_button_pressed():
	day_was_started.emit()
	visible = false
