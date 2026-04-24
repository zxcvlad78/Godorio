class_name SD_Metadata extends Resource

static func find_in(node:Node, find_in_parents:bool = true) -> SD_Metadata:
	if node.has_meta("SD_Metadata"):
		return node.get_meta("SD_Metadata")
	elif find_in_parents:
		var found:SD_Metadata = null
		var parents:Array[Node] = []
		var current_parent = node.get_parent()
		
		while current_parent != null:
			if current_parent.has_meta("SD_Metadata"):
				var meta = current_parent.get_meta("SD_Metadata")
				if meta is SD_Metadata:
					found = meta
			parents.append(current_parent)
			current_parent = current_parent.get_parent()
		return found
	return null

static func safe_find_in(node:Node, find_in_parents:bool = true) -> SD_Metadata:
	var found:SD_Metadata = find_in(node, find_in_parents)
	if not found:
		return SD_Metadata.new()
	return found


static func find_of_type(node: Node, type: GDScript, find_in_parents: bool = true) -> SD_Metadata:
	if not is_instance_valid(node):
		return null
	
	var list = _get_meta_list(node)
	for meta in list:
		if is_instance_of(meta, type):
			return meta
			
	if find_in_parents and node.get_parent():
		return find_of_type(node.get_parent(), type, true)
	return null

static func _get_meta_list(node: Node) -> Array:
	if not is_instance_valid(node):
		return []
	if node.has_meta("SD_Metadata_List"):
		return node.get_meta("SD_Metadata_List")
	return []
