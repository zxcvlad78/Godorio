@tool
class_name ViewModelRoot3D extends Node3D

enum ViewModelType {
	VIEW,
	ENTITY,
}


@export var type:ViewModelType = ViewModelType.VIEW :
	set(val):
		type = val
		if is_inside_tree(): _update()

@export var inventory:C_Inventory
@export var entity_head:EntityHead
var animated_model:BaseAnimatedModel

@export var object:R_WorldObject :
	set(val):
		object = val
		if is_inside_tree():
			_update()

var _ref:Node

func _get_property_list() -> Array:
	var properties = []
	
	if type == ViewModelType.ENTITY:
		properties.append({
			"name": "animated_model",
			"type": TYPE_OBJECT,
			"hint": PROPERTY_HINT_NODE_TYPE,
			"hint_string": "BaseAnimatedModel",
			"usage": PROPERTY_USAGE_DEFAULT
		})
		
	return properties

static func find_in(node: Node) -> ViewModelRoot3D:
	if node is ViewModelRoot3D:
		return node
	
	for child in node.get_children():
		var result = find_in(child)
		if result:
			return result
			
	return null

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	SimusNetRPC.register(
		[_send],
		SimusNetRPCConfig.new().flag_mode_any_peer()
	)
	SimusNetRPC.register(
		[_receive],
		SimusNetRPCConfig.new().flag_mode_server_only()
	)
	
	_update()
	
	inventory.slot_selected.connect(_on_inventory_slot_selected)
	
	if !multiplayer.is_server():
		_request_receive_data()

func _request_receive_data() -> void:
	SimusNetRPC.invoke_on_server(_send)

func _send() -> void:
	SimusNetRPC.invoke_on_sender(_receive, object)

func _receive(s_object:R_WorldObject) -> void:
	object = s_object

func _on_inventory_slot_selected(slot:InventorySlot) -> void:
	if !slot:
		return
	
	if !slot.item_stack:
		object = null
		return
	
	object = slot.item_stack.object

func _update() -> void:
	if Engine.is_editor_hint(): 
		return
	
	if _ref:
		remove_child(_ref)
		_ref.queue_free()
	
	if !object or !object.viewmodel:
		if animated_model:
			animated_model.local_stop_item_animation()
		return
	
	if type == ViewModelType.VIEW:
		_ref = object.viewmodel.instantiate_view()
	elif type == ViewModelType.ENTITY:
		_ref = object.viewmodel.instantiate_entity()
	
	if !_ref:
		return
		
	if animated_model:
		animated_model.local_play_item_animation(object.viewmodel.entity_animation)
	
	_ref.set_multiplayer_authority(get_multiplayer_authority())
	_ref.set("entity", entity_head.entity)
	_ref.set("entity_head", entity_head)
	object.set_in(_ref)
	add_child(_ref, true)
