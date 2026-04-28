class_name C_UI_InventorySlotDrag extends Node

signal drag_started()
signal drag_finished()
signal dropped(draggable:Control, at:Control)

@export var slot:UI_InventorySlot


func _ready() -> void:
	if !slot:
		return
	
	slot.gui_input.connect(_on_gui_input)

func _on_gui_input(event:InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				start_drag()
			else:
				stop_drag()

func can_drop(drop_slot:InventorySlot) -> bool:
	return true

func start_drag() -> void:
	drag_started.emit()

func stop_drag() -> void:
	drag_finished.emit()
	dropped.emit()

func drop(draggable:Control, at:Control) -> void:
	
	dropped.emit(draggable, at)
