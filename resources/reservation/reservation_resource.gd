class_name ReservationResource extends Resource

var _reservations: Dictionary = {}  # Object -> Node2D (worker)

func reserve(obj: Object, worker: Node2D) -> bool:
	print("reserving ", obj, " for worker ", worker.name)
	if is_reserved_by_other(obj, worker):
		print("object ", obj, " was already reserved")
		return false
	_reservations[obj] = worker
	return true

func release(obj: Object, worker: Node2D) -> void:
	print("releasing ", obj, " for worker ", worker.name)
	if _reservations.get(obj) == worker:
		_reservations.erase(obj)


func release_all(worker: Node2D) -> void:
	for obj: Object in _reservations.keys():
		if _reservations[obj] == worker:
			_reservations.erase(obj)


func is_reserved(obj: Object) -> bool:
	var reserver: Node2D = _reservations.get(obj)
	return is_instance_valid(reserver)


func is_reserved_by(obj: Object, worker: Node2D) -> bool:
	return _reservations.get(obj) == worker


func is_reserved_by_other(obj: Object, worker: Node2D) -> bool:
	if obj not in _reservations:
		return false
	var reserver: Node2D = _reservations.get(obj)
	print("checking reserver ", reserver, " is same as worker ", worker)
	return is_instance_valid(reserver) and reserver != worker
