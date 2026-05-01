class_name ItemStack extends Resource

signal quantity_changed()

@export var object:R_WorldObject
@export var quantity:int = 1 :
	set(val):
		quantity = val
		quantity_changed.emit()


func _init() -> void:
	if SimusNetConnection.is_server():
		_network_ready()


func _network_ready() -> void:
	var id = SimusNetIdentity.register(self)
	
	SimusNetVars.register(
		self,
		[
			"object",
			"quantity",
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
	return item_stack


func simusnet_serialize(serialization:SimusNetCustomSerialization) -> void:
	serialization.pack(object)
	serialization.pack(quantity)
	serialization.pack(SimusNetIdentity.register(self).get_unique_id())

static func simusnet_deserialize(serialization:SimusNetCustomSerialization) -> void:
	var incoming_object = serialization.unpack()
	var incoming_quantity = serialization.unpack()
	var network_id = serialization.unpack()
	
	var identity:SimusNetIdentity = SimusNetIdentity.get_dictionary_by_unique_id().get(network_id)
	var item_stack:ItemStack
	
	if identity and is_instance_valid(identity.owner):
		item_stack = identity.owner
		item_stack.object = incoming_object
		item_stack.quantity = incoming_quantity
	else:
		item_stack = ItemStack.new()
		item_stack.object = incoming_object
		item_stack.quantity = incoming_quantity
		SimusNetIdentity.register(item_stack, network_id)
		item_stack._network_ready()
	
	
	serialization.set_result(item_stack)
