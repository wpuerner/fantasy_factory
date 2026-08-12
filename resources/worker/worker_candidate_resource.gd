class_name WorkerCandidateResource extends Resource

const CANDIDATE_MAX_AGE_DAYS: int = 3
const NEW_CANDIDATES_PER_DAY_MIN: int = 1
const NEW_CANDIDATES_PER_DAY_MAX: int = 3

var candidates: Array[Dictionary] = []
var current_day: int = 0


func add_random_candidates(count: int) -> void:
	for _i: int in range(count):
		var candidate: Dictionary = {
			name = _generate_name(),
			daily_wage = snapped(randf_range(2.0, 50.0), 0.01),
			day_added = current_day,
		}
		candidates.append(candidate)


func get_valid_candidates() -> Array[Dictionary]:
	_prune_expired()
	return candidates.duplicate()


func remove_candidate(candidate: Dictionary) -> void:
	candidates.erase(candidate)


func on_day_started() -> void:
	current_day += 1
	_prune_expired()
	var new_count: int = randi_range(NEW_CANDIDATES_PER_DAY_MIN, NEW_CANDIDATES_PER_DAY_MAX)
	add_random_candidates(new_count)


func _prune_expired() -> void:
	candidates = candidates.filter(func(c: Dictionary) -> bool:
		return current_day - c.day_added < CANDIDATE_MAX_AGE_DAYS
	)


func _generate_name() -> String:
	var first_names: Array[String] = [
		"Alice", "Bob", "Charlie", "Diana", "Edgar", "Fiona", "George",
		"Hannah", "Ivan", "Julia", "Klaus", "Lena", "Marco", "Nina",
		"Oscar", "Petra", "Quinn", "Rosa", "Sam", "Tina", "Ulysses",
		"Vera", "Walter", "Xena", "Yuri", "Zara",
	]
	var last_names: Array[String] = [
		"Smith", "Jones", "Lee", "Patel", "Mueller", "Tanaka", "Dubois",
		"Rossi", "Andersen", "Kowalski", "O'Brien", "Garcia", "Kim",
		"Nakamura", "Silva", "Johansson",
	]
	var first: String = first_names[randi() % first_names.size()]
	var last: String = last_names[randi() % last_names.size()]
	return first + " " + last
