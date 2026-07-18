extends Node2D

@export var day_timer: Timer
@export var money_label: Label
@export var new_worker_window: Control
@export var order_items_window: Control
@export var day_time_progress_bar: ProgressBar
@export var end_of_day_window: Control
@export var grid_resource: GridResource
@export var bankrupt_label: Control

@onready var money_resource = preload("res://resources/money/money_resource.tres")
@onready var furniture_resource = preload("res://resources/furniture/furniture_resource.tres")
@onready var storage_areas_resource = preload("res://resources/storage_areas/storage_areas_resource.tres")
@onready var item_resource = preload("res://resources/item/item_resource.tres")

const MAX_DAY_LENGTH_SECONDS: float = 30.0

var time_left_in_day: float = MAX_DAY_LENGTH_SECONDS

func _enter_tree():
	var grid_rect = get_viewport_rect()
	grid_rect.size *= 100
	grid_resource.init(grid_rect)
	
func _ready():
	money_resource.amount_changed.connect(_on_money_amount_changed)
	
	for i in range(4):
		var foo = item_resource.create_from_template("Foo")
		foo.global_position = Vector2(100, (i+1) * 100)
		add_child(foo)
		grid_resource.maybe_add_node(foo)
	
	grid_resource.maybe_add_node($EnchantingTable)
	
	$NavigationRegion2D.bake_navigation_polygon(true)
		
	day_time_progress_bar.max_value = day_timer.wait_time
	_start_day()
	
	
func _physics_process(_delta):
	day_time_progress_bar.value = day_timer.time_left

func _start_day():
	day_timer.start(GlobalConfig.DAY_DURATION_SECONDS)
	get_tree().call_group("day_aware", "start_day")

func _on_money_amount_changed(new_amount: float):
	money_label.text = "$" + str(new_amount)

func _on_check_button_toggled(toggled_on):
	furniture_resource.is_moving_allowed = toggled_on

func _on_hire_workers_button_pressed():
	new_worker_window.open()

func _on_new_worker_window_worker_hired(worker):
	worker.global_position = Vector2(200, 200)
	add_child(worker)

func _on_order_items_button_pressed():
	order_items_window.open()

func _on_day_timer_timeout():
	get_tree().paused = true
	end_of_day_window.open()

func _on_end_of_day_window_day_was_started():
	_start_day()
	
func _on_end_of_day_window_bankrupted():
	bankrupt_label.open()
