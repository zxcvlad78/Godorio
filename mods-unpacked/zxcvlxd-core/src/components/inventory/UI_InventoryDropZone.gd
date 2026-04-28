@tool
class_name UI_InventoryDropZone extends Control


var _color_rect:ColorRect = null
var _label:Label = null

var drag_and_drop:SD_UIDragAndDrop = null

func _ready() -> void:
	drag_and_drop = SD_UIDragAndDrop.new()
	drag_and_drop.drop_node = self
	add_child(drag_and_drop)
	
	if Engine.is_editor_hint():
		renamed.connect(_on_renamed)
		
		_color_rect = ColorRect.new()
		add_child(_color_rect)
		_color_rect.set_anchors_preset(PRESET_FULL_RECT)
		_color_rect.color = Color(0.0, 1.0, 1.0, 0.031)
		
		_label = Label.new()
		_label.self_modulate = Color(1.0, 1.0, 1.0, 0.157)
		_label.text = name
		_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		
		var label_settings = LabelSettings.new()
		label_settings.font = load("res://fonts/LCD40x2Display-Regular.otf")
		_label.label_settings = label_settings
		
		add_child(_label)
		_label.set_anchors_preset(PRESET_FULL_RECT)

func _on_renamed() -> void:
	if is_instance_valid(_label):
		_label.text = name
