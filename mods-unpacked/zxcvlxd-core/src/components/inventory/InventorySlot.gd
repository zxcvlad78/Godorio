class_name InventorySlot extends Resource

signal item_stack_changed(new_item_stack:ItemStack)

@export var item_stack:ItemStack :
	set(val):
		item_stack = val
		item_stack_changed.emit(item_stack)

@export var tags:Array[StringName]

@export_group("Custom", "custom_")
@export var custom_ui:PackedScene


func is_free() -> bool:
	return item_stack == null

func can_stack_with(p_item_stack:ItemStack) -> bool:
	return item_stack.object == p_item_stack.object

func _init(p_item_stack:ItemStack = null) -> void:
	item_stack = p_item_stack

func simusnet_serialize(serialization:SimusNetCustomSerialization) -> void:
	var is_copy:bool = resource_path.is_empty()
	serialization.pack(is_copy)
	if !is_copy:
		serialization.pack(resource_path)
		return
	
	serialization.pack(item_stack)
	serialization.pack(tags)

static func simusnet_deserialize(serialization:SimusNetCustomSerialization) -> void:
	var new_inventory_slot:InventorySlot = InventorySlot.new()
	var is_copy:bool = serialization.unpack()
	
	if !is_copy:
		var res_path = serialization.unpack()
		new_inventory_slot = load(res_path)
	else:
		new_inventory_slot.item_stack = serialization.unpack()
		new_inventory_slot.tags = serialization.unpack()
	
	serialization.set_result(new_inventory_slot)
