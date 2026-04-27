@tool
class_name BaseAnimatedModel extends W_AnimatedModel3D

@export_group("State Machine")
@export var actor_state_machine:BaseStateMachine
@export var tree_state_machine_path:StringName = "parameters/StateMachine/playback"

var tree_state_machine:AnimationNodeStateMachinePlayback

@export_group("Properties")
@export var _process_properties:Array[AnimatedModelProperty]
@export var _physics_properties:Array[AnimatedModelProperty]

var actor_blend_position:Vector2
var actor_velocity:Vector3

func _ready() -> void:
	SimusNetRPC.register(
		[
			local_play_item_animation,
			local_stop_item_animation,
		],
		SimusNetRPCConfig.new().flag_mode_authority()
	)
	
	var enabled:bool = !Engine.is_editor_hint()
	set_process(enabled)
	set_physics_process(enabled)
	
	tree_state_machine = tree.get(tree_state_machine_path)
	
	if actor_state_machine:
		actor_state_machine.state_enter.connect(_on_actor_state_enter)
		actor_state_machine.state_exit.connect(_on_actor_state_exit)

func _on_actor_state_enter(state_name:String) -> void:
	if !tree_state_machine:
		return
	
	tree_state_machine.travel(state_name)

func _on_actor_state_exit(_state_name:String) -> void:
	pass

func play_item_animation(
	animation_name:StringName,
	library_name:StringName = &"animation_library",
	animation_node_name:StringName = &"ItemAnimation",
	blend_node_name:StringName = &"ItemAnimationBlend",
	) -> void:
		local_play_item_animation(
			animation_name,
			library_name,
			animation_node_name,
			blend_node_name)
		
		SimusNetRPC.invoke(local_play_item_animation,
			animation_name,
			library_name,
			animation_node_name,
			blend_node_name)

func local_play_item_animation(
	animation_name:StringName,
	library_name:StringName = &"animation_library",
	animation_node_name:StringName = &"ItemAnimation",
	blend_node_name:StringName = &"ItemAnimationBlend",
	) -> void:
		var animation_node:AnimationNodeAnimation = blend_tree.get_node(animation_node_name) as AnimationNodeAnimation
		if animation_node:
			var animation_full_name:StringName = "%s/%s" % [library_name, animation_name]
			animation_node.animation = animation_full_name
		
		var blend_node:AnimationNodeBlend2 = blend_tree.get_node(blend_node_name) as AnimationNodeBlend2
		if blend_node:
			var param_path = "parameters/%s/blend_amount" % blend_node_name
			tree.set(param_path, 1.0)

func stop_item_animation(
	blend_node_name:StringName = &"ItemAnimationBlend",
	animation_node_name:StringName = &"ItemAnimation",
	) -> void:
		local_stop_item_animation(
			blend_node_name,
			animation_node_name)
		
		SimusNetRPC.invoke(local_stop_item_animation,
			blend_node_name,
			animation_node_name)

func local_stop_item_animation(
	blend_node_name:StringName = &"ItemAnimationBlend",
	animation_node_name:StringName = &"ItemAnimation",
	) -> void:
		#var animation_node:AnimationNodeAnimation = blend_tree.get_node(animation_node_name) as AnimationNodeAnimation
		#if animation_node:
			#animation_node.
		
		var blend_node:AnimationNodeBlend2 = blend_tree.get_node(blend_node_name) as AnimationNodeBlend2
		if blend_node:
			var param_path = "parameters/%s/blend_amount" % blend_node_name
			tree.set(param_path, 0.0)

func _process(_delta: float) -> void:
	if root is BaseEntity:
		actor_velocity = root.velocity.normalized() * root.transform.basis
		actor_blend_position = Vector2(actor_velocity.x, -actor_velocity.z)
	
	
	for prop in _process_properties:
		set_property(prop)

func set_property(prop:AnimatedModelProperty) -> void:
	var target_object:Variant
	if prop.object_path.is_empty():
		target_object = self
		
	else:
		target_object = get(prop.object_path)
	if !target_object:
		return
	target_object.set(prop.property_path, get(prop.property_value_path))

func _physics_process(_delta: float) -> void:
	
	
	for prop in _physics_properties:
		set_property(prop)
