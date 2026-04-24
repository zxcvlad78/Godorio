class_name R_WorldObject extends Resource

@export var id:StringName = ""
@export var name:StringName = "World Object"
@export var icon:Texture = null
@export var viewmodel:R_ViewModel3D

func set_in(node: Node) -> void:
	node.set_meta(&"R_WorldObject", self)

static func find_in(node: Node) -> R_WorldObject:
	if node.has_meta(&"R_WorldObject"):
		return node.get_meta(&"R_WorldObject") as R_WorldObject
	return null
