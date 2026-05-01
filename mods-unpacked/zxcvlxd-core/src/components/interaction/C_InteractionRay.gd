@tool
class_name C_InteractionRay extends RayCast3D

@export var entity:BaseEntity

var last_interactable:C_Interactable = null

func _init() -> void:
	var is_editor_hint = Engine.is_editor_hint()
	set_process(!is_editor_hint)
	set_physics_process(!is_editor_hint)
	set_process_input(is_editor_hint)
	
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

func _physics_process(_delta: float) -> void:
	var current_collider = get_collider()
	var current_interactable: C_Interactable = null
	
	if current_collider and current_collider.has_meta("C_Interactable"):
		current_interactable = current_collider.get_meta("C_Interactable")
	
	if last_interactable and not is_instance_valid(last_interactable):
		last_interactable = null
	
	if current_interactable != last_interactable:
		if last_interactable:
			last_interactable.on_deselect(self)
		
		if current_interactable:
			current_interactable.on_select(self)
			_connect_exiting_signal(current_interactable)
			
		last_interactable = current_interactable

func _connect_exiting_signal(interactable: C_Interactable) -> void:
	if not interactable.tree_exiting.is_connected(_on_interactable_exiting):
		interactable.tree_exiting.connect(_on_interactable_exiting.bind(interactable))

func _on_interactable_exiting(interactable: C_Interactable) -> void:
	if last_interactable == interactable:
		close_interactable()
	
	if interactable.tree_exiting.is_connected(_on_interactable_exiting):
		interactable.tree_exiting.disconnect(_on_interactable_exiting)

func close_interactable() -> void:
	if last_interactable:
		last_interactable.on_deselect(self)
		last_interactable = null
