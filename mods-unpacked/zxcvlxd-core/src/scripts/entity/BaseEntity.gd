class_name BaseEntity extends CharacterBody3D

func _ready() -> void:
	
	SimusNetVars.register(
		self,
		["velocity"],
		SimusNetVarConfig.new().flag_mode_authority().flag_replication().flag_tickrate(32.0)
	)
