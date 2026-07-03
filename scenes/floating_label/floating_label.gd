extends Node2D

var move_speed: float = 100.0
var time_to_live: float = 1.5

func init(text: String):
	$Label.text = text

func _ready():
	get_tree().create_timer(time_to_live).timeout.connect(func (): queue_free())

func _physics_process(delta: float):
	global_position.y -= move_speed * delta
