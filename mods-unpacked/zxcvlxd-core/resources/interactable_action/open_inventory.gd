#open_inventory action
extends InteractableAction

func on_interact(ray:C_InteractionRay, c_interactable:C_Interactable) -> void:
	super(ray, c_interactable)
	
	var inventory:C_Inventory = C_Inventory.find_in(c_interactable.target)
	if !inventory:
		return
	
	var inventory_ui = C_InventoryUI.find_in(inventory)
	if inventory_ui:
		inventory_ui.request_open_container()
