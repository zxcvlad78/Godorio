class_name W_WeaponFirearm extends W_Item

signal event_reload
signal event_fire
signal event_fire_empty

@export var muzzle_flash:GPUParticles3D

@export var shell_point:Node3D
@export var muzzle_point:Node3D


var exclude_rids:Array[RID]
var node_group:NodeGroup3D

static func find_above(node:Node) -> W_WeaponFirearm:
	return super(node) as W_WeaponFirearm


func _ready() -> void:
	super()
	randomize()
	
	node_group = NodeGroup3D.get_by_name("LocalObjects")
	
	var rpc_config = SimusNetRPCConfig.new()
	
	
	SimusNetRPC.register(
		[
			_fire_local,
		],
		SimusNetRPCConfig.new().flag_set_channel("item").flag_serialization().flag_mode_server_only()
	)
	
	if entity:
		exclude_rids = entity.find_collisions_rids_above()
	
	_get_or_create_sound("reload").max_distance = 15

	

func _state_machine_transitioned(from: String, to: String) -> void:
	match to:
		"reload":
			#_get_or_create_sound("reload").stream = firearm_object.reload_sound
			_get_or_create_sound("reload").play()
			event_reload.emit()


func _local_input(event: InputEvent) -> void:
	super(event)
	
	if Input.is_action_just_pressed("weapon.reload"):
		#request_reload()
		pass
	

func can_aim() -> bool:
	if movement:
		if movement.is_sprinting:
			return false
	return true


func request_press_alt() -> void:
	if not can_aim():
		return
	
	super()

func _pressed_alt_server() -> void:
	if not can_aim():
		return
	
	super()

func request_press() -> void:
	super()
	
	

func request_release() -> void:
	super()
	
	if state_machine.current_state.name == &"Using":
		state_machine.switch_by_name(&"Idle")


func _process(_delta: float) -> void:
	if !can_use():
		return
		
		if state_machine.current_state.name == &"Using":
			fire()

func fire() -> void:
	_fire_local()
	SimusNetRPC.invoke(_fire_local)


func _fire_local() -> void:
	cooldown_timer.start()
	if muzzle_flash:
		muzzle_flash.emitting = true
	
	_spawn_bullet()
	_spawn_fake_bullet()
	
	event_fire.emit()
	

func _spawn_bullet() -> void:
	var bullet:Node3D #= preload()
	
	if bullet is W_FirearmBullet:
		bullet.weapon = object 
		
		bullet.exclude_rids = exclude_rids
		
		node_group.add_child(bullet)
		
		var base_direction = -entity_head.global_transform.basis.z
		var dispersion_radians = deg_to_rad(object.base_dispersion)
	
		var spread_rotation = Basis().rotated(Vector3.UP, randf_range(-dispersion_radians, dispersion_radians))
		spread_rotation *= Basis().rotated(Vector3.RIGHT, randf_range(-dispersion_radians, dispersion_radians))
		
		var final_direction = (spread_rotation * base_direction).normalized()
	
		if muzzle_point:
			bullet.global_position = muzzle_point.global_position
		elif entity_head.camera:
			bullet.global_transform = entity_head.camera.global_transform
		
		if final_direction.length() > 0.001:
			bullet.look_at(bullet.global_position + final_direction)
		
		#bullet.setup_bullet(_get_stack().ammo)

func _spawn_fake_bullet() -> void:
	pass
