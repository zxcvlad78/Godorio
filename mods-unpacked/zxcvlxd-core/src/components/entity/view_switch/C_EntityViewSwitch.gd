class_name C_EntityViewSwitch extends Node

@export var camera:Camera3D
@export var c_nnv_view:C_NodeNetworkVisibility
@export var c_nnv_entity:C_NodeNetworkVisibility
@export var presets:Array[EntityViewPreset] = [EntityViewPreset.new(Vector3.ZERO)]

const INPUT_KEY = &"entity.switch_view"


var current_view:int = 0

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed(INPUT_KEY):
		switch()

func switch() -> void:
	if presets.is_empty():
		return
	
	current_view = (current_view + 1) % presets.size()
	
	var current_preset: EntityViewPreset = presets[current_view]
	
	if current_preset:
		c_nnv_view.mode = current_preset.c_nnv_view_mode
		c_nnv_entity.mode = current_preset.c_nnv_entity_mode
		camera.position = current_preset.position
		camera.rotation_degrees = current_preset.rotation_degrees
