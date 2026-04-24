class_name C_InventoryUI extends Node

#const DEFAULT_UI_PREFAB = preload()

@export var ui_prefab:PackedScene :
	set(val):
		ui_prefab = val
		if not is_node_ready():
			await ready
		_update_ui_instance()
@export var ui_slot_prefab:PackedScene

@export_group("Custom", "custom_")
@export var custom_inventory:C_Inventory

var inventory:C_Inventory

var canvas_layer:CanvasLayer
var ui_inst:Control

func _ready() -> void:
	var auth:bool = is_multiplayer_authority()
	set_process(auth)
	set_physics_process(auth)
	set_process_input(auth)
	set_process_unhandled_input(auth)
	set_process_unhandled_key_input(auth)
	
	_auto_bind_inventory()
	
	if !is_multiplayer_authority():
		return
	
	canvas_layer = CanvasLayer.new()
	#canvas_layer.input
	add_child(canvas_layer)
	
	_update_ui_instance()


func _update_ui_instance() -> void:
	if !canvas_layer:
		return
	if !ui_prefab:
		return
	
	if is_instance_valid(ui_inst):
		ui_inst.queue_free()
	
	ui_inst = ui_prefab.instantiate() as Control
	if !ui_inst:
		return
	
	ui_inst.set("c_inventory_ui", self)
	canvas_layer.add_child(ui_inst)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PARENTED:
		_auto_bind_inventory()

func _auto_bind_inventory() -> void:
	if custom_inventory:
		inventory = custom_inventory
	
	inventory = get_parent() as C_Inventory
