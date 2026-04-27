class_name ItemStack extends Resource

@export var object:R_WorldObject
@export var quantity:int = 1
@export var stack_size:int = 1

func _init(p_object:R_WorldObject = null) -> void:
	object = p_object

func simusnet_serialize(serialization:SimusNetCustomSerialization) -> void:
	var is_copy:bool = resource_path.is_empty()
	serialization.pack(is_copy)
	if !is_copy:
		serialization.pack(resource_path)
		return
	
	serialization.pack(object)
	serialization.pack(quantity)
	serialization.pack(stack_size)

static func simusnet_deserialize(serialization:SimusNetCustomSerialization) -> void:
	var new_item_stack:ItemStack = ItemStack.new()
	var is_copy:bool = serialization.unpack()
	
	if !is_copy:
		var res_path = serialization.unpack()
		new_item_stack = load(res_path)
	else:
		new_item_stack.object = serialization.unpack()
		new_item_stack.quantity = serialization.unpack()
		new_item_stack.stack_size = serialization.unpack()
	
	serialization.set_result(new_item_stack)
