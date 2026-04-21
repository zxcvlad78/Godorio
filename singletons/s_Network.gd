extends Node

signal on_connected

enum CHANNELS
{
	ENTITY_ATTRIBUTES = 1,
	NODE_REPLICATION,
	USERS,
	USERS_UNRELIABLE,
	ITEM,
	SHOOTING,
	INVENTORY,
	
}

const DEFAULT_PORT: int = 8080

@onready var _logger: SD_Logger = SD_Logger.new(self)

func _ready() -> void:
	#region Console Commands
	var commands_exec: Array[SD_ConsoleCommand] = [
		SD_ConsoleCommand.get_or_create("connect", "localhost:8080"),
		SD_ConsoleCommand.get_or_create("disconnect"),
		SD_ConsoleCommand.get_or_create("start.server"),
		SD_ConsoleCommand.get_or_create("start.dedicated")
	]
	
	for i in commands_exec:
		i.executed.connect(_on_cmd_executed.bind(i))
	#endregion

	SimusNetEvents.event_connected.listen(_on_network_connected)
	SimusNetEvents.event_disconnected.listen(_on_network_disconnected)
	SimusNetEvents.event_peer_disconnected.listen(_on_peer_disconnected, true)

func _on_peer_disconnected(_e: SimusNetEvent) -> void:
	pass

func _on_network_connected() -> void:
	pass

func _on_network_disconnected() -> void:
	pass

func _on_cmd_executed(cmd: SD_ConsoleCommand) -> void:
	var code = cmd.get_code()
	var args_size:int = cmd.get_arguments().size()
	
	match code:
		"connect":
			var parsed = cmd.get_value_as_string().split(":")
			var ip:String = parsed[0]
			var port:int = int(parsed[1])
			
			SimusNetConnectionENet.create_client(ip, port)
		"disconnect":
			SimusNetConnection.try_close_peer()
		"start.server":
			if args_size == 0:
				SimusNetConnectionENet.create_server(
					SimusNetSingleton.get_instance().settings.server_info.port
					)
			elif args_size == 1:
				SimusNetConnectionENet.create_server(cmd.get_value_as_int())
