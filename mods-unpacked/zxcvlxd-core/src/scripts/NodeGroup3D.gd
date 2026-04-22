class_name NodeGroup3D extends Node3D

static var _registry:Dictionary[StringName, NodeGroup3D] = {}

static func get_all() -> Array:
	return _registry.values()

static func get_by_name(node_name:StringName) -> NodeGroup3D:
	return _registry.get(node_name, null)

func append_to_list() -> void:
	_registry[name] = self

func remove_from_list() -> void:
	if _registry.get(name) == self:
		_registry.erase(name)

func _ready() -> void:
	append_to_list()

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		remove_from_list()
