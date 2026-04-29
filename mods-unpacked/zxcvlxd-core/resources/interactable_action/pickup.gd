#pickup action
extends InteractableAction

func on_interact(ray:C_InteractionRay, c_interactable:C_Interactable) -> void:
	super(ray, c_interactable)
	var target:Node = c_interactable.target
	if !is_valid_target(target):
		return
	
	if !ray:
		return
	
	var inventory:C_Inventory = C_Inventory.find_in(ray.entity)
	if !inventory:
		return
	
	
	inventory.pickup_item(target)

func is_valid_target(target:Node) -> bool:
	if !target:
		return false
	
	var item_count:int = 0
	for inv in SD_ECS.find_components_by_script(target, [C_Inventory]):
		if inv is C_Inventory:
			item_count += inv.slots.size() - inv.get_free_slots().size()
	
	if item_count > 0:
		return false
	
	return true
