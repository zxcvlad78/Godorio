class_name C_InventoryUI extends Node

var _default_ui_prefab = load("res://mods-unpacked/zxcvlxd-core/src/components/inventory/default_ui/default_inventory_ui.tscn")
var _default_ui_slot_prefab = load("res://mods-unpacked/zxcvlxd-core/src/components/inventory/default_ui/default_ui_inventory_slot.tscn")

@export var ui_prefab:PackedScene = _default_ui_prefab :
	set(val):
		ui_prefab = val
		if not is_node_ready():
			await ready
		pass

@export var ui_slot_prefab:PackedScene = _default_ui_slot_prefab

@export_group("Custom", "custom_")
@export var custom_inventory:C_Inventory

var c_interactable:C_Interactable

var inventory:C_Inventory
var ui_inst:InventoryUI

func _ready() -> void:
	SD_ECS.append_to(inventory, self)
	
	SimusNetRPC.register(
		[
			_request_open_container,
		],
		SimusNetRPCConfig.new().flag_mode_any_peer()
	)
	
	SimusNetRPC.register(
		[
			_open_ui_client,
		],
		SimusNetRPCConfig.new().flag_mode_server_only()
	)
	
	var auth:bool = is_multiplayer_authority()
	set_process(auth)
	set_physics_process(auth)
	set_process_input(auth)
	set_process_unhandled_input(auth)
	set_process_unhandled_key_input(auth)
	
	_auto_bind_inventory()
	
	c_interactable = C_Interactable.get_or_create_in(inventory.root)
	c_interactable.add_action(load("uid://ceub68nm5e7jw"),  0)
	print("Inv intct: %s" % c_interactable)
	
	if !inventory.is_syncronized:
		inventory.syncronized.connect(_on_inventory_syncronized)
	else:
		_on_inventory_syncronized()
	
	if !auth:
		return
	

static func find_in(node:Node) -> C_InventoryUI:
	return SD_ECS.find_first_component_by_script(node, [C_InventoryUI])

func _on_inventory_syncronized() -> void:
	_setup_instance()

func _setup_instance() -> void:
	if is_instance_valid(ui_inst):
		ui_inst.queue_free()
	
	ui_inst = ui_prefab.instantiate()
	if !ui_inst:
		return
	
	ui_inst.set("c_inventory_ui", self)


func request_open_container() -> void:
	SimusNetRPC.invoke_on_server(_request_open_container)

func _request_open_container() -> void:
	if inventory.private and inventory.get_multiplayer_authority() != SimusNetRemote.sender_id:
		print("err")
		return
	
	SimusNetRPC.invoke_on_sender(_open_ui_client)


func _open_ui_client() -> void:
	var player_ui = PlayerUI.i()
	if !player_ui:
		return
	
	player_ui.other_inventory = ui_inst
	if !player_ui.other_inventory:
		return
	
	if not player_ui.other_inventory.is_inside_tree():
		player_ui.inventory_container.add_child(player_ui.other_inventory)
	
	player_ui.other_inventory.show()
	player_ui.inventory_interface_menu.open()

func _notification(what: int) -> void:
	if what == NOTIFICATION_PARENTED:
		_auto_bind_inventory()

func _auto_bind_inventory() -> void:
	if custom_inventory:
		inventory = custom_inventory
		return
	
	inventory = get_parent() as C_Inventory
