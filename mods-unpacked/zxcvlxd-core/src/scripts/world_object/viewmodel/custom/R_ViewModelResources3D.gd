@tool
class_name R_ViewModelResources3D extends R_ViewModel3D

@export var view:R_ViewModelResource3D
@export var entity:R_ViewModelResource3D
@export var world:R_ViewModelResource3D

func _instantiate(resource:R_ViewModelResource3D) -> Node:
	if !resource:
		return
	
	if !resource.prefab:
		return
	
	var inst = resource.prefab.instantiate()
	if inst is Node3D:
		inst.tree_entered.connect(func(): 
			_set_instance_transform(inst, resource)
		)
		return inst
	
	return null

func instantiate_world() -> Node:
	return _instantiate(world)

func instantiate_entity() -> Node:
	return _instantiate(entity)

func instantiate_view() -> Node:
	return _instantiate(view)

func _set_instance_transform(instance:Node, resource:R_ViewModelResource3D) -> void:
	if not instance.is_inside_tree():
		return
	
	
	if instance is Node3D:
		instance.scale = resource.scale
		
		if resource.is_global_transform:
			instance.global_position = resource.position
			instance.global_rotation = resource.rotation_degrees
		else:
			instance.position = resource.position
			instance.rotation = resource.rotation_degrees
