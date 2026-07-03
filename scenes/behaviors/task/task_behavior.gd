class_name TaskBehavior extends Node

@export var type: Type

enum Type {CARRY, WORK}

signal complete
signal abort

func can_start():
	push_error("Implement can_start()!")
	
func start():
	push_error("Implement start()!")
