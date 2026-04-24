class_name UI_InventorySlot extends Control

@export var c_inventory_ui:C_InventoryUI
@export var slot:InventorySlot

@export var icon_texture_rect:TextureRect

@export_group("Custom", "custom_")
@export var custom_missing_texture:Texture

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
	
