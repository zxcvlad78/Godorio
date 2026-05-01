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
			local_play_oneshot,
			local_stop_oneshot,
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

func on_tree_animation_finished(anim_name:StringName) -> void:
	pass

func play_oneshot_animation(
	animation_name:StringName,
	library_name:StringName = &"animation_library",
	animation_node_name:StringName = &"OneShotAnimation",
	oneshot_node_name:StringName = &"OneShot",
	) -> void:
		local_play_oneshot(
			animation_name,
			library_name,
			animation_node_name,
			oneshot_node_name)
		
		SimusNetRPC.invoke(local_play_oneshot,
			animation_name,
			library_name,
			animation_node_name,
			oneshot_node_name)


func local_play_oneshot(
	animation_name:StringName,
	library_name:StringName = &"animation_library",
	animation_node_name:StringName = &"OneShotAnimation",
	oneshot_node_name:StringName = &"OneShot",
	auto_return:bool = true,
	) -> void:
		var oneshot_node:AnimationNodeOneShot = blend_tree.get_node(oneshot_node_name)
		if not tree.get("parameters/%s/request" % oneshot_node_name) == AnimationNodeOneShot.ONE_SHOT_REQUEST_NONE:
			return
		
		var prev_animation:StringName = &""
		
		var animation_node:AnimationNodeAnimation = blend_tree.get_node(animation_node_name) as AnimationNodeAnimation
		if animation_node:
			var parsed = animation_node.animation.split("/")
			prev_animation = parsed.get(parsed.size() -1)
			print(prev_animation)
			
			var animation_full_name:StringName = "%s/%s" % [library_name, animation_name]
			animation_node.animation = animation_full_name
		
		tree.set("parameters/%s/request" % oneshot_node_name, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		
		if auto_return and (not prev_animation.is_empty()):
			await tree.animation_finished
			await get_tree().process_frame
			local_play_oneshot(
				prev_animation,
				library_name,
				animation_node_name,
				oneshot_node_name, 
				false
				)

#func _auto_return(tree_finished_anim:StringName, animation_node:AnimationNodeAnimation, prev_animation:StringName) -> void:
	#if not tree_finished_anim == animation_node.animation.get_basename():
		#return
	#
	#await get_tree().process_frame
	#animation_node.animation = prev_animation

#region STOP_ONESHOT
func stop_oneshot(
	oneshot_node_name:StringName = &"OneShot",
	) -> void:
		local_stop_oneshot(
			oneshot_node_name)
		
		SimusNetRPC.invoke(local_stop_oneshot,
			oneshot_node_name)

func local_stop_oneshot(
	oneshot_node_name:StringName = &"OneShot",
	) -> void:
		var oneshot_node:AnimationNodeOneShot = blend_tree.get_node(oneshot_node_name) as AnimationNodeOneShot
		if !oneshot_node:
			return
		
		tree.set("parameters/%s/request" % oneshot_node_name, AnimationNodeOneShot.ONE_SHOT_REQUEST_FADE_OUT)
		tree.get("parameters/%s/request" % oneshot_node_name)

#endregion

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
