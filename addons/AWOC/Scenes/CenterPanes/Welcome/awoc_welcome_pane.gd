@tool
extends AWOCCenterPaneBase

@export var load_awoc_dialog: FileDialog

func _on_new_awoc_button_pressed():
	awoc_editor.load_pane(awoc_editor.new_awoc_pane)
	
func _on_load_awoc_button_pressed():
	load_awoc_dialog.visible = true


func _on_load_awoc_dialog_file_selected(path):
	var temp_awoc: Resource = load(path)
	if temp_awoc is AWOCRes:
		awoc_editor.awoc_res = temp_awoc
		awoc_editor.load_pane(awoc_editor.slots_pane)
