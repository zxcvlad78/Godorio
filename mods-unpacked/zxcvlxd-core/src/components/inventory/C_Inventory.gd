class_name C_Inventory extends Node

signal slot_selected(slot:InventorySlot)
signal slot_deselected(slot:InventorySlot)

signal slot_added(slot:InventorySlot)
signal slot_removed(slot:InventorySlot)

@export var root:Node3D
@export var private:bool = false

#region SLOTS
@export var slots:Array[InventorySlot]

func _append_slot(slot:InventorySlot) -> void:
	SimusNetRPC.invoke_all(_rpc_append_slot, slot)

func _rpc_append_slot(slot:InventorySlot) -> void:
	slots.append(slot)
	slot_added.emit(slot)

func _erase_slot(slot:InventorySlot) -> void:
	SimusNetRPC.invoke_all(_rpc_erase_slot, slot)

func _rpc_erase_slot(slot:InventorySlot) -> void:
	slots.erase(slot)
	slot_removed.emit(slot)

#endregion

var selected_slot:InventorySlot

var _drop_node:NodeGroup3D

func _ready() -> void:
	var auth:bool = is_multiplayer_authority()
	set_process_input(auth)
	set_process_unhandled_input(auth)
	
	_drop_node = NodeGroup3D.get_by_name("NetworkedObjects")
	
	SimusNetRPC.register(
		[
			_send,
			_requset_receive_data,
			_receive,
			local_select_slot,
		],
		SimusNetRPCConfig.new().flag_mode_any_peer()
	)
	SimusNetRPC.register(
		[
			_server_add_item,
			_server_remove_item,
			_server_add_slot,
			_server_remove_slot,
			_server_drop_item,
			_server_move_item,
			_server_split_item,
			_server_stack_item,
			_server_swap_item,
		],
		SimusNetRPCConfig.new().flag_mode_to_server()
	)
	
	if !multiplayer.is_server():
		_requset_receive_data()


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("hotbar_slot_0"): select_slot_by_idx(0, ["hotbar"])
	elif Input.is_action_just_pressed("hotbar_slot_1"): select_slot_by_idx(1, ["hotbar"])
	elif Input.is_action_just_pressed("hotbar_slot_2"): select_slot_by_idx(2, ["hotbar"])
	elif Input.is_action_just_pressed("hotbar_slot_3"): select_slot_by_idx(3, ["hotbar"])
	elif Input.is_action_just_pressed("hotbar_slot_4"): select_slot_by_idx(4, ["hotbar"])
	elif Input.is_action_just_pressed("hotbar_slot_5"): select_slot_by_idx(5, ["hotbar"])
	elif Input.is_action_just_pressed("hotbar_slot_6"): select_slot_by_idx(6, ["hotbar"])
	elif Input.is_action_just_pressed("hotbar_slot_7"): select_slot_by_idx(7, ["hotbar"])
	elif Input.is_action_just_pressed("hotbar_slot_8"): select_slot_by_idx(8, ["hotbar"])
	elif Input.is_action_just_pressed("hotbar_slot_9"): select_slot_by_idx(9, ["hotbar"])
	elif Input.is_action_just_pressed("hotbar_slot_10"): select_slot_by_idx(10, ["hotbar"])

#region SEND/RECEIVE
func _send() -> void: ##Server
	SimusNetRPC.invoke_on_sender(_receive, slots)

func _requset_receive_data() -> void: ##Client
	SimusNetRPC.invoke_on_server(_send)

func _receive(s_slots:Array[InventorySlot]) -> void: ##Client
	slots = s_slots
#endregion

func select_slot_by_idx(idx:int, tags:Array[StringName]) -> InventorySlot:
	var found_slots = get_slots_by_tags(tags)
	if found_slots.is_empty():
		return null
	
	if idx > found_slots.size() - 1:
		return null
	
	var slot = found_slots[idx]
	if slot:
		select_slot(slot)
	
	return slot

func select_slot(slot:InventorySlot) -> void:
	local_select_slot(slot)
	SimusNetRPC.invoke(local_select_slot, slot)

func local_select_slot(slot:InventorySlot) -> void:
	selected_slot = slot
	slot_selected.emit(slot)


#region ADD_SLOT
func add_slot(slot:InventorySlot) -> void:
	SimusNetRPC.invoke_on_server(_server_add_slot, slot)

func _server_add_slot(slot:InventorySlot) -> void:
	var new_slot = slot.duplicate(true) as InventorySlot
	
	if new_slot:
		_append_slot(new_slot)
#endregion

#region REMOVE_SLOT
func remove_slot(slot:InventorySlot) -> void:
	SimusNetRPC.invoke_on_server(_server_remove_slot, slot)

func _server_remove_slot(slot:InventorySlot) -> void:
	if !slot:
		return
	
	_erase_slot(slot)
#endregion

#region ADD_ITEM
func add_item(incoming:ItemStack) -> void:
	SimusNetRPC.invoke_on_server(_server_add_item, incoming)

func _server_add_item(incoming:ItemStack) -> void:
	for slot in slots:
		if !slot.is_free() and slot.item_stack.id == incoming.id:
			_server_stack_item(slot, incoming)
			if incoming.quantity <= 0: return

	var free_slot = get_free_slot()
	if free_slot:
		free_slot.item_stack = incoming
#endregion

#region REMOVE_ITEM
func remove_item(slot:InventorySlot) -> void:
	SimusNetRPC.invoke_on_server(_server_remove_item, slot)

func _server_remove_item(slot:InventorySlot) -> void:
	if !slot:
		return
	if !slot.item_stack:
		return
	
	slot.item_stack = null
#endregion

#region MOVE_ITEM
func move_item(from_slot:InventorySlot, to_slot:InventorySlot) -> void:
	SimusNetRPC.invoke_on_server(_server_move_item, from_slot, to_slot)

func _server_move_item(from_slot:InventorySlot, to_slot:InventorySlot) -> void:
	if !from_slot or !to_slot or from_slot == to_slot:
		return
	if from_slot.is_free():
		return

	if to_slot.is_free():
		to_slot.item_stack = from_slot.item_stack
		from_slot.item_stack = null
	elif to_slot.can_stack_with(to_slot.item_stack):
		_server_stack_item(to_slot, from_slot.item_stack)
	else:
		_server_swap_item(from_slot, to_slot)
#endregion

#region SPLIT_ITEM
func split_item(from_slot:InventorySlot, to_slot:InventorySlot) -> void:
	SimusNetRPC.invoke_on_server(_server_split_item, from_slot, to_slot)

func _server_split_item(from_slot:InventorySlot, to_slot:InventorySlot) -> void:
	if !from_slot or !to_slot or from_slot == to_slot: return
	if from_slot.is_free(): return
	
	if from_slot.item_stack.quantity <= 1:
		return 

	@warning_ignore("integer_division")
	var amount_to_split = from_slot.item_stack.quantity / 2

	if to_slot.is_free():
		var new_stack = from_slot.item_stack.duplicate()
		new_stack.quantity = amount_to_split
		
		from_slot.item_stack.quantity -= amount_to_split
		to_slot.item_stack = new_stack
		
	elif to_slot.item_stack.id == from_slot.item_stack.id:
		var space_left = to_slot.item_stack.max_stack_size - to_slot.item_stack.quantity
		var actual_transfer = min(amount_to_split, space_left)
		
		if actual_transfer > 0:
			from_slot.item_stack.quantity -= actual_transfer
			to_slot.item_stack.quantity += actual_transfer

#endregion

#region STACK_ITEM
func stack_item(slot:InventorySlot, item_stack:ItemStack) -> void:
	SimusNetRPC.invoke_on_server(_server_stack_item, slot, item_stack)

func _server_stack_item(slot:InventorySlot, incoming:ItemStack) -> void:
	if !slot or !incoming:
		return
	
	if slot.is_free():
		slot.item_stack = incoming
		return

	if slot.can_stack_with(incoming):
		var max_amount = slot.item_stack.stack_size
		var current_amount = slot.item_stack.quantity
		var space_left = max_amount - current_amount
		
		if space_left > 0:
			var transfer_amount = min(space_left, incoming.quantity)
			
			slot.item_stack.quantity += transfer_amount
			incoming.quantity -= transfer_amount
#endregion

#region SWAP_ITEM
func swap_item(slot_a:InventorySlot, slot_b:InventorySlot) -> void:
	SimusNetRPC.invoke_on_server(_server_swap_item, slot_a, slot_b)

func _server_swap_item(slot_a:InventorySlot, slot_b:InventorySlot) -> void:
	if !slot_a or !slot_b or slot_a == slot_b:
		return
	
	var temp_stack = slot_a.item_stack
	slot_a.item_stack = slot_b.item_stack
	slot_b.item_stack = temp_stack
#endregion

#region DROP_ITEM
func drop_item(slot:InventorySlot) -> void:
	SimusNetRPC.invoke_on_server(_server_drop_item, slot)

func _server_drop_item(slot:InventorySlot) -> void:
	if !slot:
		return
	
	if !_drop_node:
		return
	
	
	var _world_ref:Node = WorldObjectReference.spawn_reference(
		_drop_node,
		slot.item_stack.object,
		{"look_range": 1.5}
	)
	_world_ref.set("item_stack", slot.item_stack)
	slot.item_stack.quantity -= 1
#endregion

func get_free_slot() -> InventorySlot:
	for slot in slots:
		if slot.is_free():
			return slot
	
	return null

func get_slot_by_tags(tags: Array[StringName]) -> InventorySlot:
	for slot in slots:
		for tag in tags:
			if slot.tags.has(tag):
				return slot
	return null

func get_free_slots() -> Array[InventorySlot]:
	return slots.filter(
		func(slot): return slot.is_free()
		)

func get_slots_by_tags(tags: Array[StringName]) -> Array[InventorySlot]:
	return slots.filter(
		func(slot): return tags.any(func(tag): return slot.tags.has(tag))
	)
