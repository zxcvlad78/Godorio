class_name W_Item extends Node3D

var entity:BaseEntity
var entity_head:EntityHead

var _object:R_WorldObject

func _ready() -> void:
	if has_meta("R_WorldObject"):
		_object = get_meta("R_WorldObject")
