extends Node

@export var controller : Controller
@export var handling : bool
@export var handling_main_actions : bool


func _unhandled_input(event : InputEvent) -> void:
	if not controller or not handling_main_actions:
		return
	
	pass

func _physics_process(_delta = null) -> void:
	if not controller or not handling:
		return
	
	pass
