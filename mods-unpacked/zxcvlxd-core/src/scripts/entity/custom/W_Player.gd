class_name W_Player extends W_LivingEntity

static var instance:W_Player

func _ready() -> void:
	if is_multiplayer_authority():
		instance = self
