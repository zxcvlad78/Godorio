class_name C_ThrowableObject extends Node

@export var item:W_Item :
	set(val):
		item = val

@export var drag_node:Node3D

@export_group("Throw Settings")
@export var min_force: float = 10.0
@export var max_force: float = 30.0
@export var charge_speed: float = 20.0
@export var torque_force: float = 5.0

var current_force: float = 0.0
var is_charging: bool = false

var object:R_WorldObject
var local_camera:Camera3D

var drag_node_last_pos:Vector3
var drag_node_last_rot:Vector3

func _update() -> void:
	if !item:
		return
	
	object = R_WorldObject.find_in(item)

func _ready() -> void:
	SimusNetRPC.register(
		[
			throw,
			_on_thrown
		],
		SimusNetRPCConfig.new().flag_mode_any_peer()
	)
	
	var enabled:bool = is_multiplayer_authority()
	set_process(enabled)
	set_process_input(enabled)
	
	if !enabled:
		return
	
	_update()
	local_camera = get_viewport().get_camera_3d() 
	drag_node_last_pos = drag_node.position
	drag_node_last_rot = drag_node.rotation

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("throw"):
		is_charging = true
		current_force = min_force
		
	if event.is_action_released("throw") and is_charging:
		SimusNetRPC.invoke_on_server(throw, item, current_force)
		is_charging = false
		current_force = 0.0
		_on_thrown()

func throw(sender_item:W_Item, force:float) -> void:
	if !object:
		if !sender_item:
			return
		object = R_WorldObject.find_in(sender_item)
		if !object:
			return
	
	if !object.viewmodel:
		return
	
	var cam_xform = sender_item.entity_head.camera.global_transform
	
	var world_node = object.viewmodel.instantiate_world()
	if not world_node:
		return
	
	var direction:Vector3 = -cam_xform.basis.z
	var spawn_offset:float = 1.5
	
	object.set_in(world_node)
	
	var container = NodeGroup3D.get_by_name("NetworkedObjects")
	if container:
		container.add_child(world_node)
	
		if world_node is Node3D:
			world_node.global_transform = cam_xform
			world_node.global_transform.origin = cam_xform.origin + (direction * spawn_offset)
			
			
			if world_node is RigidBody3D:
				world_node.apply_central_impulse(direction * force)
				var right_axis = cam_xform.basis.x
				world_node.apply_torque_impulse(right_axis * (torque_force * (force / min_force)))

func _on_thrown() -> void:
	if drag_node:
		var tween = create_tween()
		tween.set_parallel(true)
		
		tween.tween_property(drag_node, "position", drag_node_last_pos, 0.2)\
			.set_trans(Tween.TRANS_BACK)\
			.set_ease(Tween.EASE_OUT)
			
		tween.tween_property(drag_node, "rotation", drag_node_last_rot, 0.2)\
			.set_trans(Tween.TRANS_CUBIC)\
			.set_ease(Tween.EASE_OUT)

func _process(delta: float) -> void:
	if is_charging:
		current_force = move_toward(current_force, max_force, charge_speed * delta)
		var t = (current_force - min_force) / (max_force - min_force)
		
		if drag_node:
			drag_node.position.z = lerp(drag_node_last_pos.z, drag_node_last_pos.z + 0.2, t)
			drag_node.rotation.x = lerp(drag_node_last_rot.x, drag_node_last_rot.x + deg_to_rad(15), t)
