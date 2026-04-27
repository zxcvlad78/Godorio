class_name C_Interactable extends Node

signal interacted(ray:C_InteractionRay)

@export var target:Node

func _ready() -> void:
	_setup()

func _setup() -> void:
	if !target:
		return
	
	target.set_meta("C_Interactable", self)

func on_interact(ray:C_InteractionRay) -> void:
	interacted.emit(ray)
