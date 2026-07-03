extends Node2D

@export var money_label: Label
@export var new_worker_window: Control
@export var day_time_progress_bar: ProgressBar

@onready var money_resource = preload("res://resources/money/money_resource.tres")
@onready var furniture_resource = preload("res://resources/furniture/furniture_resource.tres")
@onready var grid_resource = preload("res://resources/grid/grid_resource.tres")
@onready var storage_areas_resource = preload("res://resources/storage_areas/storage_areas_resource.tres")
@onready var item_resource = preload("res://resources/item/item_resource.tres")

const MAX_DAY_LENGTH_SECONDS: float = 120.0

var time_left_in_day: float = MAX_DAY_LENGTH_SECONDS

func _ready():
	grid_resource.init(get_viewport_rect())
	money_resource.amount_changed.connect(_on_money_amount_changed)
	
	for i in range(4):
		var foo = item_resource.create_from_template("Foo")
		foo.global_position = Vector2(100, (i+1) * 100)
		add_child(foo)
		grid_resource.maybe_add_node(foo)
	
	grid_resource.maybe_add_node($Seller)
	grid_resource.maybe_add_node($EnchantingTable)
	
	storage_areas_resource.create_new_storage_area(Vector2(50, 200), Vector2(400, 400))
	
	day_time_progress_bar.max_value = MAX_DAY_LENGTH_SECONDS
	day_time_progress_bar.value = MAX_DAY_LENGTH_SECONDS
	
func _physics_process(delta: float):
	time_left_in_day -= delta
	if time_left_in_day <= 0.0:
		get_tree().get_nodes_in_group("workers").map(func(worker): money_resource.add_amount(-worker.daily_wage))
		time_left_in_day = MAX_DAY_LENGTH_SECONDS
	day_time_progress_bar.value = time_left_in_day
	
func _on_money_amount_changed(new_amount: float):
	money_label.text = "$" + str(new_amount)

func _on_check_button_toggled(toggled_on):
	furniture_resource.is_moving_allowed = toggled_on

func _on_hire_workers_button_pressed():
	new_worker_window.open()

func _on_new_worker_window_worker_hired(worker):
	worker.global_position = Vector2(200, 200)
	add_child(worker)
