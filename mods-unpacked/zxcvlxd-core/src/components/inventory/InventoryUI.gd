class_name InventoryUI extends Control

@export var c_inventory_ui:C_InventoryUI
@export var container:Container
@export var hotbar_container:Container
@export var title:Label

func _ready() -> void:
	_update()
	c_inventory_ui.inventory.slot_added.connect(add_ui_slot)
	c_inventory_ui.inventory.slot_removed.connect(remove_ui_slot)
	
	if title:
		var target_text:String = "Inventory"
		var root = c_inventory_ui.inventory.root
		if root:
			if root is W_Player:
				#var player = 
				pass
		
		title.text = target_text

func _update() -> void:
	for c in container.get_children():
		c.queue_free()
	
	for c in hotbar_container.get_children():
		c.queue_free()
	
	for slot in c_inventory_ui.inventory.slots:
		add_ui_slot(slot)

func add_ui_slot(slot:InventorySlot) -> UI_InventorySlot:
	var new_ui_slot = c_inventory_ui.ui_slot_prefab.instantiate() as UI_InventorySlot
	if !new_ui_slot:
		return null
	
	new_ui_slot.c_inventory_ui = c_inventory_ui
	new_ui_slot.slot = slot
	
	if slot.tags.has("hotbar"):
		hotbar_container.add_child(new_ui_slot, true)
	else:
		container.add_child(new_ui_slot, true)
	
	
	return new_ui_slot

func remove_ui_slot(slot:InventorySlot) -> void:
	var ui_slot:UI_InventorySlot
	for c in container.get_children():
		if c.get("slot") == slot:
			ui_slot = c
			break
	
	ui_slot.queue_free()
