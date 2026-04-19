@tool
extends EditorContextMenuPlugin

var _current_paths: PackedStringArray
var _input_dialog: ConfirmationDialog
var _line_edit: LineEdit

func _popup_menu(paths: PackedStringArray):
	for path in paths:
		if path.get_extension().to_lower() in ["res", "anim", "tres"]:
			_current_paths = paths
			add_context_menu_item("Remove Root Motion", _show_input_dialog)
			break

func _show_input_dialog(paths: PackedStringArray) -> void:
	if not _input_dialog:
		_create_dialog()
	
	_line_edit.text = "Hips:position"
	_input_dialog.popup_centered(Vector2i(300, 100))
	_line_edit.grab_focus()

func _create_dialog():
	_input_dialog = ConfirmationDialog.new()
	_input_dialog.title = "Target Track Path"
	
	var vb = VBoxContainer.new()
	var label = Label.new()
	label.text = "Enter track path"
	
	_line_edit = LineEdit.new()
	_line_edit.placeholder_text = "e.g. Hips:position"
	
	vb.add_child(label)
	vb.add_child(_line_edit)
	_input_dialog.add_child(vb)
	
	EditorInterface.get_base_control().add_child(_input_dialog)
	_input_dialog.confirmed.connect(_on_dialog_confirmed)

func _on_dialog_confirmed():
	var target = _line_edit.text.strip_edges().to_lower()
	if target.is_empty():
		return
		
	for path in _current_paths:
		var res = load(path)
		var changed = false
		
		if res is Animation:
			changed = _strip_root_motion(res, target)
		elif res is AnimationLibrary:
			for anim_name in res.get_animation_list():
				if _strip_root_motion(res.get_animation(anim_name), target):
					changed = true
		
		if changed:
			ResourceSaver.save(res, path)

func _strip_root_motion(anim: Animation, target_path: String) -> bool:
	var modified = false
	for i in anim.get_track_count():
		var track_path = str(anim.track_get_path(i)).to_lower()
		
		if track_path.ends_with(target_path):
			for key_idx in anim.track_get_key_count(i):
				var pos = anim.track_get_key_value(i, key_idx)
				if pos is Vector3:
					var new_pos = Vector3(0, pos.y, 0)
					anim.track_set_key_value(i, key_idx, new_pos)
					modified = true
	return modified
