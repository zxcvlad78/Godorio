@tool
extends EditorContextMenuPlugin

# Этот метод вызывается Godot, когда ты жмешь правой кнопкой в дереве
func _popup_menu(_paths: PackedStringArray) -> void:
	# Добавляем наш пункт. 
	# "Spawn World Object" - текст, "spawn_world_obj" - уникальный ID/название действия
	add_context_menu_item("Spawn World Object", _on_spawn_pressed)

func _on_spawn_pressed(sex) -> void:
	# Вызываем диалог выбора файла ресурса
	var dialog = EditorFileDialog.new()
	dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	dialog.add_filter("*.tres, *.res", "R_WorldObject")
	
	# Подключаем логику создания при выборе файла
	dialog.file_selected.connect(func(file):
		var res = load(file)
		if res is R_WorldObject:
			_create_instance(res)
		else:
			printerr("Selected resource is not a R_WorldObject!")
	)
	
	EditorInterface.get_base_control().add_child(dialog)
	dialog.popup_file_dialog()

func _create_instance(world_obj: R_WorldObject) -> void:
	if not world_obj.viewmodel:
		printerr("WorldObject has no viewmodel!")
		return
		
	var selected_nodes = EditorInterface.get_selection().get_selected_nodes()
	var parent = selected_nodes[0] if not selected_nodes.is_empty() else EditorInterface.get_edited_scene_root()
	
	if parent:
		var instance = WorldObjectReference.spawn_reference(parent, world_obj, {"global_position": Vector3(0.0, 0.0, 0.0)})
		if instance:
			instance.owner = EditorInterface.get_edited_scene_root()
