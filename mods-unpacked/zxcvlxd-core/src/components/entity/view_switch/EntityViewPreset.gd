class_name EntityViewPreset extends Resource

func _init(p_position:Vector3 = Vector3.ZERO, p_rotation_degrees:Vector3 = Vector3.ZERO) -> void:
	position = p_position
	rotation_degrees = p_rotation_degrees

@export var position:Vector3 = Vector3.ZERO
@export var rotation_degrees:Vector3 = Vector3.ZERO

@export var c_nnv_view_mode:C_NodeNetworkVisibility.Mode = C_NodeNetworkVisibility.Mode.AUTHORITY
@export var c_nnv_entity_mode:C_NodeNetworkVisibility.Mode
