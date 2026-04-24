class_name SD_MetadataButtonInspectorPlugin extends EditorInspectorPlugin

func _can_handle(object):
	return object is Node

func _parse_end(object: Object) -> void:
	add_custom_control(SD_MetadataButton.new())
