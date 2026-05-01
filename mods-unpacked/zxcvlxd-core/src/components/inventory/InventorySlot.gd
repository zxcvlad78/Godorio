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
		
		if is_server:
			if item_stack:
				if not item_stack.quantity_changed.is_connected(_on_item_stack_quantity_changed):
					item_stack.quantity_changed.connect(_on_item_stack_quantity_changed)
		item_stack_changed.emit()


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
	if item_stack.object == p_item_stack.object:
		return true
	
	return false

func _init() -> void:
	print("init", self)
	if SimusNetConnection.is_server():
		_network_ready()

func _network_ready() -> void:
	print("net_ready")
	SimusNetIdentity.register(self)
	
	SimusNetVars.register(
		self,
		["item_stack"],
		SimusNetVarConfig.new()
			.flag_mode_server_only()
			.flag_replication()
			.flag_serialization()
	)

func simusnet_serialize(serialization:SimusNetCustomSerialization) -> void:
	serialization.pack(item_stack)
	serialization.pack(tags)
	serialization.pack(SimusNetIdentity.register(self).get_unique_id())

static func simusnet_deserialize(serialization:SimusNetCustomSerialization) -> void:
	var incoming_item_stack = serialization.unpack()
	var incoming_tags = serialization.unpack()
	var network_id = serialization.unpack()
	
	var identity:SimusNetIdentity = SimusNetIdentity.get_dictionary_by_unique_id().get(network_id)
	var slot:InventorySlot
	
	if identity and is_instance_valid(identity.owner):
		slot = identity.owner
		slot.item_stack = incoming_item_stack
		slot.tags = incoming_tags
	else:
		slot = InventorySlot.new()
		slot.item_stack = incoming_item_stack
		slot.tags = incoming_tags
		SimusNetIdentity.register(slot, network_id)
		slot._network_ready()
	
	
	serialization.set_result(slot)
