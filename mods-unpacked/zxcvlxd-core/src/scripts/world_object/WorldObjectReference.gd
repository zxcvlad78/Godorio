class_name WorldObjectReference extends RefCounted

static var _ref_list:Array[R_WorldObject]
static func get_references() -> Array[R_WorldObject]:
	return _ref_list

static func append_reference(resource:R_WorldObject) -> Error:
	if !resource:
		return FAILED
	
	if _ref_list.has(resource):
		return FAILED
	
	_ref_list.append(resource)
	return OK

static func delete_reference(resource:R_WorldObject) -> Error:
	if !resource:
		return FAILED
	
	if not _ref_list.has(resource):
		return FAILED
	
	_ref_list.erase(resource)
	return OK

static func get_reference_by_id(ref_id:String) -> R_WorldObject:
	for ref in get_references():
		if ref.id == ref_id:
			return ref
	
	return null 
