class_name W_Item extends Node3D

signal event_pick
signal event_inspect

signal on_local_use_pressed()
signal on_local_use_released()

signal on_local_use_alt_pressed()
signal on_local_use_alt_released()

signal on_server_use_pressed()
signal on_server_use_released()

signal on_server_use_alt_pressed()
signal on_server_use_alt_released()

@export var object:R_WorldObject
@export var state_machine:BaseStateMachine
@export var alt_state_machine:BaseStateMachine

var cooldown_timer:Timer 

var is_using:bool = false
var is_using_alt:bool = false

var net_config:SimusNetRPCConfig

var entity_head:EntityHead
var entity:BaseEntity = null

var _logger: SD_Logger = SD_Logger.new(self)

var inventory:C_Inventory
var movement:BaseCharacterMovement

var _sounds: Dictionary[String, AudioStreamPlayer3D]


func _ready() -> void:
	SimusNetIdentity.register(self)
	
	entity = entity_head.get_entity()
	
	net_config = (SimusNetRPCConfig.new()
		.flag_set_channel("item")
		.flag_mode_any_peer()
		)
	
	SimusNetRPC.register([
		_pressed_server,
		_released_server,
		_pressed_alt_server,
		_released_alt_server,
		
	], SimusNetRPCConfig.new().flag_mode_to_server().flag_set_channel("item"))
	
	SimusNetVars.register(self,
	[
		"is_using",
		"is_using_alt"
	
	], SimusNetVarConfig.new().flag_replication())
	
	
	if not object:
		object = R_WorldObject.find_in(self)
	
	if object is R_Item:
		cooldown_timer = Timer.new()
		cooldown_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
		add_child(cooldown_timer)
		cooldown_timer.wait_time = object.use_cooldown
		cooldown_timer.one_shot = true
	
	var auth:bool = is_multiplayer_authority()
	
	set_process_input(auth)
	set_process_unhandled_input(auth)
	set_process_shortcut_input(auth)
	set_process_unhandled_key_input(auth)
	
	if !state_machine:
		state_machine = BaseStateMachine.new(
			[
				BaseState.new(&"Idle"),
				BaseState.new(&"Using"),
				BaseState.new(&"Pressed"),
				BaseState.new(&"Inspecting"),
			]
		)
		add_child(state_machine, true)
	if !alt_state_machine:
		alt_state_machine = BaseStateMachine.new(
			[
				BaseState.new(&"Idle"),
				BaseState.new(&"Using"),
				BaseState.new(&"Pressed"),
				BaseState.new(&"Inspecting"),
			]
		)
		add_child(alt_state_machine, true)

func _get_or_create_sound(key: String) -> AudioStreamPlayer3D:
	if key in _sounds:
		return _sounds[key]
	
	var new: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	_sounds[key] = new
	add_child(new)
	return new

static func find_above(node:Node) -> W_Item:
	if node is W_Item or node == null:
		return node
	return find_above(node.get_parent())

func _input(_event: InputEvent) -> void:
	_local_input_no_interface_check(_event)
	
	if SimusDev.ui.has_active_interface():
		is_using = false
		is_using_alt = false
		return
	
	if Input.is_action_just_pressed("item.use"):
		request_press()
	elif Input.is_action_just_released("item.use"):
		request_release()
	elif Input.is_action_just_pressed("item.alt_use"):
		request_press_alt()
	elif Input.is_action_just_released("item.alt_use"):
		request_release_alt()
	elif Input.is_action_just_released("item.inspect"):
		event_inspect.emit()
	
	_local_input(_event)

func _local_input(event: InputEvent) -> void:
	pass

func _local_input_no_interface_check(event: InputEvent) -> void:
	pass

func request_press() -> void:
	SimusNetRPC.invoke_on_server(_pressed_server)
	is_using = true
	on_local_use_pressed.emit()
	state_machine.switch_by_name(&"Pressed")
	state_machine.switch_by_name(&"Using")

func request_release() -> void:
	SimusNetRPC.invoke_on_server(_released_server)
	is_using = false
	on_local_use_released.emit()
	state_machine.switch_by_name(&"Idle")

func request_press_alt() -> void:
	SimusNetRPC.invoke_on_server(_pressed_alt_server)
	is_using_alt = true
	on_local_use_alt_pressed.emit()
	alt_state_machine.switch_by_name(&"Pressed")
	alt_state_machine.switch_by_name(&"Using")

func request_release_alt() -> void:
	SimusNetRPC.invoke_on_server(_released_alt_server)
	is_using_alt = false
	on_local_use_alt_released.emit()
	alt_state_machine.switch_by_name(&"Idle")

func _pressed_server() -> void:
	is_using = true
	on_server_use_pressed.emit()

func _released_server() -> void:
	is_using = false
	on_server_use_released.emit()

func _pressed_alt_server() -> void:
	is_using_alt = true
	on_server_use_alt_pressed.emit()

func _released_alt_server() -> void:
	is_using_alt = false
	on_server_use_alt_released.emit()

func _local_client_ready() -> void:
	pass

func can_use() -> bool:
	if !is_multiplayer_authority():
		return !in_cooldown()
	
	return (not in_cooldown()) and (SimusDev.ui.get_active_interfaces().is_empty())

func in_cooldown() -> bool:
	if not is_instance_valid(cooldown_timer):
		return true
	cooldown_timer.wait_time = (object as R_Item).use_cooldown
	return cooldown_timer.time_left > 0
