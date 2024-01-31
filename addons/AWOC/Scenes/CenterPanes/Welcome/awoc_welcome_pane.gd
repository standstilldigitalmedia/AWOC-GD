@tool
extends AwocCenterPaneBase

@export var new_awoc_dialog: FileDialog
@export var load_awoc_dialog: FileDialog

# <summary>
# In response to NewAWOCButton being pressed, the NewAWOCDialog is displayed.
# </summary>
# <param name="none">none</param>
# <returns>none</returns>
func _on_new_awoc_button_pressed():
	new_awoc_dialog.visible = true
	new_awoc_dialog.clear_filters()
	new_awoc_dialog.add_filter("*.res", "Resource")
	new_awoc_dialog.current_dir = "/"

# <summary>
# In response to LoadAWOCButton being pressed, the LoadAWOCDialog is displayed.
# </summary>
# <param name="none">none</param>
# <returns>void</returns>
func _on_load_awoc_button_pressed():
	load_awoc_dialog.visible = true

# <summary>
# In response to a file path being selected in NewAWOCDialog, a new AwocRes is created and its awoc_path is set
# to the path selected in the NewAWOCDialog. The new AWOC is saved to disk and then slots_pane is loaded.
# </summary>
# <param name="path">The path selected in NewAWOCDialog</param>
# <returns>void</returns>
func _on_new_awoc_dialog_file_selected(path):
	awoc_res = AwocRes.new(AwocHelper.get_file_name_from_path(path), path)
	awoc_res.awoc_slots_res = AwocSlotsRes.new()
	awoc_res.awoc_slots_res.slots = {}
	awoc_res.save_awoc()
	awoc_editor.awoc_res = awoc_res
	awoc_editor.load_pane(awoc_editor.slots_pane)

# <summary>
# In response to a resource file being selected, the file is loaded and checked to make sure it is a AwocRes file
# If the file is a AwocRes file, awoc_path is set to the path of the loaded file in the loaded AWOC. awoc_res in 
# awoc_editor is set to the loaded AWOC. Finally, slots_pane is loaded.
# </summary>
# <param name="path">The path selected in LoadAWOCDialog</param>
# <returns>void</returns>
func _on_load_awoc_dialog_file_selected(path):
	var temp_awoc: Resource = load(path)
	if temp_awoc is AwocRes:
		temp_awoc.awoc_path = path
		awoc_editor.awoc_res = temp_awoc
		awoc_editor.load_pane(awoc_editor.slots_pane)
