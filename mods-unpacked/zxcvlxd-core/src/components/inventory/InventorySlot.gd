class_name InventorySlot extends Resource

signal item_stack_changed()

@export var item_stack:ItemStack :
	set(val):
		var is_server:bool = SimusNetConnection.is_server()
		if is_server:
			if item_stack:
				if item_stack.quantity_changed.is_connected(_on_item_stack_quantity_changed):
					item_stack.quantity_changed.disconnect(_on_item_stack_quantity_changed)
		
		item_stack = val
		item_stack_changed.emit()
		
		if is_server:
			if item_stack:
				if not item_stack.quantity_changed.is_connected(_on_item_stack_quantity_changed):
					item_stack.quantity_changed.connect(_on_item_stack_quantity_changed)


@export var tags:Array[StringName]

@export_group("Custom", "custom_")
@export var custom_ui:PackedScene

#region SERVER
func _on_item_stack_quantity_changed() -> void:
	if !item_stack:
		return
	
	if item_stack.quantity < 1:
		item_stack = null

func is_free() -> bool:
	return item_stack == null

func can_stack_with(p_item_stack:ItemStack) -> bool:
	if item_stack.object != p_item_stack.object:
		return false
	
	return true

func _init(p_item_stack:ItemStack = null) -> void:
	SimusNetIdentity.register(self)
	
	SimusNetVars.register(
		self,
		["item_stack"],
		SimusNetVarConfig.new()
			.flag_mode_server_only()
			.flag_replication()
			.flag_serialization()
	)
	
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
