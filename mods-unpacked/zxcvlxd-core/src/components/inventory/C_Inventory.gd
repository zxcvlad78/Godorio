class_name C_Inventory extends Node

signal slot_added(slot:InventorySlot)
signal slot_removed(slot:InventorySlot)

@export var entity:BaseEntity
@export var slots:Array[InventorySlot]

func _ready() -> void:
	SimusNetRPC.register(
		[
			_receive,
			local_add_slot,
			local_remove_slot,
		],
		#SimusNetRPCConfig.new()
	)
	
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(_on_peer_connected)

func _on_peer_connected(id:int) -> void:
	_send(id)

#region test
func _input(_event: InputEvent) -> void:
	if !is_multiplayer_authority():
		return
	
	if Input.is_action_just_pressed("ui_accept"):
		var item_stack:ItemStack = ItemStack.new(WorldObjectReference.get_reference_by_id("basketball_hoop"))
		add_item(item_stack)
#endregion

func _send(peer_id:int = -1) -> void:
	if peer_id == -1:
		SimusNetRPC.invoke(_receive, slots)
		return
	print(peer_id)
	SimusNetRPC.invoke_on(peer_id, _receive, slots)

func _receive(s_slots:Array[InventorySlot]) -> void:
	slots = s_slots
	print("Received slots: %s" % s_slots)

func add_slot(slot:InventorySlot) -> InventorySlot:
	var new_slot:InventorySlot = local_add_slot(slot)
	SimusNetRPC.invoke(local_add_slot, slot)
	return new_slot

func local_add_slot(slot:InventorySlot) -> InventorySlot:
	var new_slot = slot.duplicate(true) as InventorySlot
	
	if new_slot:
		slots.append(new_slot)
		slot_added.emit(new_slot)
	
	return new_slot

func remove_slot(idx:int) -> InventorySlot:
	var removed_slot:InventorySlot = local_remove_slot(idx)
	SimusNetRPC.invoke(local_remove_slot, idx)
	return removed_slot

func local_remove_slot(idx:int) -> InventorySlot:
	if idx >= 0 and idx < slots.size():
		var slot = slots[idx]
		slots.remove_at(idx)
		slot_removed.emit(slot)
		return slot
	return null

func add_item(item_stack:ItemStack) -> ItemStack:
	var free_slot = get_free_slot()
	if !free_slot:
		return
	
	free_slot.item_stack = item_stack
	return item_stack

func remove_item(item_stack:ItemStack) -> ItemStack:
	var item_slot:InventorySlot = null
	for slot in slots:
		if slot.item_stack == item_stack:
			item_slot = slot
			break
	
	item_slot.item_stack = null
	return item_stack

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
