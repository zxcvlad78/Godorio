class_name W_Player extends W_LivingEntity

static var _instance:W_Player
static func i() -> W_Player:
	return _instance

func _ready() -> void:
	super()
	
	if is_multiplayer_authority():
		_instance = self
		var player_ui = load("res://mods-unpacked/zxcvlxd-core/src/prefabs/player_ui.tscn").instantiate()
		add_child(player_ui)
