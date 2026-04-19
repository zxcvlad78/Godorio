@tool
extends EditorContextMenuPlugin

func _popup_menu(paths: PackedStringArray):
	for path in paths:
		if path.get_extension().to_lower() in ["fbx", "glb", "gltf"]:
			add_context_menu_item("Extract Mixamo Animation", _on_extract_pressed, preload("icon.svg"))
			break

func _on_extract_pressed(paths: PackedStringArray):
	for path in paths:
		var scene = load(path).instantiate()
		if not scene: continue
		
		var anim_player = _find_animation_player(scene)
		if anim_player:
			var library_names = anim_player.get_animation_library_list()
			for lib_name in library_names:
				var library = anim_player.get_animation_library(lib_name)
				for anim_name in library.get_animation_list():
					var anim = library.get_animation(anim_name)
					var new_anim = anim.duplicate()
					
					var save_path = path.get_base_dir() + "/" + anim.resource_path.get_file().get_basename() + ".anim"
					ResourceSaver.save(new_anim, save_path)
		
		scene.free()
	
	EditorInterface.get_resource_filesystem().scan()

func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer: return node
	for child in node.get_children():
		var found = _find_animation_player(child)
		if found: return found
	return null
