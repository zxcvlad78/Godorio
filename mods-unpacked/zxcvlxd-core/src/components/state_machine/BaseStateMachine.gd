class_name BaseStateMachine extends Node

signal state_enter(state_name:String)
signal state_exit(state_name:String)

@export var networked:bool = true 

var current_state:BaseState

func _init() -> void:
	SimusNetRPC.register(
		[
			local_switch,
			local_switch_by_name,
		],
		SimusNetRPCConfig.new().flag_mode_any_peer()
	)

func _enter_tree() -> void:
	SD_ECS.append_to(get_parent(), self)

func local_switch_by_name(state_name:StringName) -> void:
	for state in get_children():
		if !state is BaseState:
			continue
		
		if state.name == state_name:
			local_switch(state)
			break

func local_switch(state:BaseState) -> void:
	if !state:
		return
	
	if current_state:
		current_state.on_exit()
		state_exit.emit(current_state.name)
	
	current_state = state
	current_state.on_enter()
	state_enter.emit(current_state.name)


func switch(state:BaseState) -> void:
	local_switch(state)
	
	if networked:
		SimusNetRPC.invoke(local_switch, state)

func switch_by_name(state_name:StringName) -> void:
	local_switch_by_name(state_name)
	
	if networked:
		SimusNetRPC.invoke(local_switch_by_name, state_name)
