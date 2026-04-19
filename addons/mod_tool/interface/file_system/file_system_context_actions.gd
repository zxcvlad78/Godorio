@tool
extends EditorPlugin

var retarget_menu_id = 10002
var popupFilesystem : PopupMenu
var current_dialog : EditorFileDialog

func _enter_tree():
	find_filesystem_popup()

func _exit_tree():
	if popupFilesystem:
		popupFilesystem.about_to_popup.disconnect(_on_about_to_popup)
		popupFilesystem.id_pressed.disconnect(_on_id_pressed)

func find_filesystem_popup():
	var fs_dock = get_editor_interface().get_file_system_dock()
	# Ищем контекстное меню среди детей FileSystemDock
	for child in fs_dock.get_children():
		if child is PopupMenu:
			popupFilesystem = child
			popupFilesystem.about_to_popup.connect(_on_about_to_popup)
			popupFilesystem.id_pressed.connect(_on_id_pressed)
			break

func _on_about_to_popup():
	popupFilesystem.add_separator("Mixamo Animation Retargeter")
	popupFilesystem.add_item("Retarget Mixamo Animation(s)", retarget_menu_id)

func _on_id_pressed(id: int):
	if id == retarget_menu_id:
		var fs_dock = get_editor_interface().get_file_system_dock()
		var selected_paths = fs_dock.get_selected_paths()
		
		var fbx_files = selected_paths.filter(func(path): return path.ends_with(".fbx"))
		
		if fbx_files.size() > 0:
			_show_save_dialog(fbx_files)
		else:
			print("Mixamo Retargeter: FBX файлы не выбраны.")

func _show_save_dialog(fbx_paths: Array) -> void:
	current_dialog = EditorFileDialog.new()
	current_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_DIR
	current_dialog.access = EditorFileDialog.ACCESS_RESOURCES
	current_dialog.title = "Выберите папку для сохранения анимаций"
	
	current_dialog.dir_selected.connect(_on_export_folder_selected.bind(fbx_paths))
	current_dialog.visibility_changed.connect(func(): if not current_dialog.visible: current_dialog.queue_free())
	
	get_editor_interface().get_base_control().add_child(current_dialog)
	current_dialog.popup_centered_ratio(0.5)

func _on_export_folder_selected(dir_path: String, fbx_paths: Array) -> void:
	for fbx_path in fbx_paths:
		_process_fbx_file(fbx_path, dir_path)

func _process_fbx_file(fbx_path: String, dir_path: String) -> void:
	var import_file_path = fbx_path + ".import"
	var config = ConfigFile.new()
	var err = config.load(import_file_path)
	
	if err != OK:
		print("Ошибка загрузки .import: ", fbx_path)
		return

	var subresources = config.get_value("params", "_subresources", {})
	
	# Настройка ретаргетинга скелета
	if not "nodes" in subresources: subresources["nodes"] = {}
	var skel_path = "PATH:Skeleton3D" 
	if not skel_path in subresources["nodes"]: subresources["nodes"][skel_path] = {}
	
	var bone_map_path = "res://addons/mixamo_animation_retargeter/mixamo_bone_map.tres"
	if not FileAccess.file_exists(bone_map_path):
		print("Критическая ошибка: Файл ", bone_map_path, " не найден!")
		return
		
	subresources["nodes"][skel_path]["retarget/bone_map"] = load(bone_map_path)
	subresources["nodes"][skel_path]["retarget/bone_renamer/unique_node/skeleton_name"] = "Skeleton"
	subresources["nodes"][skel_path]["retarget/remove_tracks/unmapped_bones"] = true
	
	# Настройка анимации
	if not "animations" in subresources: subresources["animations"] = {}
	if not "mixamo_com" in subresources["animations"]: subresources["animations"]["mixamo_com"] = {}
	
	var anim_name = fbx_path.get_file().get_basename().to_snake_case()
	var save_path = dir_path.path_join(anim_name + ".res")
	
	subresources["animations"]["mixamo_com"]["save_to_file/enabled"] = true
	subresources["animations"]["mixamo_com"]["save_to_file/path"] = save_path
	subresources["animations"]["mixamo_com"]["settings/loop_mode"] = 0
	
	config.set_value("params", "_subresources", subresources)
	config.save(import_file_path)
	
	# Переимпорт
	get_editor_interface().get_resource_filesystem().reimport_files([fbx_path])
	print("Файл обработан и отправлен на реимпорт: ", fbx_path)
