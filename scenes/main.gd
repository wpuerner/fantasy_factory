extends Node2D

@export var day_timer: Timer
@export var money_label: Label
@export var hire_workers_window: Control
@export var day_time_progress_bar: ProgressBar
@export var end_of_day_window: Control
@export var grid_resource: GridResource
@export var bankrupt_label: Control
@export var worker_details_window: Control

@onready var money_resource = preload("res://resources/money/money_resource.tres")
@onready var furniture_resource = preload("res://resources/furniture/furniture_resource.tres")
@onready var storage_areas_resource = preload("res://resources/storage_areas/storage_areas_resource.tres")
@onready var item_resource: ItemResource = preload("res://resources/item/item_resource.tres")
@onready var candidate_resource: WorkerCandidateResource = preload("res://resources/worker/worker_candidate_resource.tres")

const MAX_DAY_LENGTH_SECONDS: float = 30.0

var time_left_in_day: float = MAX_DAY_LENGTH_SECONDS

func _enter_tree():
	var grid_rect = get_viewport_rect()
	grid_rect.size *= 100
	grid_resource.init(grid_rect)
	
func _ready():
	money_resource.amount_changed.connect(_on_money_amount_changed)
	
	# Wire up storage area tool
	$StorageAreaPainter.context_popup = $SubViewport/StorageAreaContextPopup
	
	for i in range(4):
		var foo: Item = item_resource.create_from_template("Foo")
		foo.global_position = Vector2(100, (i+1) * 100)
		add_child(foo)
		grid_resource.get_cell_for_node(foo).drop_item(foo)
	
	grid_resource.maybe_add_node($EnchantingTable)
	
	$NavigationRegion2D.bake_navigation_polygon(true)
	
	# Seed initial worker candidates
	candidate_resource.on_day_started()
		
	day_time_progress_bar.max_value = day_timer.wait_time
	_start_day()
	
	_connect_workers()
	
	
func _physics_process(_delta):
	day_time_progress_bar.value = day_timer.time_left

func _start_day():
	day_timer.start(GlobalConfig.DAY_DURATION_SECONDS)
	get_tree().call_group("day_aware", "start_day")

func _on_money_amount_changed(new_amount: float):
	money_label.text = "$" + str(new_amount)

func _on_check_button_toggled(toggled_on):
	furniture_resource.is_moving_allowed = toggled_on

func _on_worker_hired(worker: Node2D):
	worker.global_position = Vector2(200, 200)
	add_child(worker)
	_connect_worker(worker)

func _connect_workers() -> void:
	for worker: Node2D in get_tree().get_nodes_in_group("workers"):
		_connect_worker(worker)

func _connect_worker(worker: Node2D) -> void:
	if not worker.clicked.is_connected(_on_worker_clicked):
		worker.clicked.connect(_on_worker_clicked)

func _on_worker_clicked(worker: Node2D) -> void:
	_open_worker_details(worker)

func _on_worker_selected(worker: Node2D) -> void:
	_open_worker_details(worker)

func _open_worker_details(worker: Node2D) -> void:
	if is_instance_valid(worker):
		worker_details_window.open(worker)

func _on_day_timer_timeout():
	get_tree().paused = true
	end_of_day_window.open()

func _on_end_of_day_window_day_was_started():
	_start_day()
	
func _on_end_of_day_window_bankrupted():
	bankrupt_label.open()
