class_name C_Interactable extends Node

signal interacted(ray:C_InteractionRay)

signal ray_selected(ray:C_InteractionRay)
signal ray_deselected(ray:C_InteractionRay)

@export var target:Node
@export var actions:Array[InteractableAction]

func add_action(action:InteractableAction, position:int = -1) -> InteractableAction:
	if !action:
		return null
	if actions.has(action):
		return action
	
	if position >= 0 and position <= actions.size():
		actions.insert(position, action)
	else:
		actions.append(action)
	selected_action_idx = clampi(selected_action_idx, 0, max(0, actions.size() - 1))
	
	
	return action

func remove_action(action:InteractableAction) -> InteractableAction:
	if !action:
		return null
	if !actions.has(action):
		return action
	
	actions.erase(action)
	selected_action_idx = clampi(selected_action_idx, 0, max(0, actions.size() - 1))
	
	return action

var selected_action_idx:int = 0

static func get_or_create_in(node:Node) -> C_Interactable:
	var c_interactable:C_Interactable = C_Interactable.find_in(node)
	if !c_interactable:
		c_interactable = C_Interactable.new()
		c_interactable.target = node
		c_interactable.name = &"C_Interactable"
		c_interactable._setup()
		node.add_child.call_deferred(c_interactable, true)
	
	return c_interactable

func _setup() -> void:
	if !target:
		return
	
	target.set_meta("C_Interactable", self)

static func find_in(node:Node) -> C_Interactable:
	if !node.has_meta("C_Interactable"):
		return null
	
	return node.get_meta("C_Interactable")

func on_interact(ray:C_InteractionRay) -> void:
	if actions.size() > selected_action_idx:
		actions[selected_action_idx].on_interact(ray, self)
	
	interacted.emit(ray)
