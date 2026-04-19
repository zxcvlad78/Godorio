@tool
extends EditorPlugin

var extractor_context_menu_plugin: EditorContextMenuPlugin
var root_motion_edit_context_menu_plugin: EditorContextMenuPlugin

const EXTRACTOR_GDSCRIPT = "extractor.gd"
const ROOT_MOTION_EDIT_GDSCRIPT = "root_motion_edit.gd"

func _enter_tree() -> void:
	extractor_context_menu_plugin = _custom_add_context_menu_plugin(
		load(get_script_path(EXTRACTOR_GDSCRIPT)),
		EditorContextMenuPlugin.CONTEXT_SLOT_FILESYSTEM
		)

	extractor_context_menu_plugin = _custom_add_context_menu_plugin(
		load(get_script_path(ROOT_MOTION_EDIT_GDSCRIPT)),
		EditorContextMenuPlugin.CONTEXT_SLOT_FILESYSTEM
		)

func _custom_add_context_menu_plugin(script:Script, context_slot:EditorContextMenuPlugin.ContextMenuSlot) -> EditorContextMenuPlugin:
	if script:
		var inst = script.new()
		add_context_menu_plugin(context_slot, inst)
		return inst
	
	return null

func _exit_tree() -> void:
	remove_context_menu_plugin(extractor_context_menu_plugin)
	remove_context_menu_plugin(root_motion_edit_context_menu_plugin)

func get_dir() -> String:
	return (get_script() as Script).resource_path.get_base_dir()

func get_script_path(script_name:String) -> String:
	return get_dir().path_join(script_name)
