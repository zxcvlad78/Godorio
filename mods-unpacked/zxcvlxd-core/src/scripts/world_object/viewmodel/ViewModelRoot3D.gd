class_name ViewModelRoot3D extends Node3D

enum ViewModelType {
	VIEW,
	ENTITY,
}

@export var entity_head:EntityHead

@export var type:ViewModelType = ViewModelType.VIEW :
	set(val):
		type = val
		if is_inside_tree(): _update()

@export var object:R_WorldObject :
	set(val):
		object = val
		if is_inside_tree(): _update()

var _ref:Node

func _ready() -> void:
	_update()

func _update() -> void:
	if _ref:
		_ref.queue_free()
	
	if !object:
		return
	
	if !object.viewmodel:
		return
	
	if type == ViewModelType.VIEW:
		_ref = object.viewmodel.instantiate_view()
	elif type == ViewModelType.ENTITY:
		_ref = object.viewmodel.instantiate_entity()
	
	if !_ref:
		return
	
	_ref.set_multiplayer_authority(get_multiplayer_authority())
	_ref.set("entity", entity_head.entity)
	_ref.set("entity_head", entity_head)
	object.set_in(_ref)
	add_child(_ref, true)
