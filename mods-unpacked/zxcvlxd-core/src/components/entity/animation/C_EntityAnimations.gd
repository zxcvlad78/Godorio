class_name C_EntityAnimations extends Node

@export var animated_model:BaseAnimatedModel

static func find_in(node:Node) -> C_EntityAnimations:
	return SD_ECS.find_first_component_by_script(node, [C_EntityAnimations])

func _enter_tree() -> void:
	SD_ECS.append_to(animated_model.root, self)

func _ready() -> void:
	SimusNetRPC.register(
		[
			local_create_event,
			local_create_event_in,
		]
	)

static func create_event_in(entity:Node, event_name:StringName, anim_library:StringName = &"animation_library") -> void:
	local_create_event_in(entity, event_name, anim_library)
	SimusNetRPC.invoke(local_create_event_in, entity, event_name, anim_library)

static func local_create_event_in(entity:Node, event_name:StringName, anim_library:StringName = &"animation_library") -> void:
	if !entity:
		print(1)
		return
	
	var c_entity_animations:C_EntityAnimations = C_EntityAnimations.find_in(entity)
	if !c_entity_animations:
		print(21)
		return
	
	c_entity_animations.local_create_event(event_name, anim_library)

func create_event(event_name:StringName, anim_library:StringName = &"animation_library") -> void:
	local_create_event(event_name, anim_library)
	SimusNetRPC.invoke(local_create_event, event_name, anim_library)

func local_create_event(event_name:StringName, anim_library:StringName = &"animation_library") -> void:
	print(0)
	animated_model.local_play_oneshot(event_name, anim_library)
