@tool
extends EditorPlugin

var dock: Control

func _enter_tree():
	dock = preload("res://addons/AWOC/Scenes/AWOCEditor/Awoc_Editor.tscn").instantiate()
	dock.name = "AWOC"
	add_control_to_dock(DOCK_SLOT_LEFT_UR, dock)
	
func _exit_tree():
	remove_control_from_docks(dock)
	dock.free()
