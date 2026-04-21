extends Button

@export var main_control:Control

@export_group("Settings")
@export var main_popup_name:StringName = &"Main"

func _pressed() -> void:
	if main_control.has_method("switch_popup_by_name"):
		main_control.call("switch_popup_by_name", main_popup_name)
