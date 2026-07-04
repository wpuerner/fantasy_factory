extends PanelContainer

signal quantity_changed(item_name: String, price: float, new_quantity: int)

@export var item_name_label: Label
@export var price_label: Label
@export var quantity_label: Label

var quantity: int:
	set(value):
		quantity = value
		quantity_label.text = str(quantity)
		quantity_changed.emit(item_name, price, quantity)
var price: float
var item_name: String

func _ready():
	item_name_label.text = item_name
	price_label.text = "$" + str(price)

func _on_lower_quantity_button_pressed():
	quantity -= 1

func _on_higher_quantity_button_pressed():
	quantity += 1
