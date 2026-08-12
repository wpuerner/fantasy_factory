class_name BuyerResource extends Resource

const MAX_ITEMS_PER_SHIPMENT: int = 4

@export var item_resource: ItemResource

var buyers: Array[Buyer] = []


func register_buyer(buyer: Buyer) -> void:
	if buyer not in buyers:
		buyers.append(buyer)


func deregister_buyer(buyer: Buyer) -> void:
	buyers.erase(buyer)


func place_order(item_names: Array[String]) -> void:
	if item_names.is_empty():
		return
	if buyers.is_empty():
		push_warning("BuyerResource: No buyers registered to handle order.")
		return

	var shipments: Array[Array] = _build_shipments(item_names)
	for shipment: Array[String] in shipments:
		var best_buyer: Buyer = _find_buyer_with_fewest_shipments()
		best_buyer.add_shipment(shipment)


func _build_shipments(item_names: Array[String]) -> Array[Array]:
	var names: Array[String] = item_names.duplicate()
	var shipments: Array[Array] = []
	while names.size() > 0:
		var shipment: Array[String] = []
		for _i in range(mini(names.size(), MAX_ITEMS_PER_SHIPMENT)):
			shipment.append(names.pop_front())
		shipments.append(shipment)
	return shipments


func _find_buyer_with_fewest_shipments() -> Buyer:
	var best: Buyer = buyers[0]
	var fewest: int = best.get_shipment_count()
	for i: int in range(1, buyers.size()):
		var count: int = buyers[i].get_shipment_count()
		if count < fewest:
			fewest = count
			best = buyers[i]
	return best
