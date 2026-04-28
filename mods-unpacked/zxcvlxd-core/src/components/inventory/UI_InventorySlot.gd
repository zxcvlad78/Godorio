class_name UI_InventorySlot extends Control

@export var c_inventory_ui:C_InventoryUI
@export var slot:InventorySlot

@export var icon_texture_rect:TextureRect

@export_group("Custom", "custom_")
@export var custom_missing_texture:Texture

var is_mouse_inside:bool = false
var missing_texture:Texture = preload("res://mods-unpacked/zxcvlxd-core/src/textures/missing.png")


func _ready() -> void:
	if custom_missing_texture:
		missing_texture = custom_missing_texture
	
	
	if !slot:
		return
	
	_update()
	slot.item_stack_changed.connect(_on_item_stack_changed)

func _on_item_stack_changed(new_item_stack:ItemStack) -> void:
	_update()

func _update() -> void:
	update_icon()

func update_icon() -> void:
	if not icon_texture_rect:
		return

	var target_texture:Texture = null
	
	if slot and slot.item_stack and slot.item_stack.object:
		if slot.item_stack.object.icon:
			target_texture = slot.item_stack.object.icon
		else:
			target_texture = missing_texture
	
	icon_texture_rect.texture = target_texture

func _on_dnd_dropped(draggable: Control, at: Control) -> void:
	print(at)
	
	if slot.is_free(): 
		return
	
	
	if at is UI_InventorySlot:
		if at.slot == self.slot:
			return
			
		if Input.is_action_pressed("inventory.split"):
			c_inventory_ui.inventory.split_item(slot, at.slot)
		else:
			c_inventory_ui.inventory.move_item(slot, at.slot)
			
	elif at is UI_InventoryDropZone:
		c_inventory_ui.inventory.drop_item(slot)


func _input(event: InputEvent) -> void:
	if is_mouse_inside:
		if Input.is_action_just_pressed("inventory.fast_drop"):
			if slot.item_stack:
				c_inventory_ui.inventory.drop_item(slot)

func _on_sd_ui_drag_and_drop_drag_started() -> void:
	icon_texture_rect.self_modulate.a = 0.5
func _on_sd_ui_drag_and_drop_drag_stopped() -> void:
	icon_texture_rect.self_modulate.a = 1.0

func _on_mouse_entered() -> void:
	is_mouse_inside = true
func _on_mouse_exited() -> void:
	is_mouse_inside = false


func _on_drag_and_drop_drag_stopped() -> void:
	pass # Replace with function body.
