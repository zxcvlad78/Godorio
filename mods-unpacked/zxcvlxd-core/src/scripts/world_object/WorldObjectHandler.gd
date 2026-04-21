class_name WorldObjectHandler extends RefCounted

var scan_dirs:PackedStringArray
var debug:bool = false

func _init(p_scan_dirs:PackedStringArray = PackedStringArray([]), p_debug = false) -> void:
	scan_dirs = p_scan_dirs
	debug = p_debug

func scan() -> void:
	for path in scan_dirs:
		_scan_recursive(path)

func _scan_recursive(path:String) -> void:
	var dir = DirAccess.open(path)
	if not dir:
		return
		
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name == "." or file_name == "..":
			file_name = dir.get_next()
			continue
			
		var full_path = path.path_join(file_name)
		
		if dir.current_is_dir():
			_scan_recursive(full_path)
		else:
			if full_path.ends_with(".tres") or full_path.ends_with(".res"):
				if ResourceLoader.exists(full_path):
					var res = load(full_path)
					if res is R_WorldObject:
						var err = WorldObjectReference.append_reference(res)
						if err == OK:
							if debug:
								print_rich("[color=white][WorldObjectHandler][/color][color=green]'%s' successfully added to the reference list[/color]" % res.id)
							
		file_name = dir.get_next()
