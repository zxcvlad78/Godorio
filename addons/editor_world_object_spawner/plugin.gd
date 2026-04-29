@tool
extends EditorPlugin

var menu_extension: EditorContextMenuPlugin

func _enter_tree() -> void:
	menu_extension = preload("menu_extension.gd").new()
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_SCENE_TREE, menu_extension)

func _exit_tree() -> void:
	remove_context_menu_plugin(menu_extension)
