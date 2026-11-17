class_name WorkbenchTicket extends Resource

@export var output_item_name: String = ""
@export var input_item_names: Array[String] = []
@export var work_amount: int = 100
@export var quantity: int = 1
@export var paused: bool = false


# A ticket is only worked while it still has units left and has not been paused.
func is_active() -> bool:
	return quantity > 0 and not paused


func is_complete() -> bool:
	return quantity <= 0


func status_text() -> String:
	if is_complete():
		return "Complete"
	if paused:
		return "Paused"
	return "Working"


func input_text() -> String:
	return ", ".join(input_item_names)
