@tool
class_name C_InteractionRay extends RayCast3D

@export var entity:BaseEntity

func _init() -> void:
	collide_with_areas = true
	collide_with_bodies = true

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	var auth:bool = is_multiplayer_authority()
	
	set_process(auth)
	set_physics_process(auth)
	
	set_process_input(auth)
	set_process_unhandled_input(auth)
	

func _input(_event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	
	if Input.is_action_just_pressed("interact"):
		var collider = get_collider()
		if !collider:
			return
		
		if !collider.has_meta("C_Interactable"):
			return
		
		var c_interactable = collider.get_meta("C_Interactable")
		if !c_interactable:
			return
		
		interact(c_interactable)

func interact(interactable:C_Interactable) -> void:
	interactable.on_interact(self)
