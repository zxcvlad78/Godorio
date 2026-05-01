class_name PlayerUI extends CanvasLayer


static var instance:PlayerUI
static func i() -> PlayerUI:
	return instance

@export_group("Inventory")
@export var inventory_container:Container
@export var inventory_interface_menu:SD_UIInterfaceMenu

@export var player_inventory:InventoryUI
@export var other_inventory:InventoryUI

@export_group("Interaction")
@export var interaction_control:Control
@export var interaction_world_object_label:Label
@export var interaction_selected_action_label:Label


func _ready() -> void:
	
	if is_multiplayer_authority():
		instance = self
		
		inventory_interface_menu.closed.connect(_on_inventory_interface_menu_closed)


func _on_inventory_interface_menu_closed() -> void:
	if is_instance_valid(other_inventory):
		other_inventory.hide()

func open_interaction_interface(target:Node, action:InteractableAction) -> void:
	interaction_control.show()
	interaction_selected_action_label.text = action.resource_path.get_file().get_basename()

func hide_interaction_interface() -> void:
	interaction_control.hide()
