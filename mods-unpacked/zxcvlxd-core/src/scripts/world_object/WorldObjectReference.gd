class_name WorldObjectReference extends RefCounted

static var _logger:SD_Logger
static var _ref_list:Dictionary[StringName, R_WorldObject] = {}

static func get_logger() -> SD_Logger:
	return _logger

static func get_references() -> Dictionary[StringName, R_WorldObject]:
	return _ref_list

func _init() -> void:
	_logger = SD_Logger.new("WorldObjectReference")
	setup_console_commands()

func setup_console_commands() -> void:
	var cmd_list:Array[SD_ConsoleCommand] = [
		SD_ConsoleCommand.get_or_create("wo_ref.spawn", ""),
		]
	for cmd in cmd_list:
		if not cmd.executed.is_connected(_on_cmd_executed):
			cmd.executed.connect(_on_cmd_executed.bind(cmd))

func _on_cmd_executed(cmd:SD_ConsoleCommand) -> void:
	var args = cmd.get_arguments()
	match cmd.get_code():
		"wo_ref.spawn":
			if args.size() < 1:
				_logger.debug("spawn failed: object id required", SD_ConsoleCategories.ERROR)
				return
			
			var ref_id = args[0]
			var resource = get_reference_by_id(ref_id)
			var parent = NodeGroup3D.get_by_name("NetworkedObjects")
			
			if not resource:
				_logger.debug("spawn failed: id not found", SD_ConsoleCategories.ERROR)
				return
			
			var tree = Engine.get_main_loop() as SceneTree
			var camera = tree.root.get_camera_3d()
			
			if not camera:
				_logger.debug("spawn failed: no active camera found", SD_ConsoleCategories.ERROR)
				return
			
			var space_state = camera.get_world_3d().direct_space_state
			var ray_origin = camera.global_position
			var ray_end = ray_origin - camera.global_transform.basis.z * 5.0
			
			var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)

			var result = space_state.intersect_ray(query)
			
			var spawn_pos: Vector3
			if result:
				spawn_pos = result.position
			else:
				spawn_pos = ray_origin - camera.global_transform.basis.z * 5.0
			
			var new_node = spawn_reference(parent, resource)
			print(new_node)
			if new_node and new_node is Node3D:
				new_node.global_position = spawn_pos

static func append_reference(resource:R_WorldObject) -> Error:
	if not resource or resource.id.is_empty():
		return ERR_INVALID_PARAMETER
	_ref_list[resource.id] = resource
	return OK

static func delete_reference(resource:R_WorldObject) -> Error:
	if resource and _ref_list.erase(resource.id):
		return OK
	return ERR_DOES_NOT_EXIST

static func get_reference_by_id(ref_id:StringName) -> R_WorldObject:
	return _ref_list.get(ref_id, null)

static func spawn_reference(parent_node: Node, resource: R_WorldObject, properties: Dictionary = {}) -> Node:
	if not parent_node:
		_logger.debug("'spawn_reference' parent_node is null", SD_ConsoleCategories.ERROR)
		return null
	
	if not resource:
		_logger.debug("'spawn_reference' resource is null", SD_ConsoleCategories.ERROR)
		return null
	
	var inst = resource.viewmodel.instantiate_world()
	if not inst:
		_logger.debug("'spawn_reference' failed to instantiate viewmodel", SD_ConsoleCategories.ERROR)
		return null
	
	resource.set_in(inst)
	parent_node.add_child(inst)
	
	for prop in properties:
		inst.set(prop, properties[prop])
	
	return inst
