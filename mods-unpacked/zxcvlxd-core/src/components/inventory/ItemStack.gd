class_name ItemStack extends Resource

signal quantity_changed()

@export var object:R_WorldObject
@export var quantity:int = 1 :
	set(val):
		quantity = val
		quantity_changed.emit()

@export var stack_size:int = 1


func _init() -> void:
	if SimusNetConnection.is_server():
		_network_ready()

func _network_ready() -> void:
	SimusNetIdentity.register(self)
	
	SimusNetVars.register(
		self,
		[
			"object",
			"quantity",
			"stack_size",
		],
		SimusNetVarConfig.new()
			.flag_mode_server_only()
			.flag_replication()
	)


static func create_from(input:Object) -> ItemStack:
	var item_stack:ItemStack = ItemStack.new()
	var world_object:R_WorldObject
	
	if input is R_WorldObject:
		world_object = input
	elif input is Node:
		world_object = R_WorldObject.find_in(input)
	
	if !world_object:
		return null
	
	item_stack.object = world_object
	item_stack.stack_size = world_object.item_stack_config.stack_size
	return item_stack


func simusnet_serialize(serialization:SimusNetCustomSerialization) -> void:
	serialization.pack(object)
	serialization.pack(quantity)
	serialization.pack(stack_size)
	serialization.pack(SimusNetIdentity.register(self).get_unique_id())

static func simusnet_deserialize(serialization:SimusNetCustomSerialization) -> void:
	var new_item_stack:ItemStack = ItemStack.new()
	
	new_item_stack.object = serialization.unpack()
	new_item_stack.quantity = serialization.unpack()
	new_item_stack.stack_size = serialization.unpack()
	
	SimusNetIdentity.register(new_item_stack, serialization.unpack())
	new_item_stack._network_ready()
	serialization.set_result(new_item_stack)
