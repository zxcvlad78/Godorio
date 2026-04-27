class_name C_PlayerInventoryUI extends C_InventoryUI

#var initialized:bool = false

func _ready() -> void:
	super()
	
	if is_multiplayer_authority():
		await get_tree().process_frame
		var player_ui:PlayerUI = PlayerUI.i()
		if !player_ui:
			return
		
		if player_ui.player_inventory:
			player_ui.player_inventory.queue_free()
		
		player_ui.player_inventory = ui_inst
		player_ui.inventory_container.add_child(player_ui.player_inventory)
		player_ui.inventory_container.move_child(player_ui.player_inventory, 0)
