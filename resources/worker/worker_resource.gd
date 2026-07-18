class_name WorkerResource extends Resource

var workers = []

func register_worker(worker):
	workers.append(worker)

func get_total_worker_cost():
	return workers.map(func(worker): return worker.daily_wage).reduce(func(accum, wage): return accum + wage)
