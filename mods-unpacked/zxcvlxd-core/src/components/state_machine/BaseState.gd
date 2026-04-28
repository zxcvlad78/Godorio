class_name BaseState extends Node

func _init(p_name:StringName) -> void:
	name = p_name

func on_enter(_sm:BaseStateMachine) -> void:
	pass

func on_exit(_sm:BaseStateMachine) -> void:
	pass
