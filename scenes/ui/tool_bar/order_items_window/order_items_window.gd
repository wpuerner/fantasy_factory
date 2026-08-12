extends PanelContainer

signal closed

@export var item_line_container: Container
@export var item_resource: ItemResource
@export var total_price_label: Label
@export var total_quantity_label: Label
@export var num_shipments_label: Label
@export var buyer_resource: BuyerResource
@export var money_resource: MoneyResource
@export var message_resource: MessageResource
@export var order_item_line: PackedScene

var order = {}
var total_quantity: int: 
	set(value):
		total_quantity = value
		total_quantity_label.text = "Total Quantity: " + str(total_quantity)
		@warning_ignore("integer_division")
		num_shipments_label.text = "Num Shipments: " + str(ceili(total_quantity / 4.0))
var total_cost: float:
	set(value):
		total_cost = value
		total_price_label.text = "Total Cost: $" + str(total_cost)

func open():
	total_quantity = 0
	total_cost = 0.0
	for template in item_resource.templates:
		var item_line = order_item_line.instantiate()
		item_line.item_name = template.item_name
		item_line.price = template.value
		item_line.quantity_changed.connect(_on_item_line_quantity_changed)
		item_line_container.add_child(item_line)
	visible = true

func close():
	visible = false
	for child in item_line_container.get_children():
		child.queue_free()
	closed.emit()

func _on_item_line_quantity_changed(item_name: String, price: float, new_quantity: int):
	if new_quantity == 0 and item_name in order:
		order.erase(item_name)
	elif new_quantity > 0 and item_name not in order:
		order[item_name] = {"price": price, "quantity": new_quantity}
	elif new_quantity > 0 and item_name in order:
		order[item_name]["quantity"] = new_quantity
	
	total_quantity = 0
	total_cost = 0.0
	for item_order in order.values():
		total_quantity += item_order.quantity
		total_cost += item_order.quantity + item_order.price

func _on_cancel_button_pressed():
	close()

func _on_order_button_pressed():
	if money_resource.get_amount() < total_cost:
		message_resource.publish("You don't have enough money to make this transaction.")
		return
	money_resource.add_amount(-1 * total_cost)
	var order_list: Array[String] = []
	for item_name in order.keys():
		for i in range(order[item_name]["quantity"]):
			order_list.append(item_name)
	buyer_resource.place_order(order_list)
	close()
