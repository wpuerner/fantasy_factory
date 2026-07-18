class_name MoneyResource extends Resource

signal amount_changed(new_amount: float)

var money: float = 14.0

func get_amount():
	return money

func add_amount(value: float):
	money += value
	amount_changed.emit(money)
