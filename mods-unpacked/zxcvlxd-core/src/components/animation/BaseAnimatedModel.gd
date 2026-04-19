@tool
class_name BaseAnimatedModel extends W_AnimatedModel3D

@export_group("State Machine")
@export var actor_state_machine:BaseStateMachine
@export var tree_state_machine:AnimationNodeStateMachine

@export_group("Properties")
@export var _process_properties:Array[AnimatedModelProperty]
@export var _physics_properties:Array[AnimatedModelProperty]

var actor_blend_position:Vector2
var actor_velocity:Vector3

func _process(_delta: float) -> void:
	if root is BaseEntity:
		if root.velocity.length_squared() > 0.001:
			actor_velocity = root.velocity.normalized() * root.transform.basis
			actor_blend_position = Vector2(actor_velocity.x, -actor_velocity.z)
	
	
	for prop in _process_properties:
		set(prop.property_path, get(prop.property_value_path))

func _physics_process(_delta: float) -> void:
	
	
	for prop in _physics_properties:
		set(prop.property_path, get(prop.property_value_path))
