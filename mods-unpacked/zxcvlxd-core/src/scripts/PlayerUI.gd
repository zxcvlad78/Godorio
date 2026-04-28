class_name PlayerUI extends CanvasLayer


static var instance:PlayerUI
static func i() -> PlayerUI:
	return instance

@export var inventory_container:Container
@export var inventory_interface_menu:SD_UIInterfaceMenu


@export var player_inventory:InventoryUI
@export var other_inventory:InventoryUI

func _ready() -> void:
	
	if is_multiplayer_authority():
		instance = self
		
		inventory_interface_menu.closed.connect(_on_inventory_interface_menu_closed)


func _on_inventory_interface_menu_closed() -> void:
	if is_instance_valid(other_inventory):
		other_inventory.hide()
